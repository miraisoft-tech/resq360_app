import 'dart:io';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/utils/app_file_picker.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        children: const [
          ServiceDetailSection(),
          WorkingHoursSection(),
        ],
      ),
    );
  }
}

class ServiceDetailSection extends StatefulWidget {
  const ServiceDetailSection({super.key});

  @override
  State<ServiceDetailSection> createState() => _ServiceDetailSectionState();
}

class _ServiceDetailSectionState extends State<ServiceDetailSection> {
  TextEditingController descController = TextEditingController();
  final selectedIssue = ValueNotifier<ServiceTypeEnums?>(null);

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return ListView(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        bottom: 100.h,
        top: 30.h,
      ),
      children: [
        GenText(
          'You can select multiple service category',
          color: appColors.black,
          height: 24.5,
        ),
        16.verticalSpace,
        ValueListenableBuilder<ServiceTypeEnums?>(
          valueListenable: selectedIssue,
          builder: (context, selected, _) {
            return Column(
              children: [
                IssueRadio(
                  label: 'Towing',
                  selected: selected == ServiceTypeEnums.towing,
                  onTap: () => selectedIssue.value = ServiceTypeEnums.towing,
                ),
                IssueRadio(
                  label: 'Plumbing',
                  selected: selected == ServiceTypeEnums.plumbing,
                  onTap: () => selectedIssue.value = ServiceTypeEnums.plumbing,
                ),
                IssueRadio(
                  label: 'Mechanic',
                  selected: selected == ServiceTypeEnums.mechanic,
                  onTap: () => selectedIssue.value = ServiceTypeEnums.mechanic,
                ),
                IssueRadio(
                  label: 'Electrician',
                  selected: selected == ServiceTypeEnums.plumbing,
                  onTap: () => selectedIssue.value = ServiceTypeEnums.plumbing,
                ),
              ],
            );
          },
        ),
        30.verticalSpace,
        KFormField(
          label: 'Service Description',
          controller: descController,
          hintText: 'Describe your service in detail...',
          maxLines: 10,
          minLines: 8,
          onChanged: (value) {
            setState(() {});
          },
        ),
        30.verticalSpace,
        Col(
          children: [
            GenText(
              'Service image',
              color: appColors.black,
              height: 24.5,
            ),
            10.verticalSpace,
            Wrap(
              spacing: 10.w,
              children: [
                if (pickedImages.isEmpty)
                  ...[1, 2, 3].map((value) {
                    return GestureDetector(
                      onTap: () => pickCameraPhoto(context),
                      child: Container(
                        padding: pad(vertical: 25, horizontal: 20),
                        height: 110,
                        width: 115,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: appColors.primary.shade500,
                          ),
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
                              height: 14.5,
                              weight: FontWeight.w400,
                            ),
                          ],
                        ),
                      ),
                    );
                  })
                else
                  ...pickedImages.map(
                    (image) {
                      return Stack(
                        alignment: Alignment.topRight,
                        children: [
                          memoryImage(
                            imgBytes: image.readAsBytesSync(),
                            height: 110,
                            width: 115,
                            fit: BoxFit.cover,
                          ),
                          SVGButton(
                            path: AppAssets.ASSETS_ICONS_DELETE_ICON_SVG,
                            onTap: () {
                              setState(() {
                                pickedImages.remove(image);
                              });
                            },
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
            10.verticalSpace,
            Center(
              child: GenText(
                'You can upload up to 3 images \n PNG, JPG up to 10mb each',
                color: appColors.neutral.shade400,
                size: 12,
                weight: FontWeight.w400,
                height: 24.5,
              ),
            ),
          ],
        ),

        40.verticalSpace,
        WideButton(
          label: 'Update Service',
          onPressed: () {},
        ),
      ],
    );
  }

  List<File> pickedImages = [];

  Future<void> pickCameraPhoto(BuildContext context) async {
    pickedImages = await AppFilePicker.pickMultiImages() ?? [];

    if (pickedImages.isNotEmpty) {
      setState(() {});
    }

    if (context.mounted) {}
  }
}

class WorkingHoursSection extends StatefulWidget {
  const WorkingHoursSection({super.key});

  @override
  State<WorkingHoursSection> createState() => _WorkingHoursSectionState();
}

class _WorkingHoursSectionState extends State<WorkingHoursSection> {
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();

  ValueNotifier<bool> monday = ValueNotifier(true);
  ValueNotifier<bool> tuesday = ValueNotifier(true);
  ValueNotifier<bool> wednesday = ValueNotifier(true);
  ValueNotifier<bool> thursday = ValueNotifier(true);
  ValueNotifier<bool> friday = ValueNotifier(true);
  ValueNotifier<bool> saturday = ValueNotifier(true);
  ValueNotifier<bool> sunday = ValueNotifier(true);

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          isStartTime
              ? (startTime ?? TimeOfDay.now())
              : (endTime ?? TimeOfDay.now()),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: context.appColors.primary.shade500,
              onSurface: context.appColors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
          startTimeController.text = picked.format(context);
        } else {
          endTime = picked;
          endTimeController.text = picked.format(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return ListView(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        bottom: 100.h,
        top: 30.h,
      ),
      children: [
        GenText(
          'Working Hours',
          color: appColors.black,
          height: 24.5,
        ),
        16.verticalSpace,
        Row(
          children: [
            GenText(
              'Monday',
              color: appColors.neutral.shade400,
              height: 24.5,
            ),
            const Spacer(),
            CustomSwitchWidget(
              value: monday.value,
              onChanged: ({required value}) {
                monday.value = value;
                setState(() {});
              },
              activeThumbColor: appColors.primary.shade500,
              disabledThumbColor: appColors.textColor.shade100,
              tapColor: appColors.whiteColor,
            ),
          ],
        ),
        16.verticalSpace,
        Row(
          children: [
            GenText(
              'Tuesday',
              color: appColors.neutral.shade400,
              height: 24.5,
            ),
            const Spacer(),
            CustomSwitchWidget(
              value: tuesday.value,
              onChanged: ({required value}) {
                tuesday.value = value;
                setState(() {});
              },
              activeThumbColor: appColors.primary.shade500,
              disabledThumbColor: appColors.textColor.shade100,
              tapColor: appColors.whiteColor,
            ),
          ],
        ),
        16.verticalSpace,
        Row(
          children: [
            GenText(
              'Wednesday',
              color: appColors.neutral.shade400,
              height: 24.5,
            ),
            const Spacer(),
            CustomSwitchWidget(
              value: wednesday.value,
              onChanged: ({required value}) {
                wednesday.value = value;
                setState(() {});
              },
              activeThumbColor: appColors.primary.shade500,
              disabledThumbColor: appColors.textColor.shade100,
              tapColor: appColors.whiteColor,
            ),
          ],
        ),
        16.verticalSpace,
        Row(
          children: [
            GenText(
              'Thursday',
              color: appColors.neutral.shade400,
              height: 24.5,
            ),
            const Spacer(),
            CustomSwitchWidget(
              value: thursday.value,
              onChanged: ({required value}) {
                thursday.value = value;
                setState(() {});
              },
              activeThumbColor: appColors.primary.shade500,
              disabledThumbColor: appColors.textColor.shade100,
              tapColor: appColors.whiteColor,
            ),
          ],
        ),
        16.verticalSpace,
        Row(
          children: [
            GenText(
              'Friday',
              color: appColors.neutral.shade400,
              height: 24.5,
            ),
            const Spacer(),
            CustomSwitchWidget(
              value: friday.value,
              onChanged: ({required value}) {
                friday.value = value;
                setState(() {});
              },
              activeThumbColor: appColors.primary.shade500,
              disabledThumbColor: appColors.textColor.shade100,
              tapColor: appColors.whiteColor,
            ),
          ],
        ),
        16.verticalSpace,
        Row(
          children: [
            GenText(
              'Saturday',
              color: appColors.neutral.shade400,
              height: 24.5,
            ),
            const Spacer(),
            CustomSwitchWidget(
              value: saturday.value,
              onChanged: ({required value}) {
                saturday.value = value;
                setState(() {});
              },
              activeThumbColor: appColors.primary.shade500,
              disabledThumbColor: appColors.textColor.shade100,
              tapColor: appColors.whiteColor,
            ),
          ],
        ),
        16.verticalSpace,
        Row(
          children: [
            GenText(
              'Sunday',
              color: appColors.neutral.shade400,
              height: 24.5,
            ),
            const Spacer(),
            CustomSwitchWidget(
              value: sunday.value,
              onChanged: ({required value}) {
                sunday.value = value;
                setState(() {});
              },
              activeThumbColor: appColors.primary.shade500,
              disabledThumbColor: appColors.textColor.shade100,
              tapColor: appColors.whiteColor,
            ),
          ],
        ),

        30.verticalSpace,
        Col(
          children: [
            GenText(
              'Time',
              color: appColors.black,
              height: 24.5,
            ),
            20.verticalSpace,
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
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ),
                90.horizontalSpace,
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(context, false),
                    child: AbsorbPointer(
                      child: KFormField(
                        label: 'End Time',
                        controller: endTimeController,
                        hintText: '00:00',
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        40.verticalSpace,
        WideButton(
          label: 'Update Service',
          onPressed: () {},
        ),
      ],
    );
  }
}
