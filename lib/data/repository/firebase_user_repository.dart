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
  bool _isSigningOut = false;

  Stream<User?> Function() get authStateChanges => auth.authStateChanges;

  Future<void> save(UserModel user, {bool savePrefs = false}) async {
    SmLogger.debug(
      'Saving user',
      payload: {'savePrefs': savePrefs, 'user': user.toJson(keepPrefs: true)},
    );

    try {
      await getUserDoc().set(
        user.toJson(keepPrefs: savePrefs),
        SetOptions(merge: true),
      );
      SmLogger.info('User ${user.uid} saved.');
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Failed to save user',
        scope: ExceptionScope.database,
        payload: {'user': user.toJson(keepPrefs: true), 'exception': e},
        stackTrace: stack,
      );
    }

    SmLogger.info('User ${user.uid} saved.');
  }

  Future<UserModel> get() async {
    SmLogger.debug('Getting current user data', payload: {});

    try {
      final doc = await getUserDoc().get();
      if (!doc.exists || doc.data() == null) {
        SmLogger.warning('User does not exists, creating one');
        final defaultUser = UserModel.fromUser(currentUser);
        await save(defaultUser, savePrefs: true);
        SmLogger.warning('User ${defaultUser.uid} created');
        return defaultUser;
      }

      SmLogger.info('Got user ${doc.id}.');

      return UserModel.fromJson(doc.data()!);
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Failed to get user',
        scope: ExceptionScope.database,
        payload: {'exception': e},
        stackTrace: stack,
      );
    }
  }

  Future<UserPreferencesModel> getPreferences() async {
    SmLogger.debug('Getting user preferences', payload: {});

    try {
      final doc = await getUserDoc().get();
      return UserPreferencesModel.fromJson(
        doc.data()?[ModelKey.preferences] as Map<String, Object?>?,
      );
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Failed to get user',
        scope: ExceptionScope.database,
        payload: {'exception': e},
        stackTrace: stack,
      );
    }
  }

  Stream<UserModel> watch() {
    SmLogger.debug('Watching user', payload: {});

    return getUserDoc()
        .snapshots()
        .map((doc) {
          SmLogger.info('Stream user ${doc.id} updated.');

          return UserModel.fromJson(doc.data()!);
        })
        .handleError((e, stack) {
          throw StackMoneyException(
            message: 'Error in user timeline stream',
            scope: ExceptionScope.database,
            payload: {'exception': e},
            stackTrace: stack,
          );
        });
  }

  Future<User?> signInWithGoogle() async {
    SmLogger.debug('Signing in with google account', payload: {});

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

      SmLogger.info('User ${userCredential.user?.uid} authenticated.');

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
    if (_isSigningOut) {
      SmLogger.warning(
        'SignOut already in progress. Ignoring concurrent request.',
      );
      return;
    }

    try {
      _isSigningOut = true;

      SmLogger.info('Signing out from Google');
      await _googleSignIn.signOut();

      SmLogger.info('Signing out from Firebase');
      await auth.signOut();

      SmLogger.warning('User signed out.');
    } catch (e, stack) {
      StackMoneyException(
        message: 'Failed during sign out',
        scope: ExceptionScope.auth,
        payload: {'exception': e},
        stackTrace: stack,
      );
    } finally {
      _isSigningOut = false;
    }
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
