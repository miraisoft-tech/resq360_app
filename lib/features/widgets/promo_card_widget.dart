import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/ad_tracking_service.dart';
import 'package:resq360/core/utils/app_gen_utils.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/advertisement_bloc/customer_advertisement_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/models/advertisment/advertisement.model.dart';
import 'package:resq360/features/widgets/images.widgets.dart';

class PromoCardWidget extends StatefulWidget {
  const PromoCardWidget({
    super.key,
  });

  @override
  State<PromoCardWidget> createState() => _PromoCardWidgetState();
}

class _PromoCardWidgetState extends State<PromoCardWidget> {
  late Timer _timer;
  late PageController _pageController;
  int _currentPage = 0;
  List<Advertisement> _promoAds = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      unawaited(_trackCurrentImpression());

      _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) async {
        if (!_pageController.hasClients) return;
        if (!mounted) return;

        if (_promoAds.isEmpty) return;

        final adsLength = _promoAds.length;
        if (_currentPage < adsLength - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        await _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });

      unawaited(_trackCurrentImpression());
    });
  }

  Future<void> _trackCurrentImpression() async {
    if (_promoAds.isEmpty) return;

    final ad = _promoAds[_currentPage];
    final id = ad.id;

    if (id == null) return;

    unawaited(AdTrackingService.trackImpressionOnce(id));
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerAdvertisementBloc, CustomerAdvertisementState>(
      builder: (context, state) {
        if (state is AdminAdvertisementFetched && state.adminAds.isNotEmpty) {
          _promoAds = state.adminAds;
        }
        if (_promoAds.isEmpty) {
          return const SizedBox.shrink();
        }

        final ads = _promoAds;

        return Column(
          children: [
            20.verticalSpace,
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _pageController,
                itemCount: ads.length,
                onPageChanged: (index) async {
                  setState(() => _currentPage = index);
                  await _trackCurrentImpression();
                },
                itemBuilder: (context, index) {
                  final ad = ads[index];

                  return GestureDetector(
                    onTap: () async {
                      if (ad.id != null) {
                        unawaited(AdTrackingService.trackClick(ad.id!));
                      }
                      await AppGenUtil.launchUrlText(ad.targetUrl ?? '');
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CacheNetworkImageWidget(
                        imageUrl: ad.imageUrl ?? '',
                        height: 180,
                        width: 120,
                        fit: BoxFit.fill,
                      ),
                    ),
                  );
                },
              ),
            ),
            10.verticalSpace,
            SmallDotIndicator(
              total: ads.length,
              currentIndex: _currentPage,
            ),
          ],
        );
      },
    );
  }
}
