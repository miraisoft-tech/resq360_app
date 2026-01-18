// Reason: We have several fire-and-forget UI calls (dialogs, snackbars)
// in BlocListeners that do not need to be awaited.
// ignore_for_file: unawaited_futures

import 'dart:io';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/kyc_bloc/kyc_bloc.dart';
import 'package:resq360/core/models/identity_enums.dart';
import 'package:resq360/core/models/verification_source.enum.dart';
import 'package:resq360/core/utils/app_file_picker.dart';
import 'package:resq360/features/provider/authentication/screens/provider_step_addresss_screen.dart';
import 'package:resq360/features/widgets/dialogs/step.modal.dart';
import 'package:resq360/features/widgets/dialogs/step_indicator.dart';
import 'package:resq360/features/widgets/images.widgets.dart';

class ProviderStepIDScreen extends StatefulWidget {
  const ProviderStepIDScreen({required this.source, super.key});

  final VerificationSource source;
  @override
  @override
  State<ProviderStepIDScreen> createState() => _ProviderStepIDScreenState();
}

class _ProviderStepIDScreenState extends State<ProviderStepIDScreen> {
  final ValueNotifier<String?> _selectType = ValueNotifier(null);

  File? pickedImage;

  Future<void> pickCameraPhoto(BuildContext context) async {
    if (_selectType.value == null) {
      showErrorSnackbar(context, 'Please select an ID type');
      return;
    }

    pickedImage = await AppFilePicker.pickImage();
    if (!context.mounted) return;

    setState(() {});

    if (pickedImage != null) {
      context.read<KycBloc>().add(
        SubmitId(
          documentType: _selectType.value!,
          filePath: pickedImage!.path,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocListener<KycBloc, KycState>(
      listener: (context, state) async {
        if (state is KycIdLoading) {
          showLoadingDialog(context);
        }

        if (state is KycFailure) {
          if (context.mounted) {
            Navigator.pop(context);
          }

          showErrorSnackbar(context, state.error);
        }

        if (state is IdentitySubmitted) {
          if (context.mounted) {
            Navigator.pop(context);
          }

          await GeneralDialogs.showCustomBottomSheet(
            context,
            body: StepModal(
              title: 'You’re Almost Done!',
              description: 'Just one more step to complete your verification',
              icon: AppAssets.ASSETS_IMAGES_STEP_2_PNG,
              onContinuePressed: () async {
                await pop(context);

                if (context.mounted) {
                  await pushScreen(
                    context,
                    ProviderStepAddressScreen(
                      source: widget.source,
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
          forceMaterialTransparency: true,
          leading: IconButton(
            onPressed: () => pop(context),
            icon: AppAssets.ASSETS_ICONS_BACK_ICON_SVG.svg,
          ),
          centerTitle: false,
          title: const StepIndicator(currentStep: 2, totalSteps: 3),
          actions: const [SizedBox(width: 40)],
        ),
        body: SafeArea(
          child: Padding(
            padding: pad(horizontal: 20),
            child: Column(
              children: [
                30.verticalSpace,
                UrbText(
                  'Upload Valid Identification',
                  size: 18,
                  height: 28.5,
                  weight: FontWeight.w700,
                  color: colors.black,
                  textAlign: TextAlign.center,
                ),
                30.verticalSpace,
                ValueListenableBuilder<String?>(
                  valueListenable: _selectType,
                  builder: (
                    BuildContext context,
                    String? value,
                    Widget? child,
                  ) {
                    return ObjectKDropDown(
                      label: 'ID type',
                      hintText: 'select ID type',
                      displayStringForOption:
                          (String? id) =>
                              id?.replaceAll('_', ' ').toUpperCase() ?? '',
                      showPrefix: false,
                      value: value,
                      dropdownItems:
                          IdentityEnums.values
                              .map(
                                (e) => e.name,
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectType.value = value;
                        });
                      },
                    );
                  },
                ),
                30.verticalSpace,
                GestureDetector(
                  onTap: () => pickCameraPhoto(context),
                  child: Container(
                    padding: pad(vertical: 95),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.primary.shade500,
                      ),
                    ),
                    child: Center(
                      child:
                          pickedImage != null
                              ? memoryImage(
                                imgBytes: pickedImage!.readAsBytesSync(),
                                height: 210,
                                width: 310,
                                fit: BoxFit.contain,
                              )
                              : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AppAssets.ASSETS_ICONS_UPLOAD_SVG.svg,
                                  15.verticalSpace,
                                  GenText(
                                    'Tap to upload ID card',
                                    color: colors.primary.shade500,
                                    height: 24.5,
                                    weight: FontWeight.w400,
                                  ),
                                ],
                              ),
                    ),
                  ),
                ),
                const Spacer(),
                WideButton(
                  label: 'Proceed',
                  onPressed:
                      (_selectType.value != null && (pickedImage != null))
                          ? () {
                            context.read<KycBloc>().add(
                              SubmitId(
                                documentType: _selectType.value!,
                                filePath: pickedImage!.path,
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
