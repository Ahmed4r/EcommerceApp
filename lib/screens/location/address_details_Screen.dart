import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
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

  @override
  void dispose() {
    super.dispose();
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Addresses',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: addresses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off,
                          size: 64,
                          color: theme.disabledColor,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No addresses saved yet',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add your first address to get started',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      final address = addresses[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.dividerColor.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
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
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            address.label ?? 'No label found',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.titleMedium?.color,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              address.address ?? "No address found",
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                height: 1.3,
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(0.8),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: theme.colorScheme.error,
                              size: 24,
                            ),
                            onPressed: () {
                              _showDeleteConfirmation(context, index);
                            },
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
                  backgroundColor: theme.primaryColor,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_location_alt, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'ADD NEW ADDRESS',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.dialogBackgroundColor,
          title: Text(
            'Delete Address',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w600,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this address?',
            style: GoogleFonts.cairo(color: theme.textTheme.bodyMedium?.color),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.cairo(
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  addresses.removeAt(index);
                });
                _saveAddresses();
                Navigator.of(context).pop();
              },
              child: Text(
                'Delete',
                style: GoogleFonts.cairo(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
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
  LatLng selectedLocation = const LatLng(
    30.0444,
    31.2357,
  ); // Default to Cairo, Egypt
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    streetController.dispose();
    postCodeController.dispose();
    apartmentController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    if (!mounted) return;

    setState(() {
      isLoadingLocation = true;
    });

    try {
      await _getCurrentLocation();
      _updateMarker(selectedLocation);
      await _updateAddress(selectedLocation);
    } catch (e) {
      debugPrint('Error initializing location: $e');
      if (mounted) {
        _updateMarker(selectedLocation);
        setState(() {
          currentAddress = 'Using default location';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingLocation = false;
          _mapReady = true;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    try {
      Position? position = await LocationService.getCurrentLocation(context);

      if (!mounted) return;

      if (position != null) {
        setState(() {
          selectedLocation = LatLng(position.latitude, position.longitude);
        });

        // Only move map if it's ready and mounted
        if (_mapReady && mounted) {
          try {
            mapController.move(selectedLocation, 15.0);
          } catch (e) {
            debugPrint('Error moving map: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
      // Continue with default location
    }
  }

  void _updateMarker(LatLng location) {
    if (!mounted) return;
    setState(() {
      markers = [
        Marker(
          point: location,
          child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
        ),
      ];
    });
  }

  Future<void> _updateAddress(LatLng location) async {
    if (!mounted) return;

    try {
      String address = await LocationService.getAddressFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (!mounted) return;

      setState(() {
        currentAddress = address;
      });

      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (!mounted) return;

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
      debugPrint('Error updating address: $e');
      if (mounted) {
        setState(() {
          currentAddress = 'Address not available';
        });
      }
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng location) async {
    if (!mounted) return;

    setState(() {
      selectedLocation = location;
    });
    _updateMarker(location);
    await _updateAddress(location);
  }

  void _onMapReady() {
    setState(() {
      _mapReady = true;
    });
    if (_mapReady) {
      try {
        mapController.move(selectedLocation, 15.0);
      } catch (e) {
        debugPrint('Error moving map on ready: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                    onMapReady: _onMapReady,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.address_manager',
                      maxNativeZoom: 19,
                      maxZoom: 19,
                      additionalOptions: const {'id': 'openstreetmap'},
                      errorTileCallback: (tile, error, stackTrace) {
                        debugPrint('Map tile error: $error');
                      },
                    ),
                    MarkerLayer(markers: markers),
                  ],
                ),
                if (isLoadingLocation)
                  Container(
                    color: theme.colorScheme.surface.withOpacity(0.8),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 50,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: theme.iconTheme.color,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.my_location, color: theme.primaryColor),
                      onPressed: _getCurrentLocation,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Form Section
          Flexible(
            child: Container(
              color: theme.scaffoldBackgroundColor,
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
                        color: theme.textTheme.labelLarge?.color,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.dividerColor.withOpacity(0.3),
                        ),
                      ),
                      child: TextField(
                        controller: apartmentController,
                        decoration: InputDecoration.collapsed(
                          hintText: 'Enter apartment number',
                          hintStyle: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            color: theme.hintColor,
                          ),
                        ),
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'ADDRESS',
                      style: GoogleFonts.cairo(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: theme.textTheme.labelLarge?.color,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.dividerColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 20.r,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              currentAddress,
                              style: GoogleFonts.cairo(
                                fontSize: 14.sp,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
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
                                  color: theme.textTheme.labelLarge?.color,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: theme.dividerColor.withOpacity(0.3),
                                  ),
                                ),
                                child: TextField(
                                  controller: streetController,
                                  decoration: InputDecoration.collapsed(
                                    hintText: 'Enter street name',
                                    hintStyle: GoogleFonts.cairo(
                                      color: theme.hintColor,
                                    ),
                                  ),
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    color: theme.textTheme.bodyMedium?.color,
                                  ),
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
                                  color: theme.textTheme.labelLarge?.color,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: theme.dividerColor.withOpacity(0.3),
                                  ),
                                ),
                                child: TextField(
                                  controller: postCodeController,
                                  decoration: InputDecoration.collapsed(
                                    hintText: 'Enter post code',
                                    hintStyle: GoogleFonts.cairo(
                                      color: theme.hintColor,
                                    ),
                                  ),
                                  style: GoogleFonts.cairo(
                                    fontSize: 14.sp,
                                    color: theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    // Label selection
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
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.primaryColor
                                    : theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.primaryColor
                                      : theme.dividerColor.withOpacity(0.3),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  label,
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? theme.colorScheme.onPrimary
                                        : theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
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
                          backgroundColor: theme.primaryColor,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'SAVE LOCATION',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
