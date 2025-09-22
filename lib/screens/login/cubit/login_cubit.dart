import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      // Use the auth service to handle Google Sign-In
      await authService.signInWithGoogle();
      log('User signed in with Google successfully');

      // Get the current user and emit success
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userModel = UserModel.fromFirebaseUser(user);
        emit(LoginSuccessState(userModel));
      } else {
        emit(
          LoginFailureState(
            "Failed to get user information after Google sign-in",
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          message =
              "An account already exists with this email address but different sign-in method";
          break;
        case 'invalid-credential':
          message = "Invalid Google credentials";
          break;
        case 'operation-not-allowed':
          message = "Google sign-in is not enabled";
          break;
        case 'user-disabled':
          message = "This user account has been disabled";
          break;
        case 'network-request-failed':
          message = "Network error, please try again later";
          break;
        default:
          message = "Google sign-in failed: ${e.message ?? e.code}";
      }
      emit(LoginFailureState(message));
    } catch (e) {
      String message = e.toString();
      if (message.contains('cancelled')) {
        emit(LoginInitialState()); // Return to initial state if user cancelled
      } else {
        emit(LoginFailureState("Google sign-in failed: $message"));
      }
    }
  }
}
