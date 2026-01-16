import 'dart:async';
import 'dart:io';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/utils/app_file_picker.dart';
import 'package:resq360/features/provider/authentication/data/bloc/provider_auth_bloc.dart';
import 'package:resq360/features/settings/data/bloc/update_profile_bloc.dart/profile_update_bloc.dart';
import 'package:resq360/features/settings/data/models/service_type.enums.dart';
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
  ServiceTypeEnums? selectedServiceType;

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

  void handleToggleDay({required String day, required bool value}) {
    setState(() {
      workingDays[day] = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

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

      if (provider.openingHours != null) {
        try {
          final dateTime = DateTime.parse(provider.openingHours!);
          startTime = TimeOfDay(
            hour: dateTime.hour,
            minute: dateTime.minute,
          );
          startTimeController.text = startTime!.format(context);
        } on Exception catch (e) {
          log(e.toString());
        }
      }

      if (provider.closingHours != null) {
        try {
          final dateTime = DateTime.parse(provider.closingHours!);
          endTime = TimeOfDay(
            hour: dateTime.hour,
            minute: dateTime.minute,
          );
          endTimeController.text = endTime!.format(context);
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

    final startDateTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      startTime?.hour ?? 9,
      startTime?.minute ?? 0,
    );
    final endDateTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      endTime?.hour ?? 17,
      endTime?.minute ?? 0,
    );

    bloc.add(
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
        if (state is ProfileUpdateLoading) {
          showLoadingDialog(context);
        } 
      

        if (state is ProfileUpdateSuccess) {
            
            await showSuccessSnackbar(
              context,
              'Service updated successfully',
          
          );

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
          body: TabBarView(
            controller: _tabController,
            children: [
              ServiceDetailSection(
                descController: descController,
                pickedImages: pickedImages,
                existingImageUrls: existingImageUrls,
                imagesToKeep: imagesToKeep,
                onImagesPicked:
                    (images) => setState(() => pickedImages = images),
                onExistingImageRemoved: (url) {
                  setState(() {
                    imagesToKeep.remove(url);
                  });
                },
                onServiceSelected: (type) => selectedServiceType = type,
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
    required this.onImagesPicked,
    required this.onExistingImageRemoved,
    required this.onServiceSelected,
    required this.onSubmit,
    super.key,
  });
  final TextEditingController descController;
  final List<File> pickedImages;
  final List<String> existingImageUrls;
  final List<String> imagesToKeep;
  final ValueChanged<List<File>> onImagesPicked;
  final ValueChanged<String> onExistingImageRemoved;
  final ValueChanged<ServiceTypeEnums> onServiceSelected;
  final Future<void> Function() onSubmit;

  @override
  State<ServiceDetailSection> createState() => _ServiceDetailSectionState();
}

class _ServiceDetailSectionState extends State<ServiceDetailSection> {
  final selectedIssue = ValueNotifier<ServiceTypeEnums?>(null);

  Future<void> pickImages(BuildContext context) async {
    final images = await AppFilePicker.pickMultiImages(limit: 10) ?? [];
    if (images.isNotEmpty) {
      widget.onImagesPicked([...widget.pickedImages, ...images]);
    }
  }

  @override
  void dispose() {
    selectedIssue.dispose();
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
        ValueListenableBuilder<ServiceTypeEnums?>(
          valueListenable: selectedIssue,
          builder: (context, selected, _) {
            return Column(
              children:
                  ServiceTypeEnums.values.map((type) {
                    return IssueRadio(
                      label: type.name.capitalize,
                      selected: selected == type,
                      onTap: () {
                        selectedIssue.value = type;
                        widget.onServiceSelected(type);
                      },
                    );
                  }).toList(),
            );
          },
        ),
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
        WideButton(
          label: 'Update Service',
          onPressed: widget.onSubmit,
        ),
      ],
    );
  }
}

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
        WideButton(
          label: 'Update Service',
          onPressed: onSubmit,
        ),
      ],
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
      if (isStart) {
        startTimeController.text = picked.format(context);
        onTimeSelected(picked, TimeOfDay.now());
      } else {
        endTimeController.text = picked.format(context);
        onTimeSelected(TimeOfDay.now(), picked);
      }
    }
  }
}
