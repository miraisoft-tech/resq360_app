import 'package:resq360/__lib.dart';
import 'package:resq360/core/theme/app_color_theme.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/promotion_bloc/promotion_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/models/advertisment/advertisement.model.dart';
import 'package:resq360/features/provider/dashboard/screens/promote_service_screen.dart';
import 'package:resq360/features/provider/dashboard/widgets/edit_promotion_details_sheet.dart';
import 'package:resq360/features/provider/dashboard/widgets/promotion_card.dart';
import 'package:resq360/features/provider/dashboard/widgets/promotion_details_sheet.dart';
import 'package:resq360/features/provider/dashboard/widgets/promotion_empty_state.dart';
import 'package:resq360/features/provider/dashboard/widgets/promotion_option_sheet.dart';
import 'package:resq360/features/provider/dashboard/widgets/promotions_stats_overview.dart';

class PromotionsDashboardScreen extends StatefulWidget {
  const PromotionsDashboardScreen({super.key});

  @override
  State<PromotionsDashboardScreen> createState() =>
      _PromotionsDashboardScreenState();
}

class _PromotionsDashboardScreenState extends State<PromotionsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var _promotions = <Advertisement>[];
  bool _isLoadingPromotions = true;

  bool _isPromotionActiveByDate(Advertisement ad) {
    final endDate = ad.endDate;
    if (endDate == null) return false;
    return !endDate.toUtc().isBefore(DateTime.now().toUtc());
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPromotions();
  }

  Future<void> _loadPromotions() async {
    if (mounted) {
      setState(() {
        _isLoadingPromotions = true;
      });
    }

    context.read<PromotionBloc>().add(FetchMyPromotions());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.neutral.shade50,
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: UrbText(
          'My Promotions',
          size: 22,
          weight: FontWeight.w700,
          color: colors.textColor.shade800,
        ),
        elevation: 0,
        backgroundColor: colors.whiteColor,
        leading: IconButton(
          onPressed: () => pop(context),
          icon: AppAssets.ASSETS_ICONS_BACK_ICON_SVG.svg,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colors.primary.shade500,
          unselectedLabelColor: colors.neutral.shade400,
          indicatorColor: colors.primary.shade500,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [Tab(text: 'Active'), Tab(text: 'All')],
        ),
      ),
      body: BlocConsumer<PromotionBloc, PromotionState>(
        listener: (context, state) async {
          if (state is PromotionsFetched) {
            setState(() {
              _promotions = state.promotions;
              _isLoadingPromotions = false;
            });
          }

          if (state is PromotionError) {
            if (_isLoadingPromotions) {
              setState(() {
                _isLoadingPromotions = false;
              });
            }
            await showErrorSnackbar(context, state.error);
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildPromotionsList(activeOnly: true),
              _buildPromotionsList(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreatePromotion,
        backgroundColor: colors.primary.shade500,
        icon: Icon(Icons.add, color: colors.whiteColor),
        label: GenText(
          'New Promotion',
          weight: FontWeight.w600,
          color: colors.whiteColor,
        ),
      ),
    );
  }

  Widget _buildPromotionsList({bool activeOnly = false}) {
    if (_isLoadingPromotions && _promotions.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: context.appColors.primary.shade500,
        ),
      );
    }

    var promotions = _promotions;
    if (activeOnly) {
      promotions = promotions.where(_isPromotionActiveByDate).toList();
    }

    final stats = _calculateStats(promotions);

    return RefreshIndicator(
      onRefresh: () async => _loadPromotions(),
      color: context.appColors.primary.shade500,
      child:
          promotions.isEmpty
              ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: PromotionEmptyState(
                  activeOnly: activeOnly,
                  onCreatePromotion: _navigateToCreatePromotion,
                ),
              )
              : Column(
                children: [
                  if (promotions.isNotEmpty)
                    PromotionStatsOverview(stats: stats),
                  Expanded(
                    child: ListView.separated(
                      padding: pad(horizontal: 16, vertical: 16),
                      itemCount: promotions.length,
                      separatorBuilder: (_, _) => 16.verticalSpace,
                      itemBuilder: (context, index) {
                        return PromotionCard(
                          promotion: promotions[index],
                          onViewDetails:
                              () => _showPromotionDetails(promotions[index]),
                          onShowOptions:
                              () => _showPromotionOptions(promotions[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }

  Future<void> _showPromotionDetails(Advertisement promotion) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PromotionDetailsSheet(promotion: promotion),
    );
  }

  Future<void> _showPromotionOptions(Advertisement promotion) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.appColors.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder:
          (context) => PromotionOptionsSheet(
            promotion: promotion,
            onEdit: () => _showEditPromotionSheet(promotion, context.appColors),
            onDelete:
                () => _confirmDeletePromotion(promotion, context.appColors),
          ),
    );
  }

  Future<void> _confirmDeletePromotion(
    Advertisement promotion,
    AppColorPalette colors,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const GenText('Delete Promotion', weight: FontWeight.w700),
          content: const GenText(
            'Are you sure you want to delete this promotion? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const GenText('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<PromotionBloc>().add(
                  DeletePromotion(promotion.id!),
                );
              },
              child: GenText('Delete', color: colors.error.shade500),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditPromotionSheet(
    Advertisement promotion,
    AppColorPalette colors,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.whiteColor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => EditPromotionSheet(promotion: promotion),
    );
  }

  Future<void> _navigateToCreatePromotion() async {
    await pushScreen(context, const PromoteServiceScreen());
    await _loadPromotions();
  }

  Map<String, dynamic> _calculateStats(List<Advertisement> promotions) {
    if (promotions.isEmpty) {
      return {'totalImpressions': 0, 'totalClicks': 0, 'avgCTR': 0.0};
    }

    final totalImpressions = promotions.fold<int>(
      0,
      (sum, ad) => sum + (ad.impressionCount ?? 0),
    );
    final totalClicks = promotions.fold<int>(
      0,
      (sum, ad) => sum + (ad.clickCount ?? 0),
    );
    final avgCTR =
        totalImpressions > 0 ? (totalClicks / totalImpressions * 100) : 0.0;

    return {
      'totalImpressions': totalImpressions,
      'totalClicks': totalClicks,
      'avgCTR': avgCTR,
    };
  }
}
