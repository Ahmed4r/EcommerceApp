class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final bool isAdmin;
  LoginSuccess({this.isAdmin = false});
}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure(this.error);
}

class LoginPrefsLoaded extends LoginState {
  final String email;
  final String password;
  final bool remember;
  final bool isAdmin;

  LoginPrefsLoaded({
    required this.email,
    required this.password,
    required this.remember,
    this.isAdmin = false,
  });
}
