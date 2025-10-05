import 'package:resq360/__lib.dart';
import 'package:resq360/core/utils/app_clip_board_util.dart';

class ReferScreen extends StatefulWidget {
  const ReferScreen({super.key});

  @override
  State<ReferScreen> createState() => _ReferScreenState();
}

class _ReferScreenState extends State<ReferScreen> {
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: AppBar(
        title: UrbText(
          'Refer and Earn',
          size: 22,
          weight: FontWeight.w700,
          color: appColors.black,
        ),
        forceMaterialTransparency: true,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: appColors.whiteColor,
        foregroundColor: appColors.black,
      ),
      body: Padding(
        padding: pad(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            Center(
              child: Image.asset(
                AppAssets.ASSETS_IMAGES_GIFT_PNG,
                height: 200.h,
                width: 200.w,
              ),
            ),
            20.verticalSpace,
            const GenText(
              'Share your referral code with friends and save money on your first service.',
              size: 12,
              textAlign: TextAlign.center,
            ),
            40.verticalSpace,
            Container(
              padding: pad(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                border: Border.all(color: appColors.textColor.shade100),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GenText(
                    'Referral code',
                    color: appColors.textColor.shade500,
                  ),
                  30.verticalSpace,
                  Container(
                    padding: pad(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: appColors.neutral.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GenText(
                          'REF1234',
                          size: 16,
                          weight: FontWeight.w700,
                          color: appColors.black,
                        ),
                        GestureDetector(
                          onTap: () async {
                            await AppClipBoardUtil.copyString(
                              context,
                              content: 'REF1234',
                            );
                          },
                          child: Icon(
                            Icons.copy,
                            size: 20,
                            color: appColors.textColor.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  20.verticalSpace,
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appColors.primary.shade500,
                        padding: pad(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: () {},
                      child: const GenText(
                        'Share',
                        color: Colors.white,
                        size: 16,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
