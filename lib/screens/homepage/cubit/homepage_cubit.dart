import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/services/store/firestore_service.dart';
import 'homepage_state.dart';

class HomepageCubit extends Cubit<HomepageState> {
  HomepageCubit() : super(HomepageInitial());
  FirestoreService firestoreService = FirestoreService();
  String? userName;

  Future<void> loadUserData() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      userName = pref.getString('name');
      // You can emit a state with user data if needed
      // emit(UserDataLoaded(name));
    } catch (e) {
      // Handle error silently for now
      userName = null;
    }
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
