import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

FutureOr<String?> _redirect(BuildContext context, GoRouterState state) async {
  return null;
}

mixin AuthGuardMixin on GoRouteData {
  @override
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) async {
    return _redirect(context, state) ?? super.redirect(context, state);
  }
}

mixin ShellAuthGuardMixin on StatefulShellRouteData {
  @override
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) async {
    return _redirect(context, state) ?? super.redirect(context, state);
  }
}
