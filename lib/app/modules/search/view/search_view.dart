import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/providers_list/view/providers_list_view.dart';

class SearchView extends StatelessWidget {
  final searchCtrl = Get.put(SearchDBController());

  SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 13.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              10.ph,
              SearchField(),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.recents,
                    style: GoogleFonts.ubuntu(
                      fontSize: 14.sp,
                      color: AppColors.grey,
                    ),
                  ),
                  TextButton(
                    onPressed: () => searchCtrl.clearAll(),
                    child: Text(
                      AppLocalizations.of(context)!.clearAll,
                      style: GoogleFonts.ubuntu(
                        color: AppColors.grey,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
              Obx(
                () => Expanded(
                  child: ListView.builder(
                    itemCount: searchCtrl.searches.length,
                    itemBuilder: (_, index) {
                      final item = searchCtrl.searches[index];
                      return ListTile(
                        leading: Icon(Icons.history, color: AppColors.grey),
                        title: Text(
                          item.keyword,
                          style: GoogleFonts.ubuntu(color: AppColors.grey),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.close, color: AppColors.grey),
                          onPressed: () => searchCtrl.deleteSearch(item.id!),
                        ),
                        onTap: () async {
                          // Save search to history and perform search
                          searchCtrl.addSearch(item.keyword);
                          await _performSearch(item.keyword);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _performSearch(String keyword) async {
    try {
      // Get or create provider controller
      ProviderController providerController;
      if (Get.isRegistered<ProviderController>()) {
        providerController = Get.find<ProviderController>();
      } else {
        providerController = Get.put(ProviderController());
      }

      // Call search API
      await providerController.searchProviders(keyword: keyword);

      // Navigate to providers list view with search results
      Get.to(
        () => ProvidersListView(
          providers: providerController.providersList.toList(),
          serviceName: 'Search Results for "$keyword"',
          serviceId: null, // No service ID for search results
          isSearchResult: true, // Mark as search result
        ),
      );
    } catch (e) {
      print('Search error: $e');
      // Show error message to user
      Get.snackbar(
        'Search Error',
        'Failed to search providers. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
