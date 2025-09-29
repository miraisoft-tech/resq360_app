import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resq360/core/utils/build_config.dart';
import 'package:resq360/features/intro/screens/splash_screen.dart';

part 'auth_routes.dart';
part 'intro_routes.dart';
part 'router.g.dart';

final rootNavKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final GlobalKey<NavigatorState> dashboardShellNavigatorKey =
    GlobalKey<NavigatorState>();

class AppRouter {
  AppRouter._();

  static BuildContext get buildContext =>
      goRouter.routerDelegate.navigatorKey.currentContext!;

  static final goRouter = GoRouter(
    initialLocation: SplashScreenRoute.path,
    //  observers: [routeObserver],
    navigatorKey: rootNavKey,
    debugLogDiagnostics: BuildConfig.isDev,
    errorBuilder: (context, state) => const ErrorScreen(),
    routes: $appRoutes,
  );
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/'),
          child: const Text('Go to home page'),
        ),
      ),
    );
  }
}
