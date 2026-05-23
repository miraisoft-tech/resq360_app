import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/wallet_bloc/wallet_bloc.dart';
import 'package:resq360/core/theme/static_colors.dart';
import 'package:resq360/core/utils/app_constant.dart';
import 'package:resq360/core/utils/app_text.util.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/promotion_bloc/promotion_bloc.dart';
import 'package:resq360/features/customer/dashboard/screens/paystack_webview.dart';
import 'package:resq360/features/provider/authentication/data/bloc/provider_auth_bloc.dart';
import 'package:resq360/features/provider/dashboard/models/duration.enum.dart';
import 'package:resq360/features/widgets/dialogs/payment_finished.modal.dart';
import 'package:resq360/features/widgets/dialogs/payment_option.dialog.dart';

class PromoteServiceReviewScreen extends StatefulWidget {
  const PromoteServiceReviewScreen({
    required this.promotionDescription,
    required this.discount,
    required this.duration,
    super.key,
  });
  final String promotionDescription;
  final String discount;
  final PromotionDuration duration;

  @override
  State<PromoteServiceReviewScreen> createState() =>
      _PromoteServiceReviewScreenState();
}

class _PromoteServiceReviewScreenState
    extends State<PromoteServiceReviewScreen> {
  bool _isLoadingDialogVisible = false;
  bool _isLoadingDialogScheduled = false;
  bool _dismissLoadingDialogWhenShown = false;
  bool _isPaymentFlowRunning = false;
  BuildContext? _loadingDialogContext;

  @override
  void initState() {
    super.initState();
    context.read<PromotionBloc>().add(FetchPromotionPrice());
  }

  @override
  void dispose() {
    final loadingDialogContext = _loadingDialogContext;
    if (loadingDialogContext != null) {
      final navigator = Navigator.of(loadingDialogContext, rootNavigator: true);
      if (navigator.canPop()) {
        navigator.pop();
      }
    } else if (_isLoadingDialogScheduled) {
      _dismissLoadingDialogWhenShown = true;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    var balance = '';
    return MultiBlocListener(
      listeners: [
        BlocListener<PromotionBloc, PromotionState>(
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
                    border: Border.all(color: appColors.textColor.shade100),
                  ),
                  child: Col(
                    children: [
                      GenText(
                        'Get ${widget.discount}% off today.',
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
                          BlocBuilder<PromotionBloc, PromotionState>(
                            builder: (context, state) {
                              if (state is PromotionPriceFetched) {
                                return GenText(
                                  '₦ ${AppTextUtil.formatAmount(state.price.toString())}',
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
                          BlocBuilder<PromotionBloc, PromotionState>(
                            builder: (context, state) {
                              if (state is PromotionPriceFetched) {
                                final price = state.price;
                                // final duration = widget.duration.value;
                                final total = price * widget.duration.value;
                                final formattedTotal = AppTextUtil.formatAmount(
                                  total.toString(),
                                );
                                // print('price: $price, total: $total, formattedtotal: $formattedTotal, duration ${widget.duration.value}'  );
                                return GenText(
                                  '₦ $formattedTotal',
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
                    BlocBuilder<PromotionBloc, PromotionState>(
                      builder: (context, state) {
                        final isLoaded = state is PromotionPriceFetched;

                        return Expanded(
                          child: WideButton(
                            label: isLoaded ? 'Pay Now' : 'Loading...',
                            backgroundColor: appColors.primary.shade500,
                            textColor: appColors.whiteColor,
                            onPressed:
                                isLoaded
                                    ? () async {
                                      final price = state.price;
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
                                                    double.tryParse(
                                                      balance,
                                                    )?.toInt() ??
                                                    0,
                                                discount: widget.discount,
                                                duration: widget.duration,
                                                promotionDescription:
                                                    widget.promotionDescription,
                                                paymentType: paymentMethod.name,
                                                total: total,
                                                onPaymentStarted:
                                                    () =>
                                                        _isPaymentFlowRunning =
                                                            true,
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
    PromotionState state,
  ) async {
    if (!mounted) return;

    final shouldShowPaymentLoader =
        _isPaymentFlowRunning &&
        (state is PromotionLoading || state is PromotionPaymentVerifying);

    if (shouldShowPaymentLoader) {
      _showLoadingDialog(context);
      return;
    }

    await _hideLoadingDialog();

    if (state is PromotionPaymentInitiated) {
      if (!mounted) return;

      final completed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder:
              (_) => PaystackWebViewPage(
                authorizationUrl: state.payment.authorizationUrl,
                reference: state.payment.reference,
                callbackUrl: AppConstants.paystackCallbackUrl,
              ),
        ),
      );

      if (!mounted) return;

      if (completed ?? false) {
        await _verifyAdvertisementPayment(state.payment.reference);
      } else {
        await showErrorSnackbar(context, 'Payment cancelled');
      }
      return;
    }

    if (state is PromotionCreated) {
      _isPaymentFlowRunning = false;

      if (!mounted) return;

      if (!mounted) return;

      await GeneralDialogs.showCustomDialog<void>(
        context,
        body: PaymentFinished(
          onTap: () async {
            if (mounted) await pop(context);
            if (mounted) await pop(context);
            if (mounted) await pop(context);
          },
        ),
      );
      return;
    }

    if (state is PromotionError) {
      _isPaymentFlowRunning = false;

      if (mounted) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;
        await showErrorSnackbar(context, state.error);
        if (mounted) {
          context.read<PromotionBloc>().add(FetchPromotionPrice());
        }
      }
    }
  }

  void _showLoadingDialog(BuildContext context) {
    if (!mounted || _isLoadingDialogVisible || _isLoadingDialogScheduled) {
      return;
    }

    _isLoadingDialogScheduled = true;
    _dismissLoadingDialogWhenShown = false;

    unawaited(
      showDialog<void>(
        context: context,
        barrierColor: const Color.fromRGBO(173, 173, 173, 0.23),
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          _loadingDialogContext = dialogContext;
          _isLoadingDialogVisible = true;

          if (_dismissLoadingDialogWhenShown) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final navigator = Navigator.of(
                dialogContext,
                rootNavigator: true,
              );
              if (navigator.canPop()) {
                navigator.pop();
              }
            });
          }

          return const Center(child: ActivityDialogWidget());
        },
      ).whenComplete(() {
        _loadingDialogContext = null;
        _isLoadingDialogVisible = false;
        _isLoadingDialogScheduled = false;
        _dismissLoadingDialogWhenShown = false;
      }),
    );
  }

  Future<void> _hideLoadingDialog() async {
    if (!_isLoadingDialogVisible && !_isLoadingDialogScheduled) return;

    final loadingDialogContext = _loadingDialogContext;
    if (loadingDialogContext == null) {
      _dismissLoadingDialogWhenShown = true;
      return;
    }

    final navigator = Navigator.of(loadingDialogContext, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
      await Future<void>.delayed(Duration.zero);
    }
  }

  Future<void> _verifyAdvertisementPayment(String reference) async {
    if (!mounted) return;

    context.read<PromotionBloc>().add(
      VerifyPromotionPayment(reference: reference),
    );
  }
}

class FinishPaymentDialog extends StatefulWidget {
  const FinishPaymentDialog({
    required this.amount,
    required this.walletBalance,
    required this.discount,
    required this.duration,
    required this.promotionDescription,
    required this.paymentType,
    required this.total,
    this.onPaymentStarted,
    super.key,
  });

  final String amount;
  final num walletBalance;
  final String discount;
  final PromotionDuration duration;
  final String promotionDescription;
  final String paymentType;
  final int total;
  final VoidCallback? onPaymentStarted;

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
      padding: EdgeInsets.only(top: 270.h, bottom: 270.h),
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
                      '₦${AppTextUtil.formatAmount(widget.amount)}',
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
                            '₦${AppTextUtil.formatAmount(widget.walletBalance.toString())}',
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
                            '₦${AppTextUtil.formatAmount(widget.total.toString())}',
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
                            '₦${AppTextUtil.formatAmount(remaining.toString())}',
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
                      label:
                          'Pay ₦${AppTextUtil.formatAmount(widget.total.toString())}',
                      backgroundColor: appColors.primary.shade500,
                      textColor: appColors.whiteColor,
                      onPressed: () async {
                        final promotionBloc = context.read<PromotionBloc>();
                        final isWalletPayment =
                            widget.paymentType == PaymentMethod.wallet.name;

                        if (isWalletPayment &&
                            widget.walletBalance < widget.total) {
                          await showErrorSnackbar(
                            context,
                            'Insufficient balance',
                          );
                          return;
                        }

                        await Navigator.of(
                          context,
                          rootNavigator: true,
                        ).maybePop();
                        await Future<void>.delayed(Duration.zero);

                        widget.onPaymentStarted?.call();

                        if (isWalletPayment) {
                          _payWithWallet(promotionBloc);
                          return;
                        }

                        _payWithCard(promotionBloc);
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

  int? _resolveProviderServiceId() {
    final authState = context.read<ProviderAuthBloc>().state;
    if (authState is ProviderProfileLoadedState) {
      final services = authState.user.providerServices ?? [];
      final active = services.where((s) => s.id != null && s.isActive);
      if (active.isNotEmpty) return active.first.id;
      if (services.isNotEmpty) return services.first.id;
    }
    return null;
  }

  void _payWithWallet(PromotionBloc promotionBloc) {
    promotionBloc.add(
      CreatePromotion(
        providerServiceId: _resolveProviderServiceId(),
        discountPercentage: int.parse(widget.discount),
        durationInMilliSeconds: widget.duration.milliseconds,
        paymentMethod: PaymentMethod.wallet.name,
        description: widget.promotionDescription,
      ),
    );
  }

  void _payWithCard(PromotionBloc promotionBloc) {
    promotionBloc.add(
      CreatePromotion(
        providerServiceId: _resolveProviderServiceId(),
        discountPercentage: int.parse(widget.discount),
        durationInMilliSeconds: widget.duration.milliseconds,
        paymentMethod: PaymentMethod.new_card.name,
        description: widget.promotionDescription,
      ),
    );
  }
}
