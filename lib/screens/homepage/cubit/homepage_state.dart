import 'package:shop/model/product_model.dart';

abstract class HomepageState {}
class HomepageInitial extends HomepageState {}
class HomepageLoading extends HomepageState {}
class HomepageSuccess extends HomepageState {
  final List<Product> products;
  HomepageSuccess(this.products);
}
class HomepageFailure extends HomepageState {
  final String error;
  HomepageFailure(this.error);
}