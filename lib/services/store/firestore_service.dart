import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/model/product_model.dart';

class FirestoreService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late final CollectionReference productsCollection;
  late final CollectionReference usersCollection;

  FirestoreService() {
    productsCollection = firestore.collection('products');
    usersCollection = firestore.collection('users');
  }
  // add users
  Future<void> addUser(Map<String, dynamic> userData) async {
    try {
      await usersCollection.doc(userData['uid']).set(userData);
    } catch (e) {
      log(e.toString());
    }
  }

  // update user
  Future<void> updateUser(String uid, Map<String, dynamic> userData) async {
    try {
      await usersCollection.doc(uid).update(userData);

      // Save phone to SharedPreferences if it's being updated
      if (userData.containsKey('phone')) {
        await _savePhoneToSharedPrefs(userData['phone'] ?? '');
      }
    } catch (e) {
      log('Error updating user: ${e.toString()}');
    }
  }

  Future<String> getUserPhone() async {
    try {
      // Get current user's UID
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        log('No authenticated user found');
        return await _getPhoneFromSharedPrefs();
      }

      // Get user document using the current user's UID
      final userDoc = await usersCollection.doc(currentUser.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final phone = data['phone'] ?? '';

        // Save to SharedPreferences for offline access
        if (phone.isNotEmpty) {
          await _savePhoneToSharedPrefs(phone);
        }

        return phone;
      } else {
        log('User document does not exist in Firestore');
        return await _getPhoneFromSharedPrefs();
      }
    } catch (e) {
      log('Error getting user phone: ${e.toString()}');
      return await _getPhoneFromSharedPrefs();
    }
  }

  // Helper method to get phone from SharedPreferences as fallback
  Future<String> _getPhoneFromSharedPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('phone') ?? '';
    } catch (e) {
      log('Error getting phone from SharedPreferences: ${e.toString()}');
      return '';
    }
  }

  // Helper method to save phone to SharedPreferences
  Future<void> _savePhoneToSharedPrefs(String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('phone', phone);
    } catch (e) {
      log('Error saving phone to SharedPreferences: ${e.toString()}');
    }
  }

  // getData
  Future<List<Product>> getProducts() async {
    try {
      final QuerySnapshot snapshot = await productsCollection.get().timeout(
        const Duration(seconds: 10),
      ); // Add timeout

      if (snapshot.docs.isEmpty) {
        log('No products found in Firestore');
        return [];
      }

      return snapshot.docs
          .map((doc) {
            try {
              return Product.fromJson(doc.data() as Map<String, dynamic>);
            } catch (e) {
              log('Error parsing product ${doc.id}: $e');
              return null;
            }
          })
          .where((product) => product != null)
          .cast<Product>()
          .toList();
    } catch (e) {
      log('Error fetching products: $e');
      return [];
    }
  }
}
