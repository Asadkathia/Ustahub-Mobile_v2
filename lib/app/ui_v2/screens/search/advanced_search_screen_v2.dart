import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/common_controller.dart/provider_controller.dart';
import 'package:ustahub/app/modules/common_model_class/ProviderListModelClass.dart';
import 'package:ustahub/app/ui_v2/components/filters/price_range_filter_v2.dart';
import 'package:ustahub/app/ui_v2/components/filters/rating_filter_v2.dart';
import 'package:ustahub/app/ui_v2/components/filters/sort_options_v2.dart';
import 'package:ustahub/app/ui_v2/components/cards/recommendation_card_v2.dart';
import 'package:ustahub/app/ui_v2/ui_v2_exports.dart';
import '../provider/provider_details_screen_v2.dart';

class AdvancedSearchScreenV2 extends StatefulWidget {
  final String? initialKeyword;
  final String? serviceId;

  const AdvancedSearchScreenV2({
    super.key,
    this.initialKeyword,
    this.serviceId,
  });

  @override
  State<AdvancedSearchScreenV2> createState() => _AdvancedSearchScreenV2State();
}

class _AdvancedSearchScreenV2State extends State<AdvancedSearchScreenV2> {
  final ProviderController providerController = Get.put(ProviderController());
  final TextEditingController searchController = TextEditingController();
  final RxBool showFilters = false.obs;

  // Filter state
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 10000.0.obs;
  final RxDouble minRating = 0.0.obs;
  final RxString sortBy = 'rating'.obs;
  final RxBool verifiedOnly = false.obs;
  final RxBool availableToday = false.obs;

  @override
  void initState() {
    super.initState();
    if (widget.initialKeyword != null) {
      searchController.text = widget.initialKeyword!;
      _performSearch();
    }
  }

  Future<void> _performSearch() async {
    await providerController.advancedSearchProviders(
      keyword: searchController.text.trim().isEmpty
          ? null
          : searchController.text.trim(),
      serviceId: widget.serviceId,
      minPrice: minPrice.value > 0 ? minPrice.value : null,
      maxPrice: maxPrice.value < 10000 ? maxPrice.value : null,
      minRating: minRating.value > 0 ? minRating.value : null,
      sortBy: sortBy.value,
      verifiedOnly: verifiedOnly.value ? true : null,
      availableToday: availableToday.value ? true : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      appBar: AppAppBarV2(
        title: 'Search Providers',
        actions: [
          IconButton(
            icon: Obx(() => Icon(
              showFilters.value ? Icons.filter_list : Icons.filter_list_outlined,
              color: showFilters.value
                  ? AppColorsV2.primary
                  : AppColorsV2.textSecondary,
            )),
            onPressed: () => showFilters.value = !showFilters.value,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search providers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    _performSearch();
                  },
                ),
                fillColor: AppColorsV2.inputBackground,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          Obx(() {
            if (!showFilters.value) return const SizedBox.shrink();

            return Container(
              padding: EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
              color: AppColorsV2.surface,
              child: Column(
                children: [
                  PriceRangeFilterV2(
                    minPrice: 0.0,
                    maxPrice: 10000.0,
                    currentMin: minPrice.value,
                    currentMax: maxPrice.value,
                    onChanged: (values) {
                      minPrice.value = values.start;
                      maxPrice.value = values.end;
                      _performSearch();
                    },
                  ),
                  SizedBox(height: AppSpacing.mdVertical),
                  RatingFilterV2(
                    minRating: minRating.value,
                    onChanged: (value) {
                      minRating.value = value;
                      _performSearch();
                    },
                  ),
                  SizedBox(height: AppSpacing.mdVertical),
                  SortOptionsV2(
                    selectedSort: sortBy.value,
                    onChanged: (value) {
                      sortBy.value = value;
                      _performSearch();
                    },
                  ),
                  SizedBox(height: AppSpacing.mdVertical),
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: Text(
                            'Verified Only',
                            style: AppTextStyles.bodySmall,
                          ),
                          value: verifiedOnly.value,
                          onChanged: (value) {
                            verifiedOnly.value = value ?? false;
                            _performSearch();
                          },
                          activeColor: AppColorsV2.primary,
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          title: Text(
                            'Available Today',
                            style: AppTextStyles.bodySmall,
                          ),
                          value: availableToday.value,
                          onChanged: (value) {
                            availableToday.value = value ?? false;
                            _performSearch();
                          },
                          activeColor: AppColorsV2.primary,
                        ),
                      ),
                    ],
                  ),
                  SecondaryButtonV2(
                    text: 'Clear Filters',
                    onPressed: () {
                      minPrice.value = 0.0;
                      maxPrice.value = 10000.0;
                      minRating.value = 0.0;
                      sortBy.value = 'rating';
                      verifiedOnly.value = false;
                      availableToday.value = false;
                      _performSearch();
                    },
                  ),
                ],
              ),
            );
          }),
          Expanded(
            child: Obx(() {
              if (providerController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (providerController.providersList.isEmpty) {
                return Center(
                  child: StatusToastV2(
                    message: 'No providers found',
                    type: StatusToastType.info,
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
                itemCount: providerController.providersList.length,
                itemBuilder: (context, index) {
                  final provider = providerController.providersList[index];
                  final servicesString = (provider.services ?? [])
                      .map((s) => s.name ?? '')
                      .where((name) => name.isNotEmpty)
                      .join(', ');

                  return RecommendationCardV2(
                    title: provider.name ?? '',
                    subtitle: servicesString.isNotEmpty
                        ? servicesString.split(',').first
                        : 'Services',
                    imageUrl: provider.avatar ?? blankProfileImage,
                    rating: double.tryParse(
                            provider.averageRating?.toString() ?? '0') ??
                        0,
                    location: provider.bio ?? '',
                    onTap: () {
                      Get.to(
                        () => ProviderDetailsScreenV2(
                          id: provider.id.toString(),
                        ),
                      );
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

