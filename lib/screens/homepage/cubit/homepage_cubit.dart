import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/model/product_model.dart';
import 'package:shop/services/store/firestore_service.dart';
import 'homepage_state.dart';

class HomepageCubit extends Cubit<HomepageState> {
  HomepageCubit() : super(HomepageInitial());
  FirestoreService firestoreService = FirestoreService();

  Future<void> loadUserData() async {
    emit(HomepageLoading());
    // Load user data from SharedPreferences
    // final prefs = await SharedPreferences.getInstance();
  }

  Future<void> fetchProductsFromFirebase() async {
    emit(HomepageLoading());

    try {
      final products = await firestoreService.getProducts();
      emit(HomepageSuccess(products.toList()));
    } catch (e) {
      emit(HomepageFailure(e.toString()));
    }
  }

  // void selectCategory(int index, List<Map<String, dynamic>> categoryData) {
  //   String? selectedCategory = index > 0
  //       ? categoryData[index]["category"]
  //       : null;

  //   final filtered = state.products.where((item) {
  //     return selectedCategory == null || item.category == selectedCategory;
  //   }).toList();

  //   emit(state.copyWith(selectedIndex: index, filteredItems: filtered));
  // }
}
