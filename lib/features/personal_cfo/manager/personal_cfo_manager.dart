import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/core/widgets/sm_snack_bar.dart';
import 'package:stack_money/data/enum/message_sender.dart';
import 'package:stack_money/data/enum/snack_bar_type.dart';
import 'package:stack_money/data/models/chat_message_model.dart';
import 'package:stack_money/data/models/chat_thread_model.dart';
import 'package:stack_money/domain/service/chat_service.dart';
import 'package:stack_money/domain/service/export_service.dart';
import 'package:stack_money/features/error/error_screen.dart';

class PersonalCfoManager {
  final ChatManagementService _cfoService = ChatManagementService();

  late ChatThreadModel _thread;
  late final BuildContext _context;

  ChatThreadModel get thread => _thread;

  final ScrollController scrollController = ScrollController();
  final messagesNotifier = ValueNotifier<List<ChatMessageModel>>([]);
  final _isStreaming = ValueNotifier(false);

  List<ChatMessageModel> get messages => messagesNotifier.value;

  ValueListenable<bool> get isStreaming => _isStreaming;

  late final TextEditingController titleController;
  late final TextEditingController messageController;

  PersonalCfoManager(ChatThreadModel? initialThread, this._context) {
    _thread = initialThread ?? ChatThreadModel(title: '');

    titleController = TextEditingController(text: _thread.title);
    messageController = TextEditingController(text: '');

    _cfoService.initRemoteConfig();
    _getMessages(_thread.id);
    _listenToMessages(_thread.id);
  }

  void _getMessages(String threadId) async {
    try {
      final messagesResult = await _cfoService.fetchMessages(threadId);
      final messages = messagesResult.getOrThrow();
      messagesNotifier.value = messages;
      _scrollToBottom();
    } on StackMoneyException catch (e) {
      if (_context.mounted) {
        _context.go(ErrorScreen.route, extra: e);
      }
    } catch (e, stack) {
      if (_context.mounted) {
        _context.go(
          ErrorScreen.route,
          extra: StackMoneyException(
            message: 'Error fetching thread messages',
            scope: ExceptionScope.business,
            payload: {'threadId': threadId},
            exception: e as Exception,
            stackTrace: stack,
          ),
        );
      }
    }
  }

  void _listenToMessages(String threadId) {
    _cfoService.getMessagesStream(threadId).listen((remoteMessages) {
      if (!_isStreaming.value) {
        messagesNotifier.value = remoteMessages;
        _scrollToBottom();
      }
    });
  }

  Future<void> sendMessage() async {
    final l10n = AppLocalizations.of(_context)!;

    final cleanText = messageController.text.trim();
    if (cleanText.isEmpty || _isStreaming.value) return;
    _isStreaming.value = true;
    messageController.text = '';

    final bool isFirstMessage = _thread.lastMessage.isEmpty;

    if (isFirstMessage) {
      _thread = _thread.copyWith(lastMessage: cleanText);
      await _cfoService.saveThread(_thread);
      _listenToMessages(_thread.id);
    }

    // 2. Instancia e salva a mensagem do Usuário no Firestore
    final userMessage = ChatMessageModel(
      sender: MessageSender.user,
      text: cleanText,
    );

    messagesNotifier.value = [...messages, userMessage];
    await _cfoService.saveMessage(thread.id, userMessage);

    // 3. Prepara a mensagem "placeholder" local da IA
    final aiMessage = ChatMessageModel(sender: MessageSender.cfoAi, text: '');

    messagesNotifier.value = [...messagesNotifier.value, aiMessage];
    _scrollToBottom();
    _isStreaming.value = true;

    final StringBuffer accumulatedText = StringBuffer();

    try {
      final String liveContextJson = await ExportService().extractDataToAI();

      final responseStream = _cfoService.generateCfoResponseStream(
        userPrompt: cleanText,
        liveContextJson: liveContextJson,
        history: messages.sublist(0, messages.length - 2),
      );

      await for (final chunk in responseStream) {
        accumulatedText.write(chunk);

        final updatedList = List<ChatMessageModel>.from(messagesNotifier.value);
        final aiIndex = updatedList.indexWhere((m) => m.id == aiMessage.id);

        if (aiIndex != -1) {
          updatedList[aiIndex] = updatedList[aiIndex].copyWith(
            text: accumulatedText.toString(),
          );
          messagesNotifier.value = updatedList;
          _scrollToBottom();
        }
      }

      // 4. Salva a resposta da IA no Firestore APENAS quando o streaming terminar
      final finalAiMessage = aiMessage.copyWith(
        text: accumulatedText.toString(),
      );
      await _cfoService.saveMessage(thread.id, finalAiMessage);

      // 5. Se for a primeira troca de mensagens, gera o título de 2 palavras
      if (isFirstMessage) {
        final generatedTitleResult = await _cfoService.generateTitle(
          l10n,
          userPrompt: cleanText,
          aiResponse: accumulatedText.toString(),
        );

        final generatedTitle = generatedTitleResult.getOrThrow();

        changeTitle(generatedTitle);
        await _cfoService.updateThreadTitle(_thread.id, generatedTitle);
        _thread = _thread.copyWith(title: generatedTitle);
      }
    } catch (e) {
      final errorAiMessage = aiMessage.copyWith(text: l10n.chatConnectionError);
      messagesNotifier.value = [
        ...messagesNotifier.value..removeLast(),
        errorAiMessage,
      ];
    } finally {
      _isStreaming.value = false;
      _scrollToBottom();
    }
  }

  Future<bool> changeTitle(String title) async {
    SmLogger.debug('Change title', payload: {'title': title});

    final result = await _cfoService.updateThreadTitle(_thread.id, title);

    result.fold(
      onSuccess: (_) {
        _thread = _thread.copyWith(title: title);
      },
      onFailure: (_) {
        final l10n = AppLocalizations.of(_context)!;
        SmSnackBar(message: 'l10n.failUploadTitle', type: SnackBarType.error);
      },
    );

    return result.isSuccess;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void dispose() {
    messagesNotifier.dispose();
    _isStreaming.dispose();
    scrollController.dispose();
    titleController.dispose();
    messageController.dispose();
  }
}
