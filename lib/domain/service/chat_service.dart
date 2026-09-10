import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/app_coordinator.dart';
import 'package:stack_money/core/utils/result.dart';
import 'package:stack_money/data/enum/message_sender.dart';
import 'package:stack_money/data/helper/firebase_key.dart';
import 'package:stack_money/data/models/chat_message_model.dart';
import 'package:stack_money/data/models/chat_thread_model.dart';
import 'package:stack_money/data/repository/firebase_cfo_chat_repository.dart';
import 'package:stack_money/data/repository/shared_preferences_repository.dart';

class ChatManagementService {
  final _remoteConfig = FirebaseRemoteConfig.instance;
  final _repository = FirebaseCfoChatRepository();
  final _localRepo = SharedPreferencesRepository();

  /// Centralized instance of GenerativeModel
  GenerativeModel _getGenerativeModel(String systemInstruction) {
    final apiKey = _remoteConfig.getString(FirebaseKey.geminiApiKey);
    final modelName = _remoteConfig.getString(FirebaseKey.cfoModelName);

    return GenerativeModel(
      model: modelName.isNotEmpty ? modelName : 'gemini-3.6-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(systemInstruction),
    );
  }

  Future<Result<List<ChatThreadModel>>> fetchChats() async {
    try {
      final threadList = await _repository.fetch();
      return Success(linkDrafts(threadList));
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error fetching chat threads',
          scope: ExceptionScope.service,
          exception: e as Exception,
          stackTrace: stack,
        ),
      );
    }
  }

  Future<Result<List<ChatMessageModel>>> fetchMessages(String threadId) async {
    try {
      final messageList = await _repository.fetchMessages(threadId);
      return Success(messageList);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error fetching thread messages',
          scope: ExceptionScope.service,
          payload: {'threadId': threadId},
          exception: e as Exception,
          stackTrace: stack,
        ),
      );
    }
  }

  List<ChatThreadModel> linkDrafts(List<ChatThreadModel> chatList) {
    final chatListWithDraft = <ChatThreadModel>[];
    for (final c in chatList) {
      getDraft(c.id).then(
        (result) => result.fold(
          onSuccess: (draft) => chatListWithDraft.add(c.copyWith(draft: draft)),
          onFailure: (_) => chatListWithDraft.add(c.copyWith(draft: '')),
        ),
      );
    }
    return chatListWithDraft;
  }

  /// Init and Sync RemoteConfig
  Future<Result<void>> initRemoteConfig() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await _remoteConfig.fetchAndActivate();
      return Success(null);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error initializing remote config',
          scope: ExceptionScope.service,
          exception: e as Exception,
          stackTrace: stack,
        ),
      );
    }
  }

  /// Stream the AI response
  Stream<String> generateCfoResponseStream({
    required String userPrompt,
    required String liveContextJson,
    List<ChatMessageModel> history = const [],
  }) async* {
    /// System Prompt
    final baseSystemPrompt = _remoteConfig.getString(
      FirebaseKey.cfoSystemPrompt,
    );

    /// Instruction
    final fullSystemInstruction = '$baseSystemPrompt $liveContextJson';

    /// Init
    final model = _getGenerativeModel(fullSystemInstruction);

    /// Limit history
    final limitedHistory = history.length > 50
        ? history.sublist(history.length - 50)
        : history;

    /// Format history
    final historyContents = limitedHistory.map((msg) {
      if (msg.sender == MessageSender.user) {
        return Content.text(msg.text);
      } else {
        return Content.model([TextPart(msg.text)]);
      }
    }).toList();

    /// Session and stream
    try {
      final chat = model.startChat(history: historyContents);
      final responseStream = chat.sendMessageStream(Content.text(userPrompt));

      await for (final chunk in responseStream) {
        if (chunk.text != null && chunk.text!.isNotEmpty) {
          yield chunk.text!;
        }
      }
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Failed to initialize AI chat',
        scope: ExceptionScope.service,
        exception: e as Exception,
        stackTrace: stack,
      );
    }
  }

  /// Generate CFO chat title
  Future<Result<String>> generateTitle(
    AppLocalizations l10n, {
    required List<ChatMessageModel> messages,
  }) async {
    try {
      final systemPrompt = _remoteConfig.getString(
        FirebaseKey.cfoTitleGenerator,
      );

      final model = _getGenerativeModel(systemPrompt);

      final response = await model.generateContent([
        Content.text(
          '# Messages ${messages.map((m) => '\n- ${m.sender.name}: ${m.text}').toList()}',
        ),
      ]);

      final title = response.text?.trim() ?? '';
      return Success(title.isNotEmpty ? title : l10n.newChat);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error executing generating title',
          scope: ExceptionScope.service,
          exception: e as Exception,
          payload: {'Messages': messages},
          stackTrace: stack,
        ),
      );
    }
  }

  /// Save or Update main Tread
  Future<Result<void>> saveThread(ChatThreadModel thread) async {
    try {
      await _repository.saveThread(thread);
      return Success(null);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error saving thread',
          scope: ExceptionScope.service,
          exception: e as Exception,
          payload: thread.toJson(),
          stackTrace: stack,
        ),
      );
    }
  }

  /// Delete thread
  Future<Result<void>> deleteThread(String id) async {
    try {
      await _repository.deleteThread(id);
      return Success(null);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error deleting chat thread',
          scope: ExceptionScope.service,
          payload: {'id': id},
          exception: e as Exception,
          stackTrace: stack,
        ),
      );
    }
  }

  /// Update CFO Thread title
  Future<Result<void>> updateThreadTitle(String threadId, String title) async {
    try {
      await _repository.updateThreadTitle(threadId, title);
      return Success(null);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error saving thread',
          scope: ExceptionScope.service,
          exception: e as Exception,
          payload: {'threadId': threadId, 'title': title},
          stackTrace: stack,
        ),
      );
    }
  }

  /// Save a new message on thread
  Future<Result<void>> saveMessage(
    String threadId,
    ChatMessageModel message,
  ) async {
    try {
      await _repository.saveMessage(threadId, message);
      await _localRepo.deleteDraft(threadId);
      return Success(null);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error saving thread',
          scope: ExceptionScope.service,
          exception: e as Exception,
          payload: {'threadId': threadId, 'message': message.toJson()},
          stackTrace: stack,
        ),
      );
    }
  }

  /// Draft a message on local storage
  Future<Result<void>> draftMessage(String threadId, String text) async {
    try {
      _localRepo.saveDraft(threadId, text);
      AppCoordinator.instance.updateDrafts();
      return Success(null);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error drafting message',
          scope: ExceptionScope.service,
          exception: e as Exception,
          payload: {'threadId': threadId, 'text': text},
          stackTrace: stack,
        ),
      );
    }
  }

  /// Get draft message from local storage
  Future<Result<String?>> getDraft(String threadId) async {
    try {
      final result = await _localRepo.getDraft(threadId);
      return Success(result);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error drafting message',
          scope: ExceptionScope.service,
          exception: e as Exception,
          payload: {'threadId': threadId},
          stackTrace: stack,
        ),
      );
    }
  }

  /// Listen to all non-archived threads
  Stream<List<ChatThreadModel>> watchThreads() {
    return _repository.watchThreads();
  }

  /// Listen to a single thread chronologically
  Stream<List<ChatMessageModel>> getMessagesStream(String threadId) {
    return _repository.watchMessages(threadId);
  }
}
