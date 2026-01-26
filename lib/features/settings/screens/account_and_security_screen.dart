import 'package:resq360/__lib.dart';
import 'package:resq360/features/settings/screens/change_password_screen.dart';
import 'package:resq360/features/settings/widgets/delete_account_dialog.dart';

class AccountAndSecurityScreen extends StatelessWidget {
  const AccountAndSecurityScreen({
    required this.isProvider,
    super.key,
  });
  final bool isProvider;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        title: const GenText(
          'Account & Security',
          size: 20,
          weight: FontWeight.w600,
        ),
        centerTitle: true,
        backgroundColor: colors.whiteColor,
        foregroundColor: colors.black,
        elevation: 0,
      ),
      backgroundColor: colors.whiteColor,
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        children: [
          ListTile(
            leading: Icon(Icons.lock_outline, color: colors.black),
            title: const GenText('Change Password', weight: FontWeight.w500),
            trailing: Icon(
              Icons.chevron_right,
              color: colors.textColor.shade200,
            ),
            onTap: () async {
              await pushScreen(context, const ChangePasswordScreen());
            },
          ),

          Divider(
            height: 5,
            color: colors.textColor.shade100,
          ),
          ListTile(
            leading: Icon(
              Icons.delete_forever_outlined,
              color: colors.error.shade500,
            ),
            title: GenText(
              'Delete Account',
              color: colors.error.shade500,
              weight: FontWeight.w600,
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: colors.textColor.shade200,
            ),
            onTap: () async {
              await GeneralDialogs.showCustomDialog<void>(
                context,
                body: const DeleteAccountDialog(),
              );
            },
          ),
          Divider(
            height: 5,
            color: colors.textColor.shade100,
          ),
        ],
      ),
    );
  }
}
