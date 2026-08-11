import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:stack_money/data/enum/message_sender.dart';
import 'package:stack_money/data/helper/firebase_key.dart';
import 'package:stack_money/data/models/chat_message_model.dart';

class CfoVertexService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  /// Nome do modelo no Vertex AI
  static const String _modelName = 'gemini-1.5-pro';

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
    } catch (_) {
      // Fallback gracioso em caso de ausência de rede na inicialização
    }
  }

  /// Dispara a pergunta com streaming continuo de resposta e contexto vivo
  Stream<String> generateCfoResponseStream({
    required String userPrompt,
    required String liveContextJson,
    List<ChatMessageModel> history = const [],
  }) async* {
    // 1. Recupera o prompt base do Remote Config
    final baseSystemPrompt = _remoteConfig.getString(FirebaseKey.cfoSystemPrompt);

    // 2. Funde o prompt base com o Snapshot Vivo (JSON) do AppCoordinator
    final fullSystemInstruction = '''
$baseSystemPrompt

---
## 📊 DADOS DO USUÁRIO EM TEMPO REAL (SNAPSHOT ATUAL):
$liveContextJson
''';

    // 3. Instancia o modelo no Vertex AI com as instruções do sistema
    final model = FirebaseVertexAI.instance.generativeModel(
      model: _modelName,
      systemInstruction: Content.system(fullSystemInstruction),
    );

    // 4. Limita o histórico das últimas 50 a 100 mensagens para otimizar tokens
    final limitedHistory = history.length > 50
        ? history.sublist(history.length - 50)
        : history;

    // 5. Converte o histórico local para o formato exigido pelo SDK
    final historyContents = limitedHistory.map((msg) {
      if (msg.sender == MessageSender.user) {
        return Content.text(msg.text);
      } else {
        return Content.model([TextPart(msg.text)]);
      }
    }).toList();

    // 6. Inicia a sessão de chat e dispara o stream
    final chat = model.startChat(history: historyContents);
    final responseStream = chat.sendMessageStream(Content.text(userPrompt));

    await for (final chunk in responseStream) {
      if (chunk.text != null && chunk.text!.isNotEmpty) {
        yield chunk.text!;
      }
    }
  }
}