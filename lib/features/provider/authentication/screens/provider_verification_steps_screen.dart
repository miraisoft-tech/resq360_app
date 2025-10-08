import 'package:resq360/__lib.dart';
import 'package:resq360/features/provider/authentication/screens/provider_step_face_screen.dart';

class ProviderVerificationStepsScreen extends StatefulWidget {
  const ProviderVerificationStepsScreen({super.key});

  @override
  State<ProviderVerificationStepsScreen> createState() =>
      _ProviderVerificationStepsScreenState();
}

class _ProviderVerificationStepsScreenState
    extends State<ProviderVerificationStepsScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.whiteColor,
      appBar: AppBar(
        backgroundColor: colors.whiteColor,
        forceMaterialTransparency: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => pop(context),
            icon: Icon(Icons.close, color: colors.black),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: pad(horizontal: 20),
          child: Column(
            children: [
              AppAssets.ASSETS_IMAGES_VERIFICATION_STEP_PNG.imageAsset(
                height: 170,
                width: 180,
              ),
              30.verticalSpace,
              UrbText(
                'To continue, we need to verify\nyour identity in 3 steps',
                size: 22,
                height: 28,
                weight: FontWeight.w700,
                color: colors.black,
                textAlign: TextAlign.center,
              ),
              30.verticalSpace,
              _StepCard(
                icon: AppAssets.ASSETS_ICONS_FACE_V_ICON_SVG.svg,
                label: 'Facial Verification',
              ),
              16.verticalSpace,
              _StepCard(
                icon: AppAssets.ASSETS_ICONS_ID_V_ICON_SVG.svg,
                label: 'Valid Identity Card Upload',
              ),
              16.verticalSpace,
              _StepCard(
                icon: AppAssets.ASSETS_ICONS_ADDRES_V_ICON_SVG.svg,
                label: 'Address Verification',
              ),
              const Spacer(),
              WideButton(
                label: 'Continue',
                onPressed: () async {
                  log('Proceed verification steps');

                  await pushScreen(context, const ProviderStepFaceScreen());
                },
              ),
              20.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.icon, required this.label});
  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: pad(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.lightGreyColor2),
        color: colors.whiteColor,
      ),
      child: Row(
        children: [
          icon,
          14.horizontalSpace,
          GenText(
            label,
            height: 24.5,
            weight: FontWeight.w500,
            color: colors.black,
          ),
        ],
      ),
    );
  }
}
