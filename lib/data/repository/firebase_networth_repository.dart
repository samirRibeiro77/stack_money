import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stack_money/data/models/net_worth.dart';

class FirebaseNetworthRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<NetWorth> get() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('USER_NOT_AUTHENTICATED');

      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      return NetWorth.fromJson(snapshot.data()?['net_worth']);
    } catch (e) {
      print('DEBUG_SYSTEM [NetworthRepository]: Error fetching networth -> $e');
      rethrow;
    }
  }
}