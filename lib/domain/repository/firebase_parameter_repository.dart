import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 👈 Import necessário
import 'package:stack_money/domain/data/models/bucket.dart';

class FirebaseParameterRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // 👈 Instância de autenticação

  Future<List<Bucket>> fetchParameters() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('USER_NOT_AUTHENTICATED');

      // 🎯 Correção de rota: aponta para a subcoleção privada de parâmetros do usuário
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('parameters')
          .get();

      return snapshot.docs.map((doc) {
        return Bucket.fromJson(doc.data());
      }).toList();
    } catch (e) {
      print('DEBUG_SYSTEM [ParameterRepository]: Error fetching parameters -> $e');
      rethrow;
    }
  }
}