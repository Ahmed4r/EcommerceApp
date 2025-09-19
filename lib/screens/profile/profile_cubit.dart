import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../services/auth/auth_service.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  FirebaseAuthService authService = FirebaseAuthService();

  Future<void> loadUserData() async {
    emit(profileLoadingState());
    try {
      // Simulate loading or add actual data loading logic here
      await Future.delayed(Duration(milliseconds: 500));
      emit(profileSuccessState());
    } catch (e) {
      emit(profileFailureState());
    }
  }

  Future<void> signOut() async {
    await authService.signOut();
  }

  String? getUserEmail() {
    return authService.getUserEmail();
  }

  String? getUserName() {
    return authService.getUserName();
  }
}
