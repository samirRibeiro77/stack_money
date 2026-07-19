import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/transaction.dart';

class DataPipelineManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> runSequentialAssetSeeder() async {
    try {
      // 1. Carrega e decodifica o arquivo do pipeline
      final String jsonString = await rootBundle.loadString('assets/backup/stack_money_backup.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      // -------------------------------------------------------------------
      // BATCH 1: CRIAÇÃO DOS BUCKETS & FILTRAGEM DE MAPA
      // -------------------------------------------------------------------
      final WriteBatch bucketBatch = _firestore.batch();
      final CollectionReference bucketRef = _firestore.collection('buckets');
      final Map<String, String> resolvedBucketMap = {};

      final List<dynamic> bucketsJson = data['buckets'];
      for (var bJson in bucketsJson) {
        // Instancia usando o construtor nativo (gera UUID automático no model)
        final Bucket bucket = Bucket.fromJson(bJson as Map<String, dynamic>);

        final DocumentReference doc = bucketRef.doc(bucket.id);
        bucketBatch.set(doc, bucket.toJson());

        // Cria a chave de busca composta: "NuConta_Debit"
        final String compoundKey = '${bucket.where}_${bucket.category}';
        resolvedBucketMap[compoundKey] = bucket.id;
      }

      // Commita a primeira fase obrigatoriamente
      await bucketBatch.commit();
      print("🚀 [PIPELINE] Lote 1/2: Todos os Buckets populados com sucesso!");

      // -------------------------------------------------------------------
      // BATCH 2: RESOLUÇÃO DE SNAPSHOTS E GRAVAÇÃO DO HISTÓRICO
      // -------------------------------------------------------------------
      final WriteBatch historyBatch = _firestore.batch();
      final CollectionReference historyRef = _firestore.collection('history');

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
        final Timestamp firestoreTimestamp = Timestamp.fromMillisecondsSinceEpoch(hJson['date'] as int);

        final DocumentReference doc = historyRef.doc();

        // Monta o payload respeitando a assinatura do History.fromJson
        final Map<String, dynamic> historyPayload = {
          'id': doc.id,
          'date': firestoreTimestamp,
          'transactions': mappedTransactions.map((t) => t.toJson()).toList(),
          'total': (hJson['total'] as num).toDouble(),
          'immediateLiquidityTotal': (hJson['immediateLiquidityTotal'] as num).toDouble(),
        };

        historyBatch.set(doc, historyPayload);
      }

      // Commita o histórico completo amarrado
      await historyBatch.commit();
      print("🔥 [PIPELINE] Lote 2/2: Historial financeiro injetado sem quebras de integridade!");

    } catch (e) {
      print("❌ [PIPELINE ERROR]: Falha catastrófica na execução sequencial: $e");
      rethrow;
    }
  }
}