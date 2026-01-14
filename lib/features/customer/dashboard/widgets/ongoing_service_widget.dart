import 'package:resq360/__lib.dart';
import 'package:resq360/core/utils/app_text.util.dart';
import 'package:resq360/features/customer/chat/screens/service_completed_screen.dart';
import 'package:resq360/features/customer/dashboard/data/models/bookings/booking.model.dart';
import 'package:resq360/features/provider/bookings/data/models/booking_enums.dart';
import 'package:resq360/features/settings/data/models/admin_types.enums.dart';
import 'package:resq360/features/settings/screens/contact_admin_screen.dart';

class OngoingServiceCard extends StatefulWidget {
  const OngoingServiceCard({
    required this.booking,
    super.key,
  });

  final Bookings booking;

  @override
  State<OngoingServiceCard> createState() => _OngoingServiceCardState();
}

class _OngoingServiceCardState extends State<OngoingServiceCard> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final providerName =
        widget.booking.assignedProvider?.fullName ?? 'Assigned Provider';

    final serviceName = widget.booking.serviceCategory?.name ?? 'Service';

    final status = widget.booking.status ?? 'PENDING';

    return Container(
      padding: pad(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: colors.whiteColor,
        border: Border.all(color: colors.lightGreyColor2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              PictureWidget(
                image: widget.booking.assignedProvider?.profileImage,
              ),
              8.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GenText(
                          providerName,
                          height: 24.5,
                          weight: FontWeight.w500,
                          color: colors.black,
                        ),
                        const Spacer(),
                        Container(
                          padding: pad(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.success.shade50,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: GenText(
                            status,
                            size: 10,
                            height: 20.5,
                            color: colors.success.shade700,
                          ),
                        ),
                      ],
                    ),
                    GenText(
                      serviceName,
                      size: 12,
                      height: 20.5,
                      weight: FontWeight.w500,
                      color: colors.neutral.shade400,
                    ),
                    Row(
                      children: [
                        AppAssets.ASSETS_ICONS_TOW_ICON_SVG.svg,
                        4.horizontalSpace,
                        GenText(
                          '₦${AppTextUtil.formatAmount(widget.booking.amount?.toString() ?? '0')}',
                          size: 12,
                          height: 20.5,
                          weight: FontWeight.w400,
                          color: colors.black,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          20.verticalSpace,
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: pad(horizontal: 14, vertical: 10),
                    elevation: 0,
                    backgroundColor: colors.error.shade50,
                    foregroundColor: colors.primary.shade500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onPressed: () async {
                    await pushScreen(
                      context,
                      ContactAdminScreen(
                        issueType: AdminIssueType.serviceIssue,
                        serviceCategory: widget.booking.serviceCategory?.id,
                        relatedServiceProviderId:
                            widget.booking.assignedProvider?.id,
                      ),
                    );
                  },
                  child: GenText(
                    'Appeal',
                    height: 16.5,
                    color: colors.primary.shade500,
                    weight: FontWeight.w500,
                  ),
                ),
              ),

              if (status == BookingStatus.completed.value) ...[
                20.horizontalSpace,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final serviceRequestId = widget.booking.id;
                      if (serviceRequestId == null) return;

                      await pushScreen(
                        context,
                        ServiceCompletedScreen(
                          serviceRequestId: serviceRequestId,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: pad(horizontal: 14, vertical: 10),
                      backgroundColor: colors.primary.shade500,
                      foregroundColor: colors.whiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: GenText(
                      'Complete',
                      height: 16.5,
                      color: colors.whiteColor,
                      weight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// Future<String?> findExistingOpenAppealTicketId() async {
//   final res = await SupportRepo.instance.getTickets();

//   if (res.error != null && res.error!.isNotEmpty) {
//     return null;
//   }

//   final tickets = res.data;
//   if (tickets == null || tickets.isEmpty) return null;

//   for (final ticket in tickets) {
//     final isOpen = ticket.status == 'OPEN';
//     final isAppeal = ticket.subject == 'Service Appeal';
//     final isGeneralInquiry = ticket.category == 'GENERAL_INQUIRY';

//     if (isOpen && isAppeal && isGeneralInquiry) {
//       return ticket.ticketId;
//     }
//   }

//   return null;
// }
