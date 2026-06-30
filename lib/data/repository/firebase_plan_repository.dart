import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stack_money/data/models/salary_plan.dart';

class FirebasePlanRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _getPlanCollection() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('USER_NOT_AUTHENTICATED');

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('salary_plans');
  }

  /// 🛰️ BUSCA GERAL: Traz todos os planos do banco ordenados por data de criação mais recente
  Future<List<SalaryPlan>> fetchAllPlans() async {
    try {
      final snapshot = await _getPlanCollection()
          .orderBy('created_at', descending: true)
          .get();

      print('DEBUG_SYSTEM [PlanRepository]: Fetch complete -> ${snapshot.docs.length} total plans loaded.');

      return snapshot.docs.map((doc) => SalaryPlan.fromJson(doc.data())).toList();
    } catch (e) {
      print('DEBUG_SYSTEM [PlanRepository]: Error fetching plans -> $e');
      rethrow;
    }
  }

  /// 📥 SALVAR / ATUALIZAR PLANO INDIVIDUAL
  Future<void> savePlan(SalaryPlan plan) async {
    try {
      await _getPlanCollection().doc(plan.id).set(
        plan.toJson(),
        SetOptions(merge: true),
      );
    } catch (e) {
      print('DEBUG_SYSTEM [PlanRepository]: Error saving plan -> $e');
      rethrow;
    }
  }

  /// 🔥 AJUSTE MESTRE: Suporte completo bidirecional para ativação e desativação segura
  Future<void> updateActiveStatusInBatch(String targetPlanId, bool isActive) async {
    try {
      final collection = _getPlanCollection();

      if (isActive) {
        // 🚀 FLUXO DE ATIVAÇÃO: Inversão atômica em lote (Batch)
        print('🔥 [BATCH_PROTOCOL] -> Activating plan $targetPlanId and resetting other profiles...');
        final batch = _firestore.batch();
        final querySnapshot = await collection.get();

        for (final doc in querySnapshot.docs) {
          final planId = doc.id;

          if (planId == targetPlanId) {
            batch.update(collection.doc(planId), {
              'is_active': true,
              'is_archived': false, // Plano ativo nunca pode estar arquivado
            });
          } else {
            batch.update(collection.doc(planId), {
              'is_active': false,
            });
          }
        }
        await batch.commit();
        print('✅ [BATCH_SUCCESS] -> Activation unique cascade completed successfully.');
      } else {
        // 🔒 FLUXO DE DESATIVAÇÃO: Ponto a ponto ultra-rápido via Update
        print('🔒 [DEACTIVATION_PROTOCOL] -> Deactivating plan: $targetPlanId');
        await collection.doc(targetPlanId).update({
          'is_active': false,
        });
        print('✅ [DEACTIVATION_SUCCESS] -> Plan is now safely set to inactive.');
      }
    } catch (e) {
      print('DEBUG_SYSTEM [PlanRepository]: Active status update failed -> $e');
      rethrow;
    }
  }

  /// 📦 ATUALIZAÇÃO LÓGICA DE ARQUIVAMENTO
  Future<void> updateArchiveStatus(String id, bool isArchived) async {
    try {
      print('📦 [ARCHIVE_STATUS] -> Setting is_archived to $isArchived for plan: $id');
      final updates = <String, dynamic>{'is_archived': isArchived};

      if (isArchived) {
        updates['is_active'] = false;
      }

      await _getPlanCollection().doc(id).update(updates);
    } catch (e) {
      print('DEBUG_SYSTEM [PlanRepository]: Archive status update failed -> $e');
      rethrow;
    }
  }

  /// 🗑️ DELEÇÃO PROTOCOLO PURGE PERMANENTE
  Future<void> purgePlan(String id) async {
    try {
      print('🔥 [PURGE_PROTOCOL] -> Purging Plan UUID: $id');
      await _getPlanCollection().doc(id).delete();
    } catch (e) {
      print('DEBUG_SYSTEM [PlanRepository]: Purge operation failed -> $e');
      rethrow;
    }
  }
}