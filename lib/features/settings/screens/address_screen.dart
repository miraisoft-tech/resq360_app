import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/customer/authentication/data/bloc/customer_auth_bloc.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/customer_user_model.dart'
    as customer;
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/settings/data/bloc/update_profile_bloc.dart/profile_update_bloc.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();

  bool _isLoadingLocation = false;
  double? _latitude;
  double? _longitude;
  List<customer.Location> _savedLocations = [];
  String? _userType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeUserData();
    });
  }

  Future<void> _initializeUserData() async {
    final userType = await AuthLocalRepo.instance.getUserType();
    if (mounted) {
      setState(() {
        _userType = userType;
      });
    }

    if (userType == 'user') {
      final state = context.read<CustomerAuthBloc>().state;
      if (state is CustomerProfileLoaded) {
        setState(() {
          _savedLocations = state.user.location ?? [];
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await geo.Geolocator.openLocationSettings();
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
          });
        }
        return;
      }

      var permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
      }

      if (permission == geo.LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
          });
          unawaited(
            showErrorSnackbar(
              context,
              'Location permissions are permanently denied',
            ),
          );
        }
        return;
      }

      if (permission != geo.LocationPermission.always &&
          permission != geo.LocationPermission.whileInUse) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
          });
        }
        return;
      }

      final position = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _addressController.text =
              '${place.street ?? ''}, ${place.subLocality ?? ''}'.trim();
          _cityController.text = place.locality ?? '';
          _stateController.text = place.administrativeArea ?? '';
          _zipCodeController.text = place.postalCode ?? '';
          _isLoadingLocation = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
        unawaited(showErrorSnackbar(context, 'Failed to get location: $e'));
      }
    }
  }

  Future<void> _saveAddress() async {
    if (_addressController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _stateController.text.isEmpty ||
        _zipCodeController.text.isEmpty) {
      unawaited(showErrorSnackbar(context, 'Please fill all fields'));
      return;
    }

    if (_latitude == null || _longitude == null) {
      unawaited(
        showErrorSnackbar(context, 'Please get current location first'),
      );
      return;
    }

    if (_userType == 'user') {
      context.read<ProfileUpdateBloc>().add(
        UpdateCustomerAddress(
          state: _stateController.text,
          city: _cityController.text,
          zipCode: _zipCodeController.text,
          address: _addressController.text,
          longitude: _longitude!,
          latitude: _latitude!,
        ),
      );
    } else if (_userType == UserType.provider.name) {
      final addressData = {
        'location': {
          'state': _stateController.text,
          'city': _cityController.text,
          'zipCode': _zipCodeController.text,
          'address': _addressController.text,
          'longitude': _longitude!,
          'latitude': _latitude!,
        },
      };
      context.read<ProfileUpdateBloc>().add(
        UpdateProviderAddress(addressData: addressData),
      );
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return BlocListener<ProfileUpdateBloc, ProfileUpdateState>(
      listener: (context, state) async {
        if (state is ProfileUpdateSuccess) {
          await showSuccessSnackbar(context, 'Address saved successfully');
          if (_userType == 'user') {
            context.read<CustomerAuthBloc>().add(
              const CustomergetUserProfile(),
            );
          }
          if (mounted) {
            await pop(context);
          }
        }
        if (state is ProfileUpdateError) {
          unawaited(showErrorSnackbar(context, state.message));
        }
      },
      child: Scaffold(
        backgroundColor: appColors.whiteColor,
        appBar: AppBar(
          title: UrbText(
            'Add Address',
            size: 22,
            weight: FontWeight.w700,
            color: appColors.black,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: appColors.black),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          elevation: 0,
          forceMaterialTransparency: true,
          backgroundColor: appColors.whiteColor,
          foregroundColor: appColors.black,
        ),
        body: SafeArea(
          child: Padding(
            padding: pad(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_savedLocations.isNotEmpty) ...[
                          UrbText(
                            'Saved Locations',
                            size: 16,
                            weight: FontWeight.w600,
                            color: appColors.black,
                          ),
                          10.verticalSpace,
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _savedLocations.length,
                            separatorBuilder:
                                (context, index) => 10.verticalSpace,
                            itemBuilder: (context, index) {
                              final location = _savedLocations[index];
                              return Container(
                                padding: pad(both: 12),
                                decoration: BoxDecoration(
                                  color: appColors.neutral.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: appColors.neutral.shade200,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    UrbText(
                                      location.address ?? '',
                                      weight: FontWeight.w500,
                                      color: appColors.black,
                                    ),
                                    5.verticalSpace,
                                    UrbText(
                                      '${location.city ?? ''}, ${location.state ?? ''}',
                                      size: 12,
                                      color: appColors.textColor.shade400,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          20.verticalSpace,
                        ],
                        UrbText(
                          'Add New Location',
                          size: 16,
                          weight: FontWeight.w600,
                          color: appColors.black,
                        ),
                        20.verticalSpace,
                        KFormField(
                          label: 'Address',
                          controller: _addressController,
                          hintText: 'Enter your address',
                          onChanged: (value) {},
                        ),
                        20.verticalSpace,
                        Row(
                          children: [
                            Expanded(
                              child: KFormField(
                                label: 'City',
                                controller: _cityController,
                                hintText: 'City',
                                onChanged: (value) {},
                              ),
                            ),
                            10.horizontalSpace,
                            Expanded(
                              child: KFormField(
                                label: 'State',
                                controller: _stateController,
                                hintText: 'State',
                                onChanged: (value) {},
                              ),
                            ),
                          ],
                        ),
                        20.verticalSpace,
                        KFormField(
                          label: 'Zip Code',
                          controller: _zipCodeController,
                          hintText: 'Enter zip code',
                          keyboardType: TextInputType.number,
                          onChanged: (value) {},
                        ),
                        20.verticalSpace,
                        GestureDetector(
                          onTap:
                              _isLoadingLocation ? null : _getCurrentLocation,
                          child: Container(
                            padding: pad(vertical: 12),
                            decoration: BoxDecoration(
                              color: appColors.primary.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: appColors.primary.shade500,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isLoadingLocation)
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: appColors.primary.shade500,
                                    ),
                                  )
                                else
                                  Icon(
                                    Icons.my_location,
                                    color: appColors.primary.shade500,
                                    size: 20,
                                  ),
                                10.horizontalSpace,
                                UrbText(
                                  _isLoadingLocation
                                      ? 'Getting location...'
                                      : 'Use Current Location',
                                  weight: FontWeight.w600,
                                  color: appColors.primary.shade500,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                20.verticalSpace,
                BlocBuilder<ProfileUpdateBloc, ProfileUpdateState>(
                  builder: (context, state) {
                    return WideButton(
                      label: 'Save Address',
                      onPressed:
                          state is ProfileUpdateLoading ? null : _saveAddress,
                      loading: state is ProfileUpdateLoading,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
