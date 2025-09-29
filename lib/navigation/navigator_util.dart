import 'package:flutter/cupertino.dart';

import '../../__lib.dart';

Future<dynamic> pushScreen(
  BuildContext context,
  Widget widget, {
  bool removeSession = false,
  bool fullScreenDialog = false,
}) async {
  return Navigator.push(
    context,
    CupertinoPageRoute<dynamic>(
      fullscreenDialog: fullScreenDialog,
      builder: (BuildContext c) => widget,
    ),
  );
}

Future<dynamic> replaceScreen(
  BuildContext context,
  Widget widget, {

  bool removeSession = false,
}) async {
  return Navigator.pushAndRemoveUntil<dynamic>(
    context,
    MaterialPageRoute<dynamic>(
      builder: (BuildContext context) => widget,
    ),
    (Route<dynamic> route) => false,
  );
}

Future<dynamic> pushAndReplaceScreen(
  Widget widget, {
  required BuildContext context,
  bool removeSession = false,
}) async {
  return Navigator.pushReplacement(
    context,
    MaterialPageRoute<dynamic>(
      builder: (BuildContext context) => widget,
    ),
  );
}

void clearFocus(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();
}

Future<dynamic> pop(BuildContext context, [dynamic result]) {
  Navigator.pop(context, result);
  return Future.value(result);
}

class NavigatePageRoute extends CupertinoPageRoute<Widget> {
  NavigatePageRoute(Widget page)
    : super(builder: (BuildContext context) => page) {
    _page = page;
  }

  late Widget _page;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return FadeTransition(opacity: animation, child: _page);
  }
}
