import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/advertisement_bloc/customer_advertisement_bloc.dart';

class PromoCardWidget extends StatefulWidget {
  const PromoCardWidget({
    super.key,
  });

  @override
  State<PromoCardWidget> createState() => _PromoCardWidgetState();
}

class _PromoCardWidgetState extends State<PromoCardWidget> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocBuilder<CustomerAdvertisementBloc, CustomerAdvertisementState>(
      builder: (context, state) {
        if (state is CustomerAdvertisementLoading) {
            return const CircularProgressIndicator();
          
        }
        if(state is CustomerAdvertisementFetched ){
          final ads = state.adverisementList;
          if (ads.isEmpty) {
              return const SizedBox.shrink();
            }
        
            return Column(
              children: [
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: ads.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Container(
                        margin: pad(horizontal: 4),
                        decoration: BoxDecoration(
                          color: colors.primary.shade500,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            16.horizontalSpace,
                            Expanded(
                              child: Padding(
                                padding: pad(vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    UrbText(
                                      'Help, Anytime. Anywhere',
                                      size: 18,
                                      height: 28.5,
                                      weight: FontWeight.w700,
                                      color: colors.whiteColor,
                                    ),
                                    GenText(
                                      'Stuck? Tap now for fast roadside assistance',
                                      size: 12,
                                      height: 20.5,
                                      color: colors.whiteColor,
                                    ),
                                    10.verticalSpace,
                                    SizedBox(
                                      height: 30.h,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: pad(horizontal: 14),
                                          backgroundColor: colors.whiteColor,
                                          foregroundColor: colors.primary.shade500,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                        ),
                                        onPressed: () {},
                                        child: GenText(
                                          'Call Now',
                                          height: 16.5,
                                          color: colors.primary.shade500,
                                          weight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            AppAssets.ASSETS_IMAGES_HAPPY_MECHANIC_PNG.imageAsset(
                              height: 140,
                              width: 120,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                10.verticalSpace,
                if (ads.isNotEmpty)
                  SmallDotIndicator(total: ads.length, currentIndex: _currentPage),
              ],
            );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
