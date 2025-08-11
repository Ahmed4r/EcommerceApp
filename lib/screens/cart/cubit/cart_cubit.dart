// // cart_cubit.dart
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shop/model/product.dart';
// import 'package:shop/screens/cart/cubit/cart_state.dart';
// import 'package:shop/screens/homepage/homepage.dart';

// class CartCubit extends Cubit<CartState> {
//   CartCubit() : super(const CartState());

//   void addToCart(Product product) {
//     final currentItems = List<CartItem>.from(state.items);
    
//     int existingIndex = currentItems.indexWhere(
//       (item) => item.product.id == product.id,
//     );

//     if (existingIndex >= 0) {
//       currentItems[existingIndex] = currentItems[existingIndex].copyWith(
//         quantity: currentItems[existingIndex].quantity + 1,
//       );
//     } else {
//       currentItems.add(CartItem(product: product, quantity: 1));
//     }

//     emit(state.copyWith(items: currentItems));
//   }

//   void removeFromCart(String productId) {
//     final updatedItems = state.items
//         .where((item) => item.product.id != productId)
//         .toList();
    
//     emit(state.copyWith(items: updatedItems));
//   }

//   void updateQuantity(String productId, int quantity) {
//     if (quantity <= 0) {
//       removeFromCart(productId);
//       return;
//     }

//     final updatedItems = state.items.map((item) {
//       if (item.product.id == productId) {
//         return item.copyWith(quantity: quantity);
//       }
//       return item;
//     }).toList();

//     emit(state.copyWith(items: updatedItems));
//   }

//   void clearCart() {
//     emit(const CartState());
//   }
// }