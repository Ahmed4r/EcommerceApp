import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/model/product.dart';
import 'homepage_state.dart';

class HomepageCubit extends Cubit<HomepageState> {
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

  void loadProducts(List<Product> products) {
    emit(state.copyWith(products: products, filteredItems: products));
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
