import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/dashboard/data/models/service-model/service.model.dart';
import 'package:resq360/features/widgets/images.widgets.dart';

class ServiceCategoryWidget extends StatelessWidget {
  const ServiceCategoryWidget({
    required this.category,
    this.onTap,
    super.key,
  });

  final Service category;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: pad(horizontal: 6, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: colors.lightGreyColor2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CacheNetworkImageWidget(
              imageUrl: category.image,
              height: 60,
              width: 100,
              fit: BoxFit.contain,
            ),

            10.verticalSpace,
            SizedBox(
              width: 100.w,
              child: GenText(
                category.name,
                color: colors.black,
                size: 12,
                weight: FontWeight.w400,
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
