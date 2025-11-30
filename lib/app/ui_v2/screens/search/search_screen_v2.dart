import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/common_model_class/ProviderListModelClass.dart';
import '../../components/cards/recommendation_card_v2.dart';
import '../../components/navigation/app_app_bar_v2.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/spacing/app_spacing.dart';
import '../../design_system/typography/app_text_styles.dart';
import '../provider/provider_details_screen_v2.dart';
import 'advanced_search_screen_v2.dart';

class SearchScreenV2 extends StatefulWidget {
  SearchScreenV2({super.key});

  @override
  State<SearchScreenV2> createState() => _SearchScreenV2State();
}

class _SearchScreenV2State extends State<SearchScreenV2> {
  final SearchDBController controller = Get.put(SearchDBController());
  final TextEditingController searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.fetchSearches();
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      appBar: AppAppBarV2(
        title: AppLocalizations.of(context)!.search,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSpacing.mdVertical),
            TextField(
              controller: searchTextController,
              decoration: InputDecoration(
                hintText: 'Search services or providers',
                prefixIcon: const Icon(Icons.search),
                fillColor: AppColorsV2.inputBackground,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (value) => _performSearch(value),
            ),
            SizedBox(height: AppSpacing.mdVertical),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.recents,
                  style: AppTextStyles.bodyMediumSecondary,
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Get.to(() => AdvancedSearchScreenV2(
                          initialKeyword: searchTextController.text.trim().isEmpty
                              ? null
                              : searchTextController.text.trim(),
                        ));
                      },
                      icon: Icon(
                        Icons.tune,
                        size: 16.sp,
                        color: AppColorsV2.primary,
                      ),
                      label: Text(
                        'Advanced',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColorsV2.primary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: controller.clearAll,
                      child: Text(AppLocalizations.of(context)!.clearAll),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: Obx(() {
                if (controller.searches.isEmpty) {
                  return Center(
                    child: Text(
                      AppLocalizations.of(context)!.noServicesFound,
                      style: AppTextStyles.bodyMediumSecondary,
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColorsV2.primary,
                  onRefresh: controller.fetchSearches,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: controller.searches.length,
                    itemBuilder: (_, index) {
                      final item = controller.searches[index];
                      return ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(item.keyword),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => controller.deleteSearch(item.id!),
                        ),
                        onTap: () => _performSearch(item.keyword),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performSearch(String keyword) async {
    if (keyword.trim().isEmpty) return;
    ProviderController providerController;
    if (Get.isRegistered<ProviderController>()) {
      providerController = Get.find<ProviderController>();
    } else {
      providerController = Get.put(ProviderController());
    }
    await providerController.searchProviders(keyword: keyword);
    await controller.addSearch(keyword);
    await controller.fetchSearches();

    Get.to(
      () => ProvidersListScreenV2(
        title: keyword,
        providers: providerController.providersList.toList(),
      ),
    );
  }
}

class ProvidersListScreenV2 extends StatelessWidget {
  final String title;
  final List<ProvidersListModelClass> providers;

  const ProvidersListScreenV2({
    super.key,
    required this.title,
    required this.providers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      appBar: AppAppBarV2(
        title: title,
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPaddingHorizontal,
          vertical: AppSpacing.mdVertical,
        ),
        itemCount: providers.length,
        itemBuilder: (_, index) {
          final provider = providers[index];
          final servicesString = (provider.services ?? [])
              .map((s) => s.name ?? '')
              .where((name) => name.isNotEmpty)
              .join(', ');
          return RecommendationCardV2(
            title: provider.name ?? '',
            subtitle: servicesString.isNotEmpty
                ? servicesString.split(',').first
                : AppLocalizations.of(context)!.services,
            imageUrl: provider.avatar ?? blankProfileImage,
            rating:
                double.tryParse(provider.averageRating?.toString() ?? '0') ?? 0,
            location: provider.bio ?? '',
            onTap: () {
              Get.to(
                () => ProviderDetailsScreenV2(id: provider.id.toString()),
              );
            },
          );
        },
      ),
    );
  }
}

