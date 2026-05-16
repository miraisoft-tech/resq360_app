import 'package:resq360/__lib.dart';
import 'package:resq360/core/utils/app_text.util.dart';
import 'package:resq360/features/chat/bloc/chat_details_bloc/chat_details_bloc.dart';
import 'package:resq360/features/chat/data/models/chat_models.dart';
import 'package:resq360/features/chat/data/models/invoice_form_data.dart';

class ProviderInvoiceConfirmDialog extends StatefulWidget {
  const ProviderInvoiceConfirmDialog({
    required this.invoice,
    required this.chat,
    super.key,
  });

  final InvoiceFormData invoice;
  final ChatResponse chat;

  @override
  State<ProviderInvoiceConfirmDialog> createState() =>
      _ProviderGenerateInvoiceDialogState();
}

class _ProviderGenerateInvoiceDialogState
    extends State<ProviderInvoiceConfirmDialog> {
  bool viewMore = false;

  late final String formattedDate = () {
    final d = widget.invoice.date;
    return '${d.month}/${d.day}/${d.year}';
  }();

  Future<void> sendInvoice() async {
    final userId = widget.invoice.userId;
    final providerServiceId = widget.invoice.providerServiceId;

    log('userId: $userId, providerServiceId: $providerServiceId');
    if (userId == null) {
      await showErrorSnackbar(context, 'Missing invoice data.');
      return;
    }

    context.read<ChatDetailBloc>().add(
      SendServiceRequestInvoice(
        invoice: SendInvoice(
          userId: userId,
          providerServiceId: providerServiceId,
          chatId: widget.invoice.chatId,
          amount: widget.invoice.price,
          currency: 'NGN',
          description: widget.invoice.description,
          invoiceId: widget.invoice.invoiceNo,
          date: widget.invoice.date,
        ),
      ),
    );

    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Padding(
      padding:
          viewMore
              ? EdgeInsets.only(top: 180.h, bottom: 80.h)
              : EdgeInsets.only(top: 250.h, bottom: 150.h),
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: pad(horizontal: 20),
          padding: pad(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: appColors.whiteColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  UrbText(
                    'Invoice',
                    size: 22,
                    height: 32.5,
                    weight: FontWeight.w700,
                    color: appColors.black,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: appColors.textColor.shade400,
                    ),
                  ),
                ],
              ),
              20.verticalSpace,
              Container(
                padding: pad(vertical: 20, horizontal: 14),
                decoration: BoxDecoration(
                  color: appColors.whiteColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: appColors.textColor.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            UrbText(
                              'Invoice No.',
                              color: appColors.black,
                              size: 18,
                              height: 20.5,
                              weight: FontWeight.w700,
                            ),
                            4.verticalSpace,
                            GenText(
                              widget.invoice.invoiceNo,
                              weight: FontWeight.w400,
                              color: appColors.textColor.shade300,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            UrbText(
                              'Date',
                              color: appColors.black,
                              size: 18,
                              height: 20.5,
                              weight: FontWeight.w700,
                            ),
                            2.verticalSpace,
                            GenText(
                              formattedDate,
                              weight: FontWeight.w400,
                              color: appColors.textColor.shade300,
                            ),
                          ],
                        ),
                      ],
                    ),
                    16.verticalSpace,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GenText(
                              'Service Provider',
                              color: appColors.black,
                              weight: FontWeight.w500,
                            ),
                            2.verticalSpace,
                            GenText(
                              widget.invoice.serviceCategory,
                              size: 12,
                              weight: FontWeight.w400,
                              color: appColors.textColor.shade300,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GenText(
                              'Client',
                              color: appColors.black,
                              weight: FontWeight.w500,
                            ),
                            2.verticalSpace,
                            GenText(
                              widget.chat.user?.fullName ?? '',
                              size: 12,
                              weight: FontWeight.w400,
                              color: appColors.textColor.shade300,
                            ),
                          ],
                        ),
                      ],
                    ),
                    12.verticalSpace,
                    GestureDetector(
                      onTap:
                          () => setState(() {
                            viewMore = !viewMore;
                          }),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            GenText(
                              viewMore
                                  ? 'View Less Details'
                                  : 'View More Details',
                              color: appColors.primary.shade500,
                              weight: FontWeight.w500,
                            ),
                            4.horizontalSpace,
                            Transform.flip(
                              flipY: viewMore,
                              child: AppAssets.ASSETS_ICONS_ARROW_DROPDOWN_SVG
                                  .svgColor(color: appColors.primary.shade500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    16.verticalSpace,
                    if (viewMore)
                      Col(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GenText(
                                'Service Type',
                                color: appColors.black,
                                weight: FontWeight.w500,
                              ),
                              2.verticalSpace,
                              GenText(
                                widget.invoice.serviceCategory,
                                size: 12,
                                weight: FontWeight.w400,
                                color: appColors.textColor.shade300,
                              ),
                            ],
                          ),
                          10.verticalSpace,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GenText(
                                'Service Description',
                                color: appColors.black,
                                weight: FontWeight.w500,
                              ),
                              2.verticalSpace,
                              GenText(
                                widget.invoice.description,
                                size: 12,
                                weight: FontWeight.w400,
                                color: appColors.textColor.shade300,
                              ),
                            ],
                          ),
                          10.verticalSpace,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GenText(
                                'Location',
                                color: appColors.black,
                                weight: FontWeight.w500,
                              ),
                              2.verticalSpace,
                              GenText(
                                widget.invoice.location,
                                size: 12,
                                weight: FontWeight.w400,
                                color: appColors.textColor.shade300,
                              ),
                            ],
                          ),
                        ],
                      ),
                    Divider(color: appColors.textColor.shade100),
                    12.verticalSpace,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GenText(
                          'Total Amount',
                          color: appColors.textColor.shade400,
                        ),
                        GenText(
                          'NGN${AppTextUtil.formatAmount(widget.invoice.price.toString())}',
                          size: 16,
                          weight: FontWeight.w700,
                          color: appColors.black,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              25.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: WideButton(
                      label: 'Edit Invoice',
                      backgroundColor: appColors.primary.shade50,
                      textColor: appColors.primary.shade500,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: WideButton(
                      label: 'Send to Client',
                      backgroundColor: appColors.primary.shade500,
                      textColor: appColors.whiteColor,
                      onPressed: sendInvoice,
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
