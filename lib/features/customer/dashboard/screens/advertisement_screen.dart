import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/ad_tracking_service.dart';
import 'package:resq360/features/customer/dashboard/data/models/advertisment/advertisement.model.dart';
import 'package:resq360/features/customer/dashboard/widgets/recommended_card_widget.dart';
import 'package:resq360/features/customer/services/screens/service_provider_details_screen.dart';
import 'package:resq360/features/widgets/inputs/filter_search_field.dart';
import 'package:resq360/features/widgets/scaffolds/app_scaffold.dart';

class RecommendedListScreen extends StatefulWidget {
  const RecommendedListScreen({required this.advertisements, super.key});

  final List<Advertisement> advertisements;

  @override
  State<RecommendedListScreen> createState() => _RecommendedListScreenState();
}

class _RecommendedListScreenState extends State<RecommendedListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Advertisement> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.advertisements;
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _filtered = widget.advertisements);
      return;
    }
    setState(() {
      _filtered =
          widget.advertisements.where((ad) {
            final title = ad.title?.toLowerCase() ?? '';
            final description = ad.description?.toLowerCase() ?? '';
            final serviceType = ad.serviceType?.toLowerCase() ?? '';
            final providerName = ad.provider?.fullName?.toLowerCase() ?? '';
            return title.contains(query) ||
                description.contains(query) ||
                serviceType.contains(query) ||
                providerName.contains(query);
          }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppScaffold(
      title: 'Recommended For You',
      body: Column(
        children: [
          FilterSearchFormField(
            controller: _searchController,
            hintText: 'Search recommendations...',
            onTapSuffix: () {
              _searchController.clear();
              setState(() {});
            },
            onChanged: (value) {
              setState(() {});
            },
            prefixIconPath: AppAssets.ASSETS_ICONS_SEARCH_SVG,
          ),
          20.verticalSpace,
          Expanded(
            child:
                _filtered.isEmpty
                    ? Center(
                      child: GenText(
                        _searchController.text.isEmpty
                            ? 'No recommendations available'
                            : 'No results found',
                        color: colors.textColor.shade400,
                      ),
                    )
                    : ListView.separated(
                      itemCount: _filtered.length,
                      separatorBuilder: (_, _) => 16.verticalSpace,
                      itemBuilder: (context, index) {
                        final ad = _filtered[index];
                        return GestureDetector(
                          onTap: () async {
                            if (ad.id != null) {
                              unawaited(AdTrackingService.trackClick(ad.id!));
                            }
                            final providerId = ad.providerId;
                            if (providerId == null) return;

                            await pushScreen(
                              context,
                              ServiceProviderDetailsScreen(
                                providerId: providerId,
                              ),
                            );
                          },
                          child: RecommendedCard(advertisement: ad),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
