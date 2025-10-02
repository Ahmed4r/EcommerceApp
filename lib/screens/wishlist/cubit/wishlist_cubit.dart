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
    _initializeWishlist();
  }

  Future<void> _initializeWishlist() async {
    try {
      await _migrateOldWishlistFormat();
      await _loadFavorites();
    } catch (e) {
      log('Error initializing wishlist: $e');
      emit(const WishlistSuccessState([]));
    }
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
    try {
      final list = List<Product>.from(state.favorites);
      list.any((p) => p.id == product.id)
          ? list.removeWhere((p) => p.id == product.id)
          : list.add(product);

      emit(WishlistSuccessState(list));

      final prefs = await SharedPreferences.getInstance();

      // Clear any existing invalid data first
      final existingData = prefs.get('wishlist');
      if (existingData != null && existingData is! List<String>) {
        await prefs.remove('wishlist');
      }

      await prefs.setStringList(
        'wishlist',
        list.map((p) => jsonEncode(p.toJson())).toList(),
      );
    } catch (e) {
      log('Error in _toggleFavoriteLocal: $e');
      emit(
        WishlistErrorState(
          'Failed to update local wishlist.',
          favorites: state.favorites,
        ),
      );
    }
  }

  Future<void> _loadFavoritesLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear any invalid/old data format first
      final wishlistData = prefs.get('wishlist');

      // If data exists but is not a List<String>, clear it and start fresh
      if (wishlistData != null && wishlistData is! List<String>) {
        log('Found invalid wishlist data format, clearing...');
        await prefs.remove('wishlist');
        emit(const WishlistSuccessState([]));
        return;
      }

      final saved = prefs.getStringList('wishlist') ?? [];
      final List<Product> list = [];

      for (String item in saved) {
        try {
          // Try to parse as JSON - if it's just an ID string, skip it
          final decoded = jsonDecode(item);
          if (decoded is Map<String, dynamic>) {
            list.add(Product.fromJson(decoded));
          } else {
            log('Skipping invalid wishlist item: $item');
          }
        } catch (e) {
          log('Error parsing wishlist item: $item, error: $e');
          // Skip invalid items
        }
      }

      emit(WishlistSuccessState(list));
    } catch (e) {
      log('Error in _loadFavoritesLocal: $e');
      emit(const WishlistSuccessState([]));
    }
  }

  Future<void> syncLocalToFirebase() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final prefs = await SharedPreferences.getInstance();

      // Check for valid data format
      final wishlistData = prefs.get('wishlist');
      if (wishlistData == null || wishlistData is! List<String>) {
        log('No valid local wishlist data to sync');
        return;
      }

      final saved = prefs.getStringList('wishlist') ?? [];
      if (saved.isEmpty) return;

      final List<Product> localFavs = [];

      // Parse saved items with error handling
      for (String item in saved) {
        try {
          final decoded = jsonDecode(item);
          if (decoded is Map<String, dynamic>) {
            localFavs.add(Product.fromJson(decoded));
          }
        } catch (e) {
          log('Skipping invalid item during sync: $item, error: $e');
        }
      }

      if (localFavs.isEmpty) {
        log('No valid products to sync');
        await prefs.remove('wishlist');
        return;
      }

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

  // Migration method to handle old wishlist data format
  Future<void> _migrateOldWishlistFormat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistData = prefs.get('wishlist');

      // If data exists but is not in the correct format, clear it
      if (wishlistData != null && wishlistData is! List<String>) {
        log(
          'Migrating old wishlist format (type: ${wishlistData.runtimeType})...',
        );
        await prefs.remove('wishlist');

        // If it was a simple list of IDs, we can't recover the full product data
        // So just clear and start fresh
        emit(const WishlistSuccessState([]));
        return;
      }

      // Check if existing string list contains valid JSON
      final stringList = prefs.getStringList('wishlist') ?? [];
      if (stringList.isEmpty) return;

      bool needsMigration = false;

      for (String item in stringList) {
        try {
          final decoded = jsonDecode(item);
          if (decoded is! Map<String, dynamic>) {
            needsMigration = true;
            break;
          }
          // Additional check: ensure it has required Product fields
          if (!decoded.containsKey('id') || !decoded.containsKey('name')) {
            needsMigration = true;
            break;
          }
        } catch (e) {
          log('Invalid JSON in wishlist item: $item');
          needsMigration = true;
          break;
        }
      }

      if (needsMigration) {
        log(
          'Found invalid wishlist items, clearing and migrating to new format...',
        );
        await prefs.remove('wishlist');

        // Try to migrate simple ID list to wishlist_ids if possible
        final simpleIds = <String>[];
        for (String item in stringList) {
          // If it's just a plain string ID (not JSON), move it to wishlist_ids
          if (!item.startsWith('{') && !item.startsWith('[')) {
            simpleIds.add(item);
          }
        }

        if (simpleIds.isNotEmpty) {
          await prefs.setStringList('wishlist_ids', simpleIds);
          log('Migrated ${simpleIds.length} product IDs to wishlist_ids');
        }

        emit(const WishlistSuccessState([]));
      }
    } catch (e) {
      log('Error during wishlist migration: $e');
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('wishlist');
        emit(const WishlistSuccessState([]));
      } catch (clearError) {
        log('Error clearing corrupted wishlist data: $clearError');
        emit(const WishlistSuccessState([]));
      }
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
