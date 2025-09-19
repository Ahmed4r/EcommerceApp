// lib/model/user_model.dart
//
// Simple immutable user model with JSON (de)serialization, copyWith and
// value semantics.

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isAdmin;

  const UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isAdmin = false,
  });

  factory UserModel.fromFirebaseUser(User? u) {
    return UserModel(
      uid: u?.uid ?? '',
      email: u?.email,
      displayName: u?.displayName,
      photoUrl: u?.photoURL,
      isAdmin: false,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      isAdmin: json['isAdmin'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'isAdmin': isAdmin,
  };
}
