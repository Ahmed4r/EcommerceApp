import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop/model/product_model.dart';
import 'package:shop/services/auth/auth_service.dart';

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

  // getData
  Future<List<Product>> getProducts() async {
    try {
      final QuerySnapshot snapshot = await productsCollection.get();
      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log(e.toString());
      return [];
    }
  }
}
