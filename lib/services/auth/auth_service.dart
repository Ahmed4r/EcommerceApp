import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth authService = FirebaseAuth.instance;

  //sign out
  Future<void> signOut() async {
    await authService.signOut();
  }

  //sign in
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  //sign up
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    await authService.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  //get user email
  String? getUserEmail() {
    final user = authService.currentUser;
    if (user != null) {
      return user.email;
    }
    return null;
  }

  String? getUserName() {
    final user = authService.currentUser;
    if (user != null) {
      return user.displayName;
    }
    return null;
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled by the user.');
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await authService.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }
}
