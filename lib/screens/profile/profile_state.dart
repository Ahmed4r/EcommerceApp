part of 'profile_cubit.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

class profileLoadingState extends ProfileState {}

class profileSuccessState extends ProfileState {}

class profileFailureState extends ProfileState {}
