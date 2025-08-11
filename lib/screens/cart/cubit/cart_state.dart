// // cart_state.dart
// import 'package:equatable/equatable.dart';
// import 'package:shop/screens/homepage/homepage.dart';

// class CartState extends Equatable {
//   final List<CartItem> items;
//   final bool isLoading;

//   const CartState({this.items = const [], this.isLoading = false});

//   CartState copyWith({List<CartItem>? items, bool? isLoading}) {
//     return CartState(
//       items: items ?? this.items,
//       isLoading: isLoading ?? this.isLoading,
//     );
//   }

//   int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

//   double get totalPrice =>
//       items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));

//   @override
//   List<Object> get props => [items, isLoading];
// }
