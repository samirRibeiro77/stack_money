import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stack_money/data/models/history.dart';

class FirebaseHistoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<History>> fetch() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('USER_NOT_AUTHENTICATED');

      // 🎯 Correção de rota: entra na pasta privada do usuário logado antes de buscar a coleção
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('history')
          .orderBy('date', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        return History.fromJson(doc.id, doc.data());
      }).toList();
    } catch (e) {
      print('DEBUG_SYSTEM [HistoryRepository]: Error fetching history timeline -> $e');
      rethrow;
    }
  }
}