import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:shop/app_colors.dart';
import 'package:shop/screens/location/address_details_Screen.dart';
import 'package:shop/services/location_service.dart';
import 'package:shop/widgets/custom_button.dart';

class LocationAccessPage extends StatefulWidget {
  static const String routeName = '/location-access';

  const LocationAccessPage({super.key});
  @override
  _LocationAccessPageState createState() => _LocationAccessPageState();
}

class _LocationAccessPageState extends State<LocationAccessPage> {
  bool _locationServiceEnabled = false;
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkLocationService();
  }

  Future<void> _checkLocationService() async {
    await LocationService.checkLocationService();
    setState(() {
      _locationServiceEnabled = true;
    });
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    await LocationService.requestLocationPermission();
    setState(() {
      _locationPermissionGranted = true;
    });

    if (true) {
      // انتظار بسيط عشان المستخدم يشوف الرسالة
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pushReplacementNamed(context, AddressListScreen.routeName);
      }
    }
  }

  void initialState() {
    super.initState();
    _checkLocationService();
  }

  Future<void> delayedNavigation() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushNamed(context, AddressListScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'location access',
          style: GoogleFonts.cairo(color: isDark ? Colors.black : Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 100.r,
              backgroundImage: const AssetImage('assets/location.jpg'),
            ),
            SizedBox(height: 30.h),
            CustomButton(
              title: _locationPermissionGranted
                  ? 'LOCATION IS ENABLED'
                  : 'ACCESS LOCATION',
            ),
            SizedBox(height: 20.h),
            Text(
              _locationPermissionGranted
                  ? 'LOCATION IS ENABLED FOR THIS APP'
                  : 'this app will access your location\n only while using the app',
              style: GoogleFonts.cairo(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
