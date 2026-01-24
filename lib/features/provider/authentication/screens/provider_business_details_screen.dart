import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/service_catalog_bloc/service_catalog_bloc.dart';
import 'package:resq360/core/utils/app_gen_utils.dart';
import 'package:resq360/core/utils/app_tracking_permission_handler.dart';
import 'package:resq360/core/utils/location_helper.dart';
import 'package:resq360/core/utils/validators.dart';
import 'package:resq360/features/customer/dashboard/data/models/service-model/service.model.dart';
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

  // address controllers
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController countryController;
  late TextEditingController zipCodeController;
  late TextEditingController longitudeController;
  late TextEditingController latitudeController;

  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<Service?> _selectType = ValueNotifier(null);

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
    super.dispose();

    addressController.dispose();
    nameController.dispose();
    otherController.dispose();
  }

  Future<void> _handleSignup(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        isFetchingAddress = true;
      });
      final locationData = await LocationHelper.getCurrentLocation();

      if (!context.mounted) return;

      final address = Address(
        state: locationData['state'] as String,
        city: locationData['city'] as String,
        zipCode: locationData['zipCode'] as String,
        address: locationData['address'] as String,
        longitude: locationData['longitude'] as double,
        latitude: locationData['latitude'] as double,
      );

      if (_selectType.value == null) {
        await showErrorSnackbar(
          context,
          'Please select a service category',
        );

        return;
      }

      final selectedService = _selectType.value;

      context.read<ProviderAuthBloc>().add(
        ProviderSignupWIthEmail(
          fullname: widget.name,
          email: widget.email,
          password: widget.password,
          companyName: nameController.text,
          phoneNumber: widget.phone,
          customServiceName:
              selectedService?.name == 'Other'
                  ? otherController.text
                  : selectedService?.name ?? '',
          service: selectedService?.id ?? 0,
          address: address,
        ),
      );
    } on Exception catch (e, s) {
      log('Signup failed: $e\n$s');
    }
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
          if (context.mounted) {
            Navigator.pop(context);
          }

          setState(() {
            isFetchingAddress = false;
          });

          await pushAndReplaceScreen(
            context: context,
            ProviderConfirmEmailScreen(
              email: widget.email,
            ),
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
                          (value) => AppGenUtil.isValidName(
                            value,
                            'business name',
                            5,
                          ),
                    ),
                    16.verticalSpace,
                    KFormField(
                      label: 'Business Address',
                      hintText: 'Enter Your Business Address',
                      controller: addressController,
                      keyboardType: TextInputType.text,
                      onChanged: (a) {
                        setState(() {});
                      },
                      validator:
                          (value) => AppGenUtil.isValidName(
                            value,
                            'business address',
                            5,
                          ),
                    ),
                    16.verticalSpace,
                    BlocBuilder<ServiceCatalogBloc, ServiceCatalogState>(
                      builder: (context, state) {
                        if (state is ServiceCatalogLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
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
