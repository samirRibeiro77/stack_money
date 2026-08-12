import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stack_money/data/helper/firebase_key.dart';
import 'package:stack_money/data/helper/model_key.dart';
import 'package:stack_money/data/models/chat_message_model.dart';
import 'package:stack_money/data/models/chat_thread_model.dart';
import 'package:stack_money/data/repository/base_firebase_repository.dart';

class FirebaseCfoChatRepository extends BaseFirebaseRepository {
  CollectionReference<Map<String, Object?>> get _collection =>
      getUserDoc().collection(FirebaseKey.cfoThreads);

  /// Salva ou atualiza a thread principal no Firestore
  Future<void> saveThread(ChatThreadModel thread) async {
    await _collection
        .doc(thread.id)
        .set(thread.toJson(), SetOptions(merge: true));
  }

  /// Atualiza apenas o título da thread
  Future<void> updateThreadTitle(String threadId, String title) async {
    await _collection.doc(threadId).update({
      ModelKey.title: title,
      ModelKey.updateAt: Timestamp.now(),
    });
  }

  /// Salva uma nova mensagem dentro da subcoleção de mensagens da thread
  Future<void> saveMessage(ChatMessageModel message) async {
    await _collection
        .doc(message.id)
        .collection(FirebaseKey.messages)
        .doc(message.id)
        .set(message.toJson());

    // Atualiza a prévia da última mensagem na thread
    await _collection.doc(message.id).update({
      ModelKey.lastMessage: message.text,
      ModelKey.updateAt: message.timestamp,
    });
  }

  /// Ouve em tempo real todas as conversas não arquivadas do usuário
  Stream<List<ChatThreadModel>> getThreadsStream() {
    return _collection
        .where(ModelKey.isArchived, isEqualTo: false)
        .orderBy(ModelKey.updateAt, descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatThreadModel.fromJson(doc.data(), id: doc.id))
              .toList(),
        );
  }

  /// Ouve as mensagens de uma thread específica em ordem cronológica
  Stream<List<ChatMessageModel>> getMessagesStream(String threadId) {
    return _collection
        .doc(threadId)
        .collection(FirebaseKey.messages)
        .orderBy(ModelKey.date, descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessageModel.fromJson(doc.data(), id: doc.id))
              .toList(),
        );
  }
}
