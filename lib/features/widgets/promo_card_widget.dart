import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/ad_tracking_service.dart';
import 'package:resq360/core/utils/app_gen_utils.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/advertisement_bloc/customer_advertisement_bloc.dart';
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


  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
       unawaited(_trackCurrentImpression());

      _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) async {
        if (!mounted) return;
        final adsState = context.read<CustomerAdvertisementBloc>().state;

        if (adsState is! CustomerAdvertisementFetched) return;

        final adsLength = adsState.adminAds.length;
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
    final state = context.read<CustomerAdvertisementBloc>().state;
    if (state is! CustomerAdvertisementFetched) return;

    final ad = state.adminAds[_currentPage];
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
        if (state is CustomerAdvertisementLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CustomerAdvertisementFetched) {
          final ads = state.adminAds;
          if (ads.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            children: [
              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: ads.length,
                  onPageChanged: (index) async {
                    setState(() {
                      _currentPage = index;
                    });
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
                        // Row(
                        //     children: [
                        //       16.horizontalSpace,
                        //       Expanded(
                        //         child: Padding(
                        //           padding: pad(vertical: 10),
                        //           child: Column(
                        //             crossAxisAlignment: CrossAxisAlignment.start,
                        //             children: [
                        //               UrbText(
                        //                 ad.title ?? 'N/A',
                        //                 size: 18,
                        //                 height: 20.5,
                        //                 weight: FontWeight.w700,
                        //                 color: colors.whiteColor,
                        //               ),
                        //               20.verticalSpace,
                        //               GenText(
                        //                 ad.description ?? 'N/A',
                        //                 size: 12,
                        //                 height: 20.5,
                        //                 color: colors.whiteColor,
                        //                 maxLines: 2,
                        //               ),
                        //               30.verticalSpace,
                        //               SizedBox(
                        //                 height: 30.h,
                        //                 child: ElevatedButton(
                        //                   style: ElevatedButton.styleFrom(
                        //                     padding: pad(horizontal: 14),
                        //                     backgroundColor: colors.whiteColor,
                        //                     foregroundColor:
                        //                         colors.primary.shade500,
                        //                     shape: RoundedRectangleBorder(
                        //                       borderRadius: BorderRadius.circular(
                        //                         8.r,
                        //                       ),
                        //                     ),
                        //                   ),
                        //                   onPressed: () async {
                        //                     await AppGenUtil.callPhone(
                        //                       phoneNumber:
                        //                           ad.provider?.phoneNumber ?? '',
                        //                     );
                        //                   },
                        //                   child: GenText(
                        //                     'Call Now',
                        //                     height: 16.5,
                        //                     color: colors.primary.shade500,
                        //                     weight: FontWeight.w500,
                        //                   ),
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       ),
                        //       CacheNetworkImageWidget(
                        //         imageUrl: ad.provider?.profileImage ?? '',
                        //         height: 180,
                        //         width: 120,
                        //         fit: BoxFit.contain,
                        //       ),
                        //       20.horizontalSpace,
                        //     ],
                        //   ),
                      ),
                    );
                  },
                ),
              ),
              10.verticalSpace,
              if (ads.isNotEmpty)
                SmallDotIndicator(
                  total: ads.length,
                  currentIndex: _currentPage,
                ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
