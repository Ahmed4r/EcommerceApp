// import 'package:shared_preferences/shared_preferences.dart';

// class AdminService {
//   static const String _isAdminKey = 'isAdmin';
//   static const String _userEmailKey = 'userEmail';

//   /// Check if the current user has admin privileges
//   static Future<bool> isAdmin() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(_isAdminKey) ?? false;
//   }

//   /// Get current user email
//   static Future<String> getCurrentUserEmail() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_userEmailKey) ?? '';
//   }

//   /// Set admin status for current user
//   static Future<void> setAdminStatus(bool isAdmin) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_isAdminKey, isAdmin);
//   }

//   /// Check admin status from multiple sources
//   static Future<bool> checkAdminRole(String email) async {
//     try {
//       // Method 1: Check by predefined admin emails (Primary method)
//       List<String> adminEmails = [
//         'ahmedrady@gmail.com',
//         // Add your admin emails here
//       ];

//       if (adminEmails.contains(email.toLowerCase())) {
//         await setAdminStatus(true);
//         return true;
//       }

//       // Method 2: Check from Supabase auth metadata (if available)
//       try {
//         final supabase = Supabase.instance.client;
//         final user = supabase.auth.currentUser;
//         if (user != null && user.userMetadata?['role'] == 'admin') {
//           await setAdminStatus(true);
//           return true;
//         }
//       } catch (e) {
//         print('Auth metadata check failed: $e');
//         // Continue to next method
//       }

//       // Method 3: Check if products table exists and user can access it (admin privilege test)
//       try {
//         final supabase = Supabase.instance.client;
//         // Try to access products table to see if user has admin-like permissions
//         await supabase.from('products').select('id').limit(1);

//         // If we can access products table successfully, this is a good sign
//         // but we still rely primarily on the email list for admin access
//         print('Products table access successful for $email');
//       } catch (e) {
//         print('Products table access check failed: $e');
//         // This is fine, just means we can't use this method
//       }

//       // Default to false if no admin indicators found
//       await setAdminStatus(false);
//       return false;
//     } catch (e) {
//       print('Error checking admin role: $e');
//       // If there's any error, fall back to email-only checking
//       List<String> adminEmails = ['ahmedrady@gmail.com'];

//       bool isAdminByEmail = adminEmails.contains(email.toLowerCase());
//       await setAdminStatus(isAdminByEmail);
//       return isAdminByEmail;
//     }
//   }

//   /// Simple email-based admin check (no database queries)
//   static Future<bool> checkAdminRoleSimple(String email) async {
//     try {
//       List<String> adminEmails = ['ahmedrady@gmail.com'];

//       bool isAdminByEmail = adminEmails.contains(email.toLowerCase());
//       await setAdminStatus(isAdminByEmail);
//       return isAdminByEmail;
//     } catch (e) {
//       print('Error in simple admin check: $e');
//       await setAdminStatus(false);
//       return false;
//     }
//   }

//   /// Clear admin status (for logout)
//   static Future<void> clearAdminStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_isAdminKey);
//     await prefs.remove(_userEmailKey);
//   }

//   /// Middleware to check admin access before navigating to admin pages
//   static Future<bool> requireAdminAccess() async {
//     bool isAdminUser = await isAdmin();
//     if (!isAdminUser) {
//       throw AdminAccessDeniedException('Admin access required');
//     }
//     return true;
//   }
// }

// /// Custom exception for admin access denial
// class AdminAccessDeniedException implements Exception {
//   final String message;
//   AdminAccessDeniedException(this.message);

//   @override
//   String toString() => 'AdminAccessDeniedException: $message';
// }
