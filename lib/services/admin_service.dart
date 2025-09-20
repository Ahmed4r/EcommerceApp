import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  static const String _isAdminKey = 'isAdmin';

  // Firebase services
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check if the current user has admin privileges
  static Future<bool> isAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check from Firebase Firestore first
      final adminDoc = await _firestore
          .collection('admins')
          .doc(user.uid)
          .get();

      if (adminDoc.exists) {
        final isFirebaseAdmin = adminDoc.data()?['isAdmin'] ?? false;
        // Cache locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_isAdminKey, isFirebaseAdmin);
        return isFirebaseAdmin;
      }

      // Fallback to predefined admin emails
      return await checkAdminRole(user.email ?? '');
    } catch (e) {
      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isAdminKey) ?? false;
    }
  }

  /// Get current user email
  static Future<String> getCurrentUserEmail() async {
    final user = _auth.currentUser;
    return user?.email ?? '';
  }

  /// Set admin status for current user in Firebase and locally
  static Future<void> setAdminStatus(bool isAdmin) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Save to Firebase
        await _firestore.collection('admins').doc(user.uid).set({
          'isAdmin': isAdmin,
          'email': user.email,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Save locally as cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isAdminKey, isAdmin);
    } catch (e) {
      print('Error setting admin status: $e');
      // Fallback to local storage only
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isAdminKey, isAdmin);
    }
  }

  /// Check admin status from multiple sources
  static Future<bool> checkAdminRole(String email) async {
    try {
      // Method 1: Check by predefined admin emails (Primary method)
      List<String> adminEmails = [
        'ahmedrady@gmail.com',
        'admin@ecommerce.com',
        // Add your admin emails here
      ];

      if (adminEmails.contains(email.toLowerCase())) {
        await setAdminStatus(true);
        return true;
      }

      // Method 2: Check from Firebase Firestore admins collection
      try {
        final user = _auth.currentUser;
        if (user != null) {
          final adminDoc = await _firestore
              .collection('admins')
              .doc(user.uid)
              .get();

          if (adminDoc.exists && adminDoc.data()?['isAdmin'] == true) {
            await setAdminStatus(true);
            return true;
          }
        }
      } catch (e) {
        print('Firebase admin check failed: $e');
      }

      // Default to false if no admin indicators found
      await setAdminStatus(false);
      return false;
    } catch (e) {
      print('Error checking admin role: $e');
      return false;
    }
  }

  /// Simple email-based admin check (no database queries)
  static Future<bool> checkAdminRoleSimple(String email) async {
    try {
      List<String> adminEmails = ['ahmedrady@gmail.com', 'admin@ecommerce.com'];

      bool isAdminByEmail = adminEmails.contains(email.toLowerCase());
      await setAdminStatus(isAdminByEmail);
      return isAdminByEmail;
    } catch (e) {
      print('Error in simple admin check: $e');
      await setAdminStatus(false);
      return false;
    }
  }

  /// Clear admin status (for logout)
  static Future<void> clearAdminStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_isAdminKey);
    } catch (e) {
      print('Error clearing admin status: $e');
    }
  }

  /// Middleware to check admin access before navigating to admin pages
  static Future<bool> requireAdminAccess() async {
    bool isAdminUser = await isAdmin();
    if (!isAdminUser) {
      throw AdminAccessDeniedException('Admin access required');
    }
    return true;
  }
}

/// Custom exception for admin access denial
class AdminAccessDeniedException implements Exception {
  final String message;
  AdminAccessDeniedException(this.message);

  @override
  String toString() => 'AdminAccessDeniedException: $message';
}
