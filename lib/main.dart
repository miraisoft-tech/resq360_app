import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/theme/app_theme.providers.dart';
import 'package:resq360/core/utils/app_gen_utils.dart';
import 'package:resq360/features/customer/authentication/data/bloc/customer_auth_bloc.dart';
import 'package:resq360/features/customer/chat/data/bloc/customer_chat_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/service_bloc/customer_services_bloc.dart';
import 'package:resq360/features/intro/screens/splash_screen.dart';
import 'package:resq360/features/provider/authentication/data/bloc/provider_auth_bloc.dart';

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

  runApp(
    ProviderScope(
      child: TranslationProvider(
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => CustomerAuthBloc(),
            ),
            BlocProvider(
              create: (context) => ProviderAuthBloc(),
            ),
            BlocProvider(
              create: (context) => CustomerServicesBloc(),
            ),
            BlocProvider(
              create: (context) => CustomerChatBloc(),
            ),
          ],
          child: const MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
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

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });

    unawaited(AppGenUtil.offKeyboard());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<void>(
      Provider<void>((ref) {
        final observer = BrightnessObserver(ref);
        WidgetsBinding.instance.addObserver(observer);
        ref.onDispose(() => WidgetsBinding.instance.removeObserver(observer));
      }),
      (_, _) {},
    );

    final themeMode = ref.watch(themeModeProvider);
    final themeData = ref.watch(themeDataProvider);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeData,
          themeMode: themeMode,
          locale: TranslationProvider.of(context).flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: const SplashScreen(),
          builder:
              (context, child) => Overlay(
                initialEntries: [
                  OverlayEntry(
                    builder:
                        (context) => Builder(
                          builder:
                              (context) => MediaQuery(
                                data: MediaQuery.of(context),
                                child: child!,
                              ),
                        ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}
