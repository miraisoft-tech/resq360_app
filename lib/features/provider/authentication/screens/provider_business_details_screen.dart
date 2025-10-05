import 'package:resq360/__lib.dart';
import 'package:resq360/features/provider/authentication/screens/confirm_email_screen.dart';
import 'package:resq360/features/widgets/scaffolds/app_scaffold.dart';

class ProviderBusinessDetailsScreen extends StatefulWidget {
  const ProviderBusinessDetailsScreen({super.key});

  @override
  State<ProviderBusinessDetailsScreen> createState() =>
      _ProviderBusinessDetailsScreenState();
}

class _ProviderBusinessDetailsScreenState
    extends State<ProviderBusinessDetailsScreen> {
  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController otherController;

  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<String?> _selectType = ValueNotifier(null);

  final List<String> categories = [
    'Towing',
    'Cleaning',
    'Mechanic',
    'Electrician',
    'Other',
  ];
  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    addressController = TextEditingController();
    otherController = TextEditingController();

    // WidgetsBinding.instance.addPostFrameCallback(
    //   (_) => AppTrackingPermissionHandler.requestTrackingPermisssion(),
    // );
  }

  @override
  void dispose() {
    super.dispose();

    addressController.dispose();
    nameController.dispose();
    otherController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppScaffold(
      title: 'Business Details',
      subTitle: 'Tell us more about your business',
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KFormField(
              label: 'Business Name',
              hintText: 'Enter Your Business Name',
              controller: nameController,
              keyboardType: TextInputType.name,
              onChanged: (a) {
                setState(() {});
              },
            ),
            16.verticalSpace,
            KFormField(
              label: 'Business Address',
              hintText: 'Enter Your Business Address',
              controller: addressController,
              keyboardType: TextInputType.name,
              onChanged: (a) {
                setState(() {});
              },
            ),
            16.verticalSpace,
            ValueListenableBuilder<String?>(
              valueListenable: _selectType,
              builder: (
                BuildContext context,
                String? value,
                Widget? child,
              ) {
                return ObjectKDropDown(
                  label: 'Service Category ',
                  hintText: 'select a service category',
                  displayStringForOption: (String? id) => id ?? '',
                  showPrefix: false,
                  value: value,
                  dropdownItems: categories,
                  onChanged: (value) {
                    setState(() {
                      _selectType.value = value;
                    });
                  },
                );
              },
            ),
            30.verticalSpace,
            GenText(
              'Choose a primary service, you can add more services later in settings.',
              size: 12,
              height: 16.5,
              weight: FontWeight.w400,
              color: colors.textColor.shade500,
            ),
            16.verticalSpace,
            if (_selectType.value == 'Other')
              KFormField(
                label: 'Specify Service',
                hintText: 'Enter Your Service Name',
                controller: otherController,
                keyboardType: TextInputType.text,
                onChanged: (a) {
                  setState(() {});
                },
              ),
            const Spacer(),
            WideButton(
              label: 'Continue',
              onPressed: () async {
                await pushScreen(
                  context,
                  ConfirmEmailScreen(
                    email: addressController.text,
                  ),
                );
              },
            ),
            30.verticalSpace,
            Center(
              child: GestureDetector(
                onTap: () {
                  log('Navigate to login');
                },
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: colors.textColor.shade500),
                    children: [
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(
                          fontFamily: 'inter',
                          fontSize: 12.sp,
                          color: colors.neutral.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: 'Log in',
                        style: TextStyle(
                          fontFamily: 'inter',
                          fontSize: 12.sp,
                          color: colors.primary.shade500,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
