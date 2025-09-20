part of 'profile_cubit.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

class profileLoadingState extends ProfileState {}

class profileSuccessState extends ProfileState {
  final String name;
  final String email;
  final String phone;

  profileSuccessState({
    required this.name,
    required this.email,
    required this.phone,
  });
}

class profileFailureState extends ProfileState {}
