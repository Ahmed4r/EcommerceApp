import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth authService = FirebaseAuth.instance;

  // Configure Google Sign-In
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Force account picker for better compatibility
    forceCodeForRefreshToken: true,
  );

  //sign out
  Future<void> signOut() async {
    try {
      // Sign out from Google first if user signed in with Google
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      // Then sign out from Firebase
      await authService.signOut();
    } catch (e) {
      // Still try to sign out from Firebase even if Google sign out fails
      await authService.signOut();
    }
  }

  //sign in
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  //sign up
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    await authService.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // reset password
  Future<void> sendPasswordResetEmail(String email) async {
    await authService.sendPasswordResetEmail(email: email);
  }

  //get user email
  String? getUserEmail() {
    final user = authService.currentUser;
    if (user != null) {
      return user.email;
    }
    return null;
  }

  String? getUserName() {
    final user = authService.currentUser;
    if (user != null) {
      return user.displayName;
    }
    return null;
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      // Clear any previous Google sign-in session
      await _googleSignIn.signOut();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled by the user.');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Check if we have valid tokens
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Failed to get Google authentication tokens.');
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await authService
          .signInWithCredential(credential);

      // Update display name if not set
      if (userCredential.user != null &&
          userCredential.user!.displayName == null) {
        await userCredential.user!.updateDisplayName(
          googleUser.displayName ?? googleUser.email.split('@')[0],
        );
        await userCredential.user!.reload();
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        throw Exception(
          'Network error. Please check your internet connection.',
        );
      } else if (e.code == 'too-many-requests') {
        throw Exception('Too many sign-in attempts. Please try again later.');
      }
      throw Exception('Firebase Auth Error: ${e.code} - ${e.message}');
    } catch (e) {
      // Handle specific Google Sign-In errors
      final errorMessage = e.toString();
      if (errorMessage.contains('12500') ||
          errorMessage.contains('DEVELOPER_ERROR')) {
        throw Exception(
          'Google Sign-In configuration error. Please check your SHA-1 fingerprint and OAuth client setup.',
        );
      } else if (errorMessage.contains('7') ||
          errorMessage.contains('NETWORK_ERROR')) {
        throw Exception(
          'Network error. Please check your internet connection.',
        );
      }
      throw Exception('Google sign-in failed: $e');
    }
  }

  // Check if Google Sign-In is available
  Future<bool> isGoogleSignInAvailable() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (e) {
      return false;
    }
  }

  // Get current Google user
  GoogleSignInAccount? getCurrentGoogleUser() {
    return _googleSignIn.currentUser;
  }
}
