// import 'dart:async';
// import 'dart:convert';
// import 'package:app_badge_plus/app_badge_plus.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:remis_b2c/__lib.dart' show log;
// import 'package:remis_b2c/features/notifications/data/models/notifications_model.dart';
// import 'package:remis_b2c/firebase_options.dart';
// import 'package:rxdart/rxdart.dart';

// // Global instance for background message handler
// final notificationService = NotificationService();

// class NotificationService {
//   factory NotificationService() => instance;
//   NotificationService._internal();
//   static final NotificationService instance = NotificationService._internal();

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   var _messageSubject = BehaviorSubject<NotificationModel>();
//   var _backgroundMessageSubject = BehaviorSubject<NotificationModel>();

//   Stream<NotificationModel> get messageStream => _messageSubject.stream;
//   Stream<NotificationModel> get backgroundMessageStream =>
//       _backgroundMessageSubject.stream;

//   final Set<String> _processedMessageIds = {};

//   Future<void> initializeAppNotifications() async {
//     try {
//       await FirebaseMessaging.instance.requestPermission();
//       await FirebaseMessaging.instance
//           .setForegroundNotificationPresentationOptions(
//             alert: true,
//             badge: true,
//             sound: true,
//           );

//       await initializeLocalNotifications();

//       final token = await FirebaseMessaging.instance.getToken();
//       log('FCM Token: $token');

//       // Listen for token refresh events
//       FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
//         log('FCM Token refreshed: $newToken');
//       });

//       FirebaseMessaging.onBackgroundMessage(
//         _firebaseMessagingBackgroundHandler,
//       );

//       await clearNotificationBadge();
//     } on Exception catch (e, t) {
//       log('Error initializing notification: $e $t');
//     }
//   }

//   Future<void> initializeLocalNotifications() async {
//     // Initialize local notifications
//     const initializationSettingsAndroid = AndroidInitializationSettings(
//       '@mipmap/ic_launcher',
//     );
//     const initializationSettingsIOS = DarwinInitializationSettings();

//     const initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );

//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) async {
//         await handleNotificationTap(response.payload);
//       },
//     );

//     const androidChannel = AndroidNotificationChannel(
//       'high_importance_channel',
//       'High Importance Notifications',
//       description: 'This channel is used for important notifications.',
//       importance: Importance.max,
//       // sound: RawResourceAndroidNotificationSound('alert_tone'),
//     );

//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >()
//         ?.createNotificationChannel(androidChannel);

//     // Handle foreground messages
//     FirebaseMessaging.onMessage.listen((message) async {
//       await showNotification(message: message, isForeground: true);

//       // if (message.notification != null && message.data.isNotEmpty) {
//       //   if (message.notification?.android != null ||
//       //       message.notification?.apple != null) {
//       //     return;
//       //   }
//       // }
//     });

//     // Handle when app is in background
//     FirebaseMessaging.onMessageOpenedApp.listen((message) async {
//       // log('Notification opened from background: ${message.data}');
//       await clearNotificationBadge();

//       await handleNotificationTap(jsonEncode(message.data));
//     });

//     // Handle when app is opened from terminated state
//     await FirebaseMessaging.instance.getInitialMessage().then((message) async {
//       if (message != null) {
//         log('Notification opened from terminated state: ${message.data}');

//         await clearNotificationBadge();
//         await handleNotificationTap(jsonEncode(message.data));
//       }
//     });
//   }

//   Future<void> showNotification({
//     required RemoteMessage message,
//     required bool isForeground,
//   }) async {
//     NotificationModel? notificationDetail;

//     log(message.toMap());

//     if (message.notification != null) {
//       log('Message also contained a notification:');
//       log('Title: ${message.notification?.title}');
//       log('Body: ${message.notification?.body}');
//     }

//     final messageId = message.messageId;

//     if (_processedMessageIds.contains(messageId)) {
//       log('Skipping duplicate message: $messageId');
//       return;
//     }

//     // Add to processed messages set
//     if (messageId != null) {
//       _processedMessageIds.add(messageId);

//       // Limit the size of the set to prevent memory leaks
//       if (_processedMessageIds.length > 100) {
//         _processedMessageIds.remove(_processedMessageIds.first);
//       }
//     }

//     try {
//       notificationDetail = NotificationModel(
//         id:
//             message.messageId ??
//             DateTime.now().millisecondsSinceEpoch.toString(),
//         title: message.notification?.title ?? 'Notification',
//         body: message.notification?.body ?? '',
//         timestamp: DateTime.now(),
//         type: message.data['type']?.toString() ?? 'general',
//         data: message.data,
//         isForeground: isForeground,
//         imageUrl: message.data['imageUrl']?.toString(),
//         action: message.data['action']?.toString(),
//         actionData:
//             message.data['actionData'] is Map<String, dynamic>
//                 ? message.data['actionData'] as Map<String, dynamic>
//                 : null,
//       );
//     } on Exception catch (e) {
//       log('Error parsing notification: $e');
//       notificationDetail = null;
//       return;
//     }

//     if (isForeground) {
//       log('this came to foreground');
//       _messageSubject.add(notificationDetail);
//     } else {
//       log('this came to background');
//       _backgroundMessageSubject.add(notificationDetail);
//     }

//     if (message.notification == null && isForeground) {
//       await flutterLocalNotificationsPlugin.show(
//         message.notification.hashCode,
//         message.notification?.title ?? '',
//         message.notification?.body ?? '',
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'high_importance_channel',
//             'High Importance Notifications',
//             channelDescription:
//                 'This channel is used for important notifications.',
//             importance: Importance.max,
//             priority: Priority.high,
//             sound: RawResourceAndroidNotificationSound('notification_alert'),
//             // icon: '@drawable/ic_launcher',
//             //playSound: false,
//           ),
//           //   iOS: DarwinNotificationDetails(sound: 'notification_alert.caf'),
//         ),
//         payload: message.data.toString(),
//       );
//     }
//   }

//   Future<void> handleNotificationTap(String? payload) async {
//     log('Handling notification tap with payload: $payload');

//     if (payload == null || payload.isEmpty) return;
//     try {
//       // final data = jsonDecode(payload) as Map<String, dynamic>;
//       // final notification = PushNotification.fromJson(data).toNotification();
//       // await _appBloc.untilLoadedFavouriteTeams();
//       // await onTapNotificationElement(notification);
//     } on Exception catch (e, t) {
//       log('Error parsing notification payload: $e $t');
//     }
//   }

//   Future<void> clearNotificationBadge() async {
//     try {
//       await flutterLocalNotificationsPlugin.cancelAll();
//       await AppBadgePlus.updateBadge(0);

//       log('Badge cleared successfully');
//     } on Exception catch (e) {
//       log('Error clearing badge: $e');
//     }
//   }

//   void resetStreams() {
//     log('Resetting notification streams');

//     _processedMessageIds.clear();

//     _messageSubject.close();
//     _backgroundMessageSubject.close();

//     _messageSubject = BehaviorSubject<NotificationModel>();
//     _backgroundMessageSubject = BehaviorSubject<NotificationModel>();
//   }

//   void dispose() {
//     log('disposing notification service');

//     _messageSubject.close();
//     _backgroundMessageSubject.close();
//     flutterLocalNotificationsPlugin.cancelAll();
//   }
// }

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
// }
