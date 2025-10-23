// Reason: We have several fire-and-forget UI calls (dialogs, snackbars)
// in BlocListeners that do not need to be awaited.
// ignore_for_file: unawaited_futures
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/helpers/location_helper.dart';
import 'package:resq360/core/utils/validators.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/service_bloc/customer_services_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/models/service-model/service.model.dart';
import 'package:resq360/features/provider/authentication/data/bloc/provider_auth_bloc.dart';
import 'package:resq360/features/provider/authentication/data/models/auth_user.model.dart';
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
  // late TextEditingController addressController;
  late TextEditingController longitudeController;
  late TextEditingController latitudeController;

  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<Service?> _selectType = ValueNotifier(null);

  // final List<String> categories = [
  //   'Towing',
  //   'Cleaning',
  //   'Mechanic',
  //   'Electrician',
  //   'Other',
  // ];
  @override
  void initState() {
    super.initState();

    context.read<CustomerServicesBloc>().add(CustomerFetchServices());

    nameController = TextEditingController();
    addressController = TextEditingController();
    otherController = TextEditingController();

    // WidgetsBinding.instance.addPostFrameCallback(
    //   (_) => AppTrackingPermissionHandler.requestTrackingPermisssion(),
    // );
  }

  @override
  void dispose() {
    super.dispose();

    addressController.dispose();
    nameController.dispose();
    otherController.dispose();
  }

  bool isProcessing = false;
  Future<void> _handleSignup(BuildContext context) async {
    if (isProcessing) return;
    setState(() => isProcessing = true);

    if (!_formKey.currentState!.validate()) {
      setState(() => isProcessing = false);
      return;
    }

    try {
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

      final servicesState = context.read<CustomerServicesBloc>().state;
      if (servicesState is! CustomerServicesLoaded) {
        showSnackBar(context, 'Error', 'Please wait for services to load');
        setState(() => isProcessing = false);
        return;
      }

      final selectedService = _selectType.value;

      if (selectedService == null) {
        showSnackBar(context, 'Error', 'Please select a service category');
        setState(() => isProcessing = false);
        return;
      }

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
      if (context.mounted) {
        showSnackBar(context, 'Error', e.toString());
      }
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocListener<ProviderAuthBloc, ProviderAuthState>(
      listener: (context, state) async {
        if (!mounted) return;
        if (state is ProviderAuthLoadingState) {
          showLoadingDialog(context);
        }
        if (state is ProviderAuthFailureState) {
          if (Navigator.canPop(context)) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          showSnackBar(context, 'Error', state.error);
        }

        if (state is ProviderAuthSignupSuccessState) {
          if (Navigator.canPop(context)) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          // showSuccessSnackBar(context, 'Registration successful');
          // navigate to confirm email screen
          pushScreen(
            context,
            ProviderConfirmEmailScreen(email: widget.email, purpose: VerificationPurpose.registration),
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
                      keyboardType: TextInputType.name,
                      onChanged: (a) {
                        setState(() {});
                      },
                      validator:
                          (value) => Validators.validateNotEmpty(
                            value,
                            'business name',
                          ),
                    ),
                    16.verticalSpace,
                    KFormField(
                      label: 'Business Address',
                      hintText: 'Enter Your Business Address',
                      controller: addressController,
                      keyboardType: TextInputType.name,
                      onChanged: (a) {
                        setState(() {});
                      },
                      validator:
                          (value) => Validators.validateNotEmpty(
                            value,
                            'business address',
                          ),
                    ),
                    16.verticalSpace,
                    BlocBuilder<CustomerServicesBloc, CustomerServicesState>(
                      builder: (context, state) {
                        if (state is CustomerServicesLoading) {
                          isProcessing = true;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state is CustomerServicesError) {
                          isProcessing = false;
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
                                  context.read<CustomerServicesBloc>().add(
                                    CustomerFetchServices(),
                                  );
                                },
                              ),
                            ],
                          );
                        }

                        if (state is CustomerServicesLoaded) {
                          isProcessing = false;

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
                    GenText(
                      'Choose a primary service, you can add more services later in settings.',
                      size: 12,
                      height: 16.5,
                      weight: FontWeight.w400,
                      color: colors.textColor.shade500,
                    ),
                    16.verticalSpace,
                    if (_selectType.value!.name == 'Other')
                      KFormField(
                        label: 'Specify Service',
                        hintText: 'Enter Your Service Name',
                        controller: otherController,
                        keyboardType: TextInputType.text,
                        onChanged: (a) {
                          setState(() {});
                        },
                        validator:
                            (value) => Validators.validateNotEmpty(
                              value,
                              'service name',
                            ),
                      ),
                  ],
                ),
              ),
              WideButton(
                label: isProcessing ? 'Loading...' : 'Continue',
                onPressed: isProcessing ? null : () => _handleSignup(context),
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
