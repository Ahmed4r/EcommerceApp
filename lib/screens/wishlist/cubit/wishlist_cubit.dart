import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/screens/wishlist/cubit/wishlist_state.dart';

import '../../../model/product_model.dart';

class WishlistCubit extends Cubit<WishlistState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  WishlistCubit() : super(const WishlistInitial()) {
    _loadFavorites(); // استدعاء مبدئي واحد
  }

  Future<void> toggleFavorite(Product product) async {
    try {
      final userId = _auth.currentUser?.uid;
      final current = List<Product>.from(state.favorites);

      if (userId == null) {
        await _toggleFavoriteLocal(product);
        return;
      }

      final isFav = current.any((p) => p.id == product.id);

      if (isFav) {
        await _firestore
            .collection('wishlist')
            .doc('${userId}_${product.id}')
            .delete();
        current.removeWhere((p) => p.id == product.id);
      } else {
        await _firestore
            .collection('wishlist')
            .doc('${userId}_${product.id}')
            .set({
              'userId': userId,
              'productId': product.id,
              'productData': product.toJson(),
              'createdAt': FieldValue.serverTimestamp(),
            });
        current.add(product);
      }

      emit(WishlistSuccessState(current));
    } catch (e) {
      log('Error toggling favorite: $e');
      emit(
        WishlistErrorState(
          'Failed to update wishlist.',
          favorites: state.favorites,
        ),
      );
      await _toggleFavoriteLocal(product);
    }
  }

  bool isFavorite(Product product) =>
      state.favorites.any((p) => p.id == product.id);

  Future<void> loadFavorites() => _loadFavorites();

  Future<void> _loadFavorites() async {
    emit(WishlistLoadingState(favorites: state.favorites));
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        await _loadFavoritesLocal();
        return;
      }

      final snap = await _firestore
          .collection('wishlist')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final favs = <Product>[];
      for (var doc in snap.docs) {
        final data = doc.data();
        try {
          favs.add(Product.fromJson(data['productData']));
        } catch (e) {
          log('Error parsing product: $e');
        }
      }

      emit(WishlistSuccessState(favs));
    } catch (e) {
      log('Error loading favorites: $e');
      await _loadFavoritesLocal();
    }
  }

  // --- Local storage ---
  Future<void> _toggleFavoriteLocal(Product product) async {
    final list = List<Product>.from(state.favorites);
    list.any((p) => p.id == product.id)
        ? list.removeWhere((p) => p.id == product.id)
        : list.add(product);

    emit(WishlistSuccessState(list));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'wishlist',
      list.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }

  Future<void> _loadFavoritesLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('wishlist') ?? [];
    final list = saved.map((e) => Product.fromJson(jsonDecode(e))).toList();
    emit(WishlistSuccessState(list));
  }

  Future<void> syncLocalToFirebase() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('wishlist') ?? [];

      if (saved.isEmpty) return;

      final localFavs = saved
          .map((e) => Product.fromJson(jsonDecode(e)))
          .toList();

      final existing = await _firestore
          .collection('wishlist')
          .where('userId', isEqualTo: userId)
          .get();

      final ids = existing.docs.map((d) => d['productId'].toString()).toSet();

      final batch = _firestore.batch();
      for (var p in localFavs) {
        if (!ids.contains(p.id)) {
          final ref = _firestore.doc('wishlist/${userId}_${p.id}');
          batch.set(ref, {
            'userId': userId,
            'productId': p.id,
            'productData': p.toJson(),
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      await batch.commit();
      await prefs.remove('wishlist');
      await _loadFavorites();
    } catch (e) {
      log('Error syncing local wishlist: $e');
    }
  }

  Future<void> clearWishlist() async {
    emit(WishlistLoadingState(favorites: state.favorites));
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        final snap = await _firestore
            .collection('wishlist')
            .where('userId', isEqualTo: userId)
            .get();
        final batch = _firestore.batch();
        for (var d in snap.docs) {
          batch.delete(d.reference);
        }
        await batch.commit();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('wishlist');
      emit(const WishlistSuccessState([]));
    } catch (e) {
      log('Error clearing wishlist: $e');
      emit(
        WishlistErrorState(
          'Failed to clear wishlist.',
          favorites: state.favorites,
        ),
      );
    }
  }
}
