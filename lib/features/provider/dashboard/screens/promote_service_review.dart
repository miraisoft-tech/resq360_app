import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/wallet_bloc/wallet_bloc.dart';
import 'package:resq360/core/theme/static_colors.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/advertisement_bloc/customer_advertisement_bloc.dart';
import 'package:resq360/features/customer/dashboard/screens/paystack_webview.dart';
import 'package:resq360/features/provider/dashboard/models/duration.enum.dart';
import 'package:resq360/features/widgets/dialogs/payment_finished.modal.dart';
import 'package:resq360/features/widgets/dialogs/payment_option.dialog.dart';

class PromoteServiceReviewScreen extends StatefulWidget {
  const PromoteServiceReviewScreen({
    required this.description,
    required this.discount,
    required this.duration,
    super.key,
  });
  final String description;
  final String discount;
  final PromotionDuration duration;

  @override
  State<PromoteServiceReviewScreen> createState() =>
      _PromoteServiceReviewScreenState();
}

class _PromoteServiceReviewScreenState
    extends State<PromoteServiceReviewScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerAdvertisementBloc>().add(FetchAdvertisementPrice());
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    var balance = '';
    return MultiBlocListener(
      listeners: [
        BlocListener<CustomerAdvertisementBloc, CustomerAdvertisementState>(
          listener: _handleAdvertisementState,
        ),
        BlocListener<WalletBloc, WalletState>(
          listener: (context, state) {
            if (state is FetchedWalletInfo) {
              balance = state.wallet.balance.toString();
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: appColors.whiteColor,
        appBar: AppBar(
          backgroundColor: appColors.whiteColor,
          forceMaterialTransparency: true,
          elevation: 0,
          leading: IconButton(
            onPressed: () => pop(context),
            icon: AppAssets.ASSETS_ICONS_BACK_ICON_SVG.svg,
          ),
          centerTitle: true,
          title: UrbText(
            'Promote Your Page',
            size: 22,
            height: 32.5,
            weight: FontWeight.w700,
            color: appColors.textColor.shade800,
          ),
          actions: const [SizedBox(width: 40)],
        ),
        body: SafeArea(
          child: Padding(
            padding: pad(horizontal: 16, vertical: 10),
            child: Col(
              children: [
                GenText(
                  'Review Your Promotion',
                  size: 16,
                  height: 24.5,
                  weight: FontWeight.w700,
                  color: appColors.textColor.shade800,
                ),
                20.verticalSpace,
                Container(
                  padding: pad(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    color: appColors.whiteColor,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: appColors.textColor.shade100,
                    ),
                  ),
                  child: Col(
                    children: [
                      GenText(
                        'Get ${widget.discount}% off every service today.',
                        height: 24.5,
                        weight: FontWeight.w400,
                        color: appColors.textColor.shade400,
                      ),
                      12.verticalSpace,
                      Row(
                        children: [
                          GenText(
                            'Discount:',
                            height: 24.5,
                            weight: FontWeight.w400,
                            color: appColors.textColor.shade400,
                          ),
                          const Spacer(),
                          GenText(
                            widget.discount,
                            height: 24.5,
                            weight: FontWeight.w500,
                            color: appColors.black,
                          ),
                        ],
                      ),
                      8.verticalSpace,
                      Row(
                        children: [
                          GenText(
                            'Duration:',
                            height: 24.5,
                            weight: FontWeight.w400,
                            color: appColors.textColor.shade400,
                          ),
                          const Spacer(),
                          GenText(
                            widget.duration.label,
                            height: 24.5,
                            weight: FontWeight.w500,
                            color: appColors.black,
                          ),
                        ],
                      ),
                      8.verticalSpace,
                      Row(
                        children: [
                          GenText(
                            'Promotion Fee:',
                            height: 24.5,
                            weight: FontWeight.w400,
                            color: appColors.textColor.shade400,
                          ),
                          const Spacer(),
                          BlocBuilder<
                            CustomerAdvertisementBloc,
                            CustomerAdvertisementState
                          >(
                            builder: (context, state) {
                              if (state is AdvertisementPriceFetched) {
                                return GenText(
                                  state.price.toString(),
                                  height: 24.5,
                                  weight: FontWeight.w500,
                                  color: appColors.black,
                                );
                              }
                              return GenText(
                                'loading',
                                height: 24.5,
                                weight: FontWeight.w500,
                                color: appColors.black,
                              );
                            },
                          ),
                        ],
                      ),
                      8.verticalSpace,
                      Row(
                        children: [
                          GenText(
                            'Total:',
                            height: 24.5,
                            weight: FontWeight.w400,
                            color: appColors.textColor.shade400,
                          ),
                          const Spacer(),
                          BlocBuilder<
                            CustomerAdvertisementBloc,
                            CustomerAdvertisementState
                          >(
                            builder: (context, state) {
                              if (state is AdvertisementPriceFetched) {
                                final price = state.price ?? 0;
                                final total = price * widget.duration.value;
                                return GenText(
                                  total.toString(),
                                  height: 24.5,
                                  weight: FontWeight.w500,
                                  color: appColors.black,
                                );
                              }
                              return const GenText('Calculating...');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
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
                    BlocBuilder<
                      CustomerAdvertisementBloc,
                      CustomerAdvertisementState
                    >(
                      builder: (context, state) {
                        final isLoaded = state is AdvertisementPriceFetched;

                        return Expanded(
                          child: WideButton(
                            label: isLoaded ? 'Pay Now' : 'Loading...',
                            backgroundColor: appColors.primary.shade500,
                            textColor: appColors.whiteColor,
                            onPressed:
                                isLoaded
                                    ? () async {
                                      final price = state.price ?? 0;
                                      final total =
                                          price * widget.duration.value;

                                      await GeneralDialogs.showCustomDialog<
                                        void
                                      >(
                                        context,
                                        body: PaymentOptionDialog(
                                          onPaymentSelected: (
                                            paymentMethod,
                                          ) async {
                                            await GeneralDialogs.showCustomDialog<
                                              void
                                            >(
                                              context,
                                              body: FinishPaymentDialog(
                                                amount: state.price.toString(),
                                                walletBalance:
                                                    double.parse(
                                                      balance,
                                                    ).toInt(),
                                                discount: widget.discount,
                                                duration: widget.duration,
                                                description: widget.description,
                                                paymentType: paymentMethod.name,
                                                total: total,
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    }
                                    : null,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAdvertisementState(
    BuildContext context,
    CustomerAdvertisementState state,
  ) async {
    if (state is CustomerAdvertisementLoading ||
        state is AdvertisementPaymentVerifying) {
      showLoadingDialog(context);
      return;
    }

    if (state is AdvertisementPaymentInitiatedState) {
      Navigator.pop(context);

      final completed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder:
              (_) => PaystackWebViewPage(
                authorizationUrl: state.payment.authorizationUrl,
                reference: state.payment.reference,
                callbackUrl: 'https://example.com/callback',
              ),
        ),
      );

      if (completed ?? false) {
        await _verifyAdvertisementPayment(state.payment.reference);
      } else {
        await showErrorSnackbar(context, 'Payment cancelled');
      }
      return;
    }

    if (state is AdvertisementCreated) {
      await pop(context);
      await GeneralDialogs.showCustomDialog<void>(
        context,
        body: PaymentFinished(
          onTap: () async {
            if (context.mounted) await pop(context);
            if (context.mounted) await pop(context);
            if (context.mounted) await pop(context);
          },
        ),
      );
      return;
    }

    if (state is CustomerAdvertisementError) {
      Navigator.pop(context);
      await showErrorSnackbar(context, state.error);
    }
  }

  Future<void> _verifyAdvertisementPayment(String reference) async {
    context.read<CustomerAdvertisementBloc>().add(
      VerifyAdvertisementPayment(reference: reference),
    );
  }
}

class FinishPaymentDialog extends StatefulWidget {
  const FinishPaymentDialog({
    required this.amount,
    required this.walletBalance,
    required this.discount,
    required this.duration,
    required this.description,
    required this.paymentType,
    required this.total,
    super.key,
  });

  final String amount;
  final int walletBalance;
  final String discount;
  final PromotionDuration duration;
  final String description;
  final String paymentType;
  final int total;

  @override
  State<FinishPaymentDialog> createState() => _FinishPaymentDialogState();
}

class _FinishPaymentDialogState extends State<FinishPaymentDialog> {
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final fee = int.parse(widget.amount) * widget.duration.value;
    final remaining = widget.walletBalance - fee;

    return Padding(
      padding: EdgeInsets.only(top: 220.h, bottom: 200.h),
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
                      'Promotion Fee',
                      weight: FontWeight.w500,
                      color: appColors.black,
                    ),
                    10.verticalSpace,
                    GenText(
                      '₦${widget.amount}',
                      weight: FontWeight.w500,
                      color: appColors.black,
                    ),
                  ],
                ),
              ),
              if (widget.paymentType == PaymentMethod.wallet.name) ...[
                20.verticalSpace,
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
                      Row(
                        children: [
                          GenText(
                            'Wallet Balance',
                            weight: FontWeight.w500,
                            color: appColors.black,
                          ),
                          const Spacer(),
                          GenText(
                            '₦${widget.walletBalance}',
                            weight: FontWeight.w500,
                            color: appColors.black,
                          ),
                        ],
                      ),
                      10.verticalSpace,
                      Row(
                        children: [
                          GenText(
                            'Total Fee:',
                            weight: FontWeight.w500,
                            color: appColors.neutral.shade500,
                          ),
                          const Spacer(),
                          GenText(
                            '₦${widget.total}',
                            weight: FontWeight.w500,
                            color: appColors.neutral.shade500,
                          ),
                        ],
                      ),
                      10.verticalSpace,
                      Row(
                        children: [
                          GenText(
                            'Remaining Balance:',
                            weight: FontWeight.w500,
                            color: appColors.neutral.shade500,
                          ),
                          const Spacer(),
                          GenText(
                            '₦$remaining',
                            weight: FontWeight.w500,
                            color:
                                remaining >= 0
                                    ? appColors.success.shade600
                                    : appColors.error.shade600,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              40.verticalSpace,
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
                      label: 'Pay ₦${widget.total}',
                      backgroundColor: appColors.primary.shade500,
                      textColor: appColors.whiteColor,
                      onPressed: () async {
                        Navigator.pop(context);

                        if (widget.paymentType == PaymentMethod.wallet.name) {
                          await _payWithWallet();
                        } else {
                          await _payWithCard();
                        }
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

  Future<void> _payWithWallet() async {
    final balance = widget.walletBalance;
    final total = widget.total;

    if (balance < total) {
      await showErrorSnackbar(context, 'Insufficient balance');
      return;
    }

    context.read<CustomerAdvertisementBloc>().add(
      CreateAdvertisement(
        discount: int.parse(widget.discount),
        duration: widget.duration.milliseconds,
        paymentMethod: PaymentMethod.wallet.name,
        description: widget.description,
      ),
    );
  }

  Future<void> _payWithCard() async {
    context.read<CustomerAdvertisementBloc>().add(
      CreateAdvertisement(
        discount: int.parse(widget.discount),
        duration: widget.duration.milliseconds,
        paymentMethod: PaymentMethod.new_card.name,

        description: widget.description,
      ),
    );
  }
}
