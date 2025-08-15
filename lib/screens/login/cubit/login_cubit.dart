import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/screens/login/cubit/login_state.dart';
import 'package:shop/services/auth/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginCubit extends Cubit<LoginState> {
  SharedPreferences? sharedpref;
  final AuthService authService;

  LoginCubit(this.authService) : super(LoginInitial()) {
    _loadPrefs();
  }
  Future<void> _loadPrefs() async {
    sharedpref = await SharedPreferences.getInstance();
    emit(
      LoginPrefsLoaded(
        email: sharedpref!.getString('email') ?? '',
        password: sharedpref!.getString('password') ?? '',
        remember: sharedpref!.getBool('remember') ?? false,
      ),
    );
  }

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      emit(LoginFailure("Please enter email and password"));
      return;
    }

    emit(LoginLoading());
    try {
      await authService.signInWithEmailAndPassword(email, password);
      sharedpref ??= await SharedPreferences.getInstance();
      await sharedpref!.setBool('authToken', true);
      emit(LoginSuccess());
    } catch (e) {
      if (e is AuthRetryableFetchException) {
        emit(LoginFailure("Network error, please try again later."));
      } else if (e is AuthApiException) {
        emit(LoginFailure("Authentication failed: ${e.message}"));
      } else {
        emit(LoginFailure(e.toString()));
      }
    }
  }

  Future<void> updateRemember(
    bool remember,
    String email,
    String password,
  ) async {
    sharedpref ??= await SharedPreferences.getInstance();
    if (remember && email.isNotEmpty && password.isNotEmpty) {
      await sharedpref!.setBool('remember', true);
      await sharedpref!.setString('email', email);
      await sharedpref!.setString('password', password);
    } else {
      await sharedpref!.remove('remember');
    }
    emit(
      LoginPrefsLoaded(email: email, password: password, remember: remember),
    );
  }
}
