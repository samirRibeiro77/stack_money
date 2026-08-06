import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/data/helper/firebase_key.dart';

abstract class BaseFirebaseRepository {
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  User? get currentUser => auth.currentUser;

  DocumentReference<Map<String, Object?>> getUserDoc() {
    SmLogger.debug('Getting current user doc', payload: {});

    final user = currentUser;
    if (user == null) {
      throw StackMoneyException(
        message: 'User not authenticated in session.',
        scope: ExceptionScope.auth,
      );
    }

    SmLogger.info('Got user ${user.uid} doc');

    return firestore.collection(FirebaseKey.users).doc(user.uid);
  }
}
