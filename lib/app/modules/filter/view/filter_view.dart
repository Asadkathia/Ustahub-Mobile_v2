import 'package:ustahub/app/export/exports.dart';

// Enum for filter tabs, should be accessible or defined here if not in controller
enum FilterTab { service, rating }

class FilterView extends StatefulWidget {
  const FilterView({super.key});

  @override
  State<FilterView> createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView> {
  FilterTab _selectedFilterTab = FilterTab.service;
  List<String> _allServices = [];
  final List<String> _selectedServices = [];
  String _selectedRating = '';

  late final FilterController _filterController;
  late final ProviderServiceSelectionController _providerServiceController;

  @override
  void initState() {
    super.initState();
    _filterController = Get.put(FilterController());
    _providerServiceController = Get.put(ProviderServiceSelectionController());
    // Listen for service updates
    ever<List<ServicesModelClass>>(
      _providerServiceController.serviceCategories,
      (services) {
        setState(() {
          _allServices =
              services
                  .map((e) => e.name ?? '')
                  .where((e) => e.isNotEmpty)
                  .toList();
        });
      },
    );
    // Initial population
    final initial = _providerServiceController.serviceCategories;
    if (initial.isNotEmpty) {
      _allServices =
          initial.map((e) => e.name ?? '').where((e) => e.isNotEmpty).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Filter', onBackTap: () => Get.back()),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side filter options (Service, Rating, Price)
                SizedBox(
                  width: 120.w,
                  child: Column(
                    children: [
                      _buildFilterOption(
                        title: 'Service',
                        isSelected: _selectedFilterTab == FilterTab.service,
                        onTap: () => _updateSelectedTab(FilterTab.service),
                      ),
                      _buildFilterOption(
                        title: 'Rating',
                        isSelected: _selectedFilterTab == FilterTab.rating,
                        onTap: () => _updateSelectedTab(FilterTab.rating),
                      ),
                    ],
                  ),
                ),
                // Right side content based on selected filter
                Expanded(child: _buildContentBasedOnTab()),
              ],
            ),
          ),
          // Apply Button
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                // Apply filter logic using the controller
                _filterController.selectedServices.value = _selectedServices;
                _filterController.selectedRating.value = _selectedRating;
                _filterController.applyFilters();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Apply',
                style: AppTheme.whiteText.copyWith(fontSize: 16.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to update the selected tab and trigger a rebuild
  void _updateSelectedTab(FilterTab tab) {
    setState(() {
      _selectedFilterTab = tab;
    });
  }

  // Widget to build the content based on the selected filter tab
  Widget _buildContentBasedOnTab() {
    switch (_selectedFilterTab) {
      case FilterTab.service:
        return _buildServiceFilter();
      case FilterTab.rating:
        return _buildRatingFilter();
    }
  }

  // Widget for building filter options on the left side
  Widget _buildFilterOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    BorderRadius? customRadius;
    if (!isSelected) {
      if (_selectedFilterTab == FilterTab.rating) {
        customRadius = BorderRadius.only(
          topRight: Radius.circular(14.r),
          bottomRight: Radius.circular(14.r),
        );
      } else if (_selectedFilterTab == FilterTab.service) {
        if (title == 'Rating') {
          customRadius = BorderRadius.only(
            topRight: Radius.circular(14.r),
            bottomRight: Radius.circular(14.r),
          );
        }
      }
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.white : AppColors.green.withOpacity(0.2),
          border: Border(
            right: BorderSide(
              color:
                  isSelected
                      ? AppColors.white
                      : AppColors.green.withOpacity(0.2),
              width: 2.w,
            ),
          ),
          borderRadius: isSelected ? null : customRadius,
        ),
        child: Text(
          title,
          style: AppTheme.blackText.copyWith(
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Widget for the Service filter
  Widget _buildServiceFilter() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All service',
            style: AppTheme.blackText.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: ListView.builder(
              itemCount: _allServices.length,
              itemBuilder: (context, index) {
                final service = _allServices[index];
                return CheckboxListTile(
                  title: Text(
                    service,
                    style: AppTheme.blackText.copyWith(fontSize: 14.sp),
                  ),
                  value: _selectedServices.contains(service),
                  activeColor: AppColors.green,
                  onChanged: (bool? value) {
                    if (value != null) {
                      setState(() {
                        if (_selectedServices.contains(service)) {
                          _selectedServices.remove(service);
                        } else {
                          _selectedServices.add(service);
                        }
                      });
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget for the Rating filter
  Widget _buildRatingFilter() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select below Rating',
            style: AppTheme.blackText.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h),
          Column(
            children: [
              RadioListTile<String>(
                title: Text(
                  'Lowest to High Rating',
                  style: AppTheme.blackText.copyWith(fontSize: 14.sp),
                ),
                value: 'lowest_to_high',
                groupValue: _selectedRating,
                activeColor: AppColors.green,
                onChanged: (value) {
                  setState(() {
                    _selectedRating = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: Text(
                  'Highest to Low Rating',
                  style: AppTheme.blackText.copyWith(fontSize: 14.sp),
                ),
                value: 'highest_to_low',
                groupValue: _selectedRating,
                activeColor: AppColors.green,
                onChanged: (value) {
                  setState(() {
                    _selectedRating = value!;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
