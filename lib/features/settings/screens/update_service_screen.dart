import 'dart:async';
import 'dart:io';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/service_catalog_bloc/service_catalog_bloc.dart';
import 'package:resq360/core/utils/app_file_picker.dart';
import 'package:resq360/features/customer/dashboard/data/models/service_models/service_request.model.dart';
import 'package:resq360/features/provider/authentication/data/bloc/provider_auth_bloc.dart';
import 'package:resq360/features/provider/authentication/data/models/provider_response.dart'
    as provider_models;
import 'package:resq360/features/settings/data/bloc/update_profile_bloc.dart/profile_update_bloc.dart';
import 'package:resq360/features/settings/data/models/provider_service_update.dart';
import 'package:resq360/features/widgets/custom_switch.dart';
import 'package:resq360/features/widgets/images.widgets.dart';
import 'package:resq360/features/widgets/issue_radio_widget.dart';

class UpdateServiceScreen extends StatefulWidget {
  const UpdateServiceScreen({super.key});

  @override
  State<UpdateServiceScreen> createState() => _UpdateServiceScreenState();
}

class _UpdateServiceScreenState extends State<UpdateServiceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final descController = TextEditingController();
  List<File> pickedImages = [];
  List<String> existingImageUrls = [];
  List<String> imagesToKeep = [];

  final Map<int, ServiceCategorySelection> selectedServices = {};
  List<Service> availableCategories = [];
  bool isLoadingCategories = true;

  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  final workingDays = {
    'monday': true,
    'tuesday': true,
    'wednesday': true,
    'thursday': true,
    'friday': true,
    'saturday': true,
    'sunday': true,
  };

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  String _formatTimeOfDay(TimeOfDay time) {
    final hour12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour12.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  void _setDefaultLocalWorkingHours() {
    startTime ??= const TimeOfDay(hour: 9, minute: 0);
    endTime ??= const TimeOfDay(hour: 17, minute: 0);
    startTimeController.text = _formatTimeOfDay(startTime!);
    endTimeController.text = _formatTimeOfDay(endTime!);
  }

  void handleToggleDay({required String day, required bool value}) {
    setState(() {
      workingDays[day] = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _setDefaultLocalWorkingHours();
    context.read<ServiceCatalogBloc>().add(const FetchServices());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProviderData();
    });
  }

  void _loadProviderData() {
    final providerState = context.read<ProviderAuthBloc>().state;
    if (providerState is ProviderProfileLoadedState) {
      final provider = providerState.user;

      if (provider.images != null && provider.images!.isNotEmpty) {
        setState(() {
          existingImageUrls = List<String>.from(provider.images!);
          imagesToKeep = List<String>.from(provider.images!);
        });
      }

      if (provider.description != null) {
        descController.text = provider.description!;
      }

      final services =
          provider.providerServices ?? <provider_models.ProviderService>[];

      for (final providerService in services) {
        final service = providerService.service;
        final serviceId = service?.id;
        final minorServices =
            providerService.minorServices
                ?.where((e) => e.trim().isNotEmpty)
                .toList() ??
            <String>[];

        if (service == null || serviceId == null) continue;

        setState(() {
          selectedServices[serviceId] = ServiceCategorySelection(
            service: service,
            isSelected: providerService.isActive,
            providerServiceId: providerService.id,
            minorServices: minorServices,
          );
        });
      }

      if (provider.openingHours != null) {
        try {
          final dateTime = DateTime.parse(provider.openingHours!).toLocal();
          startTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
          startTimeController.text = _formatTimeOfDay(startTime!);
        } on Exception catch (e) {
          log(e.toString());
        }
      }

      if (provider.closingHours != null) {
        try {
          final dateTime = DateTime.parse(provider.closingHours!).toLocal();
          endTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
          endTimeController.text = _formatTimeOfDay(endTime!);
        } on Exception catch (e) {
          log(e.toString());
        }
      }

      if (provider.workingDays != null) {
        setState(() {
          for (final day in workingDays.keys) {
            workingDays[day] = provider.workingDays!.contains(day);
          }
        });
      }
    }
  }

  Future<void> handleUpdateService() async {
    final bloc = context.read<ProfileUpdateBloc>();

    final selectedDays =
        workingDays.entries.where((e) => e.value).map((e) => e.key).toList();

    final startDateTime =
        DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          startTime?.hour ?? 9,
          startTime?.minute ?? 0,
        ).toUtc();
    final endDateTime =
        DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          endTime?.hour ?? 17,
          endTime?.minute ?? 0,
        ).toUtc();

    final servicesToUpdate =
        selectedServices.entries
            .where(
              (e) => e.value.isSelected || e.value.providerServiceId != null,
            )
            .map(
              (e) => ProviderServiceUpdate(
                isActive: e.value.isSelected,
                serviceCategoryId: e.key,
                minorServices: e.value.minorServices,
              ),
            )
            .toList();

    if (servicesToUpdate.isEmpty) {
      unawaited(
        showErrorSnackbar(context, 'Please select at least one service'),
      );
      return;
    }

    bloc
      ..add(UpdateProviderServicesEvent(services: servicesToUpdate))
      ..add(
        UpdateProviderInfoEvent(
          description: descController.text.trim(),
          workingDays: selectedDays,
          openingHours: startDateTime,
          closingHours: endDateTime,
          filePath: pickedImages.isNotEmpty ? pickedImages.first.path : null,
          images: pickedImages,
          existingImages: imagesToKeep,
        ),
      );
  }

  @override
  void dispose() {
    _tabController.dispose();
    descController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return BlocConsumer<ProfileUpdateBloc, ProfileUpdateState>(
      listener: (context, state) async {
        if (state is ProfileUpdateSuccess) {
          await showSuccessSnackbar(context, 'Service updated successfully');

          context.read<ProviderAuthBloc>().add(
            const ProvidergetProviderProfile(),
          );
        } else if (state is ProfileUpdateError) {
          unawaited(showErrorSnackbar(context, state.message));
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: appColors.whiteColor,
          appBar: AppBar(
            forceMaterialTransparency: true,
            title: const GenText(
              'Update Service',
              size: 18,
              weight: FontWeight.w700,
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: appColors.black),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: appColors.whiteColor,
            foregroundColor: appColors.black,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: appColors.primary,
              labelColor: appColors.primary,
              unselectedLabelColor: appColors.textColor.shade500,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'Service Detail'),
                Tab(text: 'Working Hours'),
              ],
            ),
          ),
          body: BlocBuilder<ServiceCatalogBloc, ServiceCatalogState>(
            builder: (context, state) {
              if (state is ServiceCatalogLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ServicesLoaded) {
                availableCategories = state.services;

                return TabBarView(
                  controller: _tabController,
                  children: [
                    ServiceDetailSection(
                      descController: descController,
                      pickedImages: pickedImages,
                      existingImageUrls: existingImageUrls,
                      imagesToKeep: imagesToKeep,
                      availableCategories: availableCategories,
                      selectedServices: selectedServices,
                      onServicesChanged: (services) {
                        setState(() {
                          selectedServices
                            ..clear()
                            ..addAll(services);
                        });
                      },
                      onImagesPicked:
                          (images) => setState(() => pickedImages = images),
                      onExistingImageRemoved: (url) {
                        setState(() {
                          imagesToKeep.remove(url);
                        });
                      },
                      onSubmit: handleUpdateService,
                    ),
                    WorkingHoursSection(
                      workingDays: workingDays,
                      startTimeController: startTimeController,
                      endTimeController: endTimeController,
                      onTimeSelected: (start, end) {
                        startTime = start;
                        endTime = end;
                      },
                      onSubmit: handleUpdateService,
                      onToggleDay: handleToggleDay,
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }
}

class ServiceDetailSection extends StatefulWidget {
  const ServiceDetailSection({
    required this.descController,
    required this.pickedImages,
    required this.existingImageUrls,
    required this.imagesToKeep,
    required this.availableCategories,
    required this.selectedServices,
    required this.onServicesChanged,
    required this.onImagesPicked,
    required this.onExistingImageRemoved,
    required this.onSubmit,
    super.key,
  });

  final TextEditingController descController;
  final List<File> pickedImages;
  final List<String> existingImageUrls;
  final List<String> imagesToKeep;
  final List<Service> availableCategories;
  final Map<int, ServiceCategorySelection> selectedServices;
  final ValueChanged<Map<int, ServiceCategorySelection>> onServicesChanged;
  final ValueChanged<List<File>> onImagesPicked;
  final ValueChanged<String> onExistingImageRemoved;
  final Future<void> Function() onSubmit;

  @override
  State<ServiceDetailSection> createState() => _ServiceDetailSectionState();
}

class _ServiceDetailSectionState extends State<ServiceDetailSection> {
  final Map<int, TextEditingController> minorServiceControllers = {};
  final Map<int, bool> expandedServices = {};

  Future<void> pickImages(BuildContext context) async {
    final images = await AppFilePicker.pickMultiImages(limit: 10) ?? [];
    if (images.isNotEmpty) {
      widget.onImagesPicked([...widget.pickedImages, ...images]);
    }
  }

  void _toggleService(Service service) {
    final updated = Map<int, ServiceCategorySelection>.from(
      widget.selectedServices,
    );

    if (updated.containsKey(service.id)) {
      final current = updated[service.id]!;
      updated[service.id] = ServiceCategorySelection(
        service: service,
        isSelected: !current.isSelected,
        minorServices: current.minorServices,
        providerServiceId: current.providerServiceId,
      );
    } else {
      updated[service.id] = ServiceCategorySelection(
        service: service,
        isSelected: true,
        minorServices: [],
      );
    }

    widget.onServicesChanged(updated);
  }

  void _addMinorService(int serviceId) {
    final controller = minorServiceControllers[serviceId];
    if (controller == null) return;

    final text = controller.text.trim();
    if (text.isEmpty) return;

    final updated = Map<int, ServiceCategorySelection>.from(
      widget.selectedServices,
    );
    if (updated.containsKey(serviceId)) {
      final current = updated[serviceId]!;
      final newMinorServices = List<String>.from(current.minorServices);

      if (!newMinorServices.contains(text)) {
        newMinorServices.add(text);
        updated[serviceId] = ServiceCategorySelection(
          service: current.service,
          isSelected: current.isSelected,
          minorServices: newMinorServices,
          providerServiceId: current.providerServiceId,
        );
        widget.onServicesChanged(updated);
        controller.clear();
      }
    }
  }

  void _removeMinorService(int serviceId, String minorService) {
    final updated = Map<int, ServiceCategorySelection>.from(
      widget.selectedServices,
    );
    if (updated.containsKey(serviceId)) {
      final current = updated[serviceId]!;
      final newMinorServices = List<String>.from(current.minorServices)
        ..remove(minorService);
      updated[serviceId] = ServiceCategorySelection(
        service: current.service,
        isSelected: current.isSelected,
        minorServices: newMinorServices,
        providerServiceId: current.providerServiceId,
      );
      widget.onServicesChanged(updated);
    }
  }

  @override
  void dispose() {
    for (final controller in minorServiceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final totalImages = widget.imagesToKeep.length + widget.pickedImages.length;

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 30.h),
      children: [
        GenText(
          'You can select multiple service category',
          color: appColors.black,
        ),
        16.verticalSpace,

        ...widget.availableCategories.map((service) {
          final isSelected =
              widget.selectedServices[service.id]?.isSelected ?? false;
          final minorServices =
              widget.selectedServices[service.id]?.minorServices ?? [];
          final isExpanded =
              expandedServices[service.id] ??
              (isSelected && minorServices.isNotEmpty);

          if (!minorServiceControllers.containsKey(service.id)) {
            minorServiceControllers[service.id] = TextEditingController();
          }

          return Column(
            children: [
              Row(
                children: [
                  IssueRadio(
                    label: service.name,
                    selected: isSelected,
                    onTap: () => _toggleService(service),
                  ),
                  const Spacer(),
                  if (isSelected) ...[
                    IconButton(
                      icon: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 20.sp,
                        color: appColors.textColor.shade400,
                      ),
                      onPressed: () {
                        setState(() {
                          expandedServices[service.id] = !isExpanded;
                        });
                      },
                    ),
                  ],
                ],
              ),

              if (isSelected) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
                      if (isExpanded) ...[
                        Padding(
                          padding: EdgeInsets.only(
                            left: 40.w,
                            right: 16.w,
                            bottom: 16.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // GenText(
                              //   'Add minor services (optional)',
                              //   color: appColors.textColor.shade600,
                              //   size: 13,
                              // ),
                              // 8.verticalSpace,
                              Row(
                                children: [
                                  Expanded(
                                    child: KFormField(
                                      controller:
                                          minorServiceControllers[service.id]!,
                                      hintText: 'e.g., Jump Start, Tire Change',
                                      onFieldSubmitted:
                                          (_) => _addMinorService(service.id),
                                      label: 'Add minor services (optional)',
                                    ),
                                  ),
                                  8.horizontalSpace,
                                  IconButton(
                                    icon: Icon(
                                      Icons.add_circle,
                                      color: appColors.primary.shade500,
                                      size: 28.sp,
                                    ),
                                    onPressed:
                                        () => _addMinorService(service.id),
                                  ),
                                ],
                              ),

                              if (minorServices.isNotEmpty) ...[
                                12.verticalSpace,
                                Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.h,
                                  children:
                                      minorServices.map((minor) {
                                        return Chip(
                                          label: GenText(minor, size: 12),
                                          deleteIcon: Icon(
                                            Icons.close,
                                            size: 16.sp,
                                          ),
                                          onDeleted:
                                              () => _removeMinorService(
                                                service.id,
                                                minor,
                                              ),
                                          backgroundColor:
                                              appColors.primary.shade100,
                                          deleteIconColor:
                                              appColors.error.shade500,
                                          side: BorderSide.none,
                                        );
                                      }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          );
        }),

        30.verticalSpace,
        KFormField(
          label: 'Service Description',
          controller: widget.descController,
          hintText: 'Describe your service in detail...',
          maxLines: 8,
        ),
        30.verticalSpace,
        GenText('Service image', color: appColors.black),
        10.verticalSpace,

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
          ),
          itemCount: totalImages + 1,
          itemBuilder: (context, index) {
            if (index == totalImages) {
              return GestureDetector(
                onTap: () => pickImages(context),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: appColors.primary.shade500),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppAssets.ASSETS_ICONS_UPLOAD_SVG.svg,
                      5.verticalSpace,
                      GenText(
                        'Add Image',
                        size: 10,
                        color: appColors.primary.shade500,
                      ),
                    ],
                  ),
                ),
              );
            }

            if (index < widget.imagesToKeep.length) {
              final imageUrl = widget.imagesToKeep[index];

              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      height: double.infinity,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: appColors.textColor.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.broken_image,
                              color: appColors.textColor.shade300,
                              size: 30,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          decoration: BoxDecoration(
                            color: appColors.textColor.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                              color: appColors.primary.shade500,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        widget.onExistingImageRemoved(imageUrl);
                      },
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: appColors.primary.shade500,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 14.sp,
                          color: appColors.whiteColor,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            final pickedIndex = index - widget.imagesToKeep.length;
            final image = widget.pickedImages[pickedIndex];

            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: memoryImage(
                    imgBytes: image.readAsBytesSync(),
                    height: double.infinity,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      final updatedList = List<File>.from(widget.pickedImages)
                        ..removeAt(pickedIndex);
                      widget.onImagesPicked(updatedList);
                    },
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: appColors.error.shade500,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 14.sp,
                        color: appColors.whiteColor,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        10.verticalSpace,
        GenText(
          'You can upload more than 3 images',
          textAlign: TextAlign.center,
          color: appColors.textColor.shade300,
        ),
        GenText(
          'PNG, JPG up to 10mb each',
          textAlign: TextAlign.center,
          color: appColors.textColor.shade300,
        ),
        40.verticalSpace,
        BlocBuilder<ProfileUpdateBloc, ProfileUpdateState>(
          builder: (context, state) {
            return WideButton(
              label: 'Update Service',
              loading: state is ProfileUpdateLoading,
              onPressed: widget.onSubmit,
            );
          },
        ),
      ],
    );
  }
}

// Keep your existing WorkingHoursSection exactly as is
class WorkingHoursSection extends StatelessWidget {
  const WorkingHoursSection({
    required this.workingDays,
    required this.startTimeController,
    required this.endTimeController,
    required this.onTimeSelected,
    required this.onSubmit,
    required this.onToggleDay,
    super.key,
  });
  final Map<String, bool> workingDays;
  final TextEditingController startTimeController;
  final TextEditingController endTimeController;
  final void Function(TimeOfDay start, TimeOfDay end) onTimeSelected;
  final Future<void> Function() onSubmit;
  final void Function({required String day, required bool value}) onToggleDay;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 30.h),
      children: [
        ...workingDays.keys.map((day) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Row(
              children: [
                GenText(day.capitalize, color: appColors.neutral.shade400),
                const Spacer(),
                CustomSwitchWidget(
                  value: workingDays[day] ?? false,
                  onChanged:
                      ({required value}) => onToggleDay(day: day, value: value),
                  activeThumbColor: appColors.primary.shade500,
                  disabledThumbColor: appColors.textColor.shade100,
                  tapColor: appColors.whiteColor,
                ),
              ],
            ),
          );
        }),
        30.verticalSpace,
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectTime(context, true),
                child: AbsorbPointer(
                  child: KFormField(
                    label: 'Start Time',
                    controller: startTimeController,
                    hintText: '00:00',
                  ),
                ),
              ),
            ),
            50.horizontalSpace,
            Expanded(
              child: GestureDetector(
                onTap: () => _selectTime(context, false),
                child: AbsorbPointer(
                  child: KFormField(
                    label: 'End Time',
                    controller: endTimeController,
                    hintText: '00:00',
                  ),
                ),
              ),
            ),
          ],
        ),
        40.verticalSpace,
        BlocBuilder<ProfileUpdateBloc, ProfileUpdateState>(
          builder: (context, state) {
            return WideButton(
              label: 'Update Service',
              loading: state is ProfileUpdateLoading,
              onPressed: onSubmit,
            );
          },
        ),
      ],
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          isStart
              ? (startTimeController.text.isNotEmpty
                  ? _parseTimeOfDay(startTimeController.text) ?? TimeOfDay.now()
                  : TimeOfDay.now())
              : (endTimeController.text.isNotEmpty
                  ? _parseTimeOfDay(endTimeController.text) ?? TimeOfDay.now()
                  : TimeOfDay.now()),
      builder:
          (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: context.appColors.primary.shade500,
              ),
            ),
            child: child!,
          ),
    );

    if (picked != null) {
      final hour12 = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      final formattedTime =
          '${hour12.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} $period';

      if (isStart) {
        startTimeController.text = formattedTime;
        final currentEndTime =
            _parseTimeOfDay(endTimeController.text) ??
            const TimeOfDay(hour: 17, minute: 0);
        onTimeSelected(picked, currentEndTime);
      } else {
        endTimeController.text = formattedTime;
        final currentStartTime =
            _parseTimeOfDay(startTimeController.text) ??
            const TimeOfDay(hour: 9, minute: 0);
        onTimeSelected(currentStartTime, picked);
      }
    }
  }

  TimeOfDay? _parseTimeOfDay(String timeString) {
    if (timeString.isEmpty) return null;
    try {
      final parts = timeString.split(' ');
      if (parts.length != 2) return null;

      final timeParts = parts[0].split(':');
      if (timeParts.length != 2) return null;

      var hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final period = parts[1].toUpperCase();

      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } on Exception catch (e) {
      log(e);
      return null;
    }
  }
}
