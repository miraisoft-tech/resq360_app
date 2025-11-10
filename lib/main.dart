import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/general-chat-bloc/chat_bloc.dart';
import 'package:resq360/core/theme/app_theme.preferences.dart';
import 'package:resq360/core/theme/cubit/theme_cubit.dart';
import 'package:resq360/core/utils/app_gen_utils.dart';
import 'package:resq360/features/customer/authentication/data/bloc/customer_auth_bloc.dart';
import 'package:resq360/features/customer/bookings/data/bloc/provider_service_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/service_bloc/customer_services_bloc.dart';
import 'package:resq360/features/intro/screens/splash_screen.dart';
import 'package:resq360/features/provider/authentication/data/bloc/provider_auth_bloc.dart';
import 'package:resq360/features/settings/data/bloc/profile_update_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LocaleSettings.useDeviceLocale();
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);

  if (!BuildConfig.isDev) {
    ErrorWidget.builder = (FlutterErrorDetails details) => Container();
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  Bloc.observer = AppBlocObserver();
  final themePreferences = ThemePreferences();

  runApp(
    ProviderScope(
      child: TranslationProvider(
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ThemeCubit(themePreferences)),
            BlocProvider(create: (_) => CustomerAuthBloc()),
            BlocProvider(create: (_) => ProviderAuthBloc()),
            BlocProvider(create: (_) => CustomerServicesBloc()),
            BlocProvider(create: (_) => ChatBloc()),
            BlocProvider(create: (_) => ProfileUpdateBloc()),
            BlocProvider(create: (_) => ProviderServiceBloc()),
          ],
          child: const MyApp(),
        ),
      ),
    ),
  );
}

class AppBlocObserver extends BlocObserver {
  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    log(transition.toString());
    super.onTransition(bloc, transition);
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('$error\n$stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
    unawaited(AppGenUtil.offKeyboard());
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    final cubit = context.read<ThemeCubit>();
    if (cubit.state.mode == ThemeMode.system) {
      unawaited(cubit.loadTheme());
    }
    super.didChangePlatformBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: state.themeData,
              darkTheme: ThemeData.dark(),
              themeMode: state.mode,
              locale: TranslationProvider.of(context).flutterLocale,
              supportedLocales: AppLocaleUtils.supportedLocales,
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              home: const SplashScreen(),
              builder:
                  (context, child) => Overlay(
                    initialEntries: [
                      OverlayEntry(
                        builder:
                            (context) => MediaQuery(
                              data: MediaQuery.of(context),
                              child: child!,
                            ),
                      ),
                    ],
                  ),
            ),
          ),
        );
      },
    );
  }
}

// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// const String WS_URL =
//     'https://resq360-kspk.onrender.com'; // e.g., https://api.example.com
// const String NAMESPACE = '/chat'; // e.g., '/chat' or '' if none
// const String BEARER_TOKEN =
//     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjcsImVtYWlsIjoibWlrZS50b3dpbmdAZXhhbXBsZS5jb20iLCJ0eXBlIjoicHJvdmlkZXIiLCJpYXQiOjE3NjI3ODg1NjEsImV4cCI6MTc2Mjg3NDk2MX0.i-gN8xHrAoveq_FsgtZ5iFVmY2aZLolh2ULnWjc006E'; // your valid JWT
// const int SAMPLE_CHAT_ID = 1; // a real chatId on your backend

// void main() {
//   runApp(const ChatSmokeApp());
// }

// class ChatSmokeApp extends StatelessWidget {
//   const ChatSmokeApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Socket Smoke',
//       theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
//       home: const ChatSmokeHome(),
//     );
//   }
// }

// class ChatSmokeHome extends StatefulWidget {
//   const ChatSmokeHome({super.key});

//   @override
//   State<ChatSmokeHome> createState() => _ChatSmokeHomeState();
// }

// class _ChatSmokeHomeState extends State<ChatSmokeHome> {
//   IO.Socket? _socket;
//   bool _connected = false;
//   String? _socketId;
//   bool _joining = false;

//   final List<String> _logs = <String>[];
//   final _scrollCtrl = ScrollController();

//   final _chatIdCtrl = TextEditingController(text: SAMPLE_CHAT_ID.toString());
//   final _messageCtrl = TextEditingController(text: 'Hello from Flutter');

//   StreamSubscription? _autoScrollSub;

//   @override
//   void initState() {
//     super.initState();
//     _autoScrollSub = Stream.periodic(const Duration(milliseconds: 300)).listen((
//       _,
//     ) {
//       if (!_scrollCtrl.hasClients) return;
//       _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
//     });
//   }

//   @override
//   void dispose() {
//     _autoScrollSub?.cancel();
//     _disconnect();
//     _scrollCtrl.dispose();
//     _chatIdCtrl.dispose();
//     _messageCtrl.dispose();
//     super.dispose();
//   }

//   void _log(Object msg) {
//     setState(() {
//       _logs.add('[${DateTime.now().toIso8601String()}] $msg');
//     });
//   }

//   Future<void> _connect() async {
//     if (_socket?.connected == true) {
//       _log('Already connected');
//       return;
//     }
//     if (BEARER_TOKEN.isEmpty) {
//       _log('Token missing. Set BEARER_TOKEN');
//       return;
//     }

//     _log('Connecting to $WS_URL$NAMESPACE');

//     _socket = IO.io(
//       '$WS_URL$NAMESPACE',
//       IO.OptionBuilder()
//           .setTransports(['websocket', 'polling'])
//           .enableAutoConnect()
//           .enableReconnection()
//           .setReconnectionAttempts(5)
//           .setReconnectionDelay(1000)
//           .setReconnectionDelayMax(5000)
//           .setAuth({'token': BEARER_TOKEN})
//           .build(),
//     );

//     _setupListeners();
//     _socket?.connect();
//   }

//   void _setupListeners() {
//     _socket?.onConnect((_) {
//       _connected = true;
//       _socketId = _socket?.id;
//       setState(() {});
//       _log('Connected, socketId=$_socketId');
//     });

//     _socket?.onDisconnect((_) {
//       _connected = false;
//       _socketId = null;
//       setState(() {});
//       _log('Disconnected');
//     });

//     _socket?.onConnectError((err) {
//       _connected = false;
//       setState(() {});
//       _log('Connect error: $err');
//     });

//     _socket?.onError((err) {
//       _log('Socket error: $err');
//     });

//     // Common server-side events; adjust to your server’s contract
//     _socket?.on('connected', (data) => _log('Server says connected: $data'));
//     _socket?.on(
//       'chat-notification',
//       (data) => _log('chat-notification: ${_fmt(data)}'),
//     );
//     _socket?.on('message', (data) => _log('message: ${_fmt(data)}'));
//     _socket?.on('typing', (data) => _log('typing: ${_fmt(data)}'));
//     _socket?.on('message-read', (data) => _log('message-read: ${_fmt(data)}'));
//   }

//   Future<void> _disconnect() async {
//     try {
//       _socket?.disconnect();
//       _socket?.dispose();
//     } catch (_) {}
//     _socket = null;
//     setState(() {
//       _connected = false;
//       _socketId = null;
//     });
//     _log('Disposed socket');
//   }

//   Future<void> _joinChat() async {
//     if (!(_socket?.connected ?? false)) {
//       _log('Join aborted: not connected');
//       return;
//     }
//     final id = int.tryParse(_chatIdCtrl.text.trim());
//     if (id == null) {
//       _log('Invalid chatId');
//       return;
//     }
//     setState(() => _joining = true);

//     final c = Completer<void>();
//     _socket?.emitWithAck(
//       'join-chat',
//       {'chatId': id},
//       ack: (resp) {
//         _log('join-chat ack: ${_fmt(resp)}');
//         c.complete();
//       },
//     );
//     await c.future;
//     setState(() => _joining = false);
//   }

//   Future<void> _leaveChat() async {
//     if (!(_socket?.connected ?? false)) {
//       _log('Leave aborted: not connected');
//       return;
//     }
//     final id = int.tryParse(_chatIdCtrl.text.trim());
//     if (id == null) {
//       _log('Invalid chatId');
//       return;
//     }
//     final c = Completer<void>();
//     _socket?.emitWithAck(
//       'leave-chat',
//       {'chatId': id},
//       ack: (resp) {
//         _log('leave-chat ack: ${_fmt(resp)}');
//         c.complete();
//       },
//     );
//     await c.future;
//   }

//   Future<void> _sendText() async {
//     if (!(_socket?.connected ?? false)) {
//       _log('Send aborted: not connected');
//       return;
//     }
//     final id = int.tryParse(_chatIdCtrl.text.trim());
//     if (id == null) {
//       _log('Invalid chatId');
//       return;
//     }
//     final text = _messageCtrl.text.trim();
//     if (text.isEmpty) {
//       _log('Empty message');
//       return;
//     }
//     final payload = {
//       'chatId': id,
//       'messageType': 'TEXT',
//       'content': text,
//     };
//     final c = Completer<void>();
//     _socket?.emitWithAck(
//       'send-message',
//       payload,
//       ack: (resp) {
//         _log('send-message ack: ${_fmt(resp)}');
//         c.complete();
//       },
//     );
//     await c.future;
//   }

//   void _typing(bool isTyping) {
//     if (!(_socket?.connected ?? false)) {
//       _log('Typing aborted: not connected');
//       return;
//     }
//     final id = int.tryParse(_chatIdCtrl.text.trim());
//     if (id == null) {
//       _log('Invalid chatId');
//       return;
//     }
//     _socket?.emit('typing', {'chatId': id, 'isTyping': isTyping});
//     _log('typing emitted: chatId=$id isTyping=$isTyping');
//   }

//   static String _fmt(dynamic data) {
//     try {
//       if (data is String) return data;
//       return const JsonEncoder.withIndent('  ').convert(data);
//     } catch (_) {
//       return data.toString();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final statusColor = _connected ? Colors.green : Colors.red;
//     final statusText = _connected ? 'Online' : 'Offline';

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Socket.IO Smoke Test'),
//         actions: [
//           Container(
//             margin: const EdgeInsets.all(8),
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: statusColor,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: [
//                 const Icon(Icons.circle, size: 8, color: Colors.white),
//                 const SizedBox(width: 6),
//                 Text(
//                   statusText,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           _TopControls(
//             connected: _connected,
//             socketId: _socketId,
//             onConnect: _connect,
//             onDisconnect: _disconnect,
//           ),
//           const Divider(height: 1),
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               children: [
//                 Flexible(
//                   child: TextField(
//                     controller: _chatIdCtrl,
//                     decoration: const InputDecoration(
//                       labelText: 'chatId',
//                       border: OutlineInputBorder(),
//                       isDense: true,
//                     ),
//                     keyboardType: TextInputType.number,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 FilledButton(
//                   onPressed: _joining ? null : _joinChat,
//                   child:
//                       _joining
//                           ? const SizedBox(
//                             height: 16,
//                             width: 16,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                           : const Text('Join'),
//                 ),
//                 const SizedBox(width: 8),
//                 OutlinedButton(
//                   onPressed: _leaveChat,
//                   child: const Text('Leave'),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageCtrl,
//                     decoration: const InputDecoration(
//                       labelText: 'Message',
//                       border: OutlineInputBorder(),
//                       isDense: true,
//                     ),
//                     onChanged: (v) => _typing(true),
//                     onEditingComplete: () => _typing(false),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 FilledButton(onPressed: _sendText, child: const Text('Send')),
//               ],
//             ),
//           ),
//           const Divider(height: 1),
//           Expanded(
//             child: ListView.builder(
//               controller: _scrollCtrl,
//               padding: const EdgeInsets.all(12),
//               itemCount: _logs.length,
//               itemBuilder:
//                   (_, i) => Text(
//                     _logs[i],
//                     style: const TextStyle(
//                       fontFamily: 'monospace',
//                       fontSize: 12,
//                     ),
//                   ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _TopControls extends StatelessWidget {
//   final bool connected;
//   final String? socketId;
//   final VoidCallback onConnect;
//   final VoidCallback onDisconnect;

//   const _TopControls({
//     required this.connected,
//     required this.socketId,
//     required this.onConnect,
//     required this.onDisconnect,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(12),
//       child: Row(
//         children: [
//           Expanded(
//             child: Text(
//               connected ? 'Socket ID: $socketId' : 'Not connected',
//               style: TextStyle(
//                 color: connected ? Colors.green[800] : Colors.red[800],
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           if (!connected)
//             FilledButton(onPressed: onConnect, child: const Text('Connect'))
//           else
//             OutlinedButton(
//               onPressed: onDisconnect,
//               child: const Text('Disconnect'),
//             ),
//         ],
//       ),
//     );
//   }
// }
