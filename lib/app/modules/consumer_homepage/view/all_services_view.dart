import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/providers_list/view/providers_list_view.dart';

class AllServicesView extends StatefulWidget {
  final List services;
  const AllServicesView({super.key, required this.services});

  @override
  State<AllServicesView> createState() => _AllServicesViewState();
}

class _AllServicesViewState extends State<AllServicesView> {
  final TextEditingController _searchController = TextEditingController();
  List<ServicesModelClass> filteredServices = [];

  @override
  void initState() {
    super.initState();
    filteredServices = widget.services.cast<ServicesModelClass>();
  }

  void _filterServices(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredServices = widget.services.cast<ServicesModelClass>();
      } else {
        filteredServices = widget.services
            .cast<ServicesModelClass>()
            .where((service) => 
                service.name?.toLowerCase().contains(query.toLowerCase()) == true)
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Services we offer"),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 10.h),
        child: Column(
          children: [
            // Search Field
            Container(
              margin: EdgeInsets.only(bottom: 16.h),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _searchController,
                builder: (context, value, child) {
                  return TextField(
                    controller: _searchController,
                    onChanged: _filterServices,
                    decoration: InputDecoration(
                      hintText: 'Search services...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                      suffixIcon: value.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey.shade600),
                              onPressed: () {
                                _searchController.clear();
                                _filterServices('');
                              },
                            )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  );
                },
              ),
            ),
            // Services Grid
            Expanded(
              child: filteredServices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No services found',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Try searching with different keywords',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : CategoriesGridView(
                      showFull: true,
                      data: filteredServices,
                      onCategoryTap: (service) {
            final allProviders =
                Get.find<ConsumerHomepageController>()
                    .providerController
                    .providersList;
            // final allProviders =
            //     Get.find<ConsumerHomepageController>()
            //         .providerController
            //         .providersList;
            // final filteredProviders =
            //     allProviders
            //         .where(
            //           (p) => (p.services ?? []).any((s) => s.id == service.id),
            //         )
            //         .toList();
            Get.to(
              () => ProvidersListView(
                providers: allProviders,
                serviceName: service.name ?? '',
                serviceId: service.id.toString(), // Pass service ID
              ),
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
