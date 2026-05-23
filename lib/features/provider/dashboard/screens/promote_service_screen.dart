import 'package:flutter/services.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/provider/authentication/data/bloc/provider_auth_bloc.dart';
import 'package:resq360/features/provider/authentication/data/models/provider_response.dart';
import 'package:resq360/features/provider/dashboard/models/duration.enum.dart';
import 'package:resq360/features/provider/dashboard/screens/promote_service_review.dart';

class PromoteServiceScreen extends StatefulWidget {
  const PromoteServiceScreen({super.key});

  @override
  State<PromoteServiceScreen> createState() => _PromoteServiceScreenState();
}

class _PromoteServiceScreenState extends State<PromoteServiceScreen> {
  late TextEditingController promoController;
  late TextEditingController discountController;

  final ValueNotifier<PromotionDuration?> _selectDuration =
      ValueNotifier<PromotionDuration?>(null);
  final ValueNotifier<ProviderService?> _selectedProviderService =
      ValueNotifier<ProviderService?>(null);

  @override
  void initState() {
    super.initState();
    promoController = TextEditingController();
    discountController = TextEditingController();

    final providerState = context.read<ProviderAuthBloc>().state;
    if (providerState is! ProviderProfileLoadedState) {
      context.read<ProviderAuthBloc>().add(const ProvidergetProviderProfile());
    }
  }

  @override
  void dispose() {
    promoController.dispose();
    discountController.dispose();
    _selectDuration.dispose();
    _selectedProviderService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final categoryDurations = PromotionDuration.values.toList();
    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: AppBar(
        backgroundColor: appColors.whiteColor,
        forceMaterialTransparency: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () => pop(context),
          icon: AppAssets.ASSETS_ICONS_BACK_ICON_SVG.svg,
        ),
        centerTitle: true,
        title: UrbText(
          'Promote Your Page',
          size: 22,
          height: 32.5,
          weight: FontWeight.w700,
          color: appColors.textColor.shade800,
        ),
        actions: const [SizedBox(width: 40)],
      ),
      body: SafeArea(
        child: Padding(
          padding: pad(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    GenText(
                      'Promotion Details',
                      size: 16,
                      height: 24.5,
                      weight: FontWeight.w700,
                      color: appColors.textColor.shade800,
                    ),
                    20.verticalSpace,
                    _ProviderServiceDropdown(
                      controller: _selectedProviderService,
                    ),
                    16.verticalSpace,
                    KFormField(
                      label: 'Promotion Description',
                      hintText: 'Get 30% off every towing service today.',
                      controller: promoController,
                      keyboardType: TextInputType.text,
                      maxLines: 10,
                      minLines: 8,
                      onChanged: (a) {
                        setState(() {});
                      },
                    ),
                    16.verticalSpace,
                    KFormField(
                      label: 'Discount Rate',
                      hintText: 'Enter a Discount Rate',
                      controller: discountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (a) {
                        setState(() {});
                      },
                    ),
                    16.verticalSpace,
                    ValueListenableBuilder<PromotionDuration?>(
                      valueListenable: _selectDuration,
                      builder: (context, value, child) {
                        return ObjectKDropDown<PromotionDuration>(
                          label: 'Promotion Duration',
                          hintText: 'Select the Promotion Duration',
                          showPrefix: false,

                          displayStringForOption:
                              (PromotionDuration d) => d.label,

                          value: value,
                          dropdownItems: categoryDurations,

                          onChanged: (selected) {
                            _selectDuration.value = selected;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
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
                      label: 'Continue',
                      backgroundColor: appColors.primary.shade500,
                      textColor: appColors.whiteColor,
                      onPressed: () async {
                        final selectedProviderService =
                            _selectedProviderService.value;
                        final selected = _selectDuration.value;
                        final discount = int.tryParse(
                          discountController.text.trim(),
                        );

                        if (selectedProviderService?.id == null) {
                          await showErrorSnackbar(
                            context,
                            'Please select a service to promote',
                          );
                          return;
                        }

                        if (promoController.text.trim().isEmpty) {
                          await showErrorSnackbar(
                            context,
                            'Please enter a promotion description',
                          );
                          return;
                        }

                        if (discount == null) {
                          await showErrorSnackbar(
                            context,
                            'Please enter a valid discount rate',
                          );
                          return;
                        }

                        if (selected == null) {
                          await showErrorSnackbar(
                            context,
                            'Please select the promotion duration',
                          );
                          return;
                        }

                        await pushScreen(
                          context,
                          PromoteServiceReviewScreen(
                            providerServiceId: selectedProviderService!.id!,
                            providerServiceName: _providerServiceLabel(
                              selectedProviderService,
                            ),
                            promotionDescription: promoController.text.trim(),
                            discount: discount.toString(),
                            duration: selected,
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

class _ProviderServiceDropdown extends StatelessWidget {
  const _ProviderServiceDropdown({required this.controller});

  final ValueNotifier<ProviderService?> controller;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProviderAuthBloc, ProviderAuthState>(
      builder: (context, state) {
        final services = _providerServicesFromState(state);

        return ValueListenableBuilder<ProviderService?>(
          valueListenable: controller,
          builder: (context, selectedService, child) {
            final dropdownValue = _matchingService(services, selectedService);

            return ObjectKDropDown<ProviderService>(
              label: 'Service to Promote',
              hintText:
                  state is ProviderAuthLoadingState
                      ? 'Loading services...'
                      : 'Select a service',
              showPrefix: false,
              displayStringForOption: _providerServiceLabel,
              value: dropdownValue,
              dropdownItems: services,
              onChanged:
                  services.isEmpty
                      ? null
                      : (selected) => controller.value = selected,
            );
          },
        );
      },
    );
  }

  List<ProviderService> _providerServicesFromState(ProviderAuthState state) {
    if (state is! ProviderProfileLoadedState) {
      return const [];
    }

    return (state.user.providerServices ?? <ProviderService>[])
        .where((service) => service.id != null && service.isActive)
        .toList(growable: false);
  }

  ProviderService? _matchingService(
    List<ProviderService> services,
    ProviderService? selectedService,
  ) {
    if (selectedService?.id == null) {
      return null;
    }

    for (final service in services) {
      if (service.id == selectedService!.id) {
        return service;
      }
    }

    return null;
  }
}

String _providerServiceLabel(ProviderService service) {
  final name = service.name?.trim();
  if (name != null && name.isNotEmpty) {
    return name;
  }

  final serviceName = service.service?.name.trim();
  if (serviceName != null && serviceName.isNotEmpty) {
    return serviceName;
  }

  return 'Service ${service.id ?? ''}'.trim();
}
