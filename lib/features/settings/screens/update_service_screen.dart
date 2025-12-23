import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/utils/app_file_picker.dart';
import 'package:resq360/features/settings/data/bloc/gallery_bloc/gallery_bloc.dart';
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
  }

  Future<void> handleUploadGalleryService() async {
    context.read<GalleryBloc>().add(
      UpdateServiceEvent(
        images: pickedImages,
        caption: descController.text,
      ),
    );
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

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
          BlocConsumer<GalleryBloc, GalleryState>(
            listener: (context, state) async {
              if (state is GalleryLoading) {
                await showLoadingDialog(context);
              } else {
                Navigator.pop(context);
              }

              if (state is GalleryItemCreated) {
                unawaited(
                  showSnackBar(
                    context,
                    'Success',
                    'Service gallery updated successfully',
                  ),
                );

                setState(() {
                  pickedImages.clear();
                  descController.clear();
                });
              } else if (state is GalleryError) {
                unawaited(showErrorSnackbar(context, state.message));
              }
            },
            builder: (context, state) {
              return ServiceDetailSection(
                descController: descController,
                pickedImages: pickedImages,
                onImagesPicked:
                    (images) => setState(() => pickedImages = images),
                onServiceSelected: (type) => selectedServiceType = type,
                onSubmit: handleUploadGalleryService,
              );
            },
          ),
          BlocConsumer<ProfileUpdateBloc, ProfileUpdateState>(
            listener: (context, state) async {
              if (state is ProfileUpdateLoading) {
                await showLoadingDialog(context);
              } else {
                Navigator.pop(context);
              }

              if (state is ProfileUpdateSuccess) {
                unawaited(
                  showSnackBar(
                    context,
                    'Success',
                    'Service updated successfully',
                  ),
                );
              } else if (state is ProfileUpdateError) {
                unawaited(showErrorSnackbar(context, state.message));
              }
            },
            builder: (context, state) {
              return WorkingHoursSection(
                workingDays: workingDays,
                startTimeController: startTimeController,
                endTimeController: endTimeController,
                onTimeSelected: (start, end) {
                  startTime = start;
                  endTime = end;
                },
                onSubmit: handleUpdateService,
                onToggleDay: handleToggleDay,
              );
            },
          ),
        ],
      ),
    );
  }
}

class ServiceDetailSection extends StatefulWidget {
  const ServiceDetailSection({
    required this.descController,
    required this.pickedImages,
    required this.onImagesPicked,
    required this.onServiceSelected,
    required this.onSubmit,
    super.key,
  });
  final TextEditingController descController;
  final List<File> pickedImages;
  final ValueChanged<List<File>> onImagesPicked;
  final ValueChanged<ServiceTypeEnums> onServiceSelected;
  final Future<void> Function() onSubmit;

  @override
  State<ServiceDetailSection> createState() => _ServiceDetailSectionState();
}

class _ServiceDetailSectionState extends State<ServiceDetailSection> {
  final selectedIssue = ValueNotifier<ServiceTypeEnums?>(null);

  Future<void> pickCameraPhoto(BuildContext context) async {
    final images = await AppFilePicker.pickMultiImages() ?? [];
    if (images.isNotEmpty) widget.onImagesPicked(images);
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

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
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.pickedImages.length + 1,
            separatorBuilder: (_, _) => 10.horizontalSpace,
            itemBuilder: (context, index) {
              if (index == widget.pickedImages.length) {
                return GestureDetector(
                  onTap: () => pickCameraPhoto(context),
                  child: Container(
                    height: 110,
                    width: 115,
                    padding: pad(vertical: 25, horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: appColors.primary.shade500),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppAssets.ASSETS_ICONS_UPLOAD_SVG.svg,
                        10.verticalSpace,
                        GenText(
                          'Add Image',
                          size: 12,
                          color: appColors.primary.shade500,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final image = widget.pickedImages[index];

              return Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: memoryImage(
                      imgBytes: image.readAsBytesSync(),
                      height: 110,
                      width: 115,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: SVGButton(
                      path: AppAssets.ASSETS_ICONS_DELETE_ICON_SVG,
                      onTap: () {
                        setState(() {
                          widget.pickedImages.removeAt(index);
                          widget.onImagesPicked(widget.pickedImages);
                        });
                      },
                    ),
                  ),
                ],
              );
            },
          ),
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
