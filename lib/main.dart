import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/theme/app_theme.providers.dart';
import 'package:resq360/core/utils/app_gen_utils.dart';
import 'package:resq360/features/intro/screens/splash_screen.dart';

final container = ProviderContainer();
Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  LocaleSettings.useDeviceLocale();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

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

  runApp(
    ProviderScope(
      child: UncontrolledProviderScope(
        container: container,
        child: TranslationProvider(child: const MyApp()),
      ),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });

    unawaited(AppGenUtil.offKeyboard());

    //   notificationService.initializeAppNotifications();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<void>(
      Provider<void>((ref) {
        final observer = BrightnessObserver(ref);
        WidgetsBinding.instance.addObserver(observer);
        ref.onDispose(() {
          WidgetsBinding.instance.removeObserver(observer);
        });
      }),
      (_, _) {},
    );

    final themeMode = ref.watch(themeModeProvider);
    final themeData = ref.watch(themeDataProvider);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: ScreenUtilInit(
        designSize: designSize,
        minTextAdapt: true,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeData,
          // darkTheme: themeData.darkTheme,
          themeMode: themeMode,
          locale: TranslationProvider.of(context).flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: const SplashScreen(),
          builder:
              (context, child) => Overlay(
                initialEntries: [
                  OverlayEntry(
                    builder: (context) {
                      return Builder(
                        builder:
                            (context) => MediaQuery(
                              data: MediaQuery.of(context),
                              child: child!,
                            ),
                      );
                    },
                  ),
                ],
              ),
        ),
      ),
    );
  }
}

const designSize = Size(375, 812);
