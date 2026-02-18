import 'package:resq360/__lib.dart';

class ReportMessageDialog extends StatefulWidget {
  const ReportMessageDialog({super.key});

  @override
  State<ReportMessageDialog> createState() => _ReportMessageDialogState();
}

class _ReportMessageDialogState extends State<ReportMessageDialog> {
  String? selectedReason;
  final TextEditingController _customReasonController = TextEditingController();

  final List<String> reportReasons = [
    'Spam or misleading',
    'Inappropriate content',
    'Harassment or bullying',
    'Scam or fraud',
    'Hate speech',
    'Other',
  ];

  bool get canSubmit {
    if (selectedReason == null) return false;
    if (selectedReason == 'Other') {
      return _customReasonController.text.trim().isNotEmpty;
    }
    return true;
  }

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Dialog(
      backgroundColor: appColors.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      insetPadding: pad(vertical: 120, horizontal: 20),
      child: Padding(
        padding: pad(vertical: 20, horizontal: 24),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flag_outlined,
                  color: appColors.error.shade600,
                  size: 24.sp,
                ),
                12.horizontalSpace,
                Expanded(
                  child: GenText(
                    'Report Message',
                    size: 20,
                    weight: FontWeight.w600,
                    color: appColors.black,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: appColors.neutral.shade600,
                  ),
                ),
              ],
            ),
            16.verticalSpace,
            GenText(
              'Please select a reason for reporting this message.',
              color: appColors.neutral.shade700,
            ),
            24.verticalSpace,
            ...reportReasons.map((reason) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedReason = reason;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            selectedReason == reason
                                ? appColors.primary
                                : appColors.neutral.shade300,
                        width: selectedReason == reason ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                      color:
                          selectedReason == reason
                              ? appColors.primary.shade50
                              : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selectedReason == reason
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color:
                              selectedReason == reason
                                  ? appColors.primary
                                  : appColors.neutral.shade400,
                          size: 20.sp,
                        ),
                        12.horizontalSpace,
                        Expanded(
                          child: GenText(
                            reason,
                            color: appColors.neutral.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (selectedReason == 'Other') ...[
              16.verticalSpace,
              TextField(
                controller: _customReasonController,
                maxLines: 3,
                maxLength: 200,
                decoration: InputDecoration(
                  hintText: 'Please specify the reason...',
                  hintStyle: TextStyle(
                    color: appColors.neutral.shade400,
                    fontSize: 14.sp,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: appColors.neutral.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: appColors.primary,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
            Padding(
              padding: pad(vertical: 12),
              child: GenText(
                'This message will be sent for moderation review.',
                color: appColors.error,
                size: 10,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: WideButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                16.horizontalSpace,
                Expanded(
                  child: WideButton(
                    label: 'Report',
                    onPressed: canSubmit ? _handleSubmit : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    final reason =
        selectedReason == 'Other'
            ? _customReasonController.text.trim()
            : selectedReason!;

    Navigator.pop(context, reason);
  }
}
