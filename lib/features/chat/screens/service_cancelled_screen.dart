// ignore_for_file: deprecated_member_use, document_ignores

import 'package:resq360/__lib.dart';
import 'package:resq360/features/chat/data/models/cancel_reason_enum.dart';
import 'package:resq360/features/chat/screens/cancelled.modal.dart';

class ServiceCancelledScreen extends StatefulWidget {
  const ServiceCancelledScreen({super.key});

  @override
  State<ServiceCancelledScreen> createState() => _ServiceCancelledScreenState();
}

class _ServiceCancelledScreenState extends State<ServiceCancelledScreen> {
  CancelReason? selectedReason;
  final TextEditingController reasonController = TextEditingController();

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
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 10.h,
          bottom: 50.h,
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              AppAssets.ASSETS_ICONS_CANCEL_SVG,
              height: 40.h,
              width: 40.w,
            ),
            12.verticalSpace,
            UrbText(
              'Cancel Service',
              size: 22,
              weight: FontWeight.w700,
              color: appColors.black,
            ),
            4.verticalSpace,
            GenText(
              'Please review cancellation terms',
              color: appColors.textColor.shade400,
              weight: FontWeight.w400,
            ),
            24.verticalSpace,
            Container(
              width: double.infinity,
              padding: pad(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: appColors.error.shade50,
                border: Border.all(color: appColors.error.shade100),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GenText(
                    'Disclaimer: by proceeding, you acknowledge that:',
                    weight: FontWeight.w600,
                    color: appColors.error.shade700,
                  ),
                  8.verticalSpace,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(
                        child: GenText(
                          'Cancellation of service attracts a 10% administration fee',
                          color: appColors.error.shade600,
                          size: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            32.verticalSpace,
            Container(
              width: double.infinity,
              padding: pad(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: appColors.textColor.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GenText(
                    'Reason for Cancellation',
                    size: 16,
                    weight: FontWeight.w700,
                    color: appColors.black,
                  ),
                  4.verticalSpace,
                  GenText(
                    'Please select an appropriate reason',
                    color: appColors.textColor.shade400,
                    size: 13,
                  ),
                  14.verticalSpace,
                  ...CancelReason.values.map((reason) {
                    return GestureDetector(
                      onTap: () => setState(() => selectedReason = reason),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: Row(
                          children: [
                            Radio<CancelReason>(
                              value: reason,
                              groupValue: selectedReason,
                              onChanged:
                                  (value) =>
                                      setState(() => selectedReason = value),
                              activeColor: appColors.primary.shade500,
                            ),
                            Expanded(
                              child: GenText(
                                _reasonText(reason),
                                color: appColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            24.verticalSpace,
            if (selectedReason == CancelReason.other) ...[
              KFormField(
                label: 'Other',
                controller: reasonController,
                hintText: 'Type your reason here...',
                maxLines: 10,
                minLines: 8,
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ],
            40.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: WideButton(
                    label: 'Keep Service',
                    backgroundColor: appColors.primary.shade50,
                    textColor: appColors.primary.shade500,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: WideButton(
                    label: 'Confirm',
                    backgroundColor: appColors.error,
                    textColor: appColors.whiteColor,
                    onPressed:
                        reasonController.text.isNotEmpty ||
                                selectedReason != null
                            ? () async {
                              await GeneralDialogs.showCustomBottomSheet(
                                context,
                                body: CancelledModal(
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _reasonText(CancelReason reason) {
    switch (reason) {
      case CancelReason.changeOfPlans:
        return 'Change of plans';
      case CancelReason.notNeeded:
        return 'Service no longer needed';
      case CancelReason.alternativeSource:
        return 'Found an alternative source';
      case CancelReason.emergency:
        return 'Emergency situation';
      case CancelReason.other:
        return 'Other';
    }
  }
}
