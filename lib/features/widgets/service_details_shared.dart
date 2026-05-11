import 'package:resq360/__lib.dart';
import 'package:resq360/core/utils/app_text.util.dart';
import 'package:resq360/core/utils/dialer_util.dart';
import 'package:resq360/features/chat/data/services/chat_repo.dart';
import 'package:resq360/features/chat/screens/chat_details_screen.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';

class ServiceDetailInvoiceCard extends StatelessWidget {
  const ServiceDetailInvoiceCard({
    required this.invoiceNum,
    required this.amount,
    super.key,
  });

  final String invoiceNum;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
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
    );
  }
}

class ServicePersonCard extends StatelessWidget {
  const ServicePersonCard({
    required this.name,
    required this.subtitle,
    required this.rating,
    required this.reviewCount,
    required this.avatar,
    this.chatId,
    this.phoneNumber,
    this.showActions = false,
    super.key,
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
          if (showActions) ...[
            8.horizontalSpace,
            SVGButton(
              path: AppAssets.ASSETS_ICONS_CHAT_ICON_SVG,
              onTap: () async {
                if (chatId != null) {
                  await navigateToChatByServiceRequest(context, chatId!);
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

Future<void> navigateToChatByServiceRequest(
  BuildContext context,
  int serviceRequestId,
) async {
  try {
    log('Fetching chat for service request ID: $serviceRequestId');
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
