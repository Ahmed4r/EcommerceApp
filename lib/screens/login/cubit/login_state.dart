import 'package:shop/model/user_model.dart';

abstract class LoginState {
  const LoginState();
}

class LoginInitialState extends LoginState {}

class LoginLoadingState extends LoginState {}

// LoginSuccessState with user data and role information
class LoginSuccessState extends LoginState {
  final UserModel user;
  final String role;
  const LoginSuccessState(this.user, this.role);

  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user';
}

class LoginFailureState extends LoginState {
  final String error;
  const LoginFailureState(this.error);
}
