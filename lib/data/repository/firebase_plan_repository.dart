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

  /// 🛰️ BUSCA GERAL: Traz todos os planos não-arquivados ordenados pelo 'sort_order' manual do usuário
  Future<List<SalaryPlan>> fetchActivePlans() async {
    try {
      final snapshot = await _getPlanCollection()
          .where('is_archived', isEqualTo: false)
          .orderBy('sort_order', descending: false)
          .get();

      print('DEBUG_SYSTEM [PlanRepository]: Fetch complete -> ${snapshot.docs.length} active plans loaded.');

      return snapshot.docs.map((doc) => SalaryPlan.fromJson(doc.data())).toList();
    } catch (e) {
      print('DEBUG_SYSTEM [PlanRepository]: Error fetching plans -> $e');
      rethrow;
    }
  }

  /// 📥 SALVAR / ATUALIZAR PLANO INDIVIDUAL
  Future<void> savePlan(SalaryPlan plan) async {
    try {
      print('📡 [FIRESTORE_WRITE] -> Syncing salary plan UUID: ${plan.id}');

      await _getPlanCollection().doc(plan.id).set(
        plan.toJson(),
        SetOptions(merge: true),
      );

      print('✅ [FIRESTORE_SUCCESS] -> Plan synced: ${plan.id}');
    } catch (e) {
      print('DEBUG_SYSTEM [PlanRepository]: Error saving plan -> $e');
      rethrow;
    }
  }

  /// 🎛️ ALTERNADOR MESTRE DE ATIVAÇÃO EM LOTE
  /// Garante via Batch que ao ativar o plano alvo, todos os outros fiquem 'is_active = false'
  Future<void> setActivePlanInBatch(String targetPlanId) async {
    try {
      print('🔥 [BATCH_PROTOCOL] -> Activating plan $targetPlanId and deactivating remaining...');
      final batch = _firestore.batch();
      final collection = _getPlanCollection();

      // Busca todos os documentos ativos e não arquivados para desligá-los
      final querySnapshot = await collection.where('is_archived', isEqualTo: false).get();

      for (final doc in querySnapshot.docs) {
        final planId = doc.id;
        if (planId == targetPlanId) {
          batch.update(collection.doc(planId), {'is_active': true});
        } else {
          batch.update(collection.doc(planId), {'is_active': false});
        }
      }

      await batch.commit();
      print('✅ [BATCH_SUCCESS] -> Activation ripple cascade completed successfully.');
    } catch (e) {
      print('DEBUG_SYSTEM [PlanRepository]: Batch activation failed -> $e');
      rethrow;
    }
  }

  /// 🔄 ATUALIZAÇÃO EM LOTE PARA REORDER/DRAG & DROP
  /// Salva a nova sequência numérica de index de todos os planos de uma vez só
  Future<void> updatePlansOrderInBatch(List<SalaryPlan> orderedPlans) async {
    try {
      print('📡 [BATCH_ORDER] -> Syncing new drag & drop sorting positions...');
      final batch = _firestore.batch();
      final collection = _getPlanCollection();

      for (final plan in orderedPlans) {
        batch.update(collection.doc(plan.id), {
          'sort_order': plan.sortOrder,
          'is_active': plan.isActive,
        });
      }

      await batch.commit();
      print('✅ [BATCH_SUCCESS] -> New list sequence persisted in cloud database.');
    } catch (e) {
      print('DEBUG_SYSTEM [PlanRepository]: Batch ordering save failed -> $e');
      rethrow;
    }
  }

  /// 📦 ARQUIVAMENTO LÓGICO (Swipe Esquerda -> Direita)
  Future<void> archivePlan(String id) async {
    try {
      print('📦 [ARCHIVE_PROTOCOL] -> Archiving plan UUID: $id');
      await _getPlanCollection().doc(id).update({'is_archived': true, 'is_active': false});
      print('✅ [FIRESTORE_SUCCESS] -> Plan moved to legacy archive storage.');
    } catch (e) {
      print('DEBUG_SYSTEM [PlanRepository]: Archive operation failed -> $e');
      rethrow;
    }
  }

  /// 🗑️ DELEÇÃO PROTOCOLO PURGE PERMANENTE (Swipe Direita -> Esquerda)
  Future<void> purgePlan(String id) async {
    try {
      print('🔥 [PURGE_PROTOCOL] -> Executing permanent destruction on Plan UUID: $id');
      await _getPlanCollection().doc(id).delete();
      print('🗑️ [FIRESTORE_SUCCESS] -> Document fully purged from clusters.');
    } catch (e) {
      print('DEBUG_SYSTEM [PlanRepository]: Purge operation failed -> $e');
      rethrow;
    }
  }
}