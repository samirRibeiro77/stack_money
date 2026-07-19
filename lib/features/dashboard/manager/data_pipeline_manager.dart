import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/data/helper/firebase_key.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/data/models/transaction.dart';

class DataPipelineManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> runSequentialAssetSeeder() async {
    SmLogger.info('-- Init backup upload --');
    try {
      // 1. Carrega e decodifica o arquivo do pipeline
      final String jsonString = await rootBundle.loadString(
        'assets/backup/stack_money_backup.json',
      );
      final Map<String, dynamic> data = json.decode(jsonString);
      final user = FirebaseAuth.instance.currentUser;
      final firebaseRef = _firestore.collection(FirebaseKey.users).doc(user?.uid);

      // -------------------------------------------------------------------
      // BATCH 1: CRIAÇÃO DOS BUCKETS & FILTRAGEM DE MAPA
      // -------------------------------------------------------------------
      final WriteBatch bucketBatch = _firestore.batch();
      final CollectionReference bucketRef = firebaseRef.collection(FirebaseKey.buckets);
      final Map<String, String> resolvedBucketMap = {};

      final List<dynamic> bucketsJson = data['buckets'];
      for (var bJson in bucketsJson) {
        // Instancia usando o construtor nativo (gera UUID automático no model)
        final bucketJson = Bucket.fromJson(bJson as Map<String, Object?>);
        final bucket = bucketJson.copyWith(newId: true);

        final DocumentReference doc = bucketRef.doc(bucket.id);
        bucketBatch.set(doc, bucket.toJson());

        // Cria a chave de busca composta: "NuConta_Debit"
        final String compoundKey = '${bucket.where}_${bucket.category}';
        resolvedBucketMap[compoundKey] = bucket.id;
      }

      // Commita a primeira fase obrigatoriamente
      await bucketBatch.commit();
      SmLogger.debug(
        '🚀 [PIPELINE] Lote 1/2: Todos os Buckets populados com sucesso!',
        payload: {'buckets': resolvedBucketMap.length},
      );

      // -------------------------------------------------------------------
      // BATCH 2: RESOLUÇÃO DE SNAPSHOTS E GRAVAÇÃO DO HISTÓRICO
      // -------------------------------------------------------------------
      final WriteBatch historyBatch = _firestore.batch();
      final CollectionReference historyRef = firebaseRef.collection(FirebaseKey.history);

      final List<dynamic> historyJson = data['history'];
      for (var hJson in historyJson) {
        final List<dynamic> txsList = hJson['transactions'];

        // Mapeia e injeta o ID correto do bucket de forma dinâmica
        final List<Transaction> mappedTransactions = txsList.map((t) {
          final String key = '${t['where']}_${t['category']}';
          final String bucketId = resolvedBucketMap[key] ?? '';

          return Transaction.create(
            bucketId,
            (t['value'] as num).toDouble(),
            category: t['category'] as String,
            where: t['where'] as String,
          );
        }).toList();

        // Converte os milissegundos brutos para o Timestamp do Firestore
        final Timestamp firestoreTimestamp =
            Timestamp.fromMillisecondsSinceEpoch(hJson['date'] as int);

        final DocumentReference doc = historyRef.doc();

        // Monta o payload respeitando a assinatura do History.fromJson
        final historyPayload = History.withValues(
          transactions: mappedTransactions,
          total: (hJson['total'] as num).toDouble(),
          immediateLiquidityTotal: (hJson['immediateLiquidityTotal'] as num)
              .toDouble(),
          date: firestoreTimestamp
        );

        historyBatch.set(doc, historyPayload.toJson());
      }

      // Commita o histórico completo amarrado
      await historyBatch.commit();
      SmLogger.debug(
        '🔥 [PIPELINE] Lote 2/2: Historial financeiro injetado sem quebras de integridade!',
        payload: {'history': historyJson.length},
      );
    } catch (e, stack) {
      SmLogger.error(
        '❌ [PIPELINE ERROR]: Falha catastrófica na execução sequencial',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }

    SmLogger.info('-- Finished backup upload --');
  }
}
