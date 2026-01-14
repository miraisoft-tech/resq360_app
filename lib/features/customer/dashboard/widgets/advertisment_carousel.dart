import 'package:resq360/__lib.dart';
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.95);

    _pageController.addListener(() {
      final newIndex = _pageController.page?.round() ?? 0;

      if (newIndex != currentIndex) {
        setState(() => currentIndex = newIndex);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 170.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.ads.length,
            padEnds: false,
            clipBehavior: Clip.none,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () async {
                  final providerId = widget.ads[index].providerId;
                  if (providerId == null) return;
                  await pushScreen(
                    context,
                    ServiceProviderDetailsScreen(
                      providerId: providerId,
                    ),
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
