import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/chat/screens/support_chat_screen.dart';
import 'package:resq360/features/settings/data/models/admin_types.enums.dart';
import 'package:resq360/features/settings/data/service/support_service.dart';
import 'package:resq360/features/widgets/issue_radio_widget.dart';

class ContactAdminScreen extends StatefulWidget {
  const ContactAdminScreen({required this.email, super.key});
  final String email;

  @override
  State<ContactAdminScreen> createState() => _ContactAdminScreenState();
}

class _ContactAdminScreenState extends State<ContactAdminScreen> {
  final issueController = TextEditingController();
  final descriptionController = TextEditingController();

  final selectedIssue = ValueNotifier<AdminIssueType?>(null);

  bool isLoading = false;

  @override
  void dispose() {
    issueController.dispose();
    selectedIssue.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue(BuildContext context) async {
    final issue = selectedIssue.value;
    debugPrint('Selected issue: ${selectedIssue.value}');
    if (issue == null) {
      await showErrorSnackbar(context, 'Please select an issue');
      return;
    }

    if (issue == AdminIssueType.other && issueController.text.trim().isEmpty) {
      await showErrorSnackbar(context, 'Please choose your issue');
      return;
    }
 if (descriptionController.text.isEmpty) {
      await showErrorSnackbar(context, 'Please describe your issue');
      return;
    }



    setState(() => isLoading = true);

    log(widget.email);

    final res = await SupportRepo.instance.createTicket(
      subject: issue.value,
      description:
          descriptionController.text,
      category: issue.value,
      priority: 'LOW',
      contactEmail: widget.email,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (res.error != null) {
      await showErrorSnackbar(context, res.error!);
      return;
    }

    final ticketId = res.data!['data']['ticketId'].toString();

    await pushScreen(
      context,
      SupportChatScreen(ticketId: ticketId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

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
          child: ListView(
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
                      ...AdminIssueType.values.map((issue) {
                        return IssueRadio(
                          label: issue.label,
                          selected: selected == issue,
                          onTap: () => selectedIssue.value = issue,
                        );
                      }),
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

              15.verticalSpace,

              KFormField(
                label: 'Description',
                controller: descriptionController,
                minLines: 8,
                maxLines: 10,
                hintText: 'Type the issue you’d like help with here...',
              ),
              15.verticalSpace,
              WideButton(
                label: 'Continue',
                loading: isLoading,
                backgroundColor: appColors.primary.shade500,
                onPressed: isLoading ? null : () => _handleContinue(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
