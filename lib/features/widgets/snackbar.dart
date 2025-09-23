import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';

import '../../__lib.dart';

Future<void> showErrorSnackbar(String message) async {
  await showSnackBar(AppRouter.buildContext, 'Error', message);
}

Future<void> showSuccessSnackbar(
  String message, {
  bool showTitle = true,
}) async {
  await showSnackBar(
    AppRouter.buildContext,
    showTitle ? 'Success' : null,
    message,
  );
}

Future<void> showSnackBar(
  BuildContext context,
  String? title,
  String? msg, {
  int duration = 2,
  TextAlign align = TextAlign.start,
}) async {
  final flushBar = Flushbar<void>(
    titleText:
        title == null
            ? null
            : Row(
              children: [
                GenText(
                  title,
                  textAlign: align,
                  size: 15,
                  color:
                      title == 'Error'
                          ? Colors.red
                          : const Color.fromRGBO(56, 130, 51, 1),
                  weight: FontWeight.w700,
                ),
                const Spacer(),
                InkWell(
                  onTap: () => context.pop(),
                  child: Container(
                    height: 20.h,
                    width: 20.w,
                    padding: pad(horizontal: 1, vertical: 1),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      color:
                          title == 'Error'
                              ? Colors.red
                              : const Color.fromRGBO(56, 130, 51, 1),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'AppAssets.ASSETS_ICONS_CLOSE_CIRCLE_SVG',
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    messageText:
        msg == null
            ? null
            : Row(
              children: [
                Expanded(
                  child: GenText(
                    msg,
                    textAlign: align,
                    height: 16.5,
                    color:
                        title == 'Error'
                            ? Colors.red
                            : const Color.fromRGBO(56, 130, 51, 1),
                    weight: title == null ? FontWeight.w700 : FontWeight.w400,
                    maxLines: 5,
                  ),
                ),
                if (title == null)
                  InkWell(
                    onTap: () {
                      context.pop();
                    },
                    child: Container(
                      height: 20.h,
                      width: 20.w,
                      padding: pad(horizontal: 1, vertical: 1),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color:
                            title == 'Error'
                                ? Colors.red
                                : const Color.fromRGBO(56, 130, 51, 1),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'AppAssets.ASSETS_ICONS_CLOSE_CIRCLE_SVG',
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
    margin: EdgeInsets.only(left: 120.w, right: 16.w),
    borderRadius: BorderRadius.circular(12),
    flushbarPosition: FlushbarPosition.TOP,
    duration: Duration(seconds: duration),
    backgroundColor:
        title == 'Error'
            ? const Color.fromARGB(255, 250, 212, 209)
            : const Color.fromRGBO(222, 241, 222, 1),
  );

  if (!flushBar.isShowing()) {
    await flushBar.show(context);
  }
}

Future<void> showLoadingDialog() async {
  final context = AppRouter.buildContext;
  await showDialog<void>(
    context: context,
    barrierColor: const Color.fromRGBO(173, 173, 173, 0.23),
    builder: (BuildContext context) {
      return const Center(child: LoadingDialogWidget());
    },
  );
}

class AnimatedColorSpinKit extends StatefulWidget {
  const AnimatedColorSpinKit({super.key});

  @override
  State<AnimatedColorSpinKit> createState() => _AnimatedColorSpinKitState();
}

class _AnimatedColorSpinKitState extends State<AnimatedColorSpinKit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    unawaited(_controller.repeat(reverse: true));

    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: context.appColors.remis.shade500,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return SpinKitThreeBounce(color: _colorAnimation.value, size: 51);
      },
    );
  }
}

class LoadingDialogWidget extends StatefulWidget {
  const LoadingDialogWidget({super.key});

  @override
  LoadingDialogState createState() => LoadingDialogState();
}

class LoadingDialogState extends State<LoadingDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return SpinKitFadingCircle(
      color: context.appColors.remis.shade600,
      size: 40,
    );
  }
}
