import 'package:bloc/bloc.dart';
import 'package:shop/model/product.dart';
import 'package:shop/screens/profile/cubit/profile_state.dart';
import 'package:shop/screens/wishlist/cubit/wishlist_cubit.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit()
    : super(
        ProfileState(
          email: '',
          name: '',
          phone: '',
          location: '',
          wishlistCount: '',
        ),
      );

  void updateUserData() {}
}
