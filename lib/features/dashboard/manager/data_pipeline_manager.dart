import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/data/helper/firebase_key.dart';
import 'package:stack_money/data/helper/model_key.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/data/models/transaction.dart';
import 'package:stack_money/domain/service/bucket_service.dart';
import 'package:stack_money/domain/service/history_service.dart';
import 'package:stack_money/domain/service/plan_service.dart';

enum DataJsonClass { history, buckets, plans }

class DataPipelineManager {
  final _planService = PlanManagementService();
  final _bucketService = BucketManagementService();
  final _historyService = HistoryManagementService();

  Future<List<Object?>> _getFileData(DataJsonClass jsonClass) async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/backup/stack_money_backup.json',
      );

      return json.decode(jsonString)[jsonClass.name];
    } catch (e, stack) {
      StackMoneyException(
        message: 'Error loading JSON file',
        scope: ExceptionScope.business,
        payload: {'exception': e},
        stackTrace: stack,
      );

      return [];
    }
  }

  Future<Map<String, String>> _getBucketIds() async {
    try {
      final buckets = await _bucketService.fetch();
      return Map.fromEntries(buckets.map((b) => MapEntry(b.name, b.id)));
    } catch (e, stack) {
      StackMoneyException(
        message: 'Error fetching bucket ids',
        scope: ExceptionScope.business,
        payload: {'exception': e},
        stackTrace: stack,
      );

      return {};
    }
  }

  Future<void> loadBuckets() async {
    SmLogger.debug('Init loading buckets to Firebase', payload: {});
    final firebaseData = await _bucketService.fetch();
    final localData = await _getFileData(DataJsonClass.buckets);
    int howManyCreated = 0;

    SmLogger.debug(
      'Preparing to upload buckets',
      payload: {'firebase': firebaseData.length, 'local': localData.length},
    );

    for (final bJson in localData) {
      final localBucket = Bucket.fromJson(bJson as Map<String, Object?>);
      final firebaseBucket = firebaseData
          .where((b) => b.name == localBucket.name)
          .firstOrNull;

      if (firebaseBucket == null) {
        final createBucket = localBucket.copyWith(newId: true);
        _bucketService.save(createBucket);
        howManyCreated++;
      }
    }

    SmLogger.debug(
      'Finished upload buckets',
      payload: {'created': howManyCreated},
    );
  }

  Future<void> loadHistory() async {
    SmLogger.debug('Init loading history to Firebase', payload: {});
    final firebaseData = await _historyService.fetch();
    final localData = await _getFileData(DataJsonClass.history);
    final bucketIds = await _getBucketIds();
    int howManyCreated = 0;

    for (final hJson in localData) {
      final localHistory = History.fromJson(hJson as Map<String, Object?>);
      final firebaseHistory = firebaseData
          .where((h) => h.date == localHistory.date)
          .firstOrNull;

      if (firebaseHistory == null) {
        final resolvedTransactions = <Transaction>[];

        for (final transaction in localHistory.transactions) {
          final name = '${transaction.where} ${transaction.category}';
          final bucketId = bucketIds[name];

          final newTransaction = Transaction.create(
            bucketId!,
            transaction.actualValue,
            category: transaction.category,
            where: transaction.where,
          );

          resolvedTransactions.add(newTransaction);
        }

        final createHistory = History.withValues(
          date: localHistory.date,
          immediateLiquidityTotal: localHistory.immediateLiquidityTotal,
          total: localHistory.total,
          transactions: resolvedTransactions,
        );
        _historyService.save(createHistory);
        howManyCreated++;
      }
    }

    SmLogger.debug(
      'Finished upload history',
      payload: {'created': howManyCreated},
    );
  }

  // Future<void> runSequentialAssetSeeder() async {
  //   SmLogger.info('-- Init backup upload --');
  //   try {
  //     // 1. Carrega e decodifica o arquivo do pipeline
  //     final String jsonString = await rootBundle.loadString(
  //       'assets/backup/stack_money_backup.json',
  //     );
  //     final Map<String, dynamic> data = json.decode(jsonString);
  //     final user = FirebaseAuth.instance.currentUser;
  //     final firebaseRef = _firestore.collection(FirebaseKey.users).doc(user?.uid);
  //
  //     // -------------------------------------------------------------------
  //     // BATCH 1: CRIAÇÃO DOS BUCKETS & FILTRAGEM DE MAPA
  //     // -------------------------------------------------------------------
  //     final WriteBatch bucketBatch = _firestore.batch();
  //     final CollectionReference bucketRef = firebaseRef.collection(FirebaseKey.buckets);
  //     final Map<String, String> resolvedBucketMap = {};
  //
  //     final List<dynamic> bucketsJson = data['buckets'];
  //     for (var bJson in bucketsJson) {
  //       // Instancia usando o construtor nativo (gera UUID automático no model)
  //       final bucketJson = Bucket.fromJson(bJson as Map<String, Object?>);
  //       final bucket = bucketJson.copyWith(newId: true);
  //
  //       final DocumentReference doc = bucketRef.doc(bucket.id);
  //       bucketBatch.set(doc, bucket.toJson());
  //
  //       // Cria a chave de busca composta: "NuConta_Debit"
  //       final String compoundKey = '${bucket.where}_${bucket.category}';
  //       resolvedBucketMap[compoundKey] = bucket.id;
  //     }
  //
  //     // Commita a primeira fase obrigatoriamente
  //     await bucketBatch.commit();
  //     SmLogger.debug(
  //       '🚀 [PIPELINE] Lote 1/2: Todos os Buckets populados com sucesso!',
  //       payload: {'buckets': resolvedBucketMap.length},
  //     );
  //
  //     // -------------------------------------------------------------------
  //     // BATCH 2: RESOLUÇÃO DE SNAPSHOTS E GRAVAÇÃO DO HISTÓRICO
  //     // -------------------------------------------------------------------
  //     final WriteBatch historyBatch = _firestore.batch();
  //     final CollectionReference historyRef = firebaseRef.collection(FirebaseKey.history);
  //
  //     final List<dynamic> historyJson = data['history'];
  //     for (var hJson in historyJson) {
  //       final List<dynamic> txsList = hJson['transactions'];
  //
  //       // Mapeia e injeta o ID correto do bucket de forma dinâmica
  //       final List<Transaction> mappedTransactions = txsList.map((t) {
  //         final String key = '${t['where']}_${t['category']}';
  //         final String bucketId = resolvedBucketMap[key] ?? '';
  //
  //         return Transaction.create(
  //           bucketId,
  //           (t['value'] as num).toDouble(),
  //           category: t['category'] as String,
  //           where: t['where'] as String,
  //         );
  //       }).toList();
  //
  //       // Converte os milissegundos brutos para o Timestamp do Firestore
  //       final Timestamp firestoreTimestamp =
  //           Timestamp.fromMillisecondsSinceEpoch(hJson['date'] as int);
  //
  //       final DocumentReference doc = historyRef.doc();
  //
  //       // Monta o payload respeitando a assinatura do History.fromJson
  //       final historyPayload = History.withValues(
  //         transactions: mappedTransactions,
  //         total: (hJson['total'] as num).toDouble(),
  //         immediateLiquidityTotal: (hJson['immediateLiquidityTotal'] as num)
  //             .toDouble(),
  //         date: firestoreTimestamp
  //       );
  //
  //       historyBatch.set(doc, historyPayload.toJson());
  //     }
  //
  //     // Commita o histórico completo amarrado
  //     await historyBatch.commit();
  //     SmLogger.debug(
  //       '🔥 [PIPELINE] Lote 2/2: Historial financeiro injetado sem quebras de integridade!',
  //       payload: {'history': historyJson.length},
  //     );
  //   } catch (e, stack) {
  //     SmLogger.error(
  //       '❌ [PIPELINE ERROR]: Falha catastrófica na execução sequencial',
  //       error: e,
  //       stackTrace: stack,
  //     );
  //     rethrow;
  //   }
  //
  //   SmLogger.info('-- Finished backup upload --');
  // }
}
