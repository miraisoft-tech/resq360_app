import 'package:resq360/core/services/db_keys.local.repo.dart';
import 'package:resq360/core/services/shared_preferences.dart';
import 'package:resq360/core/utils/build_config.dart';

class ProviderOpenPingSeenStore {
  factory ProviderOpenPingSeenStore() => instance;

  ProviderOpenPingSeenStore._internal();
  static final ProviderOpenPingSeenStore instance =
      ProviderOpenPingSeenStore._internal();

  static const Duration _seenBatchIdsRetention = Duration(hours: 24);
  static const String _batchIdsKey = 'batchIds';
  static const String _savedAtKey = 'savedAt';

  final AppLocalPref _pref = AppLocalPref.instance;

  Future<Set<String>> getSeenBatchIds() async {
    try {
      final state = await _getActiveState();
      return state.batchIds;
    } on Exception catch (e) {
      log('Read seen open ping batch ids failed: $e');
      return <String>{};
    }
  }

  Future<bool> markBatchIdSeen(String batchId) async {
    final normalizedBatchId = batchId.trim();
    if (normalizedBatchId.isEmpty) return false;

    try {
      final state = await _getActiveState();
      final batchIds = state.batchIds.toSet();
      if (!batchIds.add(normalizedBatchId)) return true;

      return _saveSeenBatchIds(
        batchIds,
        savedAt: state.savedAt ?? DateTime.now().toUtc(),
      );
    } on Exception catch (e) {
      log('Mark seen open ping batch id failed: $e');
      return false;
    }
  }

  Future<bool> clearSeenBatchIds() async {
    try {
      return await _pref.deleteKey(key: DBKeys.providerOpenPingSeenBatchIds);
    } on Exception catch (e) {
      log('Clear seen open ping batch ids failed: $e');
      return false;
    }
  }

  Future<_SeenBatchIdsState> _getActiveState() async {
    final state = await _readSeenBatchIdsState();
    final now = DateTime.now().toUtc();

    if (state.isExpired(now, _seenBatchIdsRetention)) {
      await clearSeenBatchIds();
      return const _SeenBatchIdsState(batchIds: <String>{});
    }

    if (state.needsMigration && state.batchIds.isNotEmpty) {
      final savedAt = state.savedAt ?? now;
      await _saveSeenBatchIds(state.batchIds, savedAt: savedAt);
      return _SeenBatchIdsState(batchIds: state.batchIds, savedAt: savedAt);
    }

    return state;
  }

  Future<_SeenBatchIdsState> _readSeenBatchIdsState() async {
    final storedValue = await _pref.getValue(
      key: DBKeys.providerOpenPingSeenBatchIds,
    );

    if (storedValue is Map<String, dynamic>) {
      return _SeenBatchIdsState(
        batchIds: _normalizeBatchIds(storedValue[_batchIdsKey]),
        savedAt: _parseDateTime(storedValue[_savedAtKey]),
        needsMigration: !storedValue.containsKey(_savedAtKey),
      );
    }

    return _SeenBatchIdsState(
      batchIds: _normalizeBatchIds(storedValue),
      needsMigration: storedValue != null,
    );
  }

  Future<bool> _saveSeenBatchIds(
    Set<String> batchIds, {
    required DateTime savedAt,
  }) async {
    try {
      final normalizedBatchIds = batchIds
          .map((batchId) => batchId.trim())
          .where((batchId) => batchId.isNotEmpty)
          .toList(growable: false);

      if (normalizedBatchIds.isEmpty) return clearSeenBatchIds();

      return await _pref.saveMap(
        key: DBKeys.providerOpenPingSeenBatchIds,
        value: {
          _batchIdsKey: normalizedBatchIds,
          _savedAtKey: savedAt.toUtc().toIso8601String(),
        },
      );
    } on Exception catch (e) {
      log('Save seen open ping batch ids failed: $e');
      return false;
    }
  }

  Set<String> _normalizeBatchIds(Object? value) {
    if (value is! List) return <String>{};

    return value
        .map((batchId) => batchId.toString().trim())
        .where((batchId) => batchId.isNotEmpty && batchId != 'null')
        .toSet();
  }

  DateTime? _parseDateTime(Object? value) {
    if (value is DateTime) return value.toUtc();

    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'null') return null;

    return DateTime.tryParse(text)?.toUtc();
  }
}

class _SeenBatchIdsState {
  const _SeenBatchIdsState({
    required this.batchIds,
    this.savedAt,
    this.needsMigration = false,
  });

  final Set<String> batchIds;
  final DateTime? savedAt;
  final bool needsMigration;

  bool isExpired(DateTime now, Duration retention) {
    final savedAt = this.savedAt;
    if (savedAt == null || batchIds.isEmpty) return false;

    return now.difference(savedAt.toUtc()) >= retention;
  }
}
