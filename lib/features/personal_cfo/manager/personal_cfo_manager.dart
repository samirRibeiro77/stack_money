import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/data/enum/message_sender.dart';
import 'package:stack_money/data/models/chat_message_model.dart';
import 'package:stack_money/domain/service/cfo_vertex_service.dart';
import 'package:stack_money/domain/service/export_service.dart';

class PersonalCfoManager {
  final CfoVertexService _cfoService = CfoVertexService();
  final ScrollController scrollController = ScrollController();

  /// Notifiers
  final _messagesNotifier = ValueNotifier<List<ChatMessageModel>>([]);
  final _isStreamingNotifier = ValueNotifier<bool>(false);

  /// Listeners
  ValueListenable<List<ChatMessageModel>> get messagesNotifier =>
      _messagesNotifier;

  ValueListenable<bool> get isStreamingNotifier => _isStreamingNotifier;

  List<ChatMessageModel> get messages => messagesNotifier.value;

  /// Init service
  Future<void> init() async {
    await _cfoService.initRemoteConfig();
  }

  /// Send message and start stream
  Future<void> sendMessage(String userText) async {
    final cleanText = userText.trim();
    if (cleanText.isEmpty || isStreamingNotifier.value) return;

    // 1. Cria e adiciona a mensagem do usuário
    final userMessage = ChatMessageModel(
      sender: MessageSender.user,
      text: cleanText,
      timestamp: Timestamp.now(),
    );

    // 2. Cria a mensagem "placeholder" da IA para receber o streaming
    final aiMessagePlaceholder = ChatMessageModel(
      sender: MessageSender.cfoAi,
      text: '',
      timestamp: Timestamp.now(),
    );

    // Atualiza a lista com o usuário + placeholder da IA
    _messagesNotifier.value = [...messages, userMessage, aiMessagePlaceholder];

    _scrollToBottom();
    _isStreamingNotifier.value = true;

    try {
      // 3. Captura o snapshot vivo do patrimônio em JSON via AppCoordinator
      final String liveContextJson = await ExportService().extractDataToAI();

      // 4. Inicia o consumo da transmissão em tempo real
      final responseStream = _cfoService.generateCfoResponseStream(
        userPrompt: cleanText,
        liveContextJson: liveContextJson,
        history: messages.sublist(
          0,
          messages.length - 2,
        ), // Exclui as 2 últimas novas
      );

      StringBuffer accumulatedText = StringBuffer();

      await for (final chunk in responseStream) {
        accumulatedText.write(chunk);

        // Atualiza apenas a mensagem da IA que está sendo preenchida
        final updatedList = List<ChatMessageModel>.from(messagesNotifier.value);
        final aiIndex = updatedList.indexWhere(
          (m) => m.id == aiMessagePlaceholder.id,
        );

        if (aiIndex != -1) {
          updatedList[aiIndex] = updatedList[aiIndex].copyWith(
            text: accumulatedText.toString(),
          );
          _messagesNotifier.value = updatedList;
          _scrollToBottom();
        }
      }
    } catch (e, stack) {
      StackMoneyException(
        message: 'Error streaming AI message',
        scope: ExceptionScope.business,
        exception: e as Exception,
        stackTrace: stack,
      );

      // Tratamento gracioso em caso de falha de conexão
      final updatedList = List<ChatMessageModel>.from(messagesNotifier.value);
      final aiIndex = updatedList.indexWhere(
        (m) => m.id == aiMessagePlaceholder.id,
      );

      if (aiIndex != -1) {
        updatedList[aiIndex] = updatedList[aiIndex].copyWith(
          text:
              '⚡ *Fail to connect to the CFO terminal...\n_Try again later!_*',
        );
        _messagesNotifier.value = updatedList;
      }
    } finally {
      _isStreamingNotifier.value = false;
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
    _messagesNotifier.dispose();
    _isStreamingNotifier.dispose();
    scrollController.dispose();
  }
}
