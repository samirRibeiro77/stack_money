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

  /// 🛰️ PONTO 1.1.1 & 1.1.2: Traz TODOS os planos do cluster ordenados por data mais recente
  Future<List<SalaryPlan>> fetchAllPlans() async {
    try {
      final snapshot = await _getPlanCollection()
          .orderBy('created_at', descending: true)
          .get();

      print(
        'DEBUG_SYSTEM [PlanRepository]: Fetch complete -> ${snapshot.docs.length} total plans loaded.',
      );

      return snapshot.docs
          .map((doc) => SalaryPlan.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('DEBUG_SYSTEM [PlanRepository]: Error fetching plans -> $e');
      rethrow;
    }
  }

  /// 📥 SAVING COMPONENT
  Future<void> savePlan(SalaryPlan plan) async {
    try {
      await _getPlanCollection()
          .doc(plan.id)
          .set(plan.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('DEBUG_SYSTEM [PlanRepository]: Error saving plan -> $e');
      rethrow;
    }
  }

  /// 📦 PONTO 1.2.4: Atualiza o estado lógico de arquivamento (pode ativar ou desativar)
  Future<void> updateArchiveStatus(String id, bool isArchived) async {
    try {
      print(
        '📦 [ARCHIVE_STATUS] -> Setting is_archived to $isArchived for plan: $id',
      );
      final updates = <String, dynamic>{'is_archived': isArchived};

      // Se for arquivado, por regra de segurança ele perde o estado de ativo na mesma hora
      if (isArchived) {
        updates['is_active'] = false;
      }

      await _getPlanCollection().doc(id).update(updates);
    } catch (e) {
      print(
        'DEBUG_SYSTEM [PlanRepository]: Archive status update failed -> $e',
      );
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
