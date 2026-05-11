import 'package:resq360/__lib.dart';
import 'package:resq360/features/chat/screens/chat_details_screen.dart';
import 'package:resq360/features/chat/screens/payment_appeal.dialog.dart';
import 'package:resq360/features/customer/dashboard/data/models/bookings/booking.model.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/provider/bookings/screens/cancel_client_service_screen.dart';
import 'package:resq360/features/settings/data/bloc/ratings_bloc/ratings_bloc.dart';
import 'package:resq360/features/settings/data/service/support_service.dart';
import 'package:resq360/features/widgets/service_details_shared.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final providerName = widget.booking.assignedProvider?.fullName ?? '';
    final serviceRequestId = widget.booking.id;
    final amount = widget.booking.amount ?? '';
    final invoiceNum = widget.booking.invoiceId ?? '';
    final providerImage = widget.booking.assignedProvider?.profileImage;
    final serviceCategoryName = widget.booking.serviceCategory?.name;
    final chatId = widget.booking.chatId;
    final providerPhoneNumber =
        widget.booking.assignedProvider?.phoneNumber ?? '';
    // final showActions =
    //     widget.booking.status?.toUpperCase() != BookingEnums.completed.name;

    return Scaffold(
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
        padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 50.h),
        child: Column(
          children: [
            16.verticalSpace,
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

                return ServicePersonCard(
                  name: providerName,
                  subtitle: serviceCategoryName ?? '',
                  rating: providerRating,
                  reviewCount: providerReviewCount,
                  avatar: providerImage ?? '',
                  showActions: true,
                  chatId: chatId,
                  phoneNumber: providerPhoneNumber,
                );
              },
            ),
            16.verticalSpace,
            ServiceDetailInvoiceCard(invoiceNum: invoiceNum, amount: amount),
            const Spacer(),
            // if (showActions)
              Row(
                children: [
                  Expanded(
                    child: WideButton(
                      label: 'Appeal',
                      backgroundColor: appColors.primary.shade50,
                      textColor: appColors.primary.shade500,
                      onPressed: () => _handleAppeal(context, serviceRequestId),
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: WideButton(
                      label: 'Cancel',
                      backgroundColor: appColors.primary.shade500,
                      textColor: appColors.whiteColor,
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
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAppeal(
    BuildContext context,
    int? serviceRequestId,
  ) async {
    if (serviceRequestId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const PaymentAppealDialog(isProvider: false),
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
  }
}
