import 'package:bloc/bloc.dart';
import 'package:shop/model/product.dart';
import 'wishlist_state.dart';

class WishlistCubit extends Cubit<WishlistState> {
  WishlistCubit() : super(const WishlistState());

  void toggleFavorite(Product product) {
    final currentList = List<Product>.from(state.favorites);

    if (currentList.contains(product)) {
      currentList.remove(product);
    } else {
      currentList.add(product);
    }

    emit(WishlistState(favorites: currentList));
  }

  bool isFavorite(Product product) {
    return state.favorites.contains(product);
  }
}
