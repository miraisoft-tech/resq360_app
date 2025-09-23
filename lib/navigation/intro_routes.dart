part of 'router.dart';

@TypedGoRoute<SplashScreenRoute>(
  path: SplashScreenRoute.path,
  name: SplashScreenRoute.name,
)
class SplashScreenRoute extends GoRouteData {
  SplashScreenRoute();

  static const String path = '/';
  static const String name = 'splash';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SplashScreen();
  }
}
