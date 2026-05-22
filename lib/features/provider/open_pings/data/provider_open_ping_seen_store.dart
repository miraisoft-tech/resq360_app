import 'package:resq360/core/services/db_keys.local.repo.dart';
import 'package:resq360/core/services/shared_preferences.dart';
import 'package:resq360/core/utils/build_config.dart';

class ProviderOpenPingSeenStore {
  factory ProviderOpenPingSeenStore() => instance;

  ProviderOpenPingSeenStore._internal();
  static final ProviderOpenPingSeenStore instance =
      ProviderOpenPingSeenStore._internal();

  static const String _batchIdsKey = 'batchIds';

  final AppLocalPref _pref = AppLocalPref.instance;

  Future<Set<String>> getSeenBatchIds() async {
    try {
      final storedValue = await _pref.getValue(
        key: DBKeys.providerOpenPingSeenBatchIds,
      );

      if (storedValue is Map<String, dynamic>) {
        return _normalizeBatchIds(storedValue[_batchIdsKey]);
      }

      return _normalizeBatchIds(storedValue);
    } on Exception catch (e) {
      log('Read seen open ping batch ids failed: $e');
      return <String>{};
    }
  }

  Future<bool> markBatchIdSeen(String batchId) async {
    final normalizedBatchId = batchId.trim();
    if (normalizedBatchId.isEmpty) return false;

    final batchIds = await getSeenBatchIds();
    if (!batchIds.add(normalizedBatchId)) return true;

    return _saveSeenBatchIds(batchIds);
  }

  Future<bool> _saveSeenBatchIds(Set<String> batchIds) async {
    try {
      final normalizedBatchIds = batchIds
          .map((batchId) => batchId.trim())
          .where((batchId) => batchId.isNotEmpty)
          .toList(growable: false);

      return await _pref.saveMap(
        key: DBKeys.providerOpenPingSeenBatchIds,
        value: {_batchIdsKey: normalizedBatchIds},
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
}
