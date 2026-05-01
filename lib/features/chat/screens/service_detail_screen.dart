import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/booking_bloc/booking_bloc.dart';
import 'package:resq360/core/models/booking_enums.dart';
import 'package:resq360/core/utils/dialer_util.dart';
// import 'package:resq360/features/chat/bloc/chat_details_bloc/chat_details_bloc.dart';
import 'package:resq360/features/chat/data/models/chat_models.dart';
import 'package:resq360/features/chat/screens/service_cancelled_screen.dart';
import 'package:resq360/features/chat/screens/service_completed_screen.dart';
import 'package:resq360/features/settings/data/bloc/ratings_bloc/ratings_bloc.dart';
import 'package:resq360/features/settings/data/models/admin_types.enums.dart';
import 'package:resq360/features/settings/screens/contact_admin_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({
    required this.chat,
    required this.message,
    super.key,
  });
  final ChatResponse chat;
  final MessageResponse message;

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _fetchRatings();
    });
  }

    void _fetchRatings() {
    final providerId = widget.chat.provider?.id;
    final userId = widget.chat.user?.id;

    if (providerId != null) {
      context.read<RatingsBloc>().add(FetchProviderRatingsById(providerId: providerId));
    }

    if (userId != null) {
      context.read<RatingsBloc>().add(FetchCustomerRatingsById(userId: userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final companyName = widget.chat.provider?.fullName ?? '';
    final clientName = widget.chat.user?.fullName ?? '';
    final serviceRequestId = widget.chat.serviceRequestId;
    final serviceCategory = widget.chat.serviceName ?? 'service';
    final metadata = widget.message.metadata;
    final invoiceId = metadata?.invoiceId ?? 'N/A';
    final price = metadata?.amount ?? 0;
    final providerPhoneNumber =
        widget.chat.provider?.phoneNumber ?? '';  
    // final location = widget.message.

    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) async {
        if (state is BookingLoading) {
          showLoadingDialog(context);
        }
        if (state is BookingStarted) {
          Navigator.pop(context);
          // if (widget.chat.id != null) {
          //   context.read<ChatDetailBloc>().add(OpenChatDetail(widget.chat.id!));
          // }
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
          title: UrbText(
            'Service Details',
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
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            bottom: 50.h,
          ),
          child: Column(
            children: [
              // Container(
              //   width: double.infinity,
              //   padding: pad(horizontal: 10, vertical: 20),
              //   decoration: BoxDecoration(
              //     color: appColors.whiteColor,
              //     borderRadius: BorderRadius.circular(12.r),
              //     border: Border.all(color: appColors.textColor.shade100),
              //   ),
              //   child: Row(
              //     children: [
              //       AppAssets.ASSETS_ICONS_SEVICE_CONFIRMED_SVG.svg,
              //       12.horizontalSpace,
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     GenText(
              //       'Service Confirmed',
              //       weight: FontWeight.w500,
              //       color: appColors.black,
              //     ),
              //     2.verticalSpace,
              //     GenText(
              //       'The driver is preparing to depart...',
              //       color: appColors.textColor.shade400,
              //       size: 12,
              //       height: 20.5,
              //     ),
              //   ],
              // ),
              //   ],
              // ),
              // ),
              16.verticalSpace,
              BlocBuilder<RatingsBloc, RatingsState>(
                builder: (context, state) {
                  var providerRating = '0.0';
                  var providerReviews = '(0 reviews)';

                  if (state is ProviderRatingsLoaded) {
                    providerRating =
                        state.ratings.averageRatings?.toStringAsFixed(1) ??
                        '0.0';
                    providerReviews =
                        '(${state.ratings.totalReviews ?? 0} reviews)';
                  }

                  return _ServiceCard(
                    name: companyName,
                    subtitle: serviceCategory,
                    rating: providerRating,
                    reviewCount: providerReviews,
                    avatar:
                       widget.chat.provider?.profileImage ?? '' ,
                      phoneNumber: providerPhoneNumber,
                  );
                },
              ),
              12.verticalSpace,
              BlocBuilder<RatingsBloc, RatingsState>(
                builder: (context, state) {
                  var customerRating = '0.0';
                  var customerReviews = '(0 reviews)';

                  if (state is CustomerRatingsLoaded) {
                    customerRating =
                        state.ratings.averageRatings?.toStringAsFixed(1) ??
                        '0.0';
                    final count = state.ratings.totalReviews ?? 0;
                    customerReviews =
                        count == 1 ? '($count review)' : '($count reviews)';
                  }

                  return _ServiceCard(
                    name: clientName,
                    subtitle: '',
                    rating: customerRating,
                    reviewCount: customerReviews,
                    avatar:
                        widget.chat.user?.profileImage ?? '',
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
                    // 12.verticalSpace,
                    // GenText(
                    //   'Location Detail',
                    //   color: appColors.textColor.shade400,
                    //   size: 13,
                    // ),
                    // 2.verticalSpace,
                    // GenText(
                    //   'Gwarimpa highway - Olympia Street',
                    //   color: appColors.black,
                    //   weight: FontWeight.w500,
                    // ),
                  ],
                ),
              ),
              const Spacer(),
              if (widget.chat.serviceRequestStatus ==
                  BookingEnums.assigned.name)
                WideButton(
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

              10.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: WideButton(
                      label: 'Appeal',
                      backgroundColor: appColors.primary.shade50,
                      textColor: appColors.primary.shade500,
                      onPressed: () async {
                        await pushScreen(
                          context,
                          ContactAdminScreen(
                            issueType: AdminIssueType.serviceIssue,
                            serviceCategory: widget.chat.serviceCategoryId,
                            relatedServiceProviderId: widget.chat.provider?.id,
                          ),
                        );
                      },
                    ),
                  ),
                  12.horizontalSpace,
                  if (widget.chat.serviceRequestStatus ==
                      BookingEnums.progress.name)
                    Expanded(
                      child: WideButton(
                        label: 'Complete',
                        backgroundColor: appColors.primary.shade500,
                        textColor: appColors.whiteColor,
                        onPressed: () async {
                          if (serviceRequestId != null) {
                            await pushScreen(
                              context,
                              ServiceCompletedScreen(
                                serviceRequestId: serviceRequestId,
                              ),
                            );
                          }
                        },
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
              5.verticalSpace,
              // if (widget.chat.serviceRequestStatus ==
              //         BookingEnums.assigned.name ||
              //     widget.chat.serviceRequestStatus ==
              //         BookingEnums.progress.name)
                WideButton(
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
                GenText(
                  name,
                  weight: FontWeight.w500,
                  color: appColors.black,
                ),
                if(subtitle.isNotEmpty)...{
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

            // SVGButton(path: AppAssets.ASSETS_ICONS_CHAT_ICON_SVG, onTap: () {}),
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
