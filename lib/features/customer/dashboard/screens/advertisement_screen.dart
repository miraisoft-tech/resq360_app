import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/dashboard/data/models/advertisment/advertisement.model.dart';
import 'package:resq360/features/customer/dashboard/widgets/recommended_card_widget.dart';

class RecommendedListScreen extends StatelessWidget {
  const RecommendedListScreen({
    required this.advertisements,
    super.key,
  });

  final List<Advertisement> advertisements;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommended For You'),
        elevation: 0,
        backgroundColor: colors.whiteColor,
        forceMaterialTransparency: true,
      ),
      backgroundColor: colors.whiteColor,
      body:
          advertisements.isEmpty
              ? Center(
                child: GenText(
                  'No recommendations available',
                  color: colors.textColor.shade400,
                ),
              )
              : ListView.separated(
                padding: pad(horizontal: 16, vertical: 20),
                itemCount: advertisements.length,
                separatorBuilder: (_, _) => 16.verticalSpace,
                itemBuilder: (context, index) {
                  return RecommendedCard(
                    advertisement: advertisements[index],
                  );
                },
              ),
    );
  }
}
