import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/authentication/data/bloc/customer_auth_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/service_bloc/customer_services_bloc.dart';
import 'package:resq360/features/customer/dashboard/screens/notification_screen.dart';
import 'package:resq360/features/customer/dashboard/screens/wallet_screen.dart';
import 'package:resq360/features/customer/dashboard/widgets/ongoing_service_widget.dart';
import 'package:resq360/features/customer/dashboard/widgets/recommended_card_widget.dart';
import 'package:resq360/features/customer/dashboard/widgets/service_category_widget.dart';
import 'package:resq360/features/customer/services/screens/service_categories_screen.dart';
// import 'package:resq360/features/customer/services/screens/service_providers_screen.dart';
import 'package:resq360/features/widgets/inputs/filter_search_field.dart';
import 'package:resq360/features/widgets/promo_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    context.read<CustomerServicesBloc>().add(CustomerFetchServices());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.whiteColor,
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false,
        title: BlocBuilder<CustomerAuthBloc, CustomerAuthState>(
          builder: (context, state) {
            if (state is CustomerAuthLoginSuccess) {
              final user = state.user;
              return Row(
                children: [
                  const CircleAvatar(
                    radius: 19,
                    backgroundImage: AssetImage(
                      AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
                    ),
                    // TODO : replace with network image
                    // NetworkImage(
                    //   // user.profilePictureUrl ??
                    //       AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
                    // ),
                  ),
                  10.horizontalSpace,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GenText(
                        'Hello, ${user.fullName} 👋',
                        size: 12,
                        height: 20,
                        weight: FontWeight.w400,
                        color: colors.neutral.shade500,
                      ),

                      Row(
                        children: [
                          AppAssets.ASSETS_ICONS_LOCATION_SVG.svg,
                          4.horizontalSpace,
                          GenText(
                            // user.address ??
                            'No. 2 Olympia Street',
                            height: 24,
                            color: colors.black,
                            weight: FontWeight.w500,
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 14,
                            color: colors.textColor.shade500,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  const CircleAvatar(
                    radius: 19,
                    backgroundImage: AssetImage(
                      AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
                    ),
                  ),
                  10.horizontalSpace,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GenText(
                        'Hello, Jane 👋',
                        size: 12,
                        height: 20,
                        weight: FontWeight.w400,
                        color: colors.neutral.shade500,
                      ),

                      Row(
                        children: [
                          AppAssets.ASSETS_ICONS_LOCATION_SVG.svg,
                          4.horizontalSpace,
                          GenText(
                            'No. 2 Olympia Street',
                            height: 24,
                            color: colors.black,
                            weight: FontWeight.w500,
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 14,
                            color: colors.textColor.shade500,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
        actions: [
          IconButton(
            icon: AppAssets.ASSETS_ICONS_WALLET_SVG.svg,
            onPressed: () async {
              await pushScreen(context, const WalletScreen());
            },
          ),
          IconButton(
            icon: AppAssets.ASSETS_ICONS_NOTIFICATION_SVG.svg,
            onPressed: () async {
              await pushScreen(context, const NotificationScreen());
            },
          ),
          10.horizontalSpace,
        ],
      ),
      body: ListView(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 10.h,
          bottom: 50.h,
        ),
        children: [
          10.verticalSpace,
          FilterSearchFormField(
            controller: TextEditingController(),
            hintText: 'Search for services',
            onTapSuffix: () {},
            onChanged: (value) {},
            prefixIconPath: AppAssets.ASSETS_ICONS_SEARCH_SVG,
          ),
          20.verticalSpace,
          const PromoCardWidget(),
          20.verticalSpace,
          UrbText(
            'Ongoing Service',
            size: 18,
            height: 28.5,
            weight: FontWeight.w700,
            color: colors.black,
          ),
          12.verticalSpace,
          const OngoingServiceCard(),
          20.verticalSpace,
          Row(
            children: [
              UrbText(
                'What service do you need?',
                size: 18,
                height: 28.5,
                weight: FontWeight.w700,
                color: colors.black,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  await pushScreen(context, const ServiceCategoryScreen());
                },
                child: UrbText(
                  'View All',
                  size: 12,
                  height: 20.5,
                  weight: FontWeight.w400,
                  color: colors.primary.shade500,
                ),
              ),
            ],
          ),
          20.verticalSpace,
          BlocBuilder<CustomerServicesBloc, CustomerServicesState>(
            builder: (context, state) {
              if (state is CustomerServicesLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is CustomerServicesLoaded) {
                final categories = state.services;

                return SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, _) => 12.horizontalSpace,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return ServiceCategoryWidget(
                        icon: Image.network(
                          category.image,
                          height: 28,
                          width: 28,
                          errorBuilder:
                              (_, _, _) => const Icon(Icons.broken_image),
                        ),
                        label: category.name,
                      );
                    },
                  ),
                );
              }

              if (state is CustomerServicesError) {
                return Center(child: Text(state.error));
              }

              return const SizedBox.shrink();
            },
          ),
          30.verticalSpace,
          Row(
            children: [
              UrbText(
                'Recommended for You',
                size: 18,
                height: 28.5,
                weight: FontWeight.w700,
                color: colors.black,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  // await pushScreen(context, const ServiceProvidersScreen());
                },
                child: UrbText(
                  'View All',
                  size: 12,
                  height: 20.5,
                  weight: FontWeight.w400,
                  color: colors.primary.shade500,
                ),
              ),
            ],
          ),
          12.verticalSpace,
          const RecommendedCard(),
          30.verticalSpace,
        ],
      ),
    );
  }
}
