import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_place/google_place.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/kyc_bloc/kyc_bloc.dart';
import 'package:resq360/core/models/verification_source.enum.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/customer_user_model.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/main_layout.dart';
import 'package:resq360/features/provider/authentication/data/models/state_model.dart';
import 'package:resq360/features/widgets/dialogs/step.modal.dart';
import 'package:resq360/features/widgets/dialogs/step_indicator.dart';

class StepAddressScreen extends StatefulWidget {
  const StepAddressScreen({required this.source, super.key});
  final VerificationSource source;
  @override
  State<StepAddressScreen> createState() => _StepAddressScreenState();
}

class _StepAddressScreenState extends State<StepAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<String?> _selectState = ValueNotifier(null);

  final TextEditingController _streetCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();

  CustomerUserModel? userInfo;
  bool isLoadingLocation = false;
  bool _usedCurrentLocation = false;
  AutocompletePrediction? _selectedPlace;

  bool get isFormValid =>
      _streetCtrl.text.isNotEmpty &&
      _cityCtrl.text.isNotEmpty &&
      _selectState.value != null &&
      (_selectedPlace != null || _usedCurrentLocation);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KycBloc>().add(GetStates());
    });
  }

  Future<void> getCurrentLocation() async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await geo.Geolocator.openLocationSettings();
        if (mounted) {
          setState(() {
            isLoadingLocation = false;
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
            isLoadingLocation = false;
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
            isLoadingLocation = false;
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
        final stateFromLocation = place.administrativeArea ?? '';
        final matchingState = _matchingStateName(stateFromLocation);

        setState(() {
          _streetCtrl.text =
              '${place.street ?? ''}, ${place.subLocality ?? ''}'.trim();
          _cityCtrl.text = place.locality ?? '';
          _selectState.value = matchingState;
          _selectedPlace = null;
          _usedCurrentLocation = true;
          isLoadingLocation = false;
        });

        if (matchingState == null && stateFromLocation.isNotEmpty) {
          unawaited(
            showErrorSnackbar(
              context,
              'State "$stateFromLocation" not found in list. Please select manually.',
            ),
          );
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          isLoadingLocation = false;
        });
        unawaited(showErrorSnackbar(context, 'Failed to get location: $e'));
      }
    }
  }

  void _applyPlaceDetails(DetailsResult place) {
    final stateFromPlace = _addressComponent(place, const [
      'administrative_area_level_1',
    ]);
    final matchingState = _matchingStateName(stateFromPlace);

    setState(() {
      _cityCtrl.text = _addressComponent(place, const [
        'locality',
        'postal_town',
        'administrative_area_level_2',
        'sublocality_level_1',
      ]);
      _selectState.value = matchingState;
      _usedCurrentLocation = false;
    });

    if (matchingState == null && stateFromPlace.isNotEmpty) {
      unawaited(
        showErrorSnackbar(
          context,
          'State "$stateFromPlace" not found in list. Please select manually.',
        ),
      );
    }
  }

  String _addressComponent(DetailsResult place, List<String> preferredTypes) {
    final components = place.addressComponents;
    if (components == null) return '';

    for (final component in components) {
      final types = component.types ?? const <String>[];
      final hasPreferredType = preferredTypes.any(types.contains);
      if (!hasPreferredType) continue;

      final value = component.longName?.trim();
      if (value != null && value.isNotEmpty) return value;
    }

    return '';
  }

  String? _matchingStateName(String stateName) {
    final normalizedStateName = stateName.trim().toLowerCase();
    if (normalizedStateName.isEmpty) return null;

    for (final state in states) {
      final name = state.name;
      if (name != null && name.toLowerCase() == normalizedStateName) {
        return name;
      }
    }

    return null;
  }

  @override
  void dispose() {
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _selectState.dispose();
    super.dispose();
  }

  List<StateModel> states = [];
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocListener<KycBloc, KycState>(
      listener: (context, state) async {
        if (state is KycAddressLoading) {
          showLoadingDialog(context);
        }

        if (state is KycFailure) {
          if (context.mounted) {
            Navigator.pop(context);
          }

          await showErrorSnackbar(context, state.error);
        }
        if (state is KycAddressSubmitted) {
          if (context.mounted) {
            Navigator.pop(context);
          }

          await GeneralDialogs.showCustomBottomSheet(
            context,
            body: StepModal(
              title: 'Verification Complete!',
              description:
                  'Welcome to ResQ360, You can now book a service and browse service providers.',
              icon: AppAssets.ASSETS_LOGO_LOGO_PNG,
              buttonText: 'Go to Dashboard',
              onContinuePressed: () async {
                Navigator.pop(context);

                if (!context.mounted) return;

                if (widget.source == VerificationSource.settings) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                } else {
                  await replaceScreen(
                    context,
                    const MainLayoutPage(userType: UserType.customer),
                  );
                }
              },
            ),
          );
        }
        if (state is StatesLoadedState) {
          setState(() {
            states = state.states;
          });
        }
      },
      child: Scaffold(
        backgroundColor: colors.whiteColor,
        appBar: AppBar(
          forceMaterialTransparency: true,
          backgroundColor: colors.whiteColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () => pop(context),
            icon: AppAssets.ASSETS_ICONS_BACK_ICON_SVG.svg,
          ),
          centerTitle: true,
          title: const StepIndicator(currentStep: 3, totalSteps: 3),
          actions: const [SizedBox(width: 40)],
        ),
        body: SafeArea(
          child: Padding(
            padding: pad(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          20.verticalSpace,
                          UrbText(
                            'Address Verification',
                            size: 18,
                            height: 28.5,
                            weight: FontWeight.w700,
                            color: colors.black,
                            textAlign: TextAlign.center,
                          ),
                          50.verticalSpace,
                          GooglePlacesAutocompleteField(
                            label: 'Street Address',
                            controller: _streetCtrl,
                            hintText: 'Search for your street address',
                            onPredictionSelected: (prediction) {
                              setState(() {
                                _selectedPlace = prediction;
                                _usedCurrentLocation = false;
                              });
                            },
                            onPlaceDetailsSelected: _applyPlaceDetails,
                          ),
                          16.verticalSpace,
                          KFormField(
                            label: 'City',
                            hintText: 'Enter Your City',
                            controller: _cityCtrl,
                            keyboardType: TextInputType.streetAddress,
                            onChanged: (a) {
                              setState(() {});
                            },
                          ),
                          16.verticalSpace,
                          ValueListenableBuilder<String?>(
                            valueListenable: _selectState,
                            builder: (
                              BuildContext context,
                              String? value,
                              Widget? child,
                            ) {
                              return ObjectKDropDown(
                                label: 'State',
                                hintText: 'State',
                                displayStringForOption:
                                    (String? name) => name ?? '',
                                showPrefix: false,
                                value: value,
                                dropdownItems:
                                    states
                                        .map((state) => state.name ?? '')
                                        .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectState.value = value;
                                  });
                                },
                              );
                            },
                          ),
                          // 20.verticalSpace,
                          // GestureDetector(
                          //   onTap:
                          //       _isLoadingLocation ? null : _getCurrentLocation,
                          //   child: Container(
                          //     padding: pad(vertical: 12),
                          //     decoration: BoxDecoration(
                          //       color: colors.primary.shade50,
                          //       borderRadius: BorderRadius.circular(8),
                          //       border: Border.all(
                          //         color: colors.primary.shade500,
                          //       ),
                          //     ),
                          //     child: Row(
                          //       mainAxisAlignment: MainAxisAlignment.center,
                          //       children: [
                          //         if (_isLoadingLocation)
                          //           SizedBox(
                          //             width: 16,
                          //             height: 16,
                          //             child: CircularProgressIndicator(
                          //               strokeWidth: 2,
                          //               color: colors.primary.shade500,
                          //             ),
                          //           )
                          //         else
                          //           Icon(
                          //             Icons.my_location,
                          //             color: colors.primary.shade500,
                          //             size: 20,
                          //           ),
                          //         10.horizontalSpace,
                          //         UrbText(
                          //           _isLoadingLocation
                          //               ? 'Getting location...'
                          //               : 'Use Current Location',
                          //           weight: FontWeight.w600,
                          //           color: colors.primary.shade500,
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          20.verticalSpace,
                        ],
                      ),
                    ),
                  ),
                  WideButton(
                    label: 'Submit for Review',
                    onPressed:
                        isFormValid
                            ? () async {
                              context.read<KycBloc>().add(
                                SubmitKycAddress(
                                  address: _streetCtrl.text,
                                  city: _cityCtrl.text,
                                  state: _selectState.value!,
                                ),
                              );
                            }
                            : null,
                  ),
                  20.verticalSpace,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
