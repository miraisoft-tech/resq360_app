import 'dart:io';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/utils/app_file_picker.dart';
import 'package:resq360/features/provider/authentication/screens/step_addresss_screen.dart';
import 'package:resq360/features/widgets/dialogs/step.modal.dart';
import 'package:resq360/features/widgets/dialogs/step_indicator.dart';
import 'package:resq360/features/widgets/images.widgets.dart';

class ProviderStepIDScreen extends StatefulWidget {
  const ProviderStepIDScreen({super.key});

  @override
  State<ProviderStepIDScreen> createState() => _ProviderStepIDScreenState();
}

class _ProviderStepIDScreenState extends State<ProviderStepIDScreen> {
  final ValueNotifier<String?> _selectType = ValueNotifier(null);

  final List<String> idTypes = [
    'National ID',
    "Driver's License",
    'Passport',
  ];
  File? pickedImage;

  Future<void> pickCameraPhoto(BuildContext context) async {
    pickedImage = await AppFilePicker.pickImage();

    if (pickedImage != null) {
      setState(() {});
    }

    if (context.mounted) {
      await GeneralDialogs.showCustomBottomSheet(
        context,
        body: StepModal(
          title: 'You’re Almost Done!',
          description: 'Just one more step to complete your verification',
          icon: AppAssets.ASSETS_IMAGES_STEP_2_PNG,
          onContinuePressed: () async {
            await pop(context);

            if (context.mounted) {
              await pushScreen(context, const StepAddressScreen());
            }
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
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
          child: ListView(
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
                    displayStringForOption: (String? id) => id ?? '',
                    showPrefix: false,
                    value: value,
                    dropdownItems: idTypes,
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
              50.verticalSpace,
              WideButton(
                label: 'Proceed',
                onPressed:
                    (_selectType.value != null && (pickedImage != null))
                        ? () {}
                        : null,
              ),
              20.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
