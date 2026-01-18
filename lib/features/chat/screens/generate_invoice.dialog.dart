import 'dart:async';
import 'dart:math';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/service_catalog_bloc/service_catalog_bloc.dart';
import 'package:resq360/core/utils/location_helper.dart';
import 'package:resq360/features/chat/bloc/chat_details_bloc/chat_details_bloc.dart';
import 'package:resq360/features/chat/data/models/chat_models.dart';
import 'package:resq360/features/chat/screens/invoice_confirm.dialog.dart';
import 'package:resq360/features/customer/dashboard/data/models/service-model/service.model.dart';
import 'package:resq360/features/provider/authentication/data/models/provider_response.dart';
import 'package:resq360/features/provider/authentication/view_models/provider_auth_vm.dart';

class GenerateInvoiceDialog extends StatefulWidget {
  const GenerateInvoiceDialog({required this.chat, super.key});

  final ChatResponse chat;

  @override
  State<GenerateInvoiceDialog> createState() => _GenerateInvoiceDialogState();
}

class _GenerateInvoiceDialogState extends State<GenerateInvoiceDialog> {
  final ValueNotifier<Service?> _selectType = ValueNotifier(null);
  final ValueNotifier<DateTime?> _selectedDate = ValueNotifier(null);
  final TextEditingController dateController = TextEditingController();

  late TextEditingController locationController = TextEditingController();
  late TextEditingController priceController;
  late TextEditingController serviceController;

  late String selectedCategory;
  late final int? currentUserId;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(initializeLocation());
      context.read<ServiceCatalogBloc>().add(const FetchServices());
      unawaited(fetchCategory());
      dateController.text = '';
    });

    priceController = TextEditingController();
    serviceController = TextEditingController();
    currentUserId = auth?.id;
  }

  Future<void> initializeLocation() async {
    final locationData = await LocationHelper.getCurrentLocation();
    if (locationController.text.isNotEmpty) {
      locationController.text = (locationData['address'] as String?) ?? '';
    }
  }

  Future<bool> fetchCategory() async {
    final state = context.read<ServiceCatalogBloc>().state;

    if (state is! ServicesLoaded) {
      return false;
    }

    if (_selectType.value == null) {
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    locationController.dispose();
    priceController.dispose();
    serviceController.dispose();
    dateController.dispose();
    super.dispose();
  }

  bool isProcessing = false;

  final ProviderModel? auth = ProviderAuthProvider.instance.authInfo;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Padding(
      padding: EdgeInsets.only(top: 180.h, bottom: 90.h),
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: pad(horizontal: 30),
          padding: pad(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: appColors.whiteColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  UrbText(
                    'Generate Invoice',
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
              BlocBuilder<ServiceCatalogBloc, ServiceCatalogState>(
                builder: (context, state) {
                  if (state is ServiceCatalogLoading) {
                    isProcessing = true;
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is ServiceCatalogError) {
                    isProcessing = false;
                    log('Error loading services: ${state.error}');
                    return Column(
                      children: [
                        const Center(
                          child: Text(
                            'fetching services failed',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        WideButton(
                          label: 'retry',
                          onPressed: () {
                            context.read<ServiceCatalogBloc>().add(
                              const FetchServices(),
                            );
                          },
                        ),
                      ],
                    );
                  }

                  if (state is ServicesLoaded) {
                    isProcessing = false;
                    return ServiceDropdown(
                      items: state.services,
                      controller: _selectType,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              14.verticalSpace,
              KFormField(
                label: 'Location',
                hintText: 'Enter your location',
                controller: locationController,
                keyboardType: TextInputType.text,
              ),
              14.verticalSpace,
              ValueListenableBuilder<DateTime?>(
                valueListenable: _selectedDate,
                builder: (_, value, _) {
                  return KFormField(
                    label: 'Task date',
                    hintText: 'Select date',
                    controller: dateController,
                    type: InputType.dob,
                    onTapSuffix: () async {
                      final now = DateTime.now();

                      final picked = await showDatePicker(
                        context: context,
                        initialDate: value ?? now,
                        firstDate: DateTime(now.year - 1),
                        lastDate: DateTime(now.year + 2),
                      );

                      if (picked != null) {
                        _selectedDate.value = picked;
                        dateController.text =
                            '${picked.month}/${picked.day}/${picked.year}';
                      }
                    },
                  );
                },
              ),

              14.verticalSpace,
              KFormField(
                label: 'Price',
                hintText: 'Enter the price',
                controller: priceController,
                keyboardType: TextInputType.number,
              ),
              14.verticalSpace,
              KFormField(
                label: 'Service Description(Optional)',
                hintText: 'Type service description here...',
                controller: serviceController,
                keyboardType: TextInputType.text,
                maxLines: 8,
                minLines: 6,
              ),
              24.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: WideButton(
                      label: 'Cancel',
                      backgroundColor: appColors.primary.shade50,
                      textColor: appColors.primary.shade500,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: WideButton(
                      label: 'Generate Invoice',
                      backgroundColor: appColors.primary.shade500,
                      textColor: appColors.whiteColor,
                      onPressed: () async {
                        if (locationController.text.isEmpty ||
                            priceController.text.isEmpty ||
                            serviceController.text.isEmpty ||
                            _selectedDate.value == null) {
                          await showErrorSnackbar(
                            context,
                            'Please fill in all required fields',
                          );
                          return;
                        }
                        final rand = Random().nextInt(999);
                        final invoiceNo =
                            "INV-${rand.toString().padLeft(3, '0')}";
                        final invoice = {
                          'invoiceNo': invoiceNo,
                          'chatId': widget.chat.id,
                          'serviceCategory': _selectType.value!.name,
                          'location': locationController.text,
                          'price': int.tryParse(priceController.text) ?? 0,
                          'description': serviceController.text,
                          'date': _selectedDate.value!.toIso8601String(),
                        };

                        await GeneralDialogs.showCustomDialog<void>(
                          context,
                          body: BlocProvider.value(
                            value: context.read<ChatDetailBloc>(),
                            child: ProviderInvoiceConfirmDialog(
                              invoice: invoice,
                              chat: widget.chat,
                            ),
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
      ),
    );
  }
}

class ServiceDropdown extends StatefulWidget {
  const ServiceDropdown({
    required this.items,
    required this.controller,
    super.key,
  });
  final List<Service> items;
  final ValueNotifier<Service?> controller;

  @override
  State<ServiceDropdown> createState() => _ServiceDropdownState();
}

class _ServiceDropdownState extends State<ServiceDropdown> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Service?>(
      valueListenable: widget.controller,
      builder: (_, value, _) {
        return ObjectKDropDown<Service>(
          label: 'Service Category',
          hintText: 'select service category',
          dropdownItems: widget.items,
          value: value,
          displayStringForOption: (s) => s.name,
          onChanged: (service) => widget.controller.value = service,
        );
      },
    );
  }
}
