import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/booking_bloc/booking_bloc.dart';
import 'package:resq360/features/chat/screens/service_completed_screen.dart';
import 'package:resq360/features/customer/dashboard/data/models/bookings/booking.model.dart';
import 'package:resq360/features/provider/bookings/screens/cancel_client_service_screen.dart';
import 'package:resq360/features/settings/data/models/admin_types.enums.dart';
import 'package:resq360/features/settings/screens/contact_admin_screen.dart';

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

    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) async {
        if (state is BookingStarted) {
          await showSuccessSnackbar(context, 'Service has started');
        }

        if (state is BookingCompleted) {
          await showSuccessSnackbar(context, 'Service has been marked as completed');
          // await pushScreen(
          //   context,
          //   ServiceCompletedScreen(serviceRequestId: state.serviceRequestId),
          // );
        }

        if (state is BookingError) {
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
              //       Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           GenText(
              //             'Service Confirmed',
              //             weight: FontWeight.w500,
              //             color: appColors.black,
              //           ),
              //           2.verticalSpace,
              //           GenText(
              //             'The driver is preparing to depart...',
              //             color: appColors.textColor.shade400,
              //             size: 12,
              //             height: 20.5,
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              16.verticalSpace,
              _ServiceCard(
                name: providerName,
                subtitle: serviceCategoryname ?? '',
                rating: '4.9',
                reviewCount: '(347 reviews)',
                avatar:
                    providerImage ??
                    'https://randomuser.me/api/portraits/men/30.jpg',
              ),
              12.verticalSpace,
              _ServiceCard(
                name: clientName,
                subtitle: '1.0km away',
                rating: '4.8',
                reviewCount: '(50 reviews)',
                avatar:
                    clientImage ??
                    'https://randomuser.me/api/portraits/men/30.jpg',
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
                          amount,
                          color: appColors.black,
                          weight: FontWeight.w500,
                        ),
                      ],
                    ),
                    12.verticalSpace,
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
              Row(
                children: [
                  if (widget.booking.status == 'PENDING' || widget.booking.status == 'ASSIGNED' || widget.booking.status == 'IN_PROGRESS')
                    Expanded(
                      child: WideButton(
                        label: 'Cancel',
                        backgroundColor: appColors.primary.shade50,
                        textColor: appColors.primary.shade500,
                        onPressed: () async {
                          if (serviceRequestId == null) return;
                          await pushScreen(
                            context,
                            CancelSlientServiceScreen(
                              serviceRequestId: serviceRequestId,
                            ),
                          );
                        },
                      ),
                    ),
                  12.horizontalSpace,
                  // if (widget.booking.status == 'PENDING') Expanded(
                  //   child: WideButton(
                  //     label: 'Start',
                  //     backgroundColor: appColors.primary.shade500,
                  //     textColor: appColors.whiteColor,
                  //     onPressed: () async {
                  //       if (serviceRequestId != null) {
                  //         context.read<BookingBloc>().add(
                  //           StartBooking(serviceRequestId: serviceRequestId),
                  //         );
                  //       }
                  //     },
                  //   ),
                  // ) else const SizedBox.shrink()
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
                        await pushScreen(
                          context,
                          ContactAdminScreen(
                            issueType: AdminIssueType.serviceIssue,
                            serviceCategory:
                                widget.booking.serviceCategory?.id ?? 0,
                            relatedServiceProviderId:
                                widget.booking.assignedProviderId,
                          ),
                        );
                        // await GeneralDialogs.showCustomDialog<void>(
                        //   context,
                        //   body: const PaymentAppealDialog(),
                        // );
                      },
                    ),
                  ),
                  12.horizontalSpace,
                  if (widget.booking.status == 'PENDING' ||  widget.booking.status == 'IN_PROGRESS')
                    Expanded(
                      child: WideButton(
                        label: 'Complete',
                        backgroundColor: appColors.primary.shade500,
                        textColor: appColors.whiteColor,
                        onPressed: () async {

                          // if (serviceRequestId != null) {
                          //   context.read<BookingBloc>().add(
                          //     CompleteBooking(
                          //       serviceRequestId: serviceRequestId,
                          //       ratings: 0,
                          //       review: '',
                          //     ),
                          //   );
                          // }
                        },
                      ),
                    ),
                ],
              ),
              // 5.verticalSpace,
              // WideButton(
              //   label: 'Submit',
              //   backgroundColor: appColors.primary.shade50,
              //   textColor: appColors.primary.shade500,
              //   onPressed: () async {},
              // ),
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
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(
              avatar,
            ),
          ),
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

            SVGButton(
              path: AppAssets.ASSETS_ICONS_CHAT_ICON_SVG,
              onTap: () {
                // navigateToChatByServiceRequest()
              },
            ),
            8.horizontalSpace,
            SVGButton(
              path: AppAssets.ASSETS_ICONS_CALL_ICON_SVG,
              onTap: () async {
                // await DialerUtil.open(phoneNumber);
              },
              color: appColors.primary.shade500,
            ),
          ],
        ],
      ),
    );
  }
}
