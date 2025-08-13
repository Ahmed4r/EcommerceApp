import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/model/product.dart';
import 'package:shop/screens/wishlist/cubit/wishlist_state.dart';

class WishlistCubit extends Cubit<WishlistState> {
  WishlistCubit() : super(const WishlistState()) {
    _loadFavorites();
  }

  void toggleFavorite(Product product) async {
    final currentList = List<Product>.from(state.favorites);

    if (currentList.any((p) => p.id == product.id)) {
      currentList.removeWhere((p) => p.id == product.id);
    } else {
      currentList.add(product);
    }

    emit(WishlistState(favorites: currentList));

    // Save products locally as JSON
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList = currentList
        .map((p) => jsonEncode(p.toJson()))
        .toList();
    await prefs.setStringList('wishlist', jsonList);
  }

  bool isFavorite(Product product) {
    return state.favorites.any((p) => p.id == product.id);
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList('wishlist') ?? [];

    List<Product> loaded = saved
        .map((e) => Product.fromJson(jsonDecode(e)))
        .toList();

    emit(WishlistState(favorites: loaded));
  }
}
