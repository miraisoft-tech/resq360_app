import 'dart:async';
import 'dart:math';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/service_catalog_bloc/service_catalog_bloc.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/core/utils/location_helper.dart';
import 'package:resq360/features/chat/bloc/chat_details_bloc/chat_details_bloc.dart';
import 'package:resq360/features/chat/data/models/chat_models.dart';
import 'package:resq360/features/chat/data/models/invoice_form_data.dart';
import 'package:resq360/features/chat/screens/invoice_confirm.dialog.dart';
import 'package:resq360/features/customer/dashboard/data/models/service_models/service_request.model.dart';
import 'package:resq360/features/widgets/skeleton_loader.dart';

class GenerateInvoiceBottomSheet extends StatefulWidget {
  const GenerateInvoiceBottomSheet({
    required this.chat,
    required this.chatDetailBloc,
    super.key,
  });

  final ChatResponse chat;
  final ChatDetailBloc chatDetailBloc;

  @override
  State<GenerateInvoiceBottomSheet> createState() =>
      _GenerateInvoiceBottomSheetState();
}

class _GenerateInvoiceBottomSheetState
    extends State<GenerateInvoiceBottomSheet> {
  final ValueNotifier<Service?> _selectType = ValueNotifier(null);
  final ValueNotifier<DateTime?> _selectedDate = ValueNotifier(null);
  final TextEditingController dateController = TextEditingController();

  late TextEditingController locationController = TextEditingController();
  late TextEditingController priceController;
  late TextEditingController serviceController;

  late String selectedCategory;
  int? currentUserId;

  Future<int?> _loadProviderId() async {
    return AuthLocalRepo.instance.getProviderId();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      unawaited(initializeLocation());
      context.read<ServiceCatalogBloc>().add(const FetchServicesForAProvider());
      unawaited(fetchCategory());
      dateController.text = '';
      final id = await _loadProviderId();
      setState(() {
        currentUserId = id;
      });
    });

    priceController = TextEditingController();
    serviceController = TextEditingController();
    // currentUserId = auth?.id;
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

  // final ProviderModel? auth = ProviderAuthProvider.instance.authInfo;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder:
            (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: appColors.whiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding: pad(horizontal: 20, vertical: 16),
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: appColors.textColor.shade200,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  16.verticalSpace,
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
                        return const SkeletonLoader(height: 48);
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
                                  const FetchServicesForAProvider(),
                                );
                              },
                            ),
                          ],
                        );
                      }

                      if (state is ServicesLoaded) {
                        isProcessing = false;

                        final services = state.services;

                        if (services.isEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GenText(
                                'No service found for this request.',
                                color: appColors.textColor.shade400,
                              ),
                              12.verticalSpace,
                              WideButton(
                                label: 'Retry',
                                onPressed: () {
                                  context.read<ServiceCatalogBloc>().add(
                                    const FetchServicesForAProvider(),
                                  );
                                },
                              ),
                            ],
                          );
                        }

                        if (_selectType.value == null ||
                            !services.any(
                              (s) => s.id == _selectType.value!.id,
                            )) {
                          _selectType.value = services.first;
                        }

                        return ServiceDropdown(
                          items: services,
                          controller: _selectType,
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                  10.verticalSpace,
                  KFormField(
                    label: 'Location',
                    hintText: 'Enter your location',
                    controller: locationController,
                    keyboardType: TextInputType.text,
                  ),
                  10.verticalSpace,
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
                            firstDate: now,
                            lastDate: DateTime(now.year + 1),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: appColors.primary.shade500,
                                  ),
                                ),
                                child: child!,
                              );
                            },
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
                  10.verticalSpace,
                  KFormField(
                    label: 'Price',
                    hintText: 'Enter the price',
                    controller: priceController,
                    keyboardType: TextInputType.number,
                  ),
                  10.verticalSpace,
                  KFormField(
                    label: 'Service Description',
                    hintText: 'Type service description here...',
                    controller: serviceController,
                    keyboardType: TextInputType.text,
                    maxLines: 8,
                    minLines: 6,
                  ),
                  16.verticalSpace,
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
                            if (currentUserId == null) {
                              await showErrorSnackbar(
                                context,
                                'Unable to identify provider.',
                              );
                              return;
                            }

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
                            final user = widget.chat.participants?.firstWhere(
                              (p) => p.participantType == 'USER',
                            );
                            final providerServiceId =
                                _selectType.value!.providerServiceId;

                            log(
                              '[INVOICE] _selectType.value: ${_selectType.value?.toJson()}',
                            );

                            if (providerServiceId == null) {
                              await showErrorSnackbar(
                                context,
                                'Selected service has no ID.',
                              );
                              return;
                            }

                            final invoice = InvoiceFormData(
                              invoiceNo:
                                  'INV-${rand.toString().padLeft(3, '0')}',
                              chatId: widget.chat.id,
                              userId: user?.participantId,
                              providerServiceId: providerServiceId,
                              serviceCategory: _selectType.value!.name,
                              location: locationController.text,
                              price: int.tryParse(priceController.text) ?? 0,
                              description: serviceController.text,
                              date: _selectedDate.value!,
                            );

                            await GeneralDialogs.showCustomDialog<void>(
                              context,
                              body: BlocProvider.value(
                                value: widget.chatDetailBloc,
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
