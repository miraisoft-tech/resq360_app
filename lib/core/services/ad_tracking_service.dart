import 'package:resq360/features/customer/dashboard/data/service/advertisement_repo.dart';

class AdTrackingService {
  static final _repo = AdvertisementRepo();
  static final _tracked = <int>{};

  static Future<void> trackImpressionOnce(int id) async {
    if (_tracked.contains(id)) return;
    _tracked.add(id);
    await _repo.trackAdvertisementImpression(id);
  }

  static Future<void> trackClick(int id) async {
    await _repo.trackAdvertisementClick(id);
  }
}
