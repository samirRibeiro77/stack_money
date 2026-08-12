import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/data/enum/message_sender.dart';
import 'package:stack_money/data/models/chat_message_model.dart';
import 'package:stack_money/data/models/chat_thread_model.dart';
import 'package:stack_money/domain/service/cfo_vertex_service.dart';
import 'package:stack_money/domain/service/export_service.dart';

class PersonalCfoManager {
  final CfoVertexService _cfoService = CfoVertexService();
  final ScrollController scrollController = ScrollController();

  final ValueNotifier<List<ChatMessageModel>> messagesNotifier = ValueNotifier(
    [],
  );
  final ValueNotifier<bool> isStreamingNotifier = ValueNotifier(false);
  final ValueNotifier<ChatThreadModel?> activeThreadNotifier = ValueNotifier(
    null,
  );

  List<ChatMessageModel> get messages => messagesNotifier.value;

  Future<void> init([String? threadId]) async {
    await _cfoService.initRemoteConfig();

    if (threadId != null) {
      _listenToMessages(threadId);
    }
  }

  void _listenToMessages(String threadId) {
    _cfoService.getMessagesStream(threadId).listen((remoteMessages) {
      if (!isStreamingNotifier.value) {
        messagesNotifier.value = remoteMessages;
        _scrollToBottom();
      }
    });
  }

  Future<void> sendMessage(AppLocalizations l10n, String userText) async {
    final cleanText = userText.trim();
    if (cleanText.isEmpty || isStreamingNotifier.value) return;

    // 1. Garante ou cria a Thread ativa
    final thread =
        activeThreadNotifier.value ??
        ChatThreadModel(title: 'l10n.newChat', lastMessage: cleanText);

    final bool isFirstMessage = activeThreadNotifier.value == null;

    if (isFirstMessage) {
      activeThreadNotifier.value = thread;
      await _cfoService.saveThread(thread);
      _listenToMessages(thread.id);
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
    isStreamingNotifier.value = true;

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

        await _cfoService.updateThreadTitle(thread.id, generatedTitle);
        activeThreadNotifier.value = thread.copyWith(title: generatedTitle);
      }
    } catch (e) {
      final errorAiMessage = aiMessage.copyWith(text: l10n.chatConnectionError);
      messagesNotifier.value = [
        ...messagesNotifier.value..removeLast(),
        errorAiMessage,
      ];
    } finally {
      isStreamingNotifier.value = false;
      _scrollToBottom();
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
    isStreamingNotifier.dispose();
    activeThreadNotifier.dispose();
    scrollController.dispose();
  }
}
