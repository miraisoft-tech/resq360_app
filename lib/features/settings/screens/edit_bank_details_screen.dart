import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/dashboard/data/models/bank/bank_details.model.dart';
import 'package:resq360/features/settings/data/bloc/bank_bloc/bloc/bank_bloc.dart';
import 'package:resq360/features/widgets/scaffolds/app_scaffold.dart';

class EditBankDetailScreen extends StatefulWidget {
  const EditBankDetailScreen({required this.bank, super.key});
  final BankDetails bank;

  @override
  State<EditBankDetailScreen> createState() => _EditBankDetailScreenState();
}

class _EditBankDetailScreenState extends State<EditBankDetailScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController numberCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.bank.accountName);
    numberCtrl = TextEditingController(text: widget.bank.accountNumber);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    numberCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return AppScaffold(
      title: 'Edit Bank Details',
      body: Padding(
        padding: pad(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            KFormField(
              label: 'Account Name',
              controller: nameCtrl,
              hintText: 'Enter account name',
            ),
            16.verticalSpace,
            KFormField(
              label: 'Account Number',
              controller: numberCtrl,
              hintText: 'Enter account number',
            ),
            16.verticalSpace,
            BlocBuilder<BankBloc, BankState>(
              builder: (context, state) {
                return WideButton(
                  label: 'Save Changes',
                  loading: state is BankLoading,
                  onPressed: () {
                    context.read<BankBloc>().add(
                      BankUpdateAccount(
                        id: widget.bank.id!,
                        accountName: nameCtrl.text.trim(),
                        accountNumber: numberCtrl.text.trim(),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
