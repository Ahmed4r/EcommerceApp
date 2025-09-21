import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shop/model/user_model.dart';
import 'package:shop/screens/login/cubit/login_state.dart';
import 'package:shop/services/auth/auth_service.dart';
// import 'package:shop/services/store/firestore_service.dart'; // Unused import

class LoginCubit extends Cubit<LoginState> {
  final FirebaseAuthService authService;

  LoginCubit(this.authService) : super(LoginInitialState());

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      emit(LoginFailureState("Please enter email and password"));
      return;
    }
    emit(LoginLoadingState());
    try {
      await authService.signInWithEmailAndPassword(email, password);
      final user = FirebaseAuth.instance.currentUser;
      final userModel = UserModel.fromFirebaseUser(user);
      emit(LoginSuccessState(userModel));
    } on FirebaseAuthException catch (e) {
      // Handle common Firebase auth errors
      String message;
      if (e.code == 'network-request-failed') {
        message = "Network error, please try again later.";
      } else {
        message = "Authentication failed: ${e.message ?? e.code}";
      }
      emit(LoginFailureState(message));
    } catch (e) {
      emit(LoginFailureState(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(LoginLoadingState());
    try {
      await authService.signOut();
      emit(LoginInitialState());
    } on FirebaseAuthException catch (e) {
      emit(LoginFailureState("Error during sign out: ${e.message ?? e.code}"));
    } catch (e) {
      emit(LoginFailureState("Error during sign out: ${e.toString()}"));
    }
  }

  //  google sign-in
  Future<void> nativeGoogleSignIn() async {
    emit(LoginLoadingState());
    try {
      // Use simple GoogleSignIn configuration for mobile
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Ensure a fresh sign in
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // user cancelled
        emit(LoginInitialState());
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        emit(LoginFailureState("Missing Google tokens"));
        return;
      }

      // Delegate Firebase sign-in to the auth service
      await authService.signInWithGoogle();

      // Build UserModel from Firebase user and emit success
      final user = FirebaseAuth.instance.currentUser;
      final userModel = UserModel.fromFirebaseUser(user);
      emit(LoginSuccessState(userModel));
    } on FirebaseAuthException catch (e) {
      emit(LoginFailureState(e.message ?? e.code));
    } catch (e) {
      emit(LoginFailureState(e.toString()));
    }
  }
}
