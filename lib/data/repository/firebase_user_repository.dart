import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/data/helper/model_key.dart';
import 'package:stack_money/data/models/user_model.dart';
import 'package:stack_money/data/models/user_preferences_model.dart';
import 'package:stack_money/data/repository/base_firebase_repository.dart';

class FirebaseUserRepository extends BaseFirebaseRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> Function() get authStateChanges => auth.authStateChanges;

  Future<void> save(UserModel user, {bool savePrefs = false}) async {
    await getUserDoc().set(
      user.toJson(keepPrefs: savePrefs),
      SetOptions(merge: true),
    );
  }

  Future<UserModel> get() async {
    final doc = await getUserDoc().get();
    if (!doc.exists || doc.data() == null) {
      final defaultUser = UserModel.fromUser(currentUser);
      await save(defaultUser, savePrefs: true);
      return defaultUser;
    }
    return UserModel.fromJson(doc.data()!);
  }

  Future<UserPreferencesModel> getPreferences() async {
    final doc = await getUserDoc().get();
    return UserPreferencesModel.fromJson(
      doc.data()?[ModelKey.preferences] as Map<String, Object?>?,
    );
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await auth.signInWithCredential(
        credential,
      );

      await _syncUser(userCredential.user);

      return userCredential.user;
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Google authentication protocol failed',
        scope: ExceptionScope.auth,
        payload: {'exception': e},
        stackTrace: stack,
      );
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await auth.signOut();
  }

  Future<void> _syncUser(User? user) async {
    if (user == null) return;

    final updateUser = await get();

    SmLogger.debug(
      'Sync user',
      payload: {'auth': user, 'firebase': updateUser.toJson(keepPrefs: true)},
    );

    await save(updateUser);
  }
}
