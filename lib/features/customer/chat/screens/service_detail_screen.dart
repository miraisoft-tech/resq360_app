import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/booking_bloc/booking_bloc.dart';
import 'package:resq360/core/bloc/general-chat-bloc/chat_details_bloc/bloc/chat_details_bloc.dart';
import 'package:resq360/features/customer/chat/data/models/chat/chat_models.dart';
import 'package:resq360/features/customer/chat/screens/service_cancelled_screen.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {});
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
    // final location = widget.message.

    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) async {
        if (state is BookingLoading) {
          await showLoadingDialog(context);
        }
        if (state is BookingStarted) {
          Navigator.pop(context);
          if (widget.chat.id != null) {
            context.read<ChatDetailBloc>().add(OpenChatDetail(widget.chat.id!));
          }
          await showSuccessSnackbar(context, 'Service has started');
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
              _ServiceCard(
                name: companyName,
                subtitle: serviceCategory,
                rating: '4.9',
                reviewCount: '(347 reviews)',
                avatar: AppAssets.ASSETS_IMAGES_GENERIC_ICON_PNG.imageAsset(),
                showActions: true,
              ),
              12.verticalSpace,
              _ServiceCard(
                name: clientName,
                subtitle: '1.0km away',
                rating: '4.8',
                reviewCount: '(50 reviews)',
                avatar: AppAssets.ASSETS_IMAGES_GENERIC_ICON_PNG.imageAsset(),
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
              if (widget.chat.serviceRequestStatus == 'PENDING')
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
                  if (widget.chat.serviceRequestStatus != 'COMPLETED')
                    Expanded(
                      child: WideButton(
                        label: 'Complete',
                        backgroundColor: appColors.primary.shade500,
                        textColor: appColors.whiteColor,
                        onPressed: () async {
                          if (serviceRequestId != null) {
                            context.read<BookingBloc>().add(
                              CompleteBooking(
                                serviceRequestId: serviceRequestId,
                                ratings: 4,
                                review: 'okay',
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
              if (widget.chat.serviceRequestStatus != 'COMPLETED')
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
    this.showActions = false,
  });

  final String name;
  final String subtitle;
  final String rating;
  final String reviewCount;
  final Widget avatar;
  final bool showActions;

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
          CircleAvatar(radius: 24, child: avatar),
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
                2.verticalSpace,
                GenText(
                  subtitle,
                  color: appColors.textColor.shade400,
                  size: 12,
                  height: 20.5,
                ),
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

            SVGButton(path: AppAssets.ASSETS_ICONS_CHAT_ICON_SVG, onTap: () {}),
            8.horizontalSpace,
            SVGButton(
              path: AppAssets.ASSETS_ICONS_CALL_ICON_SVG,
              onTap: () {},
              color: appColors.primary.shade500,
            ),
          ],
        ],
      ),
    );
  }
}
