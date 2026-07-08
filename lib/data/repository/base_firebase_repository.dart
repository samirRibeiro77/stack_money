import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/data/helper/firebase_key.dart';

abstract class BaseFirebaseRepository {
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  User? get currentUser => auth.currentUser;

  DocumentReference<Map<String, Object?>> getUserDoc() {
    final user = currentUser;
    if (user == null) {
      throw StackMoneyException(
        message: 'User not authenticated in database session.',
        where: 'BaseRepository',
        scope: ExceptionScope.auth,
      );
    }
    return firestore.collection(FirebaseKey.users).doc(user.uid);
  }
}