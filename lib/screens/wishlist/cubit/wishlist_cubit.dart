import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/model/product_model.dart';
import 'package:shop/screens/wishlist/cubit/wishlist_state.dart';

class WishlistCubit extends Cubit<WishlistState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  WishlistCubit() : super(const WishlistState()) {
    _loadFavorites();
  }

  Future<void> toggleFavorite(Product product) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        // User not logged in, fallback to local storage
        await _toggleFavoriteLocal(product);
        return;
      }

      final currentList = List<Product>.from(state.favorites);
      final isCurrentlyFavorite = currentList.any((p) => p.id == product.id);

      if (isCurrentlyFavorite) {
        // Remove from wishlist
        await _firestore
            .collection('wishlist')
            .doc('${userId}_${product.id}')
            .delete();

        currentList.removeWhere((p) => p.id == product.id);
      } else {
        // Add to wishlist
        await _firestore
            .collection('wishlist')
            .doc('${userId}_${product.id}')
            .set({
              'userId': userId,
              'productId': product.id,
              'productData': product.toJson(),
              'createdAt': FieldValue.serverTimestamp(),
            });

        currentList.add(product);
      }

      emit(WishlistState(favorites: currentList));
    } catch (e) {
      log('Error toggling favorite: $e');
      // Fallback to local storage if Firebase fails
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
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        // User not logged in, load from local storage
        await _loadFavoritesLocal();
        return;
      }

      // Load wishlist from Firebase Firestore
      final querySnapshot = await _firestore
          .collection('wishlist')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      List<Product> favorites = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['productData'] != null) {
          try {
            final product = Product.fromJson(data['productData']);
            favorites.add(product);
          } catch (e) {
            log('Error parsing product data: $e');
          }
        }
      }

      emit(WishlistState(favorites: favorites));
    } catch (e) {
      log('Error loading favorites from Firebase: $e');
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

  // Method to sync local wishlist to Firebase when user logs in
  Future<void> syncLocalToFirebase() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Get local favorites
      final prefs = await SharedPreferences.getInstance();
      List<String> saved = prefs.getStringList('wishlist') ?? [];

      if (saved.isNotEmpty) {
        List<Product> localFavorites = saved
            .map((e) => Product.fromJson(jsonDecode(e)))
            .toList();

        // Get existing wishlist from Firebase
        final existingSnapshot = await _firestore
            .collection('wishlist')
            .where('userId', isEqualTo: userId)
            .get();

        Set<String> existingProductIds = existingSnapshot.docs
            .map((doc) => doc.data()['productId'].toString())
            .toSet();

        // Batch write for better performance
        final batch = _firestore.batch();

        // Insert local favorites that don't exist in Firebase
        for (var product in localFavorites) {
          if (!existingProductIds.contains(product.id)) {
            final docRef = _firestore
                .collection('wishlist')
                .doc('${userId}_${product.id}');

            batch.set(docRef, {
              'userId': userId,
              'productId': product.id,
              'productData': product.toJson(),
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        }

        await batch.commit();

        // Clear local storage after sync
        await prefs.remove('wishlist');

        // Reload favorites from Firebase
        await _loadFavorites();
      }
    } catch (e) {
      log('Error syncing local wishlist to Firebase: $e');
    }
  }

  // Method to clear wishlist (useful for logout)
  Future<void> clearWishlist() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        // Get all wishlist documents for the user
        final snapshot = await _firestore
            .collection('wishlist')
            .where('userId', isEqualTo: userId)
            .get();

        // Batch delete for better performance
        final batch = _firestore.batch();
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      // Also clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('wishlist');

      emit(const WishlistState(favorites: []));
    } catch (e) {
      log('Error clearing wishlist: $e');
    }
  }
}
