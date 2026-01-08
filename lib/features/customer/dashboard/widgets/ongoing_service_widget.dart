import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/customer/authentication/view_models/auth_vm.dart';
import 'package:resq360/features/customer/chat/screens/payment_appeal.dialog.dart';
import 'package:resq360/features/customer/chat/screens/service_completed_screen.dart';
import 'package:resq360/features/customer/chat/screens/support_chat_screen.dart';
import 'package:resq360/features/customer/dashboard/data/models/bookings/booking.model.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/provider/authentication/view_models/auth_vm.dart';
import 'package:resq360/features/settings/data/models/admin_types.enums.dart';
import 'package:resq360/features/settings/data/service/support_service.dart';

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
  String? userType;
  dynamic currentUser;
  bool userReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _setupUser();
    });
  }

  Future<void> _setupUser() async {
    final type = await AuthLocalRepo.instance.getUserType();
    if (type == null) return;

    userType = type;

    if (type == 'user') {
      currentUser = CustomerAuthProvider.instance.authInfo;
    } else if (type == UserType.provider.name) {
      currentUser = ProviderAuthProvider.instance.authInfo;
    }

    if (mounted) {
      setState(() {
        userReady = currentUser != null;
      });
    }
  }

Future<void> _handleAppeal(BuildContext context) async {
  final shouldProceed = await GeneralDialogs.showCustomDialog<bool>(
    context,
    body: const PaymentAppealDialog(),
  );

  if (shouldProceed != true) return;

  final existingTicketId = await findExistingOpenAppealTicketId();

  if (!context.mounted) {
    return;
  }

  if (existingTicketId != null) {

    if (currentUser != null) {
       await pushScreen(
      context,
      SupportChatScreen(ticketId: existingTicketId, providerName: widget.booking.assignedProvider?.fullName ?? 'Assigned Provider')
    );
    }
   

    return;
  }

   final serviceName = widget.booking.serviceCategory?.name ?? 'service';
    final contactEmail = currentUser.email;
    final contactPhone = currentUser.phoneNumber;

   final res = await SupportRepo.instance.createTicket(
      subject: 'Service Appeal',
      description: 'User opened an appeal for $serviceName service.',
      category: AdminIssueType.serviceIssue.value,
      priority: 'LOW',
      contactEmail: contactEmail.toString(),
      contactPhone: contactPhone.toString(),
      serviceCategory: widget.booking.serviceCategory?.id,
      relatedServiceProviderId: widget.booking.assignedProvider?.id,
    );


  if (!context.mounted) return;

  if (res.error != null) {
    await showErrorSnackbar(context, res.error!);
    return;
  }

  final ticketId = res.data!['data']['ticketId'].toString();

  await pushScreen(
    context,
    SupportChatScreen(ticketId: ticketId, providerName: 
        widget.booking.assignedProvider?.fullName ?? 'Assigned Provider'),
  );

}

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
              CircleAvatar(
                radius: 25,
                backgroundImage:
                    widget.booking.assignedProvider?.profileImage != null
                        ? NetworkImage(
                          widget.booking.assignedProvider!.profileImage!,
                        )
                        : const AssetImage(
                              AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
                            )
                            as ImageProvider,
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
                          '15000',
                          // '₦${widget.booking.price ?? 15000}',
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
          30.verticalSpace,
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
                  onPressed: () => _handleAppeal(context),
                  child: GenText(
                    'Appeal',
                    height: 16.5,
                    color: colors.primary.shade500,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
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
          ),
        ],
      ),
    );
  }
}

Future<String?> findExistingOpenAppealTicketId() async {
  final res = await SupportRepo.instance.getTickets();

  if (res.error != null && res.error!.isNotEmpty) {
    return null;
  }

  final tickets = res.data;
  if (tickets == null || tickets.isEmpty) return null;

  for (final ticket in tickets) {
    final isOpen = ticket.status == 'OPEN';
    final isAppeal = ticket.subject == 'Service Appeal';
    final isGeneralInquiry = ticket.category == 'GENERAL_INQUIRY';

    if (isOpen && isAppeal && isGeneralInquiry) {
      return ticket.ticketId;
    }
  }

  return null;
}
