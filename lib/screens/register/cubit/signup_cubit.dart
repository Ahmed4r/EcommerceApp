import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop/model/user_model.dart';
import 'package:shop/screens/register/cubit/signup_state.dart';
import 'package:shop/services/auth/auth_service.dart';
import 'package:shop/services/store/firestore_service.dart';

class SignupCubit extends Cubit<SignUpState> {
  final FirebaseAuthService authService;
  final FirestoreService storeService;
  SignupCubit(this.authService, this.storeService)
    : super(SignUpInitialState());

  void register(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    // Validation
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      emit(SignUpFailureState("All fields are required"));
      return;
    }

    // Email format validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      emit(SignUpFailureState("Invalid email format"));
      return;
    }

    // Password validation
    if (password.length < 8) {
      emit(SignUpFailureState("Password must be at least 8 characters"));
      return;
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      emit(
        SignUpFailureState(
          "Password must contain at least one uppercase letter",
        ),
      );
      return;
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      emit(
        SignUpFailureState(
          "Password must contain at least one lowercase letter",
        ),
      );
      return;
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      emit(SignUpFailureState("Password must contain at least one number"));
      return;
    }

    if (password != confirmPassword) {
      emit(SignUpFailureState("Passwords do not match"));
      return;
    }

    emit(SignUpLoadingState());

    try {
      // Create user in Firebase Authentication
      await authService.signUpWithEmailAndPassword(email, password);

      // Update display name
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();

        // Get updated user and add to Firestore
        final updatedUser = FirebaseAuth.instance.currentUser;
        await storeService.addUser({
          'uid': updatedUser!.uid,
          'email': email,
          'displayName': name,
          'createdAt': DateTime.now().toIso8601String(),
        });

        final userModel = UserModel.fromFirebaseUser(updatedUser);
        emit(SignUpSuccessState(userModel));
      } else {
        emit(SignUpFailureState("Failed to get user information"));
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = "The password provided is too weak";
          break;
        case 'email-already-in-use':
          message = "An account already exists for this email";
          break;
        case 'invalid-email':
          message = "The email address is not valid";
          break;
        case 'network-request-failed':
          message = "Network error, please try again later";
          break;
        default:
          message = "Registration failed: ${e.message ?? e.code}";
      }
      emit(SignUpFailureState(message));
    } catch (e) {
      emit(SignUpFailureState("An unexpected error occurred: ${e.toString()}"));
    }
  }
}
