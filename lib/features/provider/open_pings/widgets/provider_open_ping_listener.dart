import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/general_auth_bloc/auth_bloc.dart';
import 'package:resq360/core/navigation/navigator.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/chat/data/models/chat_models.dart';
import 'package:resq360/features/chat/data/services/chat_repo.dart';
import 'package:resq360/features/chat/screens/chat_details_screen.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/provider/authentication/data/bloc/provider_auth_bloc.dart';
import 'package:resq360/features/provider/open_pings/data/provider_open_ping_seen_store.dart';
import 'package:resq360/features/provider/open_pings/data/provider_open_pings_repo.dart';
import 'package:resq360/features/provider/open_pings/models/provider_open_ping.model.dart';
import 'package:resq360/features/provider/open_pings/widgets/service_request_notification.dart';

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
  static const String _contactCustomerMessage =
      'Hello, I am available for booking.';

  final ProviderOpenPingsRepo _repo = ProviderOpenPingsRepo.instance;
  final ProviderOpenPingSeenStore _seenStore =
      ProviderOpenPingSeenStore.instance;
  final ChatRepo _chatRepo = ChatRepo();
  final Set<String> _seenPingBatchIds = <String>{};

  late ProviderOpenPingsResponse _latestResponse;
  Timer? _pollTimer;
  bool _isChecking = false;
  bool _isDialogOpen = false;
  bool _hasLoadedSeenPingBatchIds = false;

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
      _seenPingBatchIds.clear();
      _hasLoadedSeenPingBatchIds = false;
      _stopPolling();
      return;
    }

    await _loadSeenPingBatchIds();
    if (!mounted) return;

    _startPolling();
  }

  Future<void> _loadSeenPingBatchIds() async {
    if (_hasLoadedSeenPingBatchIds) return;

    final seenBatchIds = await _seenStore.getSeenBatchIds();
    if (!mounted) return;

    _seenPingBatchIds.addAll(seenBatchIds);
    _hasLoadedSeenPingBatchIds = true;
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

    await _loadSeenPingBatchIds();
    if (!mounted) return;

    _isChecking = true;
    try {
      final result = await _repo.getOpenPings();
      final response = result.data;
      if (!mounted || response == null) return;

      _latestResponse = response;
      final openPings = _latestResponse.data;

      if (openPings.isEmpty) return;

      ProviderOpenPing? ping;
      for (final item in openPings) {
        if (!_seenPingBatchIds.contains(item.seenKey)) {
          ping = item;
          break;
        }
      }

      if (ping == null) return;

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

    try {
      await _markPingSeen(ping);
      if (!mounted) return;

      await GeneralDialogs.showCustomDialog<void>(
        context,
        body: ServiceRequestNotification(
          message: ping.notificationMessage,
          onContactCustomer:
              ping.canContactCustomer
                  ? () => _contactCustomerFromPing(ping)
                  : null,
        ),
      );
    } finally {
      _isDialogOpen = false;
    }
  }

  Future<void> _contactCustomerFromPing(ProviderOpenPing ping) async {
    final context = AppNavigator.navKey.currentContext;
    if (context == null) return;

    try {
      final chatId = await _findOrCreateChat(ping);
      if (chatId == null) {
        await showErrorSnackbar(context, 'Unable to contact customer');
        return;
      }

      if (!mounted) return;

      final currentContext = AppNavigator.navKey.currentContext;
      if (currentContext == null) return;

      await Navigator.of(currentContext, rootNavigator: true).maybePop();
      await Future<void>.delayed(Duration.zero);

      final navigationContext = AppNavigator.navKey.currentContext;
      if (navigationContext == null) return;

      await pushScreen(
        navigationContext,
        ChatDetailScreen(
          chatId: chatId,
          userType: UserType.provider,
          providerServiceId: ping.providerServiceId,
          initialMessage: _contactCustomerMessage,
        ),
      );
    } on Exception catch (e, s) {
      log('Contact customer from ping failed: $e\n$s');
      if (!mounted) return;

      final currentContext = AppNavigator.navKey.currentContext;
      if (currentContext != null) {
        await showErrorSnackbar(currentContext, 'Unable to contact customer');
      }
    }
  }

  Future<void> _markPingSeen(ProviderOpenPing ping) async {
    final seenKey = ping.seenKey;
    if (_seenPingBatchIds.contains(seenKey)) return;

    _seenPingBatchIds.add(seenKey);
    final saved = await _seenStore.markBatchIdSeen(seenKey);
    if (!saved) {
      log('Failed to persist seen open ping batch id: $seenKey');
    }
  }

  Future<int?> _findOrCreateChat(ProviderOpenPing ping) async {
    final existingChatId = ping.chatId;
    if (existingChatId != null) return existingChatId;

    final serviceRequestId = ping.serviceRequestId;
    if (serviceRequestId != null) {
      final existingChat = await _chatRepo.getChatByserviceRequestId(
        serviceRequestId,
      );
      final chatId = existingChat.data?.id;
      if (chatId != null) return chatId;
    }

    final customerId = ping.customerId;
    if (customerId == null) return null;

    final providerId = await AuthLocalRepo.instance.getProviderId();
    if (providerId == null) return null;

    final result = await _chatRepo.createChat(
      chatRequest: CreateChatRequest(
        title: _chatTitleForPing(ping),
        type: 'PRIVATE',
        participants: [
          ChatParticipant(participantType: 'USER', participantId: customerId),
          ChatParticipant(
            participantType: 'PROVIDER',
            participantId: providerId,
          ),
        ],
      ),
    );

    return result.data?.id;
  }

  String _chatTitleForPing(ProviderOpenPing ping) {
    final customerName = ping.customerName?.trim();
    if (customerName != null && customerName.isNotEmpty) {
      return 'Service request with $customerName';
    }

    return 'Service request';
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthLoggedOut) {
              _seenPingBatchIds.clear();
              _hasLoadedSeenPingBatchIds = false;
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
