import 'package:firebase_auth/firebase_auth.dart';


class FirebaseAuthService {
  final FirebaseAuth authService = FirebaseAuth.instance;

  //sign out
  Future<void> signOut() async {
    await authService.signOut();
  }

  //sign in
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await authService.signInWithEmailAndPassword(email: email, password: password);
  }

  //sign up
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    await authService.createUserWithEmailAndPassword(email: email, password: password);
  }

  //get user email
  String? getUserEmail() {
    final user = authService.currentUser;
    return user?.email;
  }

  Future<void> signInWithGoogle({required String idToken, required String accessToken}) async {}
}
