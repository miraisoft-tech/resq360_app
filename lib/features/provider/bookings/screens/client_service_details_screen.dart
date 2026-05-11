import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/booking_bloc/booking_bloc.dart';
import 'package:resq360/core/models/booking_enums.dart';
import 'package:resq360/features/chat/screens/service_completed_screen.dart';
import 'package:resq360/features/customer/dashboard/data/models/bookings/booking.model.dart';
import 'package:resq360/features/provider/bookings/screens/cancel_client_service_screen.dart';
import 'package:resq360/features/settings/data/bloc/ratings_bloc/ratings_bloc.dart';
import 'package:resq360/features/widgets/service_details_shared.dart';

class ClientServiceDetailScreen extends StatefulWidget {
  const ClientServiceDetailScreen({required this.booking, super.key});

  final Bookings booking;

  @override
  State<ClientServiceDetailScreen> createState() =>
      _ClientServiceDetailScreenState();
}

class _ClientServiceDetailScreenState extends State<ClientServiceDetailScreen> {
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
    final serviceCategoryName = widget.booking.serviceCategory?.name;
    final chatId = widget.booking.chatId;
    final clientPhoneNumber = widget.booking.user?.phoneNumber ?? '';
    final providerPhoneNumber =
        widget.booking.assignedProvider?.phoneNumber ?? '';
    final showActions =
        widget.booking.status?.toUpperCase() != BookingEnums.completed.name;
    final status = widget.booking.status;

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
              12.verticalSpace,
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
                    chatId: chatId,
                    phoneNumber: providerPhoneNumber,
                  );
                },
              ),
              12.verticalSpace,
              BlocBuilder<RatingsBloc, RatingsState>(
                builder: (context, ratingsState) {
                  var customerRating = '0.0';
                  var customerReviewCount = '(0 reviews)';

                  if (ratingsState is CustomerRatingsLoaded) {
                    final ratings = ratingsState.ratings;
                    final totalReviews = ratings.totalReviews ?? 0;
                    customerRating =
                        ratings.averageRatings?.toStringAsFixed(1) ?? '0.0';
                    customerReviewCount =
                        totalReviews > 1
                            ? '($totalReviews reviews)'
                            : '($totalReviews review)';
                  }

                  return ServicePersonCard(
                    name: clientName,
                    subtitle: '',
                    rating: customerRating,
                    reviewCount: customerReviewCount,
                    avatar: clientImage ?? '',
                    showActions: true,
                    chatId: chatId,
                    phoneNumber: clientPhoneNumber,
                  );
                },
              ),
              16.verticalSpace,
              ServiceDetailInvoiceCard(invoiceNum: invoiceNum, amount: amount),
              const Spacer(),
              if (showActions)
                Row(
                  children: [
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
                    Expanded(
                      child: WideButton(
                        label:
                            status == BookingEnums.assigned.name
                                ? 'Start Service'
                                : 'Complete',
                        backgroundColor: appColors.primary.shade500,
                        textColor: appColors.whiteColor,
                        onPressed: () async {
                          if (status == BookingEnums.assigned.name) {
                            if (serviceRequestId != null) {
                              context.read<BookingBloc>().add(
                                StartBooking(
                                  serviceRequestId: serviceRequestId,
                                ),
                              );
                            }
                          } else if (status == BookingEnums.progress.name) {
                            if (widget.booking.id != null) {
                              await pushScreen(
                                context,
                                ServiceCompletedScreen(
                                  serviceRequestId: widget.booking.id!,
                                ),
                              );
                            }
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
