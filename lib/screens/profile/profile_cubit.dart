import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/services/store/firestore_service.dart';

import '../../services/auth/auth_service.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());
  final FirebaseAuthService authService = FirebaseAuthService();
  final FirestoreService firestoreService = FirestoreService();

  Future<void> loadUserData() async {
    emit(profileLoadingState());
    try {
      // Get user data from Firebase Auth and Firestore
      final userName = authService.getUserName();
      final userEmail = authService.getUserEmail();
      final userPhone = await firestoreService.getUserPhone();

      print('ProfileCubit - Loading user data:');
      print('Name: $userName');
      print('Email: $userEmail');
      print('Phone: $userPhone');

      // Save to SharedPreferences
      await saveUserDate("name", userName ?? "");
      await saveUserDate("email", userEmail ?? "");
      await saveUserDate("phone", userPhone);

      emit(
        profileSuccessState(
          name: userName ?? 'No Name',
          email: userEmail ?? 'No Email',
          phone: userPhone,
        ),
      );
    } catch (e) {
      print('ProfileCubit - Error loading user data: $e');
      emit(profileFailureState());
    }
  }

  Future<void> updateUserData(Map<String, dynamic> userData) async {
    emit(profileLoadingState());
    try {
      await firestoreService.updateUser(userData['uid'], userData);
      // Reload user data after update
      await loadUserData();
    } catch (e) {
      emit(profileFailureState());
    }
  }

  Future<void> signOut() async {
    await authService.signOut();
  }

  // Keep these methods for backward compatibility, but they're now synchronous
  String? getUserEmail() {
    return authService.getUserEmail();
  }

  String? getUserName() {
    return authService.getUserName();
  }

  Future<void> saveUserDate(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
}
