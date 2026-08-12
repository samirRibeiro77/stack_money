import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
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
    SmLogger.debug('Initializing save', payload: thread.toJson());

    _collection
        .doc(thread.id)
        .set(thread.toJson(), SetOptions(merge: true))
        .then((_) {
          SmLogger.info(
            'Document synced in background: ${thread.id} (${thread.title})',
          );
        })
        .catchError((e, stack) {
          throw StackMoneyException(
            message: 'Background sync failed',
            scope: ExceptionScope.database,
            exception: e as Exception,
            stackTrace: stack,
          );
        });
  }

  /// Atualiza apenas o título da thread
  Future<void> updateThreadTitle(String threadId, String title) async {
    SmLogger.debug(
      'Updating thread title',
      payload: {ModelKey.title: title, ModelKey.updateAt: Timestamp.now()},
    );

    _collection
        .doc(threadId)
        .update({ModelKey.title: title, ModelKey.updateAt: Timestamp.now()})
        .then((_) {
          SmLogger.info('Document updated in background: $threadId ($title)');
        })
        .catchError((e, stack) {
          throw StackMoneyException(
            message: 'Background update failed',
            scope: ExceptionScope.database,
            payload: {
              ModelKey.title: title,
              ModelKey.updateAt: Timestamp.now(),
            },
            exception: e as Exception,
            stackTrace: stack,
          );
        });
  }

  /// Salva uma nova mensagem dentro da subcoleção de mensagens da thread
  Future<void> saveMessage(String threadId, ChatMessageModel message) async {
    SmLogger.debug(
      'Initializing save',
      payload: {'threadId': threadId, 'message': message.toJson()},
    );

    try {
      await _collection
          .doc(message.id)
          .collection(FirebaseKey.messages)
          .doc(message.id)
          .set(message.toJson());

      /// Update last thread message
      await _collection.doc(threadId).update({
        ModelKey.lastMessage: message.text,
        ModelKey.updateAt: message.timestamp,
      });
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Background update failed',
        scope: ExceptionScope.database,
        payload: {'threadId': threadId, 'message': message.toJson()},
        exception: e as Exception,
        stackTrace: stack,
      );
    }
  }

  /// Ouve em tempo real todas as conversas não arquivadas do usuário
  Stream<List<ChatThreadModel>> watchThreads() {
    SmLogger.debug('Watching threads', payload: {});

    return _collection
        .where(ModelKey.isArchived, isEqualTo: false)
        .orderBy(ModelKey.updateAt, descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatThreadModel.fromJson(doc.data(), id: doc.id))
              .toList(),
        )
        .handleError((e, stack) {
          throw StackMoneyException(
            message: 'Error in threads timeline stream',
            scope: ExceptionScope.database,
            exception: e as Exception,
            stackTrace: stack,
          );
        });
  }

  /// Ouve as mensagens de uma thread específica em ordem cronológica
  Stream<List<ChatMessageModel>> watchMessages(String threadId) {
    SmLogger.debug('Watching messages', payload: {'threadId': threadId});

    return _collection
        .doc(threadId)
        .collection(FirebaseKey.messages)
        .orderBy(ModelKey.date, descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessageModel.fromJson(doc.data(), id: doc.id))
              .toList(),
        )
        .handleError((e, stack) {
          throw StackMoneyException(
            message: 'Error in messages timeline stream',
            scope: ExceptionScope.database,
            payload: {'threadId': threadId},
            exception: e as Exception,
            stackTrace: stack,
          );
        });
  }
}
