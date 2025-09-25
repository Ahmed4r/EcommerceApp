import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop/screens/admin/admin_dashboard.dart';
import 'package:shop/screens/login/login.dart';
import 'package:shop/services/user_service.dart';
import 'package:shop/widgets/navigationbar.dart';

class AuthGate extends StatelessWidget {
  static const String routeName = '/auth_gate';
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Handle errors in auth stream
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 50, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Authentication Error'),
                  const SizedBox(height: 8),
                  Text('${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Try to restart auth check
                      Navigator.pushReplacementNamed(
                        context,
                        LoginPage.routeName,
                      );
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in - check role and navigate accordingly
          return FutureBuilder<String?>(
            future: UserService.getUserRole(snapshot.data!.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (roleSnapshot.hasError || !roleSnapshot.hasData) {
                // If role check fails, default to regular navigation
                return const Navigationbar();
              }

              // Navigate based on role
              if (roleSnapshot.data == 'admin') {
                return const AdminPage();
              } else {
                return const Navigationbar();
              }
            },
          );
        } else {
          // User is not logged in
          return const LoginPage();
        }
      },
    );
  }
}
