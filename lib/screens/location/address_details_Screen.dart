import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shop/app_colors.dart';
import 'package:shop/model/address_model.dart';
import 'package:shop/services/location_service.dart';

class AddressListScreen extends StatefulWidget {
  static String routeName = 'address_list';

  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  List<AddressModel> addresses = [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? addressJsonList = prefs.getStringList('addresses');
    if (addressJsonList != null) {
      setState(() {
        addresses = addressJsonList
            .map(
              (jsonStr) => AddressModel.fromJson(
                Map<String, dynamic>.from(jsonDecode(jsonStr) as Map),
              ),
            )
            .toList();
      });
    }
  }

  Future<void> _saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> addressJsonList = addresses
        .map((a) => jsonEncode(a.toJson()))
        .toList();
    await prefs.setStringList('addresses', addressJsonList);
  }

  Future<void> _addNewAddress() async {
    final AddressModel? newAddress = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddressDetailsScreen()),
    );
    if (newAddress != null) {
      setState(() {
        addresses.add(newAddress);
      });
      await _saveAddresses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffEDF1F4),
      appBar: AppBar(
        backgroundColor: Color(0xffEDF1F4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Address',
          style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: address.iconColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        address.icon,
                        color: address.iconColor,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      address.label ?? 'no label found',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        address.address ?? "no address found",
                        style: GoogleFonts.cairo(fontSize: 16, height: 1.3),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              addresses.removeAt(index);
                            });
                            _saveAddresses();
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      // You can implement view/edit on tap if needed
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _addNewAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'ADD NEW ADDRESS',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddressDetailsScreen extends StatefulWidget {
  final AddressModel? address;

  const AddressDetailsScreen({super.key, this.address});

  @override
  _AddressDetailsScreenState createState() => _AddressDetailsScreenState();
}

class _AddressDetailsScreenState extends State<AddressDetailsScreen> {
  final MapController mapController = MapController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController postCodeController = TextEditingController();
  final TextEditingController apartmentController = TextEditingController();

  String selectedLabel = 'Home';
  final List<String> labels = ['Home', 'Work', 'Other'];

  List<Marker> markers = [];
  String currentAddress = 'Loading address...';
  bool isLoadingLocation = false;
  LatLng selectedLocation = LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _setCurrentLocation();
    if (widget.address != null) {
      streetController.text = 'Hason Nagar';
      postCodeController.text = '34567';
      apartmentController.text = '345';
      selectedLabel = widget.address!.label == 'HOME'
          ? 'Home'
          : widget.address!.label == 'WORK'
          ? 'Work'
          : 'Other';
    }

    _initializeLocation();
  }

  Future<void> _setCurrentLocation() async {
    Position? position = await LocationService.getCurrentLocation(context);
    if (position != null) {
      setState(() {
        selectedLocation = LatLng(position.latitude, position.longitude);
      });
    }
    currentAddress = await LocationService.getAddressFromCoordinates(
      selectedLocation.latitude,
      selectedLocation.longitude,
    );
  }

  Future<void> _initializeLocation() async {
    await _getCurrentLocation();
    _updateMarker(selectedLocation);
    _updateAddress(selectedLocation);
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      Position? position = await LocationService.getCurrentLocation(context);
      if (position != null) {
        setState(() {
          selectedLocation = LatLng(position.latitude, position.longitude);
        });

        mapController.move(selectedLocation, 15.0);
        _updateMarker(selectedLocation);
        _updateAddress(selectedLocation);
      }
    } catch (e) {
      print('Error getting current location: $e');
      _updateAddress(selectedLocation);
    } finally {
      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  void _updateMarker(LatLng location) {
    setState(() {
      markers = [
        Marker(
          point: location,
          child: const FaIcon(
            FontAwesomeIcons.locationDot,
            color: Colors.red,
            size: 40,
          ),
        ),
      ];
    });
  }

  Future<void> _updateAddress(LatLng location) async {
    try {
      String address = await LocationService.getAddressFromCoordinates(
        location.latitude,
        location.longitude,
      );
      setState(() {
        currentAddress = address;
      });

      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        if (place.street != null && place.street!.isNotEmpty) {
          streetController.text = place.street!;
        }
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          postCodeController.text = place.postalCode!;
        }
      }
    } catch (e) {
      setState(() {
        currentAddress = 'Address not available';
      });
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng location) async {
    setState(() {
      selectedLocation = location;
    });
    _updateMarker(location);
    _updateAddress(location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      // resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: selectedLocation,
                    initialZoom: 15.0,
                    onTap: _onMapTap,
                    minZoom: 3.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.address_manager',
                      maxNativeZoom: 19,
                      maxZoom: 19,
                      additionalOptions: const {'id': 'openstreetmap'},
                    ),
                    MarkerLayer(markers: markers),
                  ],
                ),
                if (isLoadingLocation)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                Positioned(
                  top: 50,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 16,
                  child: Container(
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: IconButton(
                      icon: const FaIcon(
                        FontAwesomeIcons.locationArrow,
                        color: Colors.black,
                      ),
                      onPressed: _getCurrentLocation,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Form Section
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'APARTMENT',
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: apartmentController,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Enter apartment number',
                        hintStyle: GoogleFonts.cairo(fontSize: 14.sp),
                      ),
                      style: GoogleFonts.cairo(fontSize: 14.sp),
                    ),
                  ),
                  Text(
                    'ADDRESS',
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  //  SizedBox(height: 8.h),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, size: 20.r),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            currentAddress,
                            style: GoogleFonts.cairo(fontSize: 14.sp),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'STREET',
                              style: GoogleFonts.cairo(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                controller: streetController,
                                decoration: InputDecoration.collapsed(
                                  hintText: 'Enter street name',
                                  hintStyle: GoogleFonts.cairo(
                                    color: Colors.grey[500],
                                  ),
                                ),
                                style: GoogleFonts.cairo(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.h),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'POST CODE',
                              style: GoogleFonts.cairo(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: TextField(
                                controller: postCodeController,
                                decoration: InputDecoration.collapsed(
                                  hintText: 'Enter post code',
                                  hintStyle: GoogleFonts.cairo(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                style: GoogleFonts.cairo(fontSize: 14.sp),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // SizedBox(height: 24.h),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 600) {
                        return Row(
                          children: labels.map((label) {
                            final isSelected = selectedLabel == label;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedLabel = label;
                                  });
                                },
                                child: Container(
                                  // width: 12,
                                  // height: 15,
                                  margin: EdgeInsets.only(
                                    right: label != labels.last ? 8 : 0,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Text(
                                          label,
                                          style: GoogleFonts.cairo(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      } else {
                        return Column(
                          children: [
                            Text(
                              'LABEL AS',
                              style: GoogleFonts.cairo(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: labels.map((label) {
                                final isSelected = selectedLabel == label;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedLabel = label;
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        right: label != labels.last ? 8 : 0,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Center(
                                        child: Text(
                                          label,
                                          style: GoogleFonts.cairo(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      }
                    },
                  ),

                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          AddressModel(
                            label: selectedLabel.toUpperCase(),
                            address: currentAddress,
                            iconName: selectedLabel == 'Home'
                                ? 'home'
                                : selectedLabel == 'Work'
                                ? 'work'
                                : 'location_on',
                            iconColor: selectedLabel == 'Home'
                                ? Colors.blue
                                : selectedLabel == 'Work'
                                ? Colors.purple
                                : Colors.red,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'SAVE LOCATION',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
