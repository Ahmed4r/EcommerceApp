import 'package:shop/model/user_model.dart';

abstract class LoginState {
  const LoginState();
}

class LoginInitialState extends LoginState {}

class LoginLoadingState extends LoginState {}

// Keep LoginSuccessState carrying your UserModel
class LoginSuccessState extends LoginState {
  final UserModel user;
  const LoginSuccessState(this.user);
}

class LoginFailureState extends LoginState {
  final String error;
  const LoginFailureState(this.error);
}


