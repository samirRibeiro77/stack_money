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

  Future<List<ChatThreadModel>> fetch() async {
    SmLogger.debug('Fetching threads', payload: {});

    try {
      final snapshot = await _collection
          .orderBy(ModelKey.updateAt, descending: false)
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      SmLogger.info(
        'Fetch Threads completed with ${snapshot.docs.length} entries.',
      );

      return snapshot.docs.map((doc) {
        return ChatThreadModel.fromJson(doc.data(), id: doc.id);
      }).toList();
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Error fetching chat threads timeline',
        scope: ExceptionScope.database,
        exception: e as Exception,
        stackTrace: stack,
      );
    }
  }

  Future<List<ChatMessageModel>> fetchMessages(String threadId) async {
    SmLogger.debug('Fetching messages', payload: {'threadId': threadId});

    try {
      final snapshot = await _collection
          .doc(threadId)
          .collection(FirebaseKey.messages)
          .orderBy(ModelKey.date, descending: false)
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      SmLogger.info(
        'Fetch messages completed with ${snapshot.docs.length} entries.',
      );

      return snapshot.docs.map((doc) {
        return ChatMessageModel.fromJson(doc.data(), id: doc.id);
      }).toList();
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Error fetching thread messages timeline',
        scope: ExceptionScope.database,
        exception: e as Exception,
        stackTrace: stack,
      );
    }
  }

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

  /// Deleta a thread principal no Firestore
  Future<void> deleteThread(String id) async {
    SmLogger.debug('Deleting chat thread', payload: {'id': id});

    try {
      await _deleteMessages(id);
      await _collection.doc(id).delete();
      SmLogger.warning('Chat thread deleted.');
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Hard purge execution failed on core cluster',
        scope: ExceptionScope.database,
        exception: e as Exception,
        payload: {'id': id},
        stackTrace: stack,
      );
    }
  }

  Future<void> _deleteMessages(String id) async {
    SmLogger.debug('Deleting chat messages', payload: {'id': id});

    try {
      final collectionRef = FirebaseFirestore.instance.collection(
        FirebaseKey.messages,
      );
      final querySnapshot = await collectionRef.get();
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      SmLogger.warning('Chat messages deleted.');
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Hard purge execution failed on core cluster',
        scope: ExceptionScope.database,
        exception: e as Exception,
        payload: {'id': id},
        stackTrace: stack,
      );
    }
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
      payload: {'threadId': threadId, 'message': message.id},
    );

    try {
      await _collection
          .doc(threadId)
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
        .orderBy(ModelKey.updateAt, descending: true)
        .snapshots()
        .map((snapshot) {
          SmLogger.info(
            'Stream threads updated with ${snapshot.docs.length} entries.',
          );

          return snapshot.docs
              .map((doc) => ChatThreadModel.fromJson(doc.data()))
              .toList();
        })
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
