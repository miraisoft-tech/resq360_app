import 'package:resq360/__lib.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.title,
    required this.body,
    this.subTitle,
    super.key,
  });

  final String title;
  final String? subTitle;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: pad(horizontal: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (Navigator.canPop(context))
                        IconButton(
                          onPressed: () => pop(context),
                          icon: AppAssets.ASSETS_ICONS_BACK_ICON_SVG.svg,
                        )
                      else
                        const SizedBox(
                          width: 40,
                        ),

                      UrbText(
                        title,
                        size: 22,
                        height: 32,
                        weight: FontWeight.w700,
                        color: colors.black,
                        textAlign: TextAlign.center,
                      ),
                      40.horizontalSpace,
                    ],
                  ),
                  if (subTitle != null) ...[
                    GenText(
                      subTitle!,
                      height: 18.5,
                      weight: FontWeight.w400,
                      color: colors.textColor.shade500,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            30.verticalSpace,
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  top: 10.h,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
