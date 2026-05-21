import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/booking_bloc/booking_bloc.dart';
import 'package:resq360/core/models/booking_enums.dart';
import 'package:resq360/core/utils/dialer_util.dart';
import 'package:resq360/features/chat/data/models/chat_models.dart';
import 'package:resq360/features/chat/screens/chat_details_screen.dart';
import 'package:resq360/features/chat/screens/payment_appeal.dialog.dart';
import 'package:resq360/features/chat/screens/service_cancelled_screen.dart';
import 'package:resq360/features/customer/bookings/screens/rate_provider_screen.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/provider/bookings/screens/client_service_completed_screen.dart';
import 'package:resq360/features/settings/data/bloc/ratings_bloc/ratings_bloc.dart';
import 'package:resq360/features/settings/data/service/support_service.dart';

class ChatServiceDetailScreen extends StatefulWidget {
  const ChatServiceDetailScreen({
    required this.chat,
    required this.message,
    required this.userType,
    super.key,
  });

  final ChatResponse chat;
  final MessageResponse message;
  final UserType userType;

  @override
  State<ChatServiceDetailScreen> createState() =>
      _ChatServiceDetailScreenState();
}

class _ChatServiceDetailScreenState extends State<ChatServiceDetailScreen> {
  bool get _isProvider => widget.userType == UserType.provider;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchRatings());
  }

  void _fetchRatings() {
    final providerId = widget.chat.provider?.id;
    final userId = widget.chat.user?.id;

    if (providerId != null) {
      context.read<RatingsBloc>().add(
        FetchProviderRatingsById(providerId: providerId),
      );
    }

    if (userId != null) {
      context.read<RatingsBloc>().add(FetchCustomerRatingsById(userId: userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    final clientName = widget.chat.user?.fullName ?? '';

    final serviceRequestId = widget.chat.serviceRequestId;

    final serviceCategory = widget.chat.serviceName ?? 'service';

    final metadata = widget.message.metadata;

    final invoiceId = metadata?.invoiceId ?? 'N/A';

    final price = metadata?.amount ?? 0;

    final providerPhoneNumber = widget.chat.provider?.phoneNumber ?? '';

    final status = widget.chat.serviceRequestStatus;

    final providerId = widget.chat.provider?.id;
    final providerName = widget.chat.provider?.fullName ?? '';

    final isAssigned =
        status?.toUpperCase() == BookingEnums.assigned.name.toUpperCase();

    final isProgress =
        status?.toUpperCase() == BookingEnums.progress.name.toUpperCase();

    final isCompleted =
        status?.toUpperCase() == BookingEnums.completed.name.toUpperCase();

    final canCancel = !isCompleted;

    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) async {
        if (state is BookingLoading) {
          showLoadingDialog(context);
        }

        if (state is BookingStarted) {
          Navigator.pop(context);

          await showSuccessSnackbar(context, 'Service has started');

          Navigator.pop(context);
        }

        if (state is BookingCompleted) {
          Navigator.pop(context);

          await showSuccessSnackbar(
            context,
            'Service has been marked as completed',
          );
        }

        if (state is BookingError) {
          Navigator.pop(context);

          await showErrorSnackbar(context, state.error);
        }
      },
      child: Scaffold(
        backgroundColor: appColors.whiteColor,
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: UrbText(
            'Service Details',
            color: appColors.black,
            weight: FontWeight.w700,
            size: 22,
            height: 32.5,
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: appColors.whiteColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: appColors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 50.h),
          child: Column(
            children: [
              16.verticalSpace,

              BlocBuilder<RatingsBloc, RatingsState>(
                builder: (context, state) {
                  if (state is! RatingsLoaded) {
                    return const SizedBox();
                  }

                  final loaded = state;

                  final providerRating =
                      loaded.providerRatings?.averageRatings?.toStringAsFixed(
                        1,
                      ) ??
                      '0.0';

                  final providerReviews =
                      '(${loaded.providerRatings?.totalReviews ?? 0} reviews)';

                  return _ServiceCard(
                    name: providerName,
                    subtitle: serviceCategory,
                    rating: providerRating,
                    reviewCount: providerReviews,
                    avatar: widget.chat.provider?.profileImage ?? '',
                    phoneNumber: providerPhoneNumber,
                    showActions: true,
                  );
                },
              ),

              12.verticalSpace,

              BlocBuilder<RatingsBloc, RatingsState>(
                builder: (context, state) {
                  final loaded =
                      state is RatingsLoaded ? state : const RatingsLoaded();
                  final customerRating =
                      loaded.customerRatings?.averageRatings?.toStringAsFixed(
                        1,
                      ) ??
                      '0.0';
                  final customerReviews =
                      '(${loaded.customerRatings?.totalReviews ?? 0} reviews)';

                  return _ServiceCard(
                    name: clientName,
                    subtitle: '',
                    rating: customerRating,
                    reviewCount: customerReviews,
                    avatar: widget.chat.user?.profileImage ?? '',
                    showActions: true,
                  );
                },
              ),

              16.verticalSpace,

              Container(
                width: double.infinity,
                padding: pad(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: appColors.textColor.shade100),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GenText(
                          'Invoice No.',
                          color: appColors.textColor.shade400,
                          size: 13,
                        ),
                        GenText(
                          'Total Cost',
                          color: appColors.textColor.shade400,
                          size: 13,
                        ),
                      ],
                    ),

                    2.verticalSpace,

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GenText(
                          invoiceId,
                          color: appColors.black,
                          weight: FontWeight.w500,
                        ),
                        GenText(
                          price.toString(),
                          color: appColors.black,
                          weight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Row(
                children: [
                  if (!isCompleted) ...[
                    if (canCancel) ...[
                      Expanded(
                        child: WideButton(
                          label: 'Cancel',
                          backgroundColor: appColors.primary.shade50,
                          textColor: appColors.primary.shade500,
                          onPressed: () async {
                            if (serviceRequestId == null) return;

                            await pushScreen(
                              context,
                              ServiceCancelledScreen(
                                serviceRequestId: serviceRequestId,
                              ),
                            );
                          },
                        ),
                      ),
                      12.horizontalSpace,
                    ],

                    Expanded(
                      child: WideButton(
                        label:
                            _isProvider
                                ? (isAssigned ? 'Start Service' : 'Complete')
                                : 'Appeal',
                        backgroundColor: appColors.primary.shade500,
                        textColor: appColors.whiteColor,
                        onPressed: () async {
                          if (_isProvider) {
                            if (isAssigned) {
                              context.read<BookingBloc>().add(
                                StartBooking(
                                  serviceRequestId: serviceRequestId!,
                                ),
                              );
                            } else if (isProgress) {
                              await pushScreen(
                                context,
                                ClientServiceCompletedScreen(
                                  serviceRequestId: serviceRequestId!,
                                ),
                              );
                            }
                          } else {
                            await _handleAppeal(context, serviceRequestId);
                          }
                        },
                      ),
                    ),
                  ],

                  if (isCompleted) ...[
                    Expanded(
                      child: WideButton(
                        label: 'Appeal',
                        backgroundColor: appColors.primary.shade50,
                        textColor: appColors.primary.shade500,
                        onPressed: () async {
                          await _handleAppeal(context, serviceRequestId);
                        },
                      ),
                    ),
                    12.horizontalSpace,
                    if (!_isProvider)
                      Expanded(
                        child: WideButton(
                          label: 'Rate',
                          backgroundColor: appColors.primary.shade500,
                          textColor: appColors.whiteColor,
                          onPressed: () async {
                            if (serviceRequestId == null ||
                                providerId == null) {
                              return;
                            }

                            await pushScreen(
                              context,
                              RateProviderScreen(
                                serviceRequestId: serviceRequestId,
                                providerId: providerId,
                                providerName: providerName,
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAppeal(
    BuildContext context,
    int? serviceRequestId,
  ) async {
    if (serviceRequestId == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => PaymentAppealDialog(isProvider: _isProvider),
    );

    if (confirmed != true) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    showLoadingDialog(context);

    final result = await SupportRepo.instance.fileDispute(
      requestId: serviceRequestId,
      reason: 'Service Appeal',
      details:
          '${_isProvider ? 'Provider' : 'Customer'} filed an appeal for service request #$serviceRequestId',
    );

    if (!context.mounted) {
      return;
    }

    Navigator.pop(context);

    if (result.error != null) {
      await showErrorSnackbar(context, result.error!);

      return;
    }

    final chatId = result.data!;

    await pushScreen(
      context,
      ChatDetailScreen(chatId: chatId, userType: widget.userType),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.name,
    required this.subtitle,
    required this.rating,
    required this.reviewCount,
    required this.avatar,
    this.phoneNumber,
    this.showActions = false,
  });

  final String name;
  final String subtitle;
  final String rating;
  final String reviewCount;
  final String avatar;
  final bool showActions;
  final String? phoneNumber;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      padding: pad(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: appColors.textColor.shade100),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          PictureWidget(image: avatar),

          12.horizontalSpace,

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GenText(name, weight: FontWeight.w500, color: appColors.black),

                if (subtitle.isNotEmpty) ...[
                  2.verticalSpace,

                  GenText(
                    subtitle,
                    color: appColors.textColor.shade400,
                    size: 12,
                    height: 20.5,
                  ),
                ],

                2.verticalSpace,

                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),

                    4.horizontalSpace,

                    GenText(
                      rating,
                      size: 12,
                      color: appColors.textColor.shade400,
                    ),

                    4.horizontalSpace,

                    GenText(
                      reviewCount,
                      size: 12,
                      color: appColors.neutral.shade300,
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (showActions && phoneNumber != null) ...[
            8.horizontalSpace,

            SVGButton(
              path: AppAssets.ASSETS_ICONS_CALL_ICON_SVG,
              onTap: () async => DialerUtil.open(phoneNumber!),
              color: appColors.primary.shade500,
            ),
          ],
        ],
      ),
    );
  }
}
