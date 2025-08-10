import 'package:equatable/equatable.dart';
import 'package:shop/model/product.dart';

class WishlistState extends Equatable {
  final List<Product> favorites;

  const WishlistState({this.favorites = const []});

  @override
  List<Object> get props => [favorites];
}
