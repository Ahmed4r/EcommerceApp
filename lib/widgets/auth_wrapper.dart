import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/screens/login/login.dart';
import 'package:shop/widgets/navigationbar.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  // Method to clear all local data (without signing out if already signed out)
  Future<void> _clearAllLocalData({bool signOut = true}) async {
    try {
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      log('AuthWrapper: Cleared all SharedPreferences data');

      // Only sign out if explicitly requested and user is signed in
      if (signOut && FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
        log('AuthWrapper: Signed out from Firebase Auth');
      }
    } catch (e) {
      log('AuthWrapper: Error clearing local data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        log('AuthWrapper - ConnectionState: ${snapshot.connectionState}');
        log('AuthWrapper - Has data: ${snapshot.hasData}');
        log('AuthWrapper - User: ${snapshot.data?.email}');

        // Show loading indicator while waiting for auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Check if user is logged in and user exists
        if (snapshot.hasData && snapshot.data != null) {
          // Verify user still exists in Firebase Auth
          snapshot.data!.reload().catchError((error) {
            log(
              'AuthWrapper: User no longer exists in Firebase Auth, clearing local data',
            );
            _clearAllLocalData(signOut: true);
            return null;
          });

          log(
            'AuthWrapper: Navigating to Navigationbar for user: ${snapshot.data!.email}',
          );
          return const Navigationbar();
        } else {
          log('AuthWrapper: Navigating to LoginPage - no user');
          // Clear only SharedPreferences when no user is present (don't sign out again)
          _clearAllLocalData(signOut: false);
          return const LoginPage();
        }
      },
    );
  }
}
