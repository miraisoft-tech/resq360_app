import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/general_auth_bloc/auth_bloc.dart';
import 'package:resq360/core/navigation/navigator.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/provider/authentication/data/bloc/provider_auth_bloc.dart';
import 'package:resq360/features/provider/dashboard/data/provider_open_pings_repo.dart';
import 'package:resq360/features/provider/dashboard/models/provider_open_ping.model.dart';
import 'package:resq360/features/provider/dashboard/screens/service_request_notification.dart';

class ProviderOpenPingListener extends StatefulWidget {
  const ProviderOpenPingListener({required this.child, super.key});

  final Widget child;

  @override
  State<ProviderOpenPingListener> createState() =>
      _ProviderOpenPingListenerState();
}

class _ProviderOpenPingListenerState extends State<ProviderOpenPingListener>
    with WidgetsBindingObserver {
  static const Duration _initialCheckDelay = Duration(seconds: 4);
  static const Duration _pollInterval = Duration(seconds: 30);

  final ProviderOpenPingsRepo _repo = ProviderOpenPingsRepo.instance;
  final Set<String> _shownPingFingerprints = <String>{};

  Timer? _pollTimer;
  bool _isChecking = false;
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(_initialCheckDelay, () {
        if (mounted) _syncPollingState();
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncPollingState();
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _stopPolling();
    }
  }

  Future<void> _syncPollingState() async {
    final shouldPoll = await _shouldPollOpenPings();
    if (!mounted) return;

    if (!shouldPoll) {
      _shownPingFingerprints.clear();
      _stopPolling();
      return;
    }

    _startPolling();
  }

  Future<bool> _shouldPollOpenPings() async {
    final token = await AuthLocalRepo.instance.getAccessToken();
    if (token == null || token.isEmpty) return false;

    final userType = await AuthLocalRepo.instance.getUserType();
    return userType == UserType.provider.value;
  }

  void _startPolling() {
    if (_pollTimer != null) return;

    unawaited(_checkOpenPings());
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      unawaited(_checkOpenPings());
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _checkOpenPings() async {
    if (_isChecking || _isDialogOpen) return;

    final shouldPoll = await _shouldPollOpenPings();
    if (!mounted || !shouldPoll) {
      _stopPolling();
      return;
    }

    _isChecking = true;
    try {
      final result = await _repo.getOpenPings();
      if (!mounted || result.data == null) return;

      if (result.data!.isEmpty) {
        _shownPingFingerprints.clear();
        return;
      }

      final ping = result.data!.firstWhere(
        (item) => !_shownPingFingerprints.contains(item.fingerprint),
        orElse: () => result.data!.first,
      );

      if (_shownPingFingerprints.contains(ping.fingerprint)) return;

      await _showOpenPingDialog(ping);
    } on Exception catch (e, s) {
      log('Provider open ping check failed: $e\n$s');
    } finally {
      _isChecking = false;
    }
  }

  Future<void> _showOpenPingDialog(ProviderOpenPing ping) async {
    final navigator = AppNavigator.navKey.currentState;
    final context = AppNavigator.navKey.currentContext;

    if (navigator == null || context == null || _isDialogOpen) return;

    _isDialogOpen = true;
    _shownPingFingerprints.add(ping.fingerprint);

    try {
      await GeneralDialogs.showCustomDialog<void>(
        context,
        body: ServiceRequestNotification(message: ping.notificationMessage),
      );
    } finally {
      _isDialogOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthLoggedOut) {
              _shownPingFingerprints.clear();
              _stopPolling();
            }
          },
        ),
        BlocListener<ProviderAuthBloc, ProviderAuthState>(
          listener: (context, state) {
            if (state is ProviderAuthLoginSuccessState ||
                state is ProviderProfileLoadedState) {
              _syncPollingState();
            }
          },
        ),
      ],
      child: widget.child,
    );
  }
}
