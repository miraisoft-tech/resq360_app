import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/booking_bloc/booking_bloc.dart';
import 'package:resq360/core/models/booking_enums.dart';
import 'package:resq360/core/utils/app_text.util.dart';
import 'package:resq360/core/utils/dialer_util.dart';
import 'package:resq360/features/chat/data/services/chat_repo.dart';
import 'package:resq360/features/chat/screens/chat_details_screen.dart';
import 'package:resq360/features/chat/screens/payment_appeal.dialog.dart';
import 'package:resq360/features/chat/screens/service_completed_screen.dart';
import 'package:resq360/features/customer/dashboard/data/models/bookings/booking.model.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/main_layout_provider.dart';
import 'package:resq360/features/provider/bookings/screens/cancel_client_service_screen.dart';
import 'package:resq360/features/settings/data/bloc/ratings_bloc/ratings_bloc.dart';
import 'package:resq360/features/settings/data/service/support_service.dart';

class ProviderServiceDetailScreen extends StatefulWidget {
  const ProviderServiceDetailScreen({required this.booking, super.key});

  final Bookings booking;
  @override
  State<ProviderServiceDetailScreen> createState() =>
      _ProviderServiceDetailScreenState();
}

class _ProviderServiceDetailScreenState
    extends State<ProviderServiceDetailScreen> {
  @override
  void initState() {
    super.initState();
    _fetchRatings();
  }

  void _fetchRatings() {
    if (widget.booking.assignedProviderId != null) {
      context.read<RatingsBloc>().add(
        FetchProviderRatingsById(
          providerId: widget.booking.assignedProviderId!,
        ),
      );
    }

    if (widget.booking.userId != null) {
      context.read<RatingsBloc>().add(
        FetchCustomerRatingsById(userId: widget.booking.userId!),
      );
    }
  }

  final isProvider = dashboardViewModel.userType == UserType.provider;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final providerName = widget.booking.assignedProvider?.fullName ?? '';
    final clientName = widget.booking.user?.fullName ?? '';
    final serviceRequestId = widget.booking.id;
    final amount = widget.booking.amount ?? '';
    final invoiceNum = widget.booking.invoiceId ?? '';
    final providerImage = widget.booking.assignedProvider?.profileImage;
    final clientImage = widget.booking.user?.profileImage;
    final serviceCategoryname = widget.booking.serviceCategory?.name;
    final chatId = widget.booking.chatId;
    final clientPhoneNumber = widget.booking.user?.phoneNumber ?? '';
    final providerPhoneNumber =
        widget.booking.assignedProvider?.phoneNumber ?? '';
    final showAction =
        widget.booking.status?.toUpperCase() != BookingEnums.completed.name;

    return MultiBlocListener(
      listeners: [
        BlocListener<BookingBloc, BookingState>(
          listener: (context, state) async {
            if (state is BookingLoading) {
              showLoadingDialog(context);
            }

            if (state is BookingStarted) {
              await pop(context);
              await showSuccessSnackbar(context, 'Service has started');
              await pop(context);
            }

            if (state is BookingError) {
              await pop(context);
              await showErrorSnackbar(context, state.error);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: appColors.whiteColor,
        appBar: AppBar(
          title: UrbText(
            'Service Detail',
            color: appColors.black,
            weight: FontWeight.w700,
            size: 22,
            height: 32.5,
          ),
          forceMaterialTransparency: true,
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
              if (!isProvider) 16.verticalSpace,
              BlocBuilder<RatingsBloc, RatingsState>(
                builder: (context, ratingsState) {
                  var providerRating = '0.0';
                  var providerReviewCount = '(0 reviews)';

                  if (ratingsState is ProviderRatingsLoaded) {
                    final ratings = ratingsState.ratings;
                    providerRating =
                        ratings.averageRatings?.toStringAsFixed(1) ?? '0.0';
                    providerReviewCount =
                        '(${ratings.totalReviews ?? 0} reviews)';
                  }

                  return _ServiceCard(
                    name: providerName,
                    subtitle: serviceCategoryname ?? '',
                    rating: providerRating,
                    reviewCount: providerReviewCount,
                    avatar: providerImage ?? '',
                    showActions: showAction,
                    chatId: chatId,
                    phoneNumber: providerPhoneNumber,
                  );
                },
              ),
              if (isProvider) 12.verticalSpace,
              BlocBuilder<RatingsBloc, RatingsState>(
                builder: (context, ratingsState) {
                  var customerRating = '0.0';
                  var customerReviewCount = '(0 reviews)';
                  if (ratingsState is CustomerRatingsLoaded) {
                    final ratings = ratingsState.ratings;
                    final totalreviews = ratings.totalReviews ?? 0;
                    customerRating =
                        ratings.averageRatings?.toStringAsFixed(1) ?? '0.0';
                    customerReviewCount =
                        totalreviews > 1
                            ? '(${ratings.totalReviews ?? 0} reviews)'
                            : '(${ratings.totalReviews ?? 0} review)';
                  }

                  return _ServiceCard(
                    name: clientName,
                    subtitle: '',
                    rating: customerRating,
                    reviewCount: customerReviewCount,
                    avatar: clientImage ?? '',
                    showActions: showAction,
                    chatId: chatId,
                    phoneNumber: clientPhoneNumber,
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
                          invoiceNum,
                          color: appColors.black,
                          weight: FontWeight.w500,
                        ),
                        GenText(
                          'NGN ${AppTextUtil.formatAmount(amount)}',
                          color: appColors.black,
                          weight: FontWeight.w500,
                        ),
                      ],
                    ),
                    12.verticalSpace,
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  if (widget.booking.status == BookingEnums.assigned.name)
                    Expanded(
                      child: WideButton(
                        label: 'Start',
                        backgroundColor: appColors.primary.shade500,
                        textColor: appColors.whiteColor,
                        onPressed: () async {
                          if (serviceRequestId != null) {
                            context.read<BookingBloc>().add(
                              StartBooking(serviceRequestId: serviceRequestId),
                            );
                          }
                        },
                      ),
                    ),

                  10.verticalSpace,
                  if (widget.booking.status == BookingEnums.progress.name ||
                      widget.booking.status == BookingEnums.assigned.name)
                    Expanded(
                      child: WideButton(
                        label: 'Cancel',
                        backgroundColor: appColors.primary.shade50,
                        textColor: appColors.primary.shade500,
                        onPressed: () async {
                          if (serviceRequestId == null) return;
                          await pushScreen(
                            context,
                            CancelClientServiceScreen(
                              serviceRequestId: serviceRequestId,
                            ),
                          );
                        },
                      ),
                    ),
                  12.horizontalSpace,
                ],
              ),
              12.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: WideButton(
                      label: 'Appeal',
                      backgroundColor: appColors.primary.shade50,
                      textColor: appColors.primary.shade500,
                      onPressed: () async {
                        final serviceRequestId = widget.booking.id;
                        if (serviceRequestId == null) return;

                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (_) => const PaymentAppealDialog(isProvider: false,),
                        );
                        if (confirmed != true) return;
                        if (!context.mounted) return;

                        showLoadingDialog(context);

                        final result = await SupportRepo.instance.fileDispute(
                          requestId: serviceRequestId,
                          reason: 'Service Appeal',
                          details:
                              'Customer filed an appeal for service request #$serviceRequestId',
                        );

                        if (!context.mounted) return;
                        Navigator.pop(context);

                        if (result.error != null) {
                          await showErrorSnackbar(context, result.error!);
                          return;
                        }

                        final chatId = result.data!;
                        await pushScreen(
                          context,
                          ChatDetailScreen(
                            chatId: chatId,
                            userType:
                                widget.booking.userId != null
                                    ? UserType.customer
                                    : UserType.provider,
                          ),
                        );
                      },
                    ),
                  ),
                  12.horizontalSpace,
                  if (widget.booking.status == BookingEnums.progress.name &&
                      isProvider)
                    Expanded(
                      child: WideButton(
                        label: 'Complete',
                        backgroundColor: appColors.primary.shade500,
                        textColor: appColors.whiteColor,
                        onPressed: () async {
                          if (widget.booking.id != null) {
                            await pushScreen(
                              context,
                              ServiceCompletedScreen(
                                serviceRequestId: widget.booking.id!,
                              ),
                            );
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
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.name,
    required this.subtitle,
    required this.rating,
    required this.reviewCount,
    required this.avatar,
    this.chatId,
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
  final int? chatId;

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
                if (subtitle.isNotEmpty) ...{
                  2.verticalSpace,
                  GenText(
                    subtitle,
                    color: appColors.textColor.shade400,
                    size: 12,
                    height: 20.5,
                  ),
                },
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
          if (showActions) ...[
            8.horizontalSpace,
            SVGButton(
              path: AppAssets.ASSETS_ICONS_CHAT_ICON_SVG,
              onTap: () async {
                if (chatId != null) {
                  await _navigateToChatByServiceRequest(context, chatId!);
                }
              },
            ),
            8.horizontalSpace,
            SVGButton(
              path: AppAssets.ASSETS_ICONS_CALL_ICON_SVG,
              onTap: () async {
                if (phoneNumber != null) {
                  await DialerUtil.open(phoneNumber!);
                }
              },
              color: appColors.primary.shade500,
            ),
          ],
        ],
      ),
    );
  }
}

Future<void> _navigateToChatByServiceRequest(
  BuildContext context,
  int serviceRequestId,
) async {
  try {
    showLoadingDialog(context);

    final response = await ChatRepo().getChatByserviceRequestId(
      serviceRequestId,
    );

    Navigator.pop(context);

    if (response.data != null) {
      final chatId = response.data?.id;
      if (chatId != null) {
        await pushScreen(
          context,
          ChatDetailScreen(chatId: chatId, userType: UserType.customer),
        );
      }
    } else {
      await showErrorSnackbar(context, 'Unable to open chat');
    }
  } on Exception catch (e) {
    Navigator.pop(context);
    await showErrorSnackbar(context, 'Failed to load chat: $e');
  }
}
