import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/model/product.dart';
import 'homepage_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomepageCubit extends Cubit<HomepageState> {
  static const String _productsKey = 'cached_products';
  Future<void> loadProductsFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_productsKey);
    if (cached != null) {
      final List<dynamic> jsonList = Product.decodeJsonList(cached);
      final products = jsonList
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
      emit(state.copyWith(products: products, filteredItems: products));
    }
  }

  static const String _nameKey = 'profile_name';
  static const String _imageKey = 'profile_img';

  HomepageCubit() : super(const HomepageState());

  Future<void> loadUserData() async {
    emit(state.copyWith(isLoading: true));
    final prefs = await SharedPreferences.getInstance();
    emit(
      state.copyWith(
        name: prefs.getString(_nameKey) ?? '',
        image: prefs.getString(_imageKey),
        isLoading: false,
      ),
    );
  }

  Future<void> fetchProductsFromSupabase() async {
    emit(state.copyWith(isLoading: true, error: null));
    final supabase = Supabase.instance.client;
    try {
      final data = await supabase.from('products').select().then((value) {
        print('Supabase products response:');
        print(value);
        return value as List<dynamic>;
      });
      final products = data.map((item) {
        print('Product item:');
        print(item);
        return Product.fromJson(item as Map<String, dynamic>);
      }).toList();
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(_productsKey, Product.encodeJsonList(products));
      emit(
        state.copyWith(
          products: products,
          filteredItems: products,
          isLoading: false,
          error: null,
        ),
      );
    } catch (e) {
      log(e.toString());
    }
  }

  void selectCategory(int index, List<Map<String, dynamic>> categoryData) {
    String? selectedCategory = index > 0
        ? categoryData[index]["category"]
        : null;

    final filtered = state.products.where((item) {
      return selectedCategory == null || item.category == selectedCategory;
    }).toList();

    emit(state.copyWith(selectedIndex: index, filteredItems: filtered));
  }
}
