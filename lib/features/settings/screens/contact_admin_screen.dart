import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/settings/data/models/admin_types.enums.dart';
import 'package:resq360/features/settings/data/service/support_service.dart';
import 'package:resq360/features/widgets/issue_radio_widget.dart';

class ContactAdminScreen extends StatefulWidget {
  const ContactAdminScreen({super.key, this.issueType, this.serviceCategory, this.relatedServiceProviderId});
  final AdminIssueType? issueType;
  final int? serviceCategory;
  final int? relatedServiceProviderId;

  @override
  State<ContactAdminScreen> createState() => _ContactAdminScreenState();
}

class _ContactAdminScreenState extends State<ContactAdminScreen> {
  final issueController = TextEditingController();
  final descriptionController = TextEditingController();

  final selectedIssue = ValueNotifier<AdminIssueType?>(null);

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    issueController.dispose();
    selectedIssue.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<String?> _getEmail() async {
    var email = '';
    final cred = await AuthLocalRepo.instance.getLocalCredentials();
    if (cred != null) {
      email = cred.userName ?? '';
    }
    return email;
  }
  

Future<void> _handleContinue(BuildContext context) async {
  final issue = selectedIssue.value;

  if (issue == null) {
    return showErrorSnackbar(context, 'Please select an issue');
  }

  if (issue == AdminIssueType.other && issueController.text.trim().isEmpty) {
    return showErrorSnackbar(context, 'Please choose your issue');
  }

  if (descriptionController.text.isEmpty) {
    return showErrorSnackbar(context, 'Please describe your issue');
  }

  setState(() => isLoading = true);

  final email = await _getEmail();

  int? serviceCategory;
  int? relatedServiceProviderId;

if (widget.issueType != null &&
    widget.issueType == AdminIssueType.serviceIssue) {
  serviceCategory = widget.serviceCategory;
  relatedServiceProviderId = widget.relatedServiceProviderId;
}


  final res = await SupportRepo.instance.createTicket(
    subject: issue == AdminIssueType.other ? issueController.text.trim() : issue.value,
    description: descriptionController.text.trim(),
    category: issue.value,
    priority: issue.priority,
    contactEmail: email ?? '',
    serviceCategory: serviceCategory,
    relatedServiceProviderId: relatedServiceProviderId,
  );

  if (!mounted) return;

  setState(() => isLoading = false);

  if (res.error != null) {
    return showErrorSnackbar(context, res.error!);
  }

  await showSuccessSnackbar(
    context,
    'Ticket has been sent, check email for response',
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
