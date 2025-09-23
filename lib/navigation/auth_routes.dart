part of 'router.dart';

// @TypedGoRoute<SignUpRoute>(path: SignUpRoute.path, name: SignUpRoute.name)
// class SignUpRoute extends GoRouteData {
//   SignUpRoute();

//   static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavKey;
//   static const String path = '/signup';
//   static const String name = 'signupScreen';

//   @override
//   Widget build(BuildContext context, GoRouterState state) {
//     return const SignupScreen();
//   }
// }

// @TypedGoRoute<LoginRoute>(path: LoginRoute.path, name: LoginRoute.name)
// class LoginRoute extends GoRouteData {
//   LoginRoute({this.from});

//   static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavKey;
//   static const String path = '/login';
//   static const String name = 'loginScreen';

//   final String? from;

//   @override
//   Widget build(BuildContext context, GoRouterState state) {
//     return const LoginScreen();
//   }
// }

// @TypedGoRoute<ConfirmEmailRoute>(
//   path: ConfirmEmailRoute.path,
//   name: ConfirmEmailRoute.name,
// )
// class ConfirmEmailRoute extends GoRouteData {
//   ConfirmEmailRoute({this.email, this.code});

//   static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavKey;
//   static const String path = '/confirm-email';
//   static const String name = 'confirmEmailScreen';

//   final String? email;
//   final String? code;

//   @override
//   Widget build(BuildContext context, GoRouterState state) {
//     return ConfirmEmailScreen(email: email, code: code);
//   }
// }

// @TypedGoRoute<CompleteDetailsRoute>(
//   path: CompleteDetailsRoute.path,
//   name: CompleteDetailsRoute.name,
// )
// class CompleteDetailsRoute extends GoRouteData {
//   CompleteDetailsRoute();

//   static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavKey;
//   static const String path = '/complete-details';
//   static const String name = 'completeDetailsScreen';

//   @override
//   Widget build(BuildContext context, GoRouterState state) {
//     return const CompleteDetailsScreen();
//   }
// }

// @TypedGoRoute<SetupPinRoute>(path: SetupPinRoute.path, name: SetupPinRoute.name)
// class SetupPinRoute extends GoRouteData {
//   SetupPinRoute();

//   static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavKey;
//   static const String path = '/setup-pin';
//   static const String name = 'setupPinScreen';

//   @override
//   Widget build(BuildContext context, GoRouterState state) {
//     return const SetupPinScreen();
//   }
// }

// // password

// @TypedGoRoute<ForgotPasswordRoute>(
//   path: ForgotPasswordRoute.path,
//   name: ForgotPasswordRoute.name,
// )
// class ForgotPasswordRoute extends GoRouteData {
//   ForgotPasswordRoute();

//   static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavKey;
//   static const String path = '/forgot-password';
//   static const String name = 'forgotPasswordScreen';

//   @override
//   Widget build(BuildContext context, GoRouterState state) {
//     return const ForgotPasswordScreen();
//   }
// }

// @TypedGoRoute<ForgotPasswordOTPRoute>(
//   path: ForgotPasswordOTPRoute.path,
//   name: ForgotPasswordOTPRoute.name,
// )
// class ForgotPasswordOTPRoute extends GoRouteData {
//   ForgotPasswordOTPRoute({required this.email});

//   static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavKey;
//   static const String path = '/forgot-password-otp';
//   static const String name = 'forgotPasswordOTPScreen';

//   final String email;

//   @override
//   Widget build(BuildContext context, GoRouterState state) {
//     return ForgotPasswordOTPScreen(email: email);
//   }
// }

// @TypedGoRoute<ForgotPasswordResetRoute>(
//   path: ForgotPasswordResetRoute.path,
//   name: ForgotPasswordResetRoute.name,
// )
// class ForgotPasswordResetRoute extends GoRouteData {
//   ForgotPasswordResetRoute({required this.email, required this.otp});

//   static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavKey;
//   static const String path = '/forgot-password-reset';
//   static const String name = 'forgotPasswordResetScreen';

//   final String email;
//   final String otp;

//   @override
//   Widget build(BuildContext context, GoRouterState state) {
//     return ForgotPasswordResetScreen(email: email, otp: otp);
//   }
// }
