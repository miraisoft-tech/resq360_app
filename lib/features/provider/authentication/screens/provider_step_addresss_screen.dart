import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/helpers/location_helper.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/main_layout.dart';
import 'package:resq360/features/provider/authentication/data/bloc/provider_auth_bloc.dart';
import 'package:resq360/features/provider/authentication/data/models/provider_response.dart';
import 'package:resq360/features/provider/authentication/data/models/state_model.dart';
import 'package:resq360/features/widgets/dialogs/step.modal.dart';
import 'package:resq360/features/widgets/dialogs/step_indicator.dart';

class ProviderStepAddressScreen extends StatefulWidget {
  const ProviderStepAddressScreen({super.key});

  @override
  State<ProviderStepAddressScreen> createState() =>
      _ProviderStepAddressScreenState();
}

class _ProviderStepAddressScreenState extends State<ProviderStepAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<String?> _selectState = ValueNotifier(null);

  final TextEditingController _streetCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();

  ProviderModel? userInfo;

  Future<void> initializeLocation() async {
    final locationData = await LocationHelper.getCurrentLocation();

    _streetCtrl.text = (locationData['address'] as String?) ?? '';
    _cityCtrl.text = (locationData['city'] as String?) ?? '';
    _selectState.value = (locationData['state'] as String?) ?? '';

    userInfo = await AuthLocalRepo.instance.getProviderAuthCredentials();

    setState(() {});
  }

  List<StateModel> states = [];

  bool get isFormValid =>
      _streetCtrl.text.isNotEmpty &&
      _cityCtrl.text.isNotEmpty &&
      _selectState.value != null;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(initializeLocation());

      context.read<ProviderAuthBloc>().add(
        ProviderGetStates(),
      );
    });
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

    return BlocListener<ProviderAuthBloc, ProviderAuthState>(
      listener: (context, state) async {
        if (state is ProviderAuthLoadingState) {
          showLoadingDialog(context);
        }

        if (state is ProviderKycSubmissionFailure) {
          if (context.mounted) {
            Navigator.pop(context);
          }

          await showErrorSnackbar(context, state.error);
        }

        if (state is ProviderKycAddressSubmitted) {
          await GeneralDialogs.showCustomBottomSheet(
            context,
            body: StepModal(
              title: 'Verification Complete!',
              description:
                  'Welcome to ResQ360, ${userInfo?.fullName ?? ''}! You can now book a service and browse service providers.',
              icon: AppAssets.ASSETS_LOGO_LOGO_PNG,
              buttonText: 'Go to Dashboard',
              onContinuePressed: () async {
                Navigator.pop(context);

                if (context.mounted) {
                  final hasMainLayout =
                      Navigator.of(context).canPop() &&
                      ModalRoute.of(context)?.settings.name != '/';

                  if (hasMainLayout) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else {
                    await replaceScreen(
                      context,
                      const MainLayoutPage(
                        userType: UserType.provider,
                      ),
                    );
                  }
                }
              },
            ),
          );
        }

        if (state is ProviderStatesLoadedState) {
          setState(() {
            states = state.states;
          });
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
            child: Column(
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
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
                      ],
                    ),
                  ),
                ),
                WideButton(
                  label: 'Submit for Review',
                  onPressed:
                      isFormValid
                          ? () async {
                            context.read<ProviderAuthBloc>().add(
                              ProviderSubmitKycAddress(
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
    );
  }
}
