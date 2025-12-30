import 'dart:async';


import 'package:resq360/__lib.dart';
import 'package:resq360/core/helpers/location_helper.dart';
import 'package:resq360/features/customer/authentication/data/bloc/customer_auth_bloc.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/main_layout.dart';
import 'package:resq360/features/widgets/dialogs/step.modal.dart';
import 'package:resq360/features/widgets/dialogs/step_indicator.dart';

class StepAddressScreen extends StatefulWidget {
  const StepAddressScreen({super.key});

  @override
  State<StepAddressScreen> createState() => _StepAddressScreenState();
}

class _StepAddressScreenState extends State<StepAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<String?> _selectState = ValueNotifier(null);

  final TextEditingController _streetCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();

  final List<String> states = [
    'Lagos',
    'Abuja',
    'Kano',
    'Rivers',
    'Oyo',
    'Enugu',
  ];

  bool get isFormValid =>
      _streetCtrl.text.isNotEmpty &&
      _cityCtrl.text.isNotEmpty &&
      _selectState.value != null;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(initializeLocation());
    });
  }

  Future<void> initializeLocation() async {
    final locationData = await LocationHelper.getCurrentLocation();

    _streetCtrl.text = (locationData['address'] as String?) ?? '';
    _cityCtrl.text = (locationData['city'] as String?) ?? '';
  }

  @override
  void dispose() {
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocListener<CustomerAuthBloc, CustomerAuthState>(
      listener: (context, state) async {
        if (!context.mounted) return;
        if (state is CustomerAuthLoading) {
          await showLoadingDialog(context);
        }

        if (state is CustomerKycSubmissionFailure) {
          await showSnackBar(context, 'Error', state.error);
        }
        if (state is CustomerKycAddressSubmitted) {
          await pop(context);

          await GeneralDialogs.showCustomBottomSheet(
            context,
            body: StepModal(
              title: 'Verification Complete!',
              description:
                  'Welcome to ResQ360, Jane! You can now book a service and browse service providers.',
              icon: AppAssets.ASSETS_LOGO_LOGO_PNG,
              buttonText: 'Go to Dashboard',
              onContinuePressed: () async {
                await pop(context);

                if (context.mounted) {
                  await replaceScreen(
                    context,
                    const MainLayoutPage(
                      userType: UserType.customer,
                    ),
                  );
                }
              },
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: colors.whiteColor,
        appBar: AppBar(
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
                  KFormField(
                    label: 'Street Address',
                    hintText: 'Enter Your Street Address',
                    controller: _streetCtrl,
                    keyboardType: TextInputType.streetAddress,
                    onChanged: (a) {
                      setState(() {});
                    },
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
                        displayStringForOption: (String? id) => id ?? '',
                        showPrefix: false,
                        value: value,
                        dropdownItems: states,
                        onChanged: (value) {
                          setState(() {
                            _selectState.value = value;
                          });
                        },
                      );
                    },
                  ),
                  const Spacer(),
                  WideButton(
                    label: 'Submit for Review',
                    onPressed:
                        isFormValid
                            ? () async {
                              context.read<CustomerAuthBloc>().add(
                                CustomerSubmitKycAddress(
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
