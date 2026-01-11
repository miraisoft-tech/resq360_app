import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/general-chat-bloc/chat_details_bloc/bloc/chat_details_bloc.dart';
import 'package:resq360/features/customer/chat/data/models/chat/chat_response.dart';
import 'package:resq360/features/customer/chat/data/models/chat/send_invoice_request.dart';

class ProviderInvoiceConfirmDialog extends StatefulWidget {
  const ProviderInvoiceConfirmDialog({
    required this.invoice,
    required this.chat,
    super.key,
  });

  final Map<String, dynamic> invoice;
  final ChatResponse chat;

  @override
  State<ProviderInvoiceConfirmDialog> createState() =>
      _ProviderGenerateInvoiceDialogState();
}

class _ProviderGenerateInvoiceDialogState
    extends State<ProviderInvoiceConfirmDialog> {
  bool viewMore = false;
  final now = DateTime.now();
  late final formattedDate = '${now.month}/${now.day}/${now.year}';

  // Future<void> sendInvoice() async {
  //   final meta = {
  //     'InvoiceNo': widget.invoice['invoiceNo'],
  //     'Date': formattedDate,
  //     'serviceCategory': widget.invoice['serviceCategory'],
  //     'ClientName': 'John Doe',
  //     'description': widget.invoice['description'],
  //     'amount': widget.invoice['price'],
  //   };

  //   final request = SendMessageRequest(
  //     chatId: widget.invoice['chatId'] as int,
  //     messageType: 'SYSTEM',
  //     content: 'Here is your invoice',
  //     metadata: meta,
  //   );
  //   context.read<ChatBloc>().add(
  //     SendMessageEvent(messageRequest: request),
  //   );
  //   // await GeneralDialogs.showCustomDialog<void>(
  //   //   context,
  //   //   body: const PaymentCompleted(),
  //   // );
  //   await showSuccessSnackbar(context, 'invoice sent sucessfully');
  //   log('Sending invoice with metadata: $meta');
  //   Navigator.of(context).pop();
  // }

  Future<void> sendInvoice() async {
    log('sent');
    final request = SendInvoice(
      chatId: widget.invoice['chatId'] as int,
      amount: widget.invoice['price'] as int,
      currency: 'NGN',
      description: widget.invoice['description'] as String,
      invoiceId: widget.invoice['invoiceNo'] as String,
      fileName: '',
      fileUrl: '',
      fileSize: 0,
      mimeType: '',
    );

    context.read<ChatDetailBloc>().add(
      SendInvoiceMessage(request),
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
                              widget.invoice['invoiceNo'].toString(),
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
                              widget.invoice['serviceCategory'].toString(),
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
                                  .svgColor(
                                    color: appColors.primary.shade500,
                                  ),
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
                                widget.invoice['serviceCategory'].toString(),
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
                                widget.invoice['description'].toString(),
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
                                widget.invoice['location'].toString(),
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
                          widget.invoice['price'].toString(),
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
                      onPressed: () {
                        Navigator.pop(context);
                      },
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
