import 'package:shop/model/user_model.dart';

abstract class SignUpState {
  const SignUpState();
}

class SignUpInitialState extends SignUpState {}

class SignUpLoadingState extends SignUpState {}

// Keep LoginSuccessState carrying your UserModel
class SignUpSuccessState extends SignUpState {
  final UserModel user;
  const SignUpSuccessState(this.user);
}

class SignUpFailureState extends SignUpState {
  final String error;
  const SignUpFailureState(this.error);
}
