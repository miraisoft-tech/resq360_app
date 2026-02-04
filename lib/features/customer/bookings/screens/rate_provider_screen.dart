import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/settings/data/bloc/ratings_bloc/ratings_bloc.dart';

class RateProviderScreen extends StatefulWidget {
  const RateProviderScreen({
    required this.serviceRequestId,
    required this.providerId,
    required this.providerName,
    super.key,
  });
  
  final int serviceRequestId;
  final int providerId;
  final String providerName;

  @override
  State<RateProviderScreen> createState() => _RateProviderScreenState();
}

class _RateProviderScreenState extends State<RateProviderScreen> {
  int rating = 0;
  final TextEditingController reviewController = TextEditingController();

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

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
        title: UrbText(
          'Rate Service',
          color: appColors.black,
          size: 18,
          weight: FontWeight.w600,
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
              'Service Completed!',
              size: 22,
              weight: FontWeight.w700,
              color: appColors.black,
            ),
            4.verticalSpace,
            GenText(
              'How was your experience with ${widget.providerName}?',
              color: appColors.textColor.shade400,
              weight: FontWeight.w400,
              textAlign: TextAlign.center,
            ),
            32.verticalSpace,
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
              initialRating: rating.toDouble(),
              minRating: 1,
              itemSize: 32,
              allowHalfRating: true,
              unratedColor: appColors.textColor.shade200,
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: appColors.primary.shade500,
              ),
              onRatingUpdate: (val) {
                setState(() => rating = val.toInt());
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
            BlocConsumer<RatingsBloc, RatingsState>(
              listener: (context, state) async {
                if (state is RateProviderSuccess) {
                  await GeneralDialogs.showCustomBottomSheet(
                    context,
                    body: CustomerThankYouModal(
                      onContinuePressed: () async {
                        if (context.mounted) await pop(context);
                        if (context.mounted) await pop(context);
                      },
                    ),
                  );
                }
                if (state is RatingsError) {
                  await showErrorSnackbar(context, state.message);
                }
              },
              builder: (context, state) {
                return WideButton(
                  label: 'Submit Rating',
                  backgroundColor: appColors.primary.shade500,
                  loading: state is RatingsLoading,
                  onPressed: reviewController.text.isNotEmpty && rating > 0
                      ? () async {
                          context.read<RatingsBloc>().add(
                                RateProviderEvent(
                                  serviceRequestId: widget.serviceRequestId.toString(),
                                  ratings: rating,
                                  review: reviewController.text,
                                ),
                              );
                        }
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerThankYouModal extends StatelessWidget {
  const CustomerThankYouModal({
    required this.onContinuePressed,
    super.key,
  });

  final void Function() onContinuePressed;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).viewInsets.bottom +
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
            'Thank You!',
            color: appColors.black,
            size: 22,
            height: 32.5,
            weight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),
          GenText(
            'Your feedback helps us improve our service quality.',
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
