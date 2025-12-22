import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/general-chat-bloc/chat_bloc.dart';
import 'package:resq360/core/bloc/wallet_bloc/wallet_bloc.dart';
import 'package:resq360/core/theme/app_theme.preferences.dart';
import 'package:resq360/core/theme/cubit/theme_cubit.dart';
import 'package:resq360/core/utils/app_gen_utils.dart';
import 'package:resq360/features/customer/authentication/data/bloc/customer_auth_bloc.dart';
import 'package:resq360/features/customer/bookings/data/bloc/customer_booking_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/advertisement_bloc/customer_advertisement_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/payment_bloc/customer_payment_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/service_bloc/customer_services_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/service_provider_bloc/service_provider_bloc.dart';
import 'package:resq360/features/intro/screens/splash_screen.dart';
import 'package:resq360/features/provider/authentication/data/bloc/provider_auth_bloc.dart';
import 'package:resq360/features/provider/bookings/data/bloc/provider_service_bloc.dart';
import 'package:resq360/features/settings/data/bloc/bank_bloc/bloc/bank_bloc.dart';
import 'package:resq360/features/settings/data/bloc/ratings_bloc/ratings_bloc.dart';
import 'package:resq360/features/settings/data/bloc/update_profile_bloc.dart/profile_update_bloc.dart';
import 'package:resq360/features/settings/data/service/ratings_service.dart';

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
  final ratingsRepo = RatingsRepo.instance;

  runApp(
    TranslationProvider(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit(themePreferences)),
          BlocProvider(create: (_) => CustomerAuthBloc()),
          BlocProvider(create: (_) => ProviderAuthBloc()),
          BlocProvider(create: (_) => CustomerServicesBloc()),
          BlocProvider(create: (_) => ServiceProviderBloc()),
          BlocProvider(create: (_) => ChatBloc()),
          BlocProvider(create: (_) => ProfileUpdateBloc()),
          BlocProvider(create: (_) => ProviderServiceBloc()),
          BlocProvider(create: (_) => BankBloc()),
          BlocProvider(create: (_) => WalletBloc()),
          BlocProvider(create: (_) => CustomerBookingBloc()),
          BlocProvider(create: (_) => CustomerAdvertisementBloc()),
          BlocProvider(create: (_) => CustomerPaymentBloc()),
          BlocProvider(create: (_) => RatingsBloc(ratingsRepo)),
        ],
        child: const MyApp(),
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
