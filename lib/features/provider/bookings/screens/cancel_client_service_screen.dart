// ignore_for_file: deprecated_member_use, document_ignores

import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/booking_bloc/booking_bloc.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/main_layout_provider.dart';
import 'package:resq360/features/provider/bookings/data/provider_cancel_enums.dart';
import 'package:resq360/features/widgets/dialogs/cancelled.modal.dart';

class CancelClientServiceScreen extends StatefulWidget {
  const CancelClientServiceScreen({required this.serviceRequestId, super.key});
  final int serviceRequestId;
  @override
  State<CancelClientServiceScreen> createState() =>
      _CancelClientServiceScreenState();
}

bool get isProvider =>
    dashboardViewModel.userType == UserType.provider;

String get pageTitle =>
    isProvider ? 'Cancel Client Service' : 'Cancel Service';

String get subtitle =>
    isProvider
        ? 'Please review provider cancellation terms'
        : 'Please review cancellation terms';

// String get cancellationChargeText =>
//     isProvider
//         ? 'Cancelling may affect your provider wallet balance.'
//         : 'Cancellation of service attracts a cancellation charge of ₦3,000.';

class _CancelClientServiceScreenState extends State<CancelClientServiceScreen> {
  CancelReasonEnum? selectedReason;
  final TextEditingController reasonController = TextEditingController();
  final isProvider = dashboardViewModel.userType == UserType.provider;
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
  
    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) async {
        if (state is BookingCancelled) {
          Navigator.pop(context);
          await showSuccessSnackbar(context, 'Booking cancelled');
          await GeneralDialogs.showCustomBottomSheet(
            context,
            body: CancelledModal(
              onContinuePressed: () async {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              },
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: appColors.whiteColor,
        appBar: AppBar(
          backgroundColor: appColors.whiteColor,
          forceMaterialTransparency: true,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: appColors.black),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 10.h,
            bottom: 50.h,
          ),
          child: Column(
            children: [
              SvgPicture.asset(
                AppAssets.ASSETS_ICONS_CANCEL_SVG,
                height: 40.h,
                width: 40.w,
              ),
              12.verticalSpace,
              UrbText(
                pageTitle,
                size: 22,
                weight: FontWeight.w700,
                color: appColors.black,
              ),
              4.verticalSpace,
              GenText(
                subtitle,
                color: appColors.textColor.shade400,
                weight: FontWeight.w400,
              ),
              24.verticalSpace,
              Container(
                width: double.infinity,
                padding: pad(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: appColors.error.shade50,
                  border: Border.all(color: appColors.error.shade100),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GenText(
                      'Disclaimer: by proceeding, you acknowledge that:',
                      weight: FontWeight.w600,
                      color: appColors.error.shade700,
                    ),
                    5.verticalSpace,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GenText(
                          '• ',
                          color: appColors.error.shade600,
                        ),
                        Expanded(
                          child: GenText(
                           'A cancellation of service attracts a 20% cancellation charge',
                            color: appColors.error.shade600,
                            size: 13,
                          ),
                        ),
                      ],
                    ),
                    5.verticalSpace,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GenText(
                          '• ',
                          color: appColors.error.shade600,
                        ),
                        Expanded(
                          child: GenText(
                            'Service started cannot be cancelled',
                            color: appColors.error.shade600,
                            size: 13,
                          ),
                        ),
                      ],
                    ),
                    5.verticalSpace,
                    if (isProvider)...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GenText(
                          '• ',
                          color: appColors.error.shade600,
                        ),
                        Expanded(
                          child: GenText(
                            'You can have a negative wallet balance',
                            color: appColors.error.shade600,
                            size: 13,
                          ),
                        ),
                      ],
                    ),

                      Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GenText(
                          '• ',
                          color: appColors.error.shade600,
                        ),
                        Expanded(
                          child: GenText(
                            'Service payment will be sent back to the customer',
                            color: appColors.error.shade600,
                            size: 13,
                          ),
                        ),
                      ],
                    ),
                    5.verticalSpace,
                    ]
                  ],
                ),
              ),
              32.verticalSpace,
              Container(
                width: double.infinity,
                padding: pad(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: appColors.textColor.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GenText(
                      'Reason for Cancellation',
                      size: 16,
                      weight: FontWeight.w700,
                      color: appColors.black,
                    ),
                    4.verticalSpace,
                    GenText(
                      'Please select an appropriate reason',
                      color: appColors.textColor.shade400,
                      size: 13,
                    ),
                    14.verticalSpace,
                    ...visibleReasons.map((reason) {
                      return GestureDetector(
                        onTap: () => setState(() => selectedReason = reason),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          child: Row(
                            children: [
                              Radio<CancelReasonEnum>(
                                value: reason,
                                groupValue: selectedReason,
                                onChanged:
                                    (value) =>
                                        setState(() => selectedReason = value),
                                activeColor: appColors.primary.shade500,
                              ),
                              Expanded(
                                child: GenText(
                                  _reasonText(reason),
                                  color: appColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              24.verticalSpace,
              if (selectedReason == CancelReasonEnum.other) ...[
                KFormField(
                  label: 'Other',
                  controller: reasonController,
                  hintText: 'Type your reason here...',
                  maxLines: 10,
                  minLines: 8,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ],
              40.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: WideButton(
                      label: 'Keep Service',
                      backgroundColor: appColors.primary.shade50,
                      textColor: appColors.primary.shade500,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: BlocBuilder<BookingBloc, BookingState>(
                      builder: (context, state) {
                        return WideButton(
                          label: isProvider ? 'Cancel Job' : 'Cancel Service',
                          backgroundColor: appColors.error,
                          textColor: appColors.whiteColor,
                          loading: state is BookingLoading,
                          onPressed:
                              canSubmit
                                  ? () async {
                                    context.read<BookingBloc>().add(
                                      CancelBooking(
                                        cancellationReason: cancellationReason!,
                                        serviceRequestId:
                                            widget.serviceRequestId,
                                      ),
                                    );
                                  }
                                  : null,
                        );
                      },
                      // listener: (
                      //   BuildContext context,
                      //   BookingState state,
                      // ) async {
                      //   if (state is BookingCancelled) {

                      //   }

                      //   if (state is BookingError) {
                      //     await showErrorSnackbar(context, state.error);
                      //   }
                      // },
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

  String? get cancellationReason {
    if (selectedReason == null) return null;

    if (selectedReason == CancelReasonEnum.other) {
      return reasonController.text.trim().isEmpty
          ? null
          : reasonController.text.trim();
    }

    return selectedReason!.name;
  }

  bool get canSubmit {
    if (selectedReason == null) return false;

    if (selectedReason == CancelReasonEnum.other) {
      return reasonController.text.trim().isNotEmpty;
    }

    return true;
  }

String _reasonText(CancelReasonEnum reason) {
  switch (reason) {
    case CancelReasonEnum.unableToReach:
      return isProvider
          ? 'Unable to reach client'
          : 'Provider is unreachable';

    case CancelReasonEnum.vehicleEquipmentIssue:
      return isProvider
          ? 'Vehicle / Equipment issue'
          : 'Provider unavailable';

    case CancelReasonEnum.providerDelayed:
      return isProvider
          ? 'Client reported provider delay'
          : 'Provider delayed or unavailable';

    case CancelReasonEnum.noLongerNeeded:
      return isProvider
          ? 'Client no longer needs service'
          : 'Service no longer needed';

    case CancelReasonEnum.changedMind:
      return isProvider
          ? 'Client changed mind'
          : 'Changed my mind';

    case CancelReasonEnum.emergencySituation:
      return 'Emergency situation';

    case CancelReasonEnum.other:
      return 'Other';
  }
}

List<CancelReasonEnum> get visibleReasons {
  return isProvider
      ? [
          CancelReasonEnum.unableToReach,
          CancelReasonEnum.vehicleEquipmentIssue,
          CancelReasonEnum.emergencySituation,
          CancelReasonEnum.other,
        ]
      : [
          CancelReasonEnum.providerDelayed,
          CancelReasonEnum.noLongerNeeded,
          CancelReasonEnum.changedMind,
          CancelReasonEnum.emergencySituation,
          CancelReasonEnum.other,
        ];
}


}
