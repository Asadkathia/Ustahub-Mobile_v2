import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/common_model_class/ProviderListModelClass.dart';
import 'package:ustahub/app/ui_v2/ui_v2_exports.dart';

class ProvidersListView extends StatelessWidget {
  final List<ProvidersListModelClass> providers;
  final String serviceName;
  final String? serviceId;
  final bool isSearchResult;

  const ProvidersListView({
    super.key,
    required this.providers,
    required this.serviceName,
    this.serviceId,
    this.isSearchResult = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: serviceName),
      body: providers.isEmpty
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
                    'No providers found',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    isSearchResult
                        ? 'Try searching with different keywords'
                        : 'No providers available for this service',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 10.h),
              itemCount: providers.length,
              itemBuilder: (context, index) {
                final data = providers[index];
                final servicesString = (data.services ?? [])
                    .map((s) => s.name ?? '')
                    .where((name) => name.isNotEmpty)
                    .join(', ');
                return ServiceProviderCard(
                  onFavoriteTap: () async {
                    // Toggle favorite
                    final controller = Get.find<FavouriteProviderController>();
                    await controller.favouriteToggle(id: data.id.toString());
                    // Refresh the list if needed
                  },
                  isFavorite: data.isFavorite ?? false,
                  onTap: () {
                    // Always use V2 provider details screen
                    Get.to(() => ProviderDetailsScreenV2(id: data.id.toString()));
                  },
                  starValue: data.averageRating ?? 0.0,
                  name: data.name ?? "",
                  category: servicesString,
                  imageUrl: data.avatar ?? blankProfileImage,
                );
              },
            ),
    );
  }
}

