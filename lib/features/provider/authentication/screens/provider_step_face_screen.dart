// Reason: We have several fire-and-forget UI calls (dialogs, snackbars)
// in BlocListeners that do not need to be awaited.
// ignore_for_file: unawaited_futures

import 'dart:io';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/kyc_bloc/kyc_bloc.dart';
import 'package:resq360/core/models/verification_source.enum.dart';
import 'package:resq360/core/utils/app_file_picker.dart';
import 'package:resq360/features/provider/authentication/screens/provider_step_id_screen.dart';
import 'package:resq360/features/widgets/dialogs/step.modal.dart';
import 'package:resq360/features/widgets/dialogs/step_indicator.dart';

class ProviderStepFaceScreen extends StatefulWidget {
  const ProviderStepFaceScreen({required this.source, super.key});

  final VerificationSource source;

  @override
  State<ProviderStepFaceScreen> createState() => _ProviderStepFaceScreenState();
}

class _ProviderStepFaceScreenState extends State<ProviderStepFaceScreen> {
  File? pickedImage;

  Future<void> pickCameraPhoto(BuildContext context) async {
    pickedImage = await AppFilePicker.pickImage(source: ImageSource.camera);

    if (!context.mounted) return;
    if (pickedImage != null) {
      context.read<KycBloc>().add(
        SubmitKyc(filePath: pickedImage!.path),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocListener<KycBloc, KycState>(
      listener: (context, state) async {
        if (state is KycFaceLoading) {
          showLoadingDialog(context);
        }

        if (state is KycFailure) {
          if (context.mounted) {
            Navigator.pop(context);
          }

          showErrorSnackbar(context, state.error);
        }

        if (state is KycSubmitted) {
          if (context.mounted) {
            Navigator.pop(context);
          }

          await GeneralDialogs.showCustomBottomSheet(
            context,
            body: StepModal(
              title: 'Facial Verification Successful!',
              description: 'Let’s confirm your identification',
              icon: AppAssets.ASSETS_IMAGES_STEP_1_PNG,
              onContinuePressed: () async {
                Navigator.pop(context);

                if (context.mounted) {
                  await pushScreen(
                    context,
                    ProviderStepIDScreen(
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
          forceMaterialTransparency: true,
          elevation: 0,
          leading: IconButton(
            onPressed: () => pop(context),
            icon: AppAssets.ASSETS_ICONS_BACK_ICON_SVG.svg,
          ),
          centerTitle: false,
          title: const StepIndicator(currentStep: 1, totalSteps: 3),
          actions: const [SizedBox(width: 40)],
        ),
        body: SafeArea(
          child: Padding(
            padding: pad(horizontal: 20),
            child: Column(
              children: [
                30.verticalSpace,
                UrbText(
                  'Facial Verification',
                  size: 22,
                  height: 32.5,
                  weight: FontWeight.w700,
                  color: colors.black,
                  textAlign: TextAlign.center,
                ),
                12.verticalSpace,
                GenText(
                  'Align your face to the center of\nthe frame and take a photo',
                  height: 24,
                  color: colors.textColor.shade500,
                  textAlign: TextAlign.center,
                ),
                100.verticalSpace,
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 220,
                        width: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primary.shade100,
                        ),
                      ),
                      Container(
                        height: 160,
                        width: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primary.shade300,
                        ),
                      ),
                      SvgPicture.asset(
                        AppAssets.ASSETS_ICONS_FACE_STEP_SVG,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                WideButton(
                  label: 'Take a Photo',
                  onPressed: () async {
                    log('Open camera for face capture');

                    await pickCameraPhoto(context);
                  },
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
