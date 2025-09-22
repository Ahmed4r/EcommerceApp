import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkLocationService();
  }

  Future<void> _checkLocationService() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await LocationService.checkLocationService();
      if (mounted) {
        setState(() {
          _locationServiceEnabled = true;
        });
        await _requestLocationPermission();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to check location service: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _requestLocationPermission() async {
    if (!mounted) return;

    try {
      await LocationService.requestLocationPermission();
      if (mounted) {
        setState(() {
          _locationPermissionGranted = true;
          _isLoading = false;
        });

        // Navigate after a short delay
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pushReplacementNamed(context, AddressListScreen.routeName);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to get location permission: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> delayedNavigation() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushNamed(context, AddressListScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'Location Access',
          style: GoogleFonts.cairo(
            color: theme.textTheme.titleLarge?.color,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
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
            if (_isLoading)
              CircularProgressIndicator(color: theme.primaryColor)
            else
              CustomButton(
                title: _locationPermissionGranted
                    ? 'LOCATION IS ENABLED'
                    : 'ACCESS LOCATION',
                onTap: _locationPermissionGranted
                    ? null
                    : _checkLocationService,
                color: theme.primaryColor,
                textColor: theme.colorScheme.onPrimary,
              ),
            SizedBox(height: 20.h),
            if (_errorMessage != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.cairo(
                    color: theme.colorScheme.error,
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  _locationPermissionGranted
                      ? 'LOCATION IS ENABLED FOR THIS APP'
                      : 'This app will access your location\nonly while using the app',
                  style: GoogleFonts.cairo(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
