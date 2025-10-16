import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/helpers/location_helper.dart';
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
  final ValueNotifier<String?> _selectType = ValueNotifier(null);

  final List<String> categories = [
    'Towing',
    'Cleaning',
    'Mechanic',
    'Electrician',
    'Other',
  ];
  @override
  void initState() {
    super.initState();

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
  print('Signup button pressed');
   if (isProcessing) return;
  setState(() => isProcessing = true);
  print('isProcessing set to true');
  if (!_formKey.currentState!.validate()) {
    setState(() => isProcessing = false); // reset if form is invalid
    print('Form is not valid');
    return;
  }

  try {
    // Get user’s current location and address
    final locationData = await LocationHelper.getCurrentLocation();

    // If widget was disposed during async call, stop
    if (!context.mounted) return;

    final address = Address(
      state: locationData['state'] as String,
      city: locationData['city'] as String,
      zipCode: locationData['zipCode'] as String,
      address: locationData['address'] as String,
      longitude: locationData['longitude'] as double,
      latitude: locationData['latitude'] as double,
    );

    // Trigger signup event
    context.read<ProviderAuthBloc>().add(
      ProviderSignupWIthEmail(
        fullname: widget.name,
        email: widget.email,
        password: widget.password,
        companyName: nameController.text,
        phoneNumber: widget.phone,
        customServiceName:
            _selectType.value == 'Other'
                ? otherController.text
                : _selectType.value ?? '',
        service: categories.indexOf(
                  _selectType.value == 'Other'
                      ? otherController.text
                      : _selectType.value ?? '',
                ) +
                1,
        address: address,
      ),
    );
  } catch (e, s) {
    log('Signup failed: $e\n$s');

    if (!context.mounted) return;
    await showSnackBar(context, 'Error', e.toString());
  }finally {
    setState(() => isProcessing = false); // reset after dispatch
  }
}


  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocListener<ProviderAuthBloc, ProviderAuthState>(
      listener: (context, state) async {
        if (state is ProviderAuthLoadingState) {
          await showLoadingDialog(context);
        }
        if (state is ProviderAuthFailureState) {
          if (Navigator.canPop(context)) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          await showSnackBar(context, 'Error', state.error);
        }

        if (state is ProviderAuthSignupSuccessState) {
          if (Navigator.canPop(context)) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          // showSuccessSnackBar(context, 'Registration successful');
          // navigate to confirm email screen
          await pushScreen(
            context,
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
                      keyboardType: TextInputType.name,
                      onChanged: (a) {
                        setState(() {});
                      },
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
                    ),
                    16.verticalSpace,
                    ValueListenableBuilder<String?>(
                      valueListenable: _selectType,
                      builder: (
                        BuildContext context,
                        String? value,
                        Widget? child,
                      ) {
                        return ObjectKDropDown(
                          label: 'Service Category ',
                          hintText: 'select a service category',
                          displayStringForOption: (String? id) => id ?? '',
                          showPrefix: false,
                          value: value,
                          dropdownItems: categories,
                          onChanged: (value) {
                            setState(() {
                              _selectType.value = value;
                            });
                          },
                        );
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
                    if (_selectType.value == 'Other')
                      KFormField(
                        label: 'Specify Service',
                        hintText: 'Enter Your Service Name',
                        controller: otherController,
                        keyboardType: TextInputType.text,
                        onChanged: (a) {
                          setState(() {});
                        },
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
