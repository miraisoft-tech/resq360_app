import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/core/theme/static_colors.dart';
import 'package:resq360/features/chat/data/models/chat_models.dart';
import 'package:resq360/features/chat/screens/payment_completed.dialog.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/local_user.model.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/payment_bloc/customer_payment_bloc.dart';

class CompletePaymentDialog extends StatefulWidget {
  const CompletePaymentDialog({required this.amount, super.key});

  final String amount;

  @override
  State<CompletePaymentDialog> createState() => _CompletePaymentDialogState();
}

class _CompletePaymentDialogState extends State<CompletePaymentDialog> {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Padding(
      padding: EdgeInsets.only(top: 200.h, bottom: 200.h),
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: pad(horizontal: 20),
          padding: pad(horizontal: 25, vertical: 25),
          decoration: BoxDecoration(
            color: appColors.whiteColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      AppAssets.ASSETS_ICONS_PAYMENT_EXISTING_CARD_SVG.svg,
                      10.horizontalSpace,
                      GenText(
                        'Complete Payment',
                        weight: FontWeight.w500,
                        color: appColors.black,
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: appColors.textColor.shade400,
                    ),
                  ),
                ],
              ),
              14.verticalSpace,
              Container(
                width: double.infinity,
                padding: pad(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GenText(
                      'Quick Tow Emergency',
                      weight: FontWeight.w500,
                      color: appColors.black,
                    ),
                    2.verticalSpace,
                    GenText(
                      'Gwarimpa highway - Olympia Street',
                      size: 12,
                      color: appColors.textColor.shade400,
                    ),
                    8.verticalSpace,
                    GenText(
                      widget.amount,
                      weight: FontWeight.w500,
                      color: appColors.black,
                    ),
                  ],
                ),
              ),
              20.verticalSpace,
              KFormField(
                label: 'Card Number',
                hintText: '1234 5678 8123 4567',
                controller: cardNumberController,
                keyboardType: TextInputType.number,
              ),
              12.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: KFormField(
                      label: 'Expiry',
                      hintText: 'MM/YY',
                      controller: expiryController,
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: KFormField(
                      label: 'CVV',
                      hintText: '123',
                      controller: cvvController,
                      keyboardType: TextInputType.number,
                      type: InputType.password,
                    ),
                  ),
                ],
              ),
              24.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: WideButton(
                      label: 'Cancel',
                      backgroundColor: appColors.primary.shade50,
                      textColor: appColors.primary.shade500,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: WideButton(
                      label: 'Pay ${widget.amount}',
                      backgroundColor: appColors.primary.shade500,
                      textColor: appColors.whiteColor,
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await GeneralDialogs.showCustomDialog<void>(
                          context,
                          body: const PaymentCompleted(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ClientPaymentConfirmDialog extends StatefulWidget {
  const ClientPaymentConfirmDialog({
    required this.title,
    required this.amount,
    required this.invoiceNumber,
    required this.message,
    required this.chatId,
    required this.paymentMethod,
    super.key,
  });

  final String title;
  final int amount;
  final String invoiceNumber;
  final MessageResponse message;
  final int chatId;
  final String paymentMethod;

  @override
  State<ClientPaymentConfirmDialog> createState() =>
      _ClientPaymentConfirmDialogState();
}

class _ClientPaymentConfirmDialogState
    extends State<ClientPaymentConfirmDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(getCurrentUser());
    });
  }

  late final String? email;

  Future<LocalUser?> getCurrentUser() async {
    final user = await AuthLocalRepo.instance.getLocalCredentials();
    email = user?.userName;
    return user;
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Padding(
      padding: EdgeInsets.only(top: 200.h, bottom: 150.h),
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: pad(horizontal: 20),
          padding: pad(horizontal: 25, vertical: 25),
          decoration: BoxDecoration(
            color: appColors.whiteColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GenText(
                    'Complete Payment',
                    weight: FontWeight.w700,
                    color: appColors.black,
                    size: 16,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: appColors.textColor.shade400,
                    ),
                  ),
                ],
              ),

              12.verticalSpace,

              GenText(
                widget.title,
                size: 15,
                weight: FontWeight.w600,
                color: appColors.black,
              ),
              4.verticalSpace,
              GenText(
                'Invoice No: ${widget.invoiceNumber}',
                size: 13,
                color: appColors.textColor.shade400,
              ),
              4.verticalSpace,
              GenText(
                '₦${widget.amount}',
                size: 22,
                weight: FontWeight.w700,
                color: appColors.black,
              ),

              20.verticalSpace,

              Row(
                children: [
                  Expanded(
                    child: WideButton(
                      label: 'Cancel',
                      backgroundColor: appColors.primary.shade50,
                      textColor: appColors.primary.shade500,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: WideButton(
                      label: 'Pay ₦${widget.amount}',
                      backgroundColor: appColors.primary.shade500,
                      textColor: appColors.whiteColor,
                      onPressed: () {
                        Navigator.pop(context);

                        context.read<CustomerPaymentBloc>().add(
                          CustomerInitServiceRequestPaymentEvent(
                            chatId: widget.chatId,
                            invoiceMessageId: widget.message.id!,
                            paymentMethod: widget.paymentMethod,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
