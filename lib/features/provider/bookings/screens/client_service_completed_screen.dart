import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:resq360/__lib.dart';

class ClientServiceCompletedScreen extends StatefulWidget {
  const ClientServiceCompletedScreen({super.key});

  @override
  State<ClientServiceCompletedScreen> createState() =>
      _ClientServiceCompletedScreenState();
}

class _ClientServiceCompletedScreenState
    extends State<ClientServiceCompletedScreen> {
  double rating = 0;
  final TextEditingController reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: AppBar(
        backgroundColor: appColors.whiteColor,
        forceMaterialTransparency: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: appColors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: pad(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            SvgPicture.asset(
              AppAssets.ASSETS_ICONS_SEVICE_CONFIRMED_SVG,
              height: 40.h,
              width: 40.w,
            ),
            12.verticalSpace,
            UrbText(
              'Completed!',
              size: 22,
              weight: FontWeight.w700,
              color: appColors.black,
            ),
            4.verticalSpace,
            GenText(
              'Service has been marked as complete',
              color: appColors.textColor.shade400,
              weight: FontWeight.w400,
            ),
            24.verticalSpace,
            Container(
              width: double.infinity,
              padding: pad(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: appColors.success.shade50,
                border: Border.all(color: appColors.success.shade100),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GenText(
                    'Disclaimer: by proceeding, you confirm that:',
                    weight: FontWeight.w600,
                    color: appColors.success.shade700,
                  ),
                  8.verticalSpace,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GenText(
                        '• ',
                        color: appColors.success.shade700,
                      ),
                      Expanded(
                        child: GenText(
                          'You have provided a good service and the customer is satisfied',
                          color: appColors.success.shade700,
                          size: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            25.verticalSpace,
            Align(
              alignment: Alignment.centerLeft,
              child: GenText(
                'Rate Your Experience',
                weight: FontWeight.w500,
                color: appColors.black,
              ),
            ),
            4.verticalSpace,
            Align(
              alignment: Alignment.centerLeft,
              child: GenText(
                'Help others by sharing your experience',
                color: appColors.textColor.shade400,
                size: 12,
              ),
            ),
            12.verticalSpace,
            RatingBar.builder(
              initialRating: rating,
              minRating: 1,
              itemSize: 32,
              allowHalfRating: true,
              unratedColor: appColors.textColor.shade200,
              itemBuilder:
                  (context, _) => Icon(
                    Icons.star,
                    color: appColors.primary.shade500,
                  ),
              onRatingUpdate: (val) {
                setState(() => rating = val);
              },
            ),
            32.verticalSpace,

            KFormField(
              label: 'Write a review',
              controller: reviewController,
              hintText: 'Share your experience with this client...',
              maxLines: 10,
              minLines: 8,
              onChanged: (value) {
                setState(() {});
              },
            ),
            40.verticalSpace,
            WideButton(
              label: 'Submit',
              backgroundColor: appColors.primary.shade500,
              onPressed:
                  reviewController.text.isNotEmpty && rating > 0
                      ? () async {
                        await GeneralDialogs.showCustomBottomSheet(
                          context,
                          body: ProviderThankYouModal(
                            onContinuePressed: () async {
                              if (context.mounted) await pop(context);
                              if (context.mounted) await pop(context);
                              if (context.mounted) await pop(context);
                            },
                          ),
                        );
                      }
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}

class ProviderThankYouModal extends ConsumerWidget {
  const ProviderThankYouModal({
    required this.onContinuePressed,

    super.key,
  });

  final void Function() onContinuePressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = context.appColors;

    return Container(
      width: double.infinity,
      height:
          MediaQuery.of(context).viewInsets.bottom +
          (MediaQuery.of(context).size.height * 0.55),
      decoration: BoxDecoration(
        color: appColors.whiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      padding: pad(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: onContinuePressed,
              icon: Icon(Icons.close, color: appColors.black),
            ),
          ),
          AppAssets.ASSETS_IMAGES_CONGRATS_PNG.imageAsset(
            height: 172,
            width: 172,
          ),
          10.verticalSpace,
          GenText(
            'Congratulations!',
            color: appColors.black,
            size: 22,
            height: 32.5,
            weight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),
          GenText(
            'You earned a good review, get ready for more clients.',
            color: appColors.neutral.shade500,
            height: 32.5,
            weight: FontWeight.w400,
            textAlign: TextAlign.center,
          ),
          25.verticalSpace,
          WideButton(
            label: 'Back to Home',
            onPressed: onContinuePressed,
          ),
        ],
      ),
    );
  }
}
