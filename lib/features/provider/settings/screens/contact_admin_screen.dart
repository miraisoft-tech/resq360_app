import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/chat/screens/support_chat_screen.dart';
import 'package:resq360/features/customer/settings/data/models/admin_types.enums.dart';

class ContactAdminScreen extends StatelessWidget {
  const ContactAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final issueController = TextEditingController();

    final selectedIssue = ValueNotifier<AdminIssueType?>(null);

    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: AppBar(
        title: UrbText(
          'Contact Admin',
          size: 22,
          weight: FontWeight.w700,
          color: appColors.black,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
        elevation: 0,
        backgroundColor: appColors.whiteColor,
        foregroundColor: appColors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: pad(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GenText(
                'Choose the issue you’d like help with',
                weight: FontWeight.w600,
              ),
              16.verticalSpace,
              ValueListenableBuilder<AdminIssueType?>(
                valueListenable: selectedIssue,
                builder: (context, selected, _) {
                  return Column(
                    children: [
                      IssueRadio(
                        label: 'Complaints',
                        selected: selected == AdminIssueType.complaints,
                        onTap:
                            () =>
                                selectedIssue.value = AdminIssueType.complaints,
                      ),
                      IssueRadio(
                        label: 'Enquiry',
                        selected: selected == AdminIssueType.enquiry,
                        onTap:
                            () => selectedIssue.value = AdminIssueType.enquiry,
                      ),
                      IssueRadio(
                        label: 'Review',
                        selected: selected == AdminIssueType.review,
                        onTap:
                            () => selectedIssue.value = AdminIssueType.review,
                      ),
                      IssueRadio(
                        label: 'Account Issue',
                        selected: selected == AdminIssueType.accountIssue,
                        onTap:
                            () =>
                                selectedIssue.value =
                                    AdminIssueType.accountIssue,
                      ),
                      IssueRadio(
                        label: 'Other',
                        selected: selected == AdminIssueType.other,
                        onTap: () => selectedIssue.value = AdminIssueType.other,
                      ),
                      if (selected == AdminIssueType.other) ...[
                        20.verticalSpace,
                        KFormField(
                          label: 'Other',
                          controller: issueController,
                          minLines: 8,
                          maxLines: 10,
                          hintText:
                              'Type the issue you’d like help with here...',
                        ),
                      ],
                    ],
                  );
                },
              ),
              const Spacer(),
              WideButton(
                label: 'Continue',
                backgroundColor: appColors.primary.shade500,
                onPressed: () async {
                  await pushScreen(context, const SupportChatScreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IssueRadio extends StatelessWidget {
  const IssueRadio({
    required this.label,
    required this.selected,
    this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: pad(vertical: 8),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off_outlined,
              color: appColors.primary.shade500,
            ),
            12.horizontalSpace,
            GenText(
              label,
              size: 15,
              color: appColors.textColor.shade600,
            ),
          ],
        ),
      ),
    );
  }
}
