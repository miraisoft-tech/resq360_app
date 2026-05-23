import 'package:resq360/__lib.dart';
import 'package:resq360/features/chat/bloc/chat_details_bloc/chat_details_bloc.dart';

class ReportChatDialog extends StatefulWidget {
  const ReportChatDialog({
    required this.chatId,
    required this.chatTitle,
    this.returnSelectedReason = false,
    this.dialogTitle,
    this.description,
    this.submitLabel,
    super.key,
  });

  final int chatId;
  final String chatTitle;
  final bool returnSelectedReason;
  final String? dialogTitle;
  final String? description;
  final String? submitLabel;

  @override
  State<ReportChatDialog> createState() => _ReportChatDialogState();
}

class _ReportChatDialogState extends State<ReportChatDialog> {
  String? selectedReason;
  final TextEditingController _customReasonController = TextEditingController();

  final List<String> reportReasons = [
    'Spam or misleading',
    'Inappropriate content',
    'Harassment or bullying',
    'Scam or fraud',
    'Fake profile',
    'Poor service quality',
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
                  Icons.report_outlined,
                  color: appColors.error.shade600,
                  size: 24.sp,
                ),
                12.horizontalSpace,
                Expanded(
                  child: GenText(
                    widget.dialogTitle ?? 'Block Chat',
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
              widget.description ??
                  'Please select a reason for blocking this chat with "${widget.chatTitle}"',
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
                'They will no longer be able to contact you.',
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
                    label: widget.submitLabel ?? 'Block',
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

    if (widget.returnSelectedReason) {
      Navigator.pop(context, reason);
      return;
    }

    context.read<ChatDetailBloc>().add(
      ReportChat(
        chatId: widget.chatId,
        reason: reason,
      ),
    );

    Navigator.pop(context, true);
  }
}
