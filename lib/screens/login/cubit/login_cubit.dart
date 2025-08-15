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
        isAdmin: sharedpref!.getBool('isAdmin') ?? false,
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

      // Check if user is admin by checking email or role from database
      bool isAdmin = await _checkAdminRole(email);

      // Save authentication tokens
      await sharedpref!.setBool('authToken', true);
      await sharedpref!.setBool('isAdmin', isAdmin);
      await sharedpref!.setString('userEmail', email);

      emit(LoginSuccess(isAdmin: isAdmin));
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

  Future<bool> _checkAdminRole(String email) async {
    try {
      // Simple email-based admin checking (no database queries to avoid errors)
      List<String> adminEmails = [
        'ahmedrady03@gmail.com',
        'admin@shop.com',
        'admin@example.com',
        'ahmed@admin.com',
        'superadmin@shop.com',
        // Add your admin emails here
      ];

      bool isAdmin = adminEmails.contains(email.toLowerCase());
      print('Admin check for $email: $isAdmin');
      return isAdmin;
    } catch (e) {
      // If there's an error checking admin role, default to false
      print('Error checking admin role: $e');
      return false;
    }
  }

  Future<void> updateRemember(
    bool remember,
    String email,
    String password,
  ) async {
    sharedpref ??= await SharedPreferences.getInstance();
    bool isAdmin = sharedpref!.getBool('isAdmin') ?? false;

    if (remember && email.isNotEmpty && password.isNotEmpty) {
      await sharedpref!.setBool('remember', true);
      await sharedpref!.setString('email', email);
      await sharedpref!.setString('password', password);
    } else {
      await sharedpref!.remove('remember');
    }
    emit(
      LoginPrefsLoaded(
        email: email,
        password: password,
        remember: remember,
        isAdmin: isAdmin,
      ),
    );
  }

  // Helper method to check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    sharedpref ??= await SharedPreferences.getInstance();
    return sharedpref!.getBool('isAdmin') ?? false;
  }

  // Helper method to get current user email
  Future<String> getCurrentUserEmail() async {
    sharedpref ??= await SharedPreferences.getInstance();
    return sharedpref!.getString('userEmail') ?? '';
  }

  // Method to logout and clear admin status
  Future<void> logout() async {
    sharedpref ??= await SharedPreferences.getInstance();
    await sharedpref!.setBool('authToken', false);
    await sharedpref!.setBool('isAdmin', false);
    await sharedpref!.remove('userEmail');
    emit(LoginInitial());
  }
}
