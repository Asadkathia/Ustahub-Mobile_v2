import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/common_model_class/ProviderListModelClass.dart';
import 'package:ustahub/app/modules/common_controller.dart/provider_controller.dart';
import 'package:ustahub/app/ui_v2/ui_v2_exports.dart';
import '../provider/provider_details_screen_v2.dart';
import '../../components/cards/recommendation_card_v2.dart';

class AdvancedSearchScreenV2 extends StatefulWidget {
  final String? initialKeyword;
  
  const AdvancedSearchScreenV2({
    super.key,
    this.initialKeyword,
  });

  @override
  State<AdvancedSearchScreenV2> createState() => _AdvancedSearchScreenV2State();
}

class _AdvancedSearchScreenV2State extends State<AdvancedSearchScreenV2> {
  final TextEditingController _searchController = TextEditingController();
  ProviderController get _providerController {
    Get.lazyPut(() => ProviderController());
    return Get.find<ProviderController>();
  }
  
  // Filter state
  double _minRating = 0.0;
  String? _selectedServiceId;
  String _sortBy = 'rating'; // 'rating', 'reviews'
  bool _verifiedOnly = false;
  
  // Services list for filter
  List<dynamic> _services = [];
  bool _loadingServices = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialKeyword != null) {
      _searchController.text = widget.initialKeyword!;
    }
    _loadServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    setState(() => _loadingServices = true);
    try {
      final api = SupabaseApiServices();
      final response = await api.getServices();
      if (response['statusCode'] == 200 && response['body']['data'] != null) {
        setState(() {
          _services = response['body']['data'] as List;
        });
      }
    } catch (e) {
      debugPrint('[ADVANCED_SEARCH] Error loading services: $e');
    } finally {
      setState(() => _loadingServices = false);
    }
  }

  Future<void> _performSearch() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty && _selectedServiceId == null && _minRating == 0.0) {
      CustomToast.info('Please enter a search term or apply filters');
      return;
    }

    _providerController.isLoading.value = true;
    try {
      // Use existing searchProviders method with keyword
      if (keyword.isNotEmpty) {
        await _providerController.searchProviders(keyword: keyword);
      } else {
        // If no keyword, use getProvider with service filter
        await _providerController.getProvider(serviceId: _selectedServiceId);
      }
      
      // Apply client-side filters
      _applyClientSideFilters();
      
      // Navigate to results
      Get.to(
        () => _AdvancedSearchResultsScreen(
          providers: _providerController.providersList.toList(),
          searchTerm: keyword,
        ),
      );
    } catch (e) {
      CustomToast.error('Search failed: $e');
    } finally {
      _providerController.isLoading.value = false;
    }
  }

  void _applyClientSideFilters() {
    var filtered = _providerController.providersList.toList();
    
    // Filter by rating
    if (_minRating > 0) {
      filtered = filtered.where((p) {
        final rating = double.tryParse(p.averageRating?.toString() ?? '0') ?? 0.0;
        return rating >= _minRating;
      }).toList();
    }
    
    // Filter by verified (if available in model)
    if (_verifiedOnly) {
      // Note: This would need to be added to ProvidersListModelClass
      // For now, we'll skip this filter
    }
    
    // Sort
    if (_sortBy == 'rating') {
      filtered.sort((a, b) {
        final ratingA = double.tryParse(a.averageRating?.toString() ?? '0') ?? 0.0;
        final ratingB = double.tryParse(b.averageRating?.toString() ?? '0') ?? 0.0;
        return ratingB.compareTo(ratingA);
      });
    } else if (_sortBy == 'reviews') {
      filtered.sort((a, b) {
        final reviewsA = a.totalRatings ?? 0;
        final reviewsB = b.totalRatings ?? 0;
        return reviewsB.compareTo(reviewsA);
      });
    }
    
    _providerController.providersList.value = filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      appBar: AppAppBarV2(
        title: 'Advanced Search',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSpacing.mdVertical),
            
            // Search Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search providers or services',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                fillColor: AppColorsV2.inputBackground,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _performSearch(),
            ),
            
            SizedBox(height: AppSpacing.lgVertical),
            
            // Filters Section
            Text(
              'Filters',
              style: AppTextStyles.heading3,
            ),
            SizedBox(height: AppSpacing.mdVertical),
            
            // Rating Filter
            _buildRatingFilter(),
            SizedBox(height: AppSpacing.mdVertical),
            
            // Service Filter
            _buildServiceFilter(),
            SizedBox(height: AppSpacing.mdVertical),
            
            // Sort Options
            _buildSortOptions(),
            SizedBox(height: AppSpacing.mdVertical),
            
            // Verified Only Toggle
            _buildVerifiedToggle(),
            SizedBox(height: AppSpacing.xlVertical),
            
            // Search Button
            PrimaryButtonV2(
              text: 'Search',
              onPressed: _performSearch,
              isLoading: _providerController.isLoading.value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Minimum Rating',
              style: AppTextStyles.bodyMedium,
            ),
            Text(
              _minRating.toStringAsFixed(1),
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColorsV2.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.smVertical),
        Slider(
          value: _minRating,
          min: 0.0,
          max: 5.0,
          divisions: 10,
          label: _minRating.toStringAsFixed(1),
          activeColor: AppColorsV2.primary,
          onChanged: (value) {
            setState(() {
              _minRating = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildServiceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Category',
          style: AppTextStyles.bodyMedium,
        ),
        SizedBox(height: AppSpacing.smVertical),
        _loadingServices
            ? const Center(child: CircularProgressIndicator())
            : DropdownButtonFormField<String>(
                value: _selectedServiceId,
                decoration: InputDecoration(
                  fillColor: AppColorsV2.inputBackground,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                    borderSide: BorderSide.none,
                  ),
                ),
                hint: const Text('All Services'),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Services'),
                  ),
                  ..._services.map((service) {
                    return DropdownMenuItem<String>(
                      value: service['id']?.toString(),
                      child: Text(service['name'] ?? 'Unknown'),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedServiceId = value;
                  });
                },
              ),
      ],
    );
  }

  Widget _buildSortOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: AppTextStyles.bodyMedium,
        ),
        SizedBox(height: AppSpacing.smVertical),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'rating',
              label: Text('Rating'),
            ),
            ButtonSegment(
              value: 'reviews',
              label: Text('Reviews'),
            ),
          ],
          selected: {_sortBy},
          onSelectionChanged: (Set<String> newSelection) {
            setState(() {
              _sortBy = newSelection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildVerifiedToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Verified Providers Only',
          style: AppTextStyles.bodyMedium,
        ),
        Switch(
          value: _verifiedOnly,
          activeColor: AppColorsV2.primary,
          onChanged: (value) {
            setState(() {
              _verifiedOnly = value;
            });
          },
        ),
      ],
    );
  }
}

class _AdvancedSearchResultsScreen extends StatelessWidget {
  final List<ProvidersListModelClass> providers;
  final String searchTerm;

  const _AdvancedSearchResultsScreen({
    required this.providers,
    required this.searchTerm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      appBar: AppAppBarV2(
        title: searchTerm.isNotEmpty ? 'Search Results' : 'Filtered Results',
      ),
      body: providers.isEmpty
          ? Center(
              child: StatusToastV2(
                message: 'No providers found',
                type: StatusToastType.info,
              ),
            )
          : ListView.builder(
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
            ),
    );
  }
}
