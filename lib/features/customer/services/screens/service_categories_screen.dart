import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/nav_item.model.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/service_bloc/customer_services_bloc.dart';
import 'package:resq360/features/customer/dashboard/widgets/service_category_widget.dart';
import 'package:resq360/features/customer/services/screens/service_providers_screen.dart';
import 'package:resq360/features/widgets/inputs/filter_search_field.dart';

class ServiceCategoryScreen extends StatefulWidget {
  const ServiceCategoryScreen({super.key});

  @override
  State<ServiceCategoryScreen> createState() => _ServiceCategoryScreenState();
}

class _ServiceCategoryScreenState extends State<ServiceCategoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  // final List<NavItem> categories = [
  //   NavItem(body: const Icon(Icons.local_shipping_outlined), title: 'Towing'),
  //   NavItem(
  //     body: const Icon(Icons.medical_services_outlined),
  //     title: 'Ambulance',
  //   ),
  //   NavItem(body: const Icon(Icons.plumbing_outlined), title: 'Plumbing'),
  //   NavItem(
  //     body: const Icon(Icons.electrical_services_outlined),
  //     title: 'Electrical Repair',
  //   ),
  //   NavItem(
  //     body: const Icon(Icons.cleaning_services_outlined),
  //     title: 'Cleaning',
  //   ),
  //   NavItem(
  //     body: const Icon(Icons.cleaning_services_outlined),
  //     title: 'Cleaning',
  //   ),
  //   NavItem(
  //     body: const Icon(Icons.cleaning_services_outlined),
  //     title: 'Cleaning',
  //   ),
  //   NavItem(
  //     body: const Icon(Icons.cleaning_services_outlined),
  //     title: 'Cleaning',
  //   ),
  //   NavItem(
  //     body: const Icon(Icons.cleaning_services_outlined),
  //     title: 'Cleaning',
  //   ),
  // ];

  @override
  void initState() {
    context.read<CustomerServicesBloc>().add(CustomerFetchServices());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocListener<CustomerServicesBloc, CustomerServicesState>(
      listener: (context, state) {},
      child: Scaffold(
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
        body: BlocBuilder<CustomerServicesBloc, CustomerServicesState>(
          builder: (context, state) {
            if (state is CustomerServicesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CustomerServicesError) {
              return Center(
                child: Text(
                  state.error,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (state is CustomerServicesLoaded) {
              final services = state.services;
              return Padding(
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
                        itemCount: services.length,
                        
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              mainAxisExtent: 160,
                            ),
                        itemBuilder: (context, index) {
                          final service = services[index];
                          return GestureDetector(
                            onTap: () {
                              pushScreen(
                                context,
                                ServiceProvidersScreen(
                                  serviceProviderId: service.id,
                                  // serviceName: service.name,
                                ),
                              );
                            },
                            child: ServiceCategoryWidget(
                              icon: Image.network(
                                service.image,
                                fit: BoxFit.cover,
                                
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.image_not_supported,
                                    size: 32,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                              label: service.name,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
