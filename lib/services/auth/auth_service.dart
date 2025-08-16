import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shop/services/admin_service.dart';

class AuthService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  //sign out
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();

    // Clear admin status on logout
    await AdminService.clearAdminStatus();
  }

  //sign in
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  //sign up
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    await _supabaseClient.auth.signUp(email: email, password: password);
  }

  //get user email
  String? getUserEmail() {
    final session = _supabaseClient.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
}
