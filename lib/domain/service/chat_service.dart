import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/utils/result.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/data/enum/message_sender.dart';
import 'package:stack_money/data/helper/firebase_key.dart';
import 'package:stack_money/data/models/chat_message_model.dart';
import 'package:stack_money/data/models/chat_thread_model.dart';
import 'package:stack_money/data/repository/firebase_cfo_chat_repository.dart';

class ChatManagementService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  final FirebaseCfoChatRepository _repository = FirebaseCfoChatRepository();

  Future<Result<List<ChatThreadModel>>> fetchChats() async {
    try {
      final threadList = await _repository.fetch();
      return Success(threadList);
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

  /// Inicializa e sincroniza as configurações do Remote Config
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

  /// Dispara a pergunta com streaming continuo de resposta e contexto vivo
  Stream<String> generateCfoResponseStream({required String userPrompt, required String liveContextJson, List<ChatMessageModel> history = const [],}) async* {
    /// System Prompt
    final baseSystemPrompt = _remoteConfig.getString(
      FirebaseKey.cfoSystemPrompt,
    );

    /// Instruction
    final fullSystemInstruction = '$baseSystemPrompt $liveContextJson';

    /// Init model
    final model = FirebaseVertexAI.instance.generativeModel(
      model: _remoteConfig.getString(FirebaseKey.cfoModelName),
      systemInstruction: Content.system(fullSystemInstruction),
    );

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

    /// Logger
    SmLogger.debug(
      'AI data',
      payload: {
        'model': _remoteConfig.getString(FirebaseKey.cfoModelName),
        'userPrompt': userPrompt,
        'systemInstruction': fullSystemInstruction,
        'history': historyContents.map((c) => c.toJson()),
      },
    );

    /// Session and stream
    final chat = model.startChat(history: historyContents);
    final responseStream = chat.sendMessageStream(Content.text(userPrompt));

    await for (final chunk in responseStream) {
      if (chunk.text != null && chunk.text!.isNotEmpty) {
        yield chunk.text!;
      }
    }
  }

  Future<Result<String>> generateTitle(AppLocalizations l10n, {required String userPrompt, required String aiResponse,}) async {
    try {
      final systemPrompt = _remoteConfig.getString(
        FirebaseKey.cfoTitleGenerator,
      );

      final model = FirebaseVertexAI.instance.generativeModel(
        model: _remoteConfig.getString(FirebaseKey.cfoModelName),
        systemInstruction: Content.system(systemPrompt),
      );

      final response = await model.generateContent([
        Content.text('User: $userPrompt\nAI: $aiResponse'),
      ]);

      final title = response.text?.trim() ?? '';
      return Success(title.isNotEmpty ? title : 'l10n.newChat');
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error executing generating title',
          scope: ExceptionScope.service,
          exception: e as Exception,
          payload: {'userPrompt': userPrompt, 'aiResponse': aiResponse},
          stackTrace: stack,
        ),
      );
    }
  }

  /// Salva ou atualiza a thread principal no Firestore
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

  /// Atualiza apenas o título da thread
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

  /// Salva uma nova mensagem dentro da subcoleção de mensagens da thread
  Future<Result<void>> saveMessage(String threadId, ChatMessageModel message,) async {
    try {
      await _repository.saveMessage(threadId, message);
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

  /// Ouve em tempo real todas as conversas não arquivadas do usuário
  Stream<List<ChatThreadModel>> watchThreads() {
    return _repository.watchThreads();
  }

  /// Ouve as mensagens de uma thread específica em ordem cronológica
  Stream<List<ChatMessageModel>> getMessagesStream(String threadId) {
    return _repository.watchMessages(threadId);
  }
}
