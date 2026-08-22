import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/helpers/action_parser.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/core/widgets/sm_snack_bar.dart';
import 'package:stack_money/data/enum/action_status.dart';
import 'package:stack_money/data/enum/message_sender.dart';
import 'package:stack_money/data/enum/snack_bar_type.dart';
import 'package:stack_money/data/models/chat_message_model.dart';
import 'package:stack_money/data/models/chat_thread_model.dart';
import 'package:stack_money/domain/service/ai_action_service.dart';
import 'package:stack_money/domain/service/chat_service.dart';
import 'package:stack_money/domain/service/export_service.dart';
import 'package:stack_money/features/error/error_screen.dart';

class PersonalCfoManager {
  final _cfoService = ChatManagementService();
  final _aiActionService = AiActionService();

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

  Future<void> _getMessages(String threadId) async {
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

  /// Dispara o fluxo de envio de mensagem e processamento da resposta da IA
  Future<void> sendMessage() async {
    final cleanText = messageController.text.trim();
    if (cleanText.isEmpty || _isStreaming.value) return;

    _isStreaming.value = true;
    messageController.text = '';

    final bool isFirstMessage = _thread.lastMessage.isEmpty;
    final l10n = AppLocalizations.of(_context)!;

    try {
      if (isFirstMessage) {
        await _initializeFirstMessageThread(cleanText);
      }

      await _addUserMessage(cleanText);
      final aiPlaceholder = _addAiPlaceholderMessage();

      final rawResponse = await _consumeCfoStream(
        userPrompt: cleanText,
        aiMessageId: aiPlaceholder.id,
      );

      await _finalizeAiResponse(
        aiPlaceholder: aiPlaceholder,
        rawResponseText: rawResponse,
        userPrompt: cleanText,
        isFirstMessage: isFirstMessage,
        l10n: l10n,
      );
    } catch (_) {
      _handleSendMessageError(l10n.chatConnectionError);
    } finally {
      _isStreaming.value = false;
      _scrollToBottom();
    }
  }

  /// Configura a thread inicial no Firestore na primeira troca de mensagens
  Future<void> _initializeFirstMessageThread(String firstMessage) async {
    _thread = _thread.copyWith(lastMessage: firstMessage);
    await _cfoService.saveThread(_thread);
    _listenToMessages(_thread.id);
  }

  /// Cria, exibe na UI e persiste a mensagem do usuário
  Future<void> _addUserMessage(String text) async {
    final userMessage = ChatMessageModel(
      sender: MessageSender.user,
      text: text,
    );

    messagesNotifier.value = [...messages, userMessage];
    await _cfoService.saveMessage(_thread.id, userMessage);
  }

  /// Insere a mensagem placeholder da IA na tela para animação de digitação
  ChatMessageModel _addAiPlaceholderMessage() {
    final aiMessage = ChatMessageModel(sender: MessageSender.cfoAi, text: '');
    messagesNotifier.value = [...messagesNotifier.value, aiMessage];
    _scrollToBottom();
    return aiMessage;
  }

  /// Processa a stream contínua de respostas vinda do serviço do Gemini
  Future<String> _consumeCfoStream({
    required String userPrompt,
    required String aiMessageId,
  }) async {
    try {
      final StringBuffer accumulatedText = StringBuffer();
      final data = await ExportService().extractDataToAI();

      final responseStream = _cfoService.generateCfoResponseStream(
        userPrompt: userPrompt,
        liveContextJson: data.json,
        history: messages.sublist(0, messages.length - 2),
      );

      await for (final chunk in responseStream) {
        accumulatedText.write(chunk);

        final updatedList = List<ChatMessageModel>.from(messagesNotifier.value);
        final aiIndex = updatedList.indexWhere((m) => m.id == aiMessageId);

        if (aiIndex != -1) {
          updatedList[aiIndex] = updatedList[aiIndex].copyWith(
            text: accumulatedText.toString(),
          );
          messagesNotifier.value = updatedList;
          _scrollToBottom();
        }
      }

      return accumulatedText.toString();
    } catch (_) {
      rethrow;
    }
  }

  /// Finaliza a resposta da IA: limpa as tags JSON, anexa a ação e persiste tudo
  Future<void> _finalizeAiResponse({
    required ChatMessageModel aiPlaceholder,
    required String rawResponseText,
    required String userPrompt,
    required bool isFirstMessage,
    required AppLocalizations l10n,
  }) async {
    // Executa o parser da ação estruturada (<<<PROPOSED_ACTION>>>)
    final parsed = ActionParser.parse(rawResponseText);

    final finalAiMessage = aiPlaceholder.copyWith(
      text: parsed.cleanText,
      proposedAction: parsed.action,
    );

    // Atualiza a lista local com o texto limpo e a ação vinculada
    final updatedList = List<ChatMessageModel>.from(messagesNotifier.value);
    final aiIndex = updatedList.indexWhere((m) => m.id == aiPlaceholder.id);
    if (aiIndex != -1) {
      updatedList[aiIndex] = finalAiMessage;
      messagesNotifier.value = updatedList;
    }

    // Persiste a mensagem pronta no Firestore
    await _cfoService.saveMessage(_thread.id, finalAiMessage);

    // Gera o título da conversa se for o primeiro fluxo
    if (isFirstMessage) {
      final generatedTitleResult = await _cfoService.generateTitle(
        l10n,
        userPrompt: userPrompt,
        aiResponse: parsed.cleanText,
      );

      final generatedTitle = generatedTitleResult.getOrThrow();
      changeTitle(generatedTitle);
    }
  }

  /// Trata erros durante a transmissão exibindo mensagem amigável no chat
  void _handleSendMessageError(String errorText) {
    if (messagesNotifier.value.isNotEmpty) {
      final lastMessage = messagesNotifier.value.last;
      if (lastMessage.sender == MessageSender.cfoAi) {
        final errorAiMessage = lastMessage.copyWith(text: errorText);
        messagesNotifier.value = [
          ...messagesNotifier.value..removeLast(),
          errorAiMessage,
        ];
      }
    }
  }

  Future<bool> changeTitle(String title) async {
    SmLogger.debug('Change title', payload: {'title': title});

    final result = await _cfoService.updateThreadTitle(_thread.id, title);

    result.fold(
      onSuccess: (_) {
        titleController.text = title;
        _thread = _thread.copyWith(title: title);
      },
      onFailure: (_) {
        final l10n = AppLocalizations.of(_context)!;
        SmSnackBar(
          message: l10n.failUpdateThreadTitle,
          type: SnackBarType.error,
        );
      },
    );

    return result.isSuccess;
  }

  Future<void> handleActionResponse(
    String messageId,
    ActionStatus status,
  ) async {
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    final message = messages[index];

    if (status == ActionStatus.approved) {
      await _acceptProposedAction(message);
    } else if (status == ActionStatus.rejected) {
      await _rejectProposedAction(message);
    }
  }

  /// Executa a sugestão feita pelo CFO e marca a ação como aplicada
  Future<void> _acceptProposedAction(ChatMessageModel message) async {
    final action = message.proposedAction;
    if (action == null) return;

    try {
      _aiActionService.handleAction(action);

      // Atualiza o status da ação para "applied" e salva a mensagem no Firestore
      final updatedAction = action.copyWith(status: ActionStatus.approved);
      final updatedMessage = message.copyWith(proposedAction: updatedAction);

      await _cfoService.saveMessage(_thread.id, updatedMessage);

      // Atualiza o estado local
      final updatedList = List<ChatMessageModel>.from(messagesNotifier.value);
      final index = updatedList.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        updatedList[index] = updatedMessage;
        messagesNotifier.value = updatedList;
      }
    } catch (e, stack) {
      SmLogger.error(
        'Failed to apply proposed action',
        exception: e as Exception,
        payload: action.toJson(),
        stackTrace: stack,
      );
    }
  }

  /// Recusa a sugestão feita pelo CFO
  Future<void> _rejectProposedAction(ChatMessageModel message) async {
    final action = message.proposedAction;
    if (action == null) return;

    final updatedAction = action.copyWith(status: ActionStatus.rejected);
    final updatedMessage = message.copyWith(proposedAction: updatedAction);

    await _cfoService.saveMessage(_thread.id, updatedMessage);

    final updatedList = List<ChatMessageModel>.from(messagesNotifier.value);
    final index = updatedList.indexWhere((m) => m.id == message.id);
    if (index != -1) {
      updatedList[index] = updatedMessage;
      messagesNotifier.value = updatedList;
    }
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
