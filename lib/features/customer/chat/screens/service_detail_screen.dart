import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/customer/authentication/view_models/auth_vm.dart';
import 'package:resq360/features/customer/chat/data/models/chat/chat_models.dart';
import 'package:resq360/features/customer/chat/screens/payment_appeal.dialog.dart';
import 'package:resq360/features/customer/chat/screens/service_cancelled_screen.dart';
import 'package:resq360/features/customer/chat/screens/service_completed_screen.dart';
import 'package:resq360/features/customer/chat/screens/support_chat_screen.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/provider/authentication/view_models/auth_vm.dart';
import 'package:resq360/features/settings/data/service/support_service.dart';

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

late String userType;
dynamic currentUser;
bool userReady = false;

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
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

    return Scaffold(
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
              avatar: AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG.imageAsset(),
              showActions: true,
            ),
            12.verticalSpace,
            _ServiceCard(
              name: clientName,
              subtitle: '1.0km away',
              rating: '4.8',
              reviewCount: '(50 reviews)',
              avatar: AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG.imageAsset(),
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
            Row(
              children: [
                Expanded(
                  child: WideButton(
                    label: 'Appeal',
                    backgroundColor: appColors.primary.shade50,
                    textColor: appColors.primary.shade500,
                    onPressed: () async {
                      await handleServiceAppeal(
                        context: context,
                        userReady: userReady,
                        serviceCategory: serviceCategory,
                        serviceCategoryId: widget.chat.serviceCategoryId,
                        providerId: widget.chat.provider?.id,
                        contactEmail: currentUser.email.toString(),
                        contactPhone: currentUser.phoneNumber.toString(),
                        providerName:companyName
                      );
                    },
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: WideButton(
                    label: 'Complete',
                    backgroundColor: appColors.primary.shade500,
                    textColor: appColors.whiteColor,
                    onPressed: () async {
                      if (serviceRequestId == null) return;
                      await pushScreen(
                        context,
                        ServiceCompletedScreen(
                          serviceRequestId: serviceRequestId,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            5.verticalSpace,
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

Future<void> handleServiceAppeal({
  required BuildContext context,
  required bool userReady,
  required String serviceCategory,
  required int? serviceCategoryId,
  required int? providerId,
  required String contactEmail,
  required String contactPhone,
  required String providerName,
}) async {
  if (!userReady) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User not ready')),
    );
    return;
  }

  final shouldProceed = await GeneralDialogs.showCustomDialog<bool>(
    context,
    body: const PaymentAppealDialog(),
  );

  if (shouldProceed != true) return;

  final existingTicketId = await findExistingOpenAppealTicketId();

  if (!context.mounted) return;

  if (existingTicketId != null) {
    await pushScreen(
      context,
      SupportChatScreen(ticketId: existingTicketId, providerName: providerName,),
    );
    return;
  }

  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const Center(
            child: CircularProgressIndicator(),
          ),
    ),
  );

  final res = await SupportRepo.instance.createTicket(
    subject: 'Service Appeal',
    description: 'User opened an appeal for $serviceCategory service.',
    category: 'GENERAL_INQUIRY',
    priority: 'LOW',
    contactEmail: contactEmail,
    contactPhone: contactPhone,
    serviceCategory: serviceCategoryId,
    relatedServiceProviderId: providerId,
  );

  if (!context.mounted) return;


  Navigator.of(context).pop();

  final error = res.error;
  if (error != null && error.isNotEmpty) {
    await showErrorSnackbar(context, error);
    return;
  }

  final ticketId = res.data!['data']['ticketId'].toString();

  await pushScreen(
    context,
    SupportChatScreen(ticketId: ticketId, providerName: providerName,),
  );
}
