import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<void> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      return Future.error('Location permissions are denied');
    }
  }

  static Future<void> checkLocationService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    } else {
      requestLocationPermission();
    }
  }

  static Future<Position?> getCurrentLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return null;
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permissions are permanently denied.'),
        ),
      );
      return null;
    }

    // Get current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  static Future<String> getAddressFromCoordinates(
    double lat,
    double lng,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isEmpty) return 'Address not available';

      final place = placemarks.first;

      final addressParts = <String>[
        if ((place.name ?? '').isNotEmpty) place.name!,
        if ((place.street ?? '').isNotEmpty && place.street != place.name)
          place.street!,
        if ((place.subLocality ?? '').isNotEmpty) place.subLocality!,
        if ((place.locality ?? '').isNotEmpty) place.locality!,
        if ((place.administrativeArea ?? '').isNotEmpty)
          place.administrativeArea!,
        if ((place.postalCode ?? '').isNotEmpty) place.postalCode!,
      ];

      return addressParts.join(', ');
    } catch (e, stack) {
      debugPrint('❌ Error in getAddressFromCoordinates: $e\n$stack');
      return 'Address not found';
    }
  }
}
