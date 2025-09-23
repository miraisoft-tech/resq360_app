// // ignore_for_file: document_ignores, use_build_context_synchronously

// import 'dart:async';
// import 'dart:io';

// import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// import 'package:geolocator/geolocator.dart' as geo;
// import 'package:remis_b2c/__lib.dart';
// import 'package:remis_b2c/features/authentication/data/service/auth.local.repo.dart';
// import 'package:remis_b2c/features/dashboard/widgets/location_permission_dialog.dart';

// abstract class BaseViewModel extends ChangeNotifier {
//   BaseViewModel() {
//     onInit();
//   }

//   @protected
//   void onInit() {}
// }

// mixin LocationMixin on BaseViewModel {
//   geo.Position? currentPosition;

//   @override
//   void onInit() {
//     super.onInit();
//     _initLocation();
//   }

//   Future<void> _initLocation() async {
//     final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();

//     if (!serviceEnabled) {
//       await geo.Geolocator.openLocationSettings();
//       return;
//     }

//     var permission = await geo.Geolocator.checkPermission();
//     if (permission == geo.LocationPermission.denied) {
//       permission = await geo.Geolocator.requestPermission();
//     }
//     if (permission == geo.LocationPermission.deniedForever) {
//       return;
//     }

//     final hasRequested =
//         await AuthLocalRepo.instance.getBackgroundLocationRequested();

//     if (permission == geo.LocationPermission.whileInUse && !hasRequested) {
//       if (Platform.isAndroid) {
//         await GeneralDialogs.showCustomDialog(
//           AppRouter.buildContext,
//           body: LocationPermissionDialog(
//             onTap: ({required bool response}) async {
//               if (response) {
//                 permission = await geo.Geolocator.requestPermission();
//                 await _requestPermissions();
//               }

//               await AuthLocalRepo.instance.saveBackgroundLocationRequested(
//                 requested: true,
//               );
//             },
//           ),
//         );
//       } else {
//         permission = await geo.Geolocator.requestPermission();
//         await _requestPermissions();

//         await AuthLocalRepo.instance.saveBackgroundLocationRequested(
//           requested: true,
//         );
//       }
//     }

//     if (permission != geo.LocationPermission.always &&
//         permission != geo.LocationPermission.whileInUse) {
//       return;
//     }

//     const settings = geo.LocationSettings(
//       accuracy: geo.LocationAccuracy.high,
//       distanceFilter: 100,
//     );

//     currentPosition = await geo.Geolocator.getCurrentPosition(
//       locationSettings: settings,
//     );
//     log('Location fetched successfully!');

//     notifyListeners();
//     onLocationUpdated();
//   }

//   Future<void> _requestPermissions() async {
//     // Request notification permission
//     final notificationPermission =
//         await FlutterForegroundTask.checkNotificationPermission();
//     if (notificationPermission != NotificationPermission.granted) {
//       await FlutterForegroundTask.requestNotificationPermission();
//     }
//     final context = AppRouter.buildContext;

//     // Android specific permissions
//     if (Theme.of(context).platform == TargetPlatform.android) {
//       if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
//         await FlutterForegroundTask.requestIgnoreBatteryOptimization();
//       }
//     }
//   }

//   /// Override to react when location is ready.
//   @protected
//   void onLocationUpdated() {}
// }
