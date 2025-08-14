class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure(this.error);
}
class LoginPrefsLoaded extends LoginState {
  final String email;
  final String password;
  final bool remember;
  LoginPrefsLoaded({
    required this.email,
    required this.password,
    required this.remember,
  });
}