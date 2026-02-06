import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/ad_tracking_service.dart';
import 'package:resq360/features/customer/dashboard/data/models/advertisment/advertisement.model.dart';
import 'package:resq360/features/customer/dashboard/widgets/recommended_card_widget.dart';
import 'package:resq360/features/customer/services/screens/service_provider_details_screen.dart';
import 'package:resq360/features/widgets/scaffolds/app_scaffold.dart';

class RecommendedListScreen extends StatelessWidget {
  const RecommendedListScreen({
    required this.advertisements,
    super.key,
  });

  final List<Advertisement> advertisements;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppScaffold(
      title: 'Recommended For You',
      body:
          advertisements.isEmpty
              ? Center(
                child: GenText(
                  'No recommendations available',
                  color: colors.textColor.shade400,
                ),
              )
              : ListView.separated(
                itemCount: advertisements.length,
                separatorBuilder: (_, _) => 16.verticalSpace,
                itemBuilder: (context, index) {
                  final ad = advertisements[index];
                  return GestureDetector(
                    onTap: () async {
                      if (ad.id != null) {
                        unawaited(AdTrackingService.trackClick(ad.id!));
                      }
                      final providerId = ad.providerId;
                      if (providerId == null) return;

                      await pushScreen(
                        context,
                        ServiceProviderDetailsScreen(providerId: providerId),
                      );
                    },
                    child: RecommendedCard(
                      advertisement: advertisements[index],
                    ),
                  );
                },
              ),
    );
  }
}
