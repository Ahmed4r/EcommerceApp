import 'package:equatable/equatable.dart';
import 'package:shop/model/product.dart';

class ProfileState extends Equatable {
  final String name;
  final String email;
  final String phone;
  final String location;
  final String wishlistCount;

  const ProfileState({
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.wishlistCount,
  });

  @override
  List<Object> get props => [name, email, phone, location, wishlistCount];
}
