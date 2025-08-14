import 'package:equatable/equatable.dart';
import 'package:shop/model/product.dart';

class HomepageState extends Equatable {
  final String? name;
  final String? image;
  final int selectedIndex;
  final List<Product> products;
  final List<Product> filteredItems;
  final bool isLoading;

  const HomepageState({
    this.name = '',
    this.image,
    this.selectedIndex = -1,
    this.products = const [],
    this.filteredItems = const [],
    this.isLoading = false,
  });

  HomepageState copyWith({
    String? name,
    String? image,
    int? selectedIndex,
    List<Product>? products,
    List<Product>? filteredItems,
    bool? isLoading,
  }) {
    return HomepageState(
      name: name ?? this.name,
      image: image ?? this.image,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      products: products ?? this.products,
      filteredItems: filteredItems ?? this.filteredItems,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    name,
    image,
    selectedIndex,
    products,
    filteredItems,
    isLoading,
  ];
}
