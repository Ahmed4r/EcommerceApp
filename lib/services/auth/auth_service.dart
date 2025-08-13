import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  //sign out
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
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
