import 'dart:async';

import 'package:google_place/google_place.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/service_catalog_bloc/service_catalog_bloc.dart';
import 'package:resq360/core/utils/app_gen_utils.dart';
import 'package:resq360/core/utils/app_tracking_permission_handler.dart';
import 'package:resq360/core/utils/validators.dart';
import 'package:resq360/features/customer/dashboard/data/models/service_models/service_request.model.dart';
import 'package:resq360/features/provider/authentication/data/bloc/provider_auth_bloc.dart';
import 'package:resq360/features/provider/authentication/data/models/address.model.dart';
import 'package:resq360/features/provider/authentication/screens/provider_confirm_email_screen.dart';
import 'package:resq360/features/provider/authentication/screens/provider_login_screen.dart';
import 'package:resq360/features/widgets/scaffolds/app_scaffold.dart';

class ProviderBusinessDetailsScreen extends StatefulWidget {
  const ProviderBusinessDetailsScreen({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    super.key,
  });
  final String name;
  final String email;
  final String phone;
  final String password;

  @override
  State<ProviderBusinessDetailsScreen> createState() =>
      _ProviderBusinessDetailsScreenState();
}

class _ProviderBusinessDetailsScreenState
    extends State<ProviderBusinessDetailsScreen> {
  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController otherController;

  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<Service?> _selectType = ValueNotifier(null);
  AutocompletePrediction? _selectedBusinessPrediction;
  DetailsResult? _selectedBusinessPlace;

  @override
  void initState() {
    super.initState();

    context.read<ServiceCatalogBloc>().add(const FetchServices());

    nameController = TextEditingController();
    addressController = TextEditingController();
    otherController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => AppTrackingPermissionHandler.requestTrackingPermisssion(),
    );
  }

  bool isFetchingAddress = false;
  @override
  void dispose() {
    addressController.dispose();
    nameController.dispose();
    otherController.dispose();
    _selectType.dispose();
    super.dispose();
  }

  Future<void> _handleSignup(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selectedService = _selectType.value;
    if (selectedService == null) {
      await showErrorSnackbar(context, 'Please select a service category');
      return;
    }

    final selectedPrediction = _selectedBusinessPrediction;
    final selectedPlace = _selectedBusinessPlace;
    if (selectedPrediction == null || selectedPlace == null) {
      await showErrorSnackbar(
        context,
        'Please select a valid business address',
      );
      return;
    }

    final city = _addressComponent(selectedPlace, const [
      'locality',
      'postal_town',
      'administrative_area_level_2',
      'sublocality_level_1',
    ]);
    final state = _addressComponent(selectedPlace, const [
      'administrative_area_level_1',
    ]);
    final location = selectedPlace.geometry?.location;
    if (city.isEmpty || state.isEmpty) {
      await showErrorSnackbar(
        context,
        'Please choose a more specific business address',
      );
      return;
    }
    if (location?.lat == null || location?.lng == null) {
      await showErrorSnackbar(
        context,
        'Please choose a business address with map coordinates',
      );
      return;
    }

    try {
      setState(() {
        isFetchingAddress = true;
      });

      final address = Address(
        state: state,
        city: city,
        zipCode: _addressComponent(selectedPlace, const ['postal_code']),
        address: addressController.text.trim(),
        longitude: location!.lng,
        latitude: location.lat,
      );

      context.read<ProviderAuthBloc>().add(
        ProviderSignupWIthEmail(
          fullname: widget.name,
          email: widget.email,
          password: widget.password,
          companyName: nameController.text,
          phoneNumber: widget.phone,
          customServiceName:
              selectedService.name == 'Other'
                  ? otherController.text
                  : selectedService.name,
          service: selectedService.id,
          address: address,
        ),
      );
    } on Exception catch (e, s) {
      log('Signup failed: $e\n$s');
      if (mounted) {
        setState(() {
          isFetchingAddress = false;
        });
      }
    }
  }

  void _applyBusinessPlaceDetails(DetailsResult place) {
    setState(() {
      _selectedBusinessPlace = place;
    });
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

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocListener<ProviderAuthBloc, ProviderAuthState>(
      listener: (context, state) async {
        if (state is ProviderAuthLoadingState) {
          showLoadingDialog(context);
        }

        if (state is ProviderAuthFailureState) {
          if (context.mounted) {
            Navigator.pop(context);
          }

          log(state.error);
          setState(() {
            isFetchingAddress = false;
          });
          await showErrorSnackbar(context, state.error);
        }

        if (state is ProviderAuthSignupSuccessState) {
          setState(() {
            isFetchingAddress = false;
          });

          await pushAndReplaceScreen(
            context: context,
            ProviderConfirmEmailScreen(email: widget.email),
          );
        }
      },
      child: AppScaffold(
        title: 'Business Details',
        subTitle: 'Tell us more about your business',
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    KFormField(
                      label: 'Business Name',
                      hintText: 'Enter Your Business Name',
                      controller: nameController,
                      keyboardType: TextInputType.text,
                      onChanged: (a) {
                        setState(() {});
                      },
                      validator:
                          (value) =>
                              AppGenUtil.isValidName(value, 'business name', 5),
                    ),
                    16.verticalSpace,
                    GooglePlacesAutocompleteField(
                      label: 'Business Address',
                      controller: addressController,
                      hintText: 'Search for your business address',
                      onPredictionSelected: (prediction) {
                        setState(() {
                          _selectedBusinessPrediction = prediction;
                        });
                      },
                      onPlaceDetailsSelected: _applyBusinessPlaceDetails,
                    ),
                    16.verticalSpace,
                    BlocBuilder<ServiceCatalogBloc, ServiceCatalogState>(
                      builder: (context, state) {
                        if (state is ServiceCatalogLoading) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: colors.primary.shade500,
                            ),
                          );
                        }

                        if (state is ServiceCatalogError) {
                          log('Error loading services: ${state.error}');
                          return Column(
                            children: [
                              const Center(
                                child: Text(
                                  'fetching services failed',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              WideButton(
                                label: 'retry',
                                onPressed: () {
                                  context.read<ServiceCatalogBloc>().add(
                                    const FetchServices(),
                                  );
                                },
                              ),
                            ],
                          );
                        }

                        if (state is ServicesLoaded) {
                          final categories = state.services;

                          return ValueListenableBuilder<Service?>(
                            valueListenable: _selectType,
                            builder: (
                              BuildContext context,
                              Service? value,
                              Widget? child,
                            ) {
                              return ObjectKDropDown<Service>(
                                label: 'Service Category',
                                hintText: 'Select a service category',
                                displayStringForOption:
                                    (Service service) => service.name,
                                showPrefix: false,
                                value:
                                    value != null
                                        ? categories.firstWhere(
                                          (service) => service.id == value.id,
                                          orElse: () => categories.first,
                                        )
                                        : null,
                                dropdownItems: categories,
                                onChanged: (service) {
                                  setState(() {
                                    _selectType.value = service;
                                  });
                                },
                              );
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    30.verticalSpace,
                    const GenText(
                      'Choose a primary service, you can add more services later in settings.',
                      size: 12,
                      height: 16.5,
                      weight: FontWeight.w400,
                      // color: colors.textColor.shade500,
                    ),
                    16.verticalSpace,
                    if (_selectType.value?.name == 'Other') ...[
                      16.verticalSpace,
                      KFormField(
                        label: 'Specify Service',
                        hintText: 'Enter Your Service Name',
                        controller: otherController,
                        keyboardType: TextInputType.text,
                        validator:
                            (value) => Validators.validateNotEmpty(
                              value,
                              'service name',
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              WideButton(
                label: !isFetchingAddress ? 'Continue' : 'Creating',
                onPressed:
                    !isFetchingAddress ? () => _handleSignup(context) : null,
              ),
              30.verticalSpace,
              Center(
                child: GestureDetector(
                  onTap: () async {
                    await pushScreen(context, const ProviderLoginScreen());
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: colors.textColor.shade500),
                      children: [
                        TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(
                            fontFamily: 'inter',
                            fontSize: 12.sp,
                            color: colors.neutral.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: 'Log in',
                          style: TextStyle(
                            fontFamily: 'inter',
                            fontSize: 12.sp,
                            color: colors.primary.shade500,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              20.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
