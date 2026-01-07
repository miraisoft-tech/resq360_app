
import 'package:resq360/__lib.dart';
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

  @override
  void initState() {
    super.initState();

    final bloc = context.read<CustomerServicesBloc>();
    final currentState = bloc.state;

    if (currentState is! CustomerServicesLoaded) {
      bloc.add(CustomerFetchServices());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              return ErrorMessageAndButton(
                error: state.error,
                onPressed: () {
                  context.read<CustomerServicesBloc>().add(
                    CustomerFetchServices(),
                  );
                },
              );
            }

            if (state is CustomerServicesLoaded) {
              final services = state.services;

              final filteredServices =
                  _searchController.text.isEmpty
                      ? services
                      : services.where((service) {
                        return service.name.toLowerCase().contains(
                          _searchController.text.toLowerCase(),
                        );
                      }).toList();

              return Padding(
                padding: pad(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FilterSearchFormField(
                      controller: _searchController,
                      hintText: 'Search for services',
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
                          filteredServices.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 64,
                                      color: colors.greyColor,
                                    ),
                                    16.verticalSpace,
                                    UrbText(
                                      'No services found',
                                      size: 16,
                                      weight: FontWeight.w600,
                                      color: colors.greyColor,
                                    ),
                                    8.verticalSpace,
                                    UrbText(
                                      'Try searching with different keywords',
                                      color: colors.greyColor,
                                    ),
                                  ],
                                ),
                              )
                              : GridView.builder(
                                itemCount: filteredServices.length,

                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 16,
                                      crossAxisSpacing: 16,
                                      mainAxisExtent: 160,
                                    ),
                                itemBuilder: (context, index) {
                                  final service = filteredServices[index];

                                  return ServiceCategoryWidget(
                                    category: service,
                                    onTap: () async {
                                      await pushScreen(
                                        context,
                                        ServiceProvidersScreen(
                                          serviceProviderId: service.id,
                                        ),
                                      );
                                    },
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
