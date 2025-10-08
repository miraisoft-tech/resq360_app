import 'package:resq360/__lib.dart';

class ToDoSection extends StatelessWidget {
  const ToDoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Col(
      children: [
        UrbText(
          'To-Do',
          size: 18,
          weight: FontWeight.w700,
          color: colors.black,
        ),
        20.verticalSpace,
        Container(
          padding: pad(horizontal: 14, vertical: 18),
          decoration: BoxDecoration(
            border: Border.all(color: colors.textColor.shade100),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GenText(
                '⚠️ Add your service description and update your service type so clients can find you faster.',
                height: 24.5,
                weight: FontWeight.w400,
                color: colors.black,
              ),
              GenText(
                'Update Service Info',
                height: 24.5,
                weight: FontWeight.w400,
                color: colors.primary.shade600,
              ),
              GenText(
                '⚠️ Upload your profile photo.',
                height: 24.5,
                weight: FontWeight.w400,
                color: colors.black,
              ),
              GenText(
                'Upload Photo',
                height: 24.5,
                weight: FontWeight.w400,
                color: colors.primary.shade600,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
