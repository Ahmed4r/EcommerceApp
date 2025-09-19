import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/model/product_model.dart';
import 'package:shop/screens/wishlist/cubit/wishlist_state.dart';

class WishlistCubit extends Cubit<WishlistState> {
  // final supabase = Supabase.instance.client;

  WishlistCubit() : super(const WishlistState()) {
    _loadFavorites();
  }

  Future<void> toggleFavorite(Product product) async {
    try {
      // final userId = supabase.auth.currentUser?.id;
      // if (userId == null) {
      //   // User not logged in, fallback to local storage
      //   await _toggleFavoriteLocal(product);
      //   return;
      // }

      final currentList = List<Product>.from(state.favorites);
      final isCurrentlyFavorite = currentList.any((p) => p.id == product.id);

      if (isCurrentlyFavorite) {
        // Remove from wishlist
        // await supabase
        //     .from('wishlist')
        //     .delete()
        //     .eq('user_id', userId)
        //     .eq('product_id', product.id);

        currentList.removeWhere((p) => p.id == product.id);
      } else {
        // Add to wishlist
        // await supabase.from('wishlist').insert({
        //   'user_id': userId,
        //   'product_id': product.id,
        // });

        currentList.add(product);
      }

      emit(WishlistState(favorites: currentList));
    } catch (e) {
      print('Error toggling favorite: $e');
      // Fallback to local storage if Supabase fails
      await _toggleFavoriteLocal(product);
    }
  }

  bool isFavorite(Product product) {
    return state.favorites.any((p) => p.id == product.id);
  }

  // Public method to reload favorites (useful for refresh)
  Future<void> loadFavorites() async {
    await _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      // final userId = supabase.auth.currentUser?.id;
      // if (userId == null) {
      //   // User not logged in, load from local storage
      //   await _loadFavoritesLocal();
      //   return;
      // }

      // Load wishlist from Supabase with product details
      // final response = await supabase
      //     .from('wishlist')
      //     .select('''
      //       *,
      //       products (
      //         id,
      //         name,
      //         price,
      //         description,
      //         image_url,
      //         category,
      //         created_at
      //       )
      //     ''')
      //     .eq('user_id', userId)
      //     .order('created_at', ascending: false);

      // List<Product> favorites = [];
      // for (var item in response) {
      //   if (item['products'] != null) {
      //     final productData = item['products'];
      //     favorites.add(Product.fromJson(productData));
      //   }
      // }

      // emit(WishlistState(favorites: favorites));
    } catch (e) {
      print('Error loading favorites from Supabase: $e');
      // Fallback to local storage
      await _loadFavoritesLocal();
    }
  }

  // Fallback methods for local storage (when user is not logged in)
  Future<void> _toggleFavoriteLocal(Product product) async {
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

  Future<void> _loadFavoritesLocal() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList('wishlist') ?? [];

    List<Product> loaded = saved
        .map((e) => Product.fromJson(jsonDecode(e)))
        .toList();

    emit(WishlistState(favorites: loaded));
  }

  // Method to sync local wishlist to Supabase when user logs in
  Future<void> syncLocalToSupabase() async {
    try {
      // final userId = supabase.auth.currentUser?.id;
      // if (userId == null) return;

      // Get local favorites
      final prefs = await SharedPreferences.getInstance();
      List<String> saved = prefs.getStringList('wishlist') ?? [];

      if (saved.isNotEmpty) {
        List<Product> localFavorites = saved
            .map((e) => Product.fromJson(jsonDecode(e)))
            .toList();

        // Get existing wishlist from Supabase
        // final existingWishlist = await supabase
        //     .from('wishlist')
        //     .select('product_id')
        //     .eq('user_id', userId);

        // Set<String> existingProductIds = existingWishlist
        //     .map<String>((item) => item['product_id'].toString())
        //     .toSet();

        // Insert local favorites that don't exist in Supabase
        // List<Map<String, dynamic>> toInsert = [];
        // for (var product in localFavorites) {
        //   if (!existingProductIds.contains(product.id)) {
        //     toInsert.add({'user_id': userId, 'product_id': product.id});
        //   }
        // }

        // if (toInsert.isNotEmpty) {
        //   await supabase.from('wishlist').insert(toInsert);
        // }

        // Clear local storage after sync
        await prefs.remove('wishlist');

        // Reload favorites from Supabase
        await _loadFavorites();
      }
    } catch (e) {
      print('Error syncing local wishlist to Supabase: $e');
    }
  }

  // Method to clear wishlist (useful for logout)
  // Future<void> clearWishlist() async {
  //   try {
  //     final userId = supabase.auth.currentUser?.id;
  //     if (userId != null) {
  //       await supabase.from('wishlist').delete().eq('user_id', userId);
  //     }

  //     // Also clear local storage
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.remove('wishlist');

  //     emit(const WishlistState(favorites: []));
  //   } catch (e) {
  //     print('Error clearing wishlist: $e');
  //   }
  // }
}
