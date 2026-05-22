import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/booking_bloc/booking_bloc.dart';
import 'package:resq360/core/bloc/general_auth_bloc/auth_bloc.dart';
import 'package:resq360/core/bloc/general_auth_bloc/auth_bloc_registry.dart';
import 'package:resq360/core/bloc/kyc_bloc/kyc_bloc.dart';
import 'package:resq360/core/bloc/service_catalog_bloc/service_catalog_bloc.dart';
import 'package:resq360/core/bloc/wallet_bloc/wallet_bloc.dart';
import 'package:resq360/core/bloc/wallet_transaction_bloc/wallet_transaction_bloc.dart';
import 'package:resq360/core/navigation/navigator.dart';
import 'package:resq360/core/services/auth_session_killer.dart';
import 'package:resq360/core/theme/app_theme.preferences.dart';
import 'package:resq360/core/theme/cubit/theme_cubit.dart';
import 'package:resq360/core/utils/app_gen_utils.dart';
import 'package:resq360/features/chat/bloc/chat_list_bloc/chat_list_bloc.dart';
import 'package:resq360/features/customer/authentication/data/bloc/customer_auth_bloc.dart';
import 'package:resq360/features/customer/bookings/data/bloc/customer_booking_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/advertisement_bloc/customer_advertisement_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/notification_bloc/notification_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/payment_bloc/customer_payment_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/promotion_bloc/promotion_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/providers_bloc/provider_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/service_provider_bloc/service_provider_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/service_request_bloc.dart/service_request_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/service/service_repo.dart';
import 'package:resq360/features/intro/screens/select_account_type_screen.dart';
import 'package:resq360/features/intro/screens/splash_screen.dart';
import 'package:resq360/features/provider/authentication/data/bloc/provider_auth_bloc.dart';
import 'package:resq360/features/provider/authentication/data/service/provider_auth_remote.repo.dart';
import 'package:resq360/features/provider/bookings/data/bloc/provider_service_bloc.dart';
import 'package:resq360/features/provider/dashboard/data/bloc/provider_stats_bloc/provider_stats_bloc.dart';
import 'package:resq360/features/provider/open_pings/widgets/provider_open_ping_listener.dart';
import 'package:resq360/features/settings/data/bloc/bank_bloc/bloc/bank_bloc.dart';
import 'package:resq360/features/settings/data/bloc/gallery_bloc/gallery_bloc.dart';
import 'package:resq360/features/settings/data/bloc/notification_settings_bloc/notification_settings_bloc.dart';
import 'package:resq360/features/settings/data/bloc/phone_update_bloc/phone_update_bloc.dart';
import 'package:resq360/features/settings/data/bloc/ratings_bloc/ratings_bloc.dart';
import 'package:resq360/features/settings/data/bloc/update_profile_bloc.dart/profile_update_bloc.dart';
import 'package:resq360/features/settings/data/service/ratings_service.dart';
import 'package:resq360/firebase_options.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  late final AuthBloc globalAuthBloc;

  globalAuthBloc = AuthBloc();
  BlocRegistry.authBloc = globalAuthBloc;

  LocaleSettings.useDeviceLocale();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  if (!BuildConfig.isDev) {
    ErrorWidget.builder = (FlutterErrorDetails details) => Container();
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: SystemUiOverlay.values,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  Bloc.observer = AppBlocObserver();
  final themePreferences = ThemePreferences();
  final ratingsRepo = RatingsRepo.instance;
  final serviceRepo = ServiceRepo();

  runApp(
    TranslationProvider(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: globalAuthBloc),
          BlocProvider(create: (_) => ThemeCubit(themePreferences)),
          BlocProvider(create: (_) => CustomerAuthBloc()),
          BlocProvider(create: (_) => ProviderAuthBloc()),
          BlocProvider(create: (_) => ServiceProviderBloc()),
          BlocProvider(create: (_) => ChatListBloc()),
          BlocProvider(create: (_) => ProfileUpdateBloc()),
          BlocProvider(create: (_) => ProviderServiceBloc()),
          BlocProvider(create: (_) => BankBloc()),
          BlocProvider(create: (_) => WalletBloc()),
          BlocProvider(create: (_) => CustomerBookingBloc()),
          BlocProvider(create: (_) => CustomerAdvertisementBloc()),
          BlocProvider(create: (_) => CustomerPaymentBloc()),
          BlocProvider(create: (_) => RatingsBloc(ratingsRepo)),
          BlocProvider(create: (_) => NotificationBloc()),
          BlocProvider(create: (_) => GalleryBloc()),
          BlocProvider(create: (_) => WalletTransactionsBloc()),
          BlocProvider(create: (_) => BookingBloc(serviceRepo: serviceRepo)),
          BlocProvider(
            create: (_) => ServiceCatalogBloc(serviceRepo: serviceRepo),
          ),
          BlocProvider(
            create: (_) => ServiceCatalogBloc(serviceRepo: serviceRepo),
          ),
          BlocProvider(
            create: (_) => ServiceRequestBloc(serviceRepo: serviceRepo),
          ),
          BlocProvider(create: (_) => NotificationSettingsBloc()),
          BlocProvider(create: (_) => ProviderBloc()),
          BlocProvider(create: (_) => PhoneUpdateBloc()),
          BlocProvider(create: (_) => KycBloc()),
          BlocProvider(create: (_) => BankBloc()),
          BlocProvider(create: (_) => PromotionBloc()),
          BlocProvider(
            create:
                (_) => ProviderStatsBloc(authRepo: ProviderAuthRemoteRepo()),
          ),
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthLoggedOut) {
          AuthSessionKiller.reset();

          final navigator = AppNavigator.navKey.currentState;

          if (navigator != null) {
            await navigator.pushAndRemoveUntil(
              MaterialPageRoute<void>(
                builder: (_) => const SelectAccountTypeScreen(),
              ),
              (_) => false,
            );
          }
        }
      },
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: ScreenUtilInit(
              designSize: const Size(375, 812),
              minTextAdapt: true,
              child: MaterialApp(
                navigatorKey: AppNavigator.navKey,
                debugShowCheckedModeBanner: false,
                theme: state.themeData,
                darkTheme: ThemeData.dark(),
                themeMode: state.mode,
                locale: TranslationProvider.of(context).flutterLocale,
                supportedLocales: AppLocaleUtils.supportedLocales,
                localizationsDelegates: GlobalMaterialLocalizations.delegates,
                home: const SplashScreen(),
                builder:
                    (context, child) => ProviderOpenPingListener(
                      child: Overlay(
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
            ),
          );
        },
      ),
    );
  }
}
