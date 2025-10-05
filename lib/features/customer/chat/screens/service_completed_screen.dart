import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/chat/screens/thank_you.modal.dart';

class ServiceCompletedScreen extends StatefulWidget {
  const ServiceCompletedScreen({super.key});

  @override
  State<ServiceCompletedScreen> createState() => _ServiceCompletedScreenState();
}

class _ServiceCompletedScreenState extends State<ServiceCompletedScreen> {
  double rating = 0;
  final TextEditingController reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: AppBar(
        backgroundColor: appColors.whiteColor,
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
                      const Text('• '),
                      Expanded(
                        child: GenText(
                          'The service provided meets your expectations',
                          color: appColors.success.shade700,
                          size: 13,
                        ),
                      ),
                    ],
                  ),
                  4.verticalSpace,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(
                        child: GenText(
                          'The service provider has fulfilled all obligations',
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
              hintText: 'Share your experience with this provider...',
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
                          body: ThankYouModal(
                            onContinuePressed: () async {
                              if (context.mounted) await pop(context);
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
