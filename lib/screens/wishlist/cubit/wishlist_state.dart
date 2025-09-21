// wishlist_state.dart
import 'package:equatable/equatable.dart';
import 'package:shop/model/product_model.dart';

abstract class WishlistState extends Equatable {
  final List<Product> favorites;
  const WishlistState({this.favorites = const []});

  @override
  List<Object?> get props => [favorites];
}

class WishlistInitial extends WishlistState {
  const WishlistInitial() : super(favorites: const []);
}

class WishlistLoadingState extends WishlistState {
  const WishlistLoadingState({List<Product> favorites = const []})
    : super(favorites: favorites);
}

class WishlistSuccessState extends WishlistState {
  const WishlistSuccessState(List<Product> favorites)
    : super(favorites: favorites);
}

class WishlistErrorState extends WishlistState {
  final String message;
  const WishlistErrorState(this.message, {List<Product> favorites = const []})
    : super(favorites: favorites);

  @override
  List<Object?> get props => [message, favorites];
}
