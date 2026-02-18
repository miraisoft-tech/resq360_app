import 'dart:async';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/ad_tracking_service.dart';
import 'package:resq360/features/customer/dashboard/data/models/advertisment/advertisement.model.dart';
import 'package:resq360/features/customer/dashboard/widgets/recommended_card_widget.dart';
import 'package:resq360/features/customer/services/screens/service_provider_details_screen.dart';

class AdvertisementCarousel extends StatefulWidget {
  const AdvertisementCarousel({required this.ads, super.key});
  final List<Advertisement> ads;

  @override
  State<AdvertisementCarousel> createState() => _AdvertisementCarouselState();
}

class _AdvertisementCarouselState extends State<AdvertisementCarousel> {
  late final PageController _pageController;
  int currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.95);

    _pageController.addListener(() async {
      final newIndex = _pageController.page?.round() ?? 0;
      if (newIndex != currentIndex) {
        setState(() => currentIndex = newIndex);
        unawaited(_trackCurrentImpression());
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      unawaited(_trackCurrentImpression());
    });

    _startAutoScroll();
  }

  void _startAutoScroll() {
    if (widget.ads.length <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!_pageController.hasClients) return;

      final nextPage = currentIndex + 1;

      if (nextPage >= widget.ads.length) {
        await _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      } else {
        await _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _trackCurrentImpression() async {
    if (widget.ads.isEmpty) return;

    final ad = widget.ads[currentIndex];
    final adId = ad.id;

    if (adId == null) return;

    unawaited(AdTrackingService.trackImpressionOnce(adId));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.ads.length,
            padEnds: false,
            clipBehavior: Clip.none,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () async {
                  final ad = widget.ads[index];

                  if (ad.id != null) {
                    unawaited(AdTrackingService.trackClick(ad.id!));
                  }

                  final providerId = widget.ads[index].providerId;
                  if (providerId == null) return;
                  await pushScreen(
                    context,
                    ServiceProviderDetailsScreen(providerId: providerId),
                  );
                },
                child: RecommendedCard(advertisement: widget.ads[index]),
              );
            },
          ),
        ),
        5.verticalSpace,
        if (widget.ads.length > 1)
          SmallDotIndicator(
            total: widget.ads.length,
            currentIndex: currentIndex,
          ),
      ],
    );
  }
}
