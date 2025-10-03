import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/nav_item.model.dart';
import 'package:resq360/features/dashboard/widgets/service_category_widget.dart';
import 'package:resq360/features/widgets/inputs/filter_search_field.dart';

class ServiceCategoryScreen extends StatefulWidget {
  const ServiceCategoryScreen({super.key});

  @override
  State<ServiceCategoryScreen> createState() => _ServiceCategoryScreenState();
}

class _ServiceCategoryScreenState extends State<ServiceCategoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<NavItem> categories = [
    NavItem(body: const Icon(Icons.local_shipping_outlined), title: 'Towing'),
    NavItem(
      body: const Icon(Icons.medical_services_outlined),
      title: 'Ambulance',
    ),
    NavItem(body: const Icon(Icons.plumbing_outlined), title: 'Plumbing'),
    NavItem(
      body: const Icon(Icons.electrical_services_outlined),
      title: 'Electrical Repair',
    ),
    NavItem(
      body: const Icon(Icons.cleaning_services_outlined),
      title: 'Cleaning',
    ),
    NavItem(
      body: const Icon(Icons.cleaning_services_outlined),
      title: 'Cleaning',
    ),
    NavItem(
      body: const Icon(Icons.cleaning_services_outlined),
      title: 'Cleaning',
    ),
    NavItem(
      body: const Icon(Icons.cleaning_services_outlined),
      title: 'Cleaning',
    ),
    NavItem(
      body: const Icon(Icons.cleaning_services_outlined),
      title: 'Cleaning',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.whiteColor,
        leading:
            Navigator.canPop(context)
                ? IconButton(
                  icon: Icon(Icons.arrow_back, color: colors.black),
                  onPressed: () => pop(context),
                )
                : null,
        title: UrbText(
          'Service Category',
          size: 22,
          height: 32,
          weight: FontWeight.w700,
          color: colors.black,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: pad(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilterSearchFormField(
              controller: _searchController,
              hintText: 'Search for services',
              onTapSuffix: () {},
              onChanged: (value) {
                setState(() {});
              },
              prefixIconPath: AppAssets.ASSETS_ICONS_SEARCH_SVG,
            ),
            20.verticalSpace,
            Expanded(
              child: GridView.builder(
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final item = categories[index];
                  return ServiceCategoryWidget(
                    icon: item.body,
                    label: item.title,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
