import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Core authentication service driving the native Firebase and Google SDKs.
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Reactive stream that emits updates whenever the user's sign-in state changes.
  Stream<User?> Function() get authStateChanges => _firebaseAuth.authStateChanges;

  /// Synchronous getter to fetch the current authenticated user session.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Executes the Google Sign-In protocol and returns the authenticated Firebase User.
  Future<User?> signInWithGoogle() async {
    try {
      // 1. Trigger the native platform account selector overlay
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Operation aborted by the user

      // 2. Fetch secure authorization tokens from the provider
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Assemble credential tokens for the Firebase internal gateway
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Authenticate into the Firebase core system
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      throw Exception('Google authentication protocol failed: ${e.toString()}');
    }
  }

  /// Revokes active session tokens from both Google and Firebase environments.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}