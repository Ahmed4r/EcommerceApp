import 'package:shared_preferences/shared_preferences.dart';

/// Utility class for checking user authentication and admin status
class AuthUtils {
  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('authToken') ?? false;
  }

  /// Check if user is admin
  static Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isAdmin') ?? false;
  }

  /// Get current user email
  static Future<String> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail') ?? '';
  }

  /// Check if user has admin access (logged in AND admin)
  static Future<bool> hasAdminAccess() async {
    return await isLoggedIn() && await isAdmin();
  }

  /// Set user login status
  static Future<void> setLoginStatus(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('authToken', isLoggedIn);
  }

  /// Set admin status
  static Future<void> setAdminStatus(bool isAdmin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAdmin', isAdmin);
  }

  /// Set user email
  static Future<void> setUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', email);
  }

  /// Logout user (clear all auth data)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('authToken', false);
    await prefs.setBool('isAdmin', false);
    await prefs.remove('userEmail');
    await prefs.remove('remember');
    await prefs.remove('email');
    await prefs.remove('password');
  }

  /// Initialize user session after login
  static Future<void> initializeUserSession({
    required String email,
    required bool isAdmin,
  }) async {
    await setLoginStatus(true);
    await setAdminStatus(isAdmin);
    await setUserEmail(email);
  }
}
