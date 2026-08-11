import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/data/enum/message_sender.dart';
import 'package:stack_money/data/helper/firebase_key.dart';
import 'package:stack_money/data/models/chat_message_model.dart';

class CfoVertexService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  /// Inicializa e sincroniza as configurações do Remote Config
  Future<void> initRemoteConfig() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await _remoteConfig.fetchAndActivate();
    } catch (e, stack) {
      StackMoneyException(
        message: 'Error initializing remote config',
        scope: ExceptionScope.service,
        exception: e as Exception,
        stackTrace: stack,
      );
    }
  }

  /// Dispara a pergunta com streaming continuo de resposta e contexto vivo
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
    final fullSystemInstruction =
        '''
$baseSystemPrompt

---
## 📊 DADOS DO USUÁRIO EM TEMPO REAL:
$liveContextJson
''';

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
}
