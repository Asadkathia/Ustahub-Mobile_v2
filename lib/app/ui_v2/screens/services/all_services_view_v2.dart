import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/providers_list/view/providers_list_view.dart';
import 'package:ustahub/app/modules/consumer_homepage/controller/consumer_homepage_controller.dart';
import '../../components/navigation/app_app_bar_v2.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/typography/app_text_styles.dart';
import '../../design_system/spacing/app_spacing.dart';
import '../../utils/service_icon_helper.dart';

class AllServicesViewV2 extends StatefulWidget {
  final List services;
  const AllServicesViewV2({super.key, required this.services});

  @override
  State<AllServicesViewV2> createState() => _AllServicesViewV2State();
}

class _AllServicesViewV2State extends State<AllServicesViewV2> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ServicesModelClass> get _filteredServices {
    if (_searchQuery.isEmpty) {
      return widget.services.cast<ServicesModelClass>();
    }
    return widget.services
        .cast<ServicesModelClass>()
        .where((service) =>
            (service.name ?? '')
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final ConsumerHomepageController controller = Get.find<ConsumerHomepageController>();
    
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      appBar: AppAppBarV2(
        title: "Services we offer",
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPaddingHorizontal,
              vertical: AppSpacing.mdVertical,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: AppColorsV2.shadowMedium,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search services...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColorsV2.textSecondary,
                    size: 24.w,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: AppColorsV2.textSecondary,
                            size: 24.w,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                    borderSide: BorderSide(
                      color: AppColorsV2.borderLight,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                    borderSide: BorderSide(
                      color: AppColorsV2.borderLight,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                    borderSide: BorderSide(
                      color: AppColorsV2.primary,
                      width: 2,
                    ),
                  ),
                ),
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ),
          // Services Grid
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingHorizontal,
              ),
              child: Obx(
                () => controller.servicesController.isLoading.value
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColorsV2.primary,
                        ),
                      )
                    : _filteredServices.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64.w,
                                  color: AppColorsV2.textTertiary,
                                ),
                                SizedBox(height: AppSpacing.mdVertical),
                                Text(
                                  'No services found',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColorsV2.textSecondary,
                                  ),
                                ),
                                SizedBox(height: AppSpacing.xsVertical),
                                Text(
                                  'Try searching with different keywords',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColorsV2.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: AppSpacing.md,
                              mainAxisSpacing: AppSpacing.md,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: _filteredServices.length,
                            itemBuilder: (context, index) {
                              final service = _filteredServices[index];
                              return _buildServiceCard(service, controller);
                            },
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServicesModelClass service, ConsumerHomepageController controller) {
    final config = ServiceIconHelper.getConfig(service.name);
    
    return GestureDetector(
      onTap: () {
        final allProviders = controller.providerController.providersList;
        Get.to(
          () => ProvidersListView(
            providers: allProviders,
            serviceName: service.name ?? '',
            serviceId: service.id.toString(),
          ),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: cardWidth * 0.85,
                height: cardWidth * 0.85,
                decoration: BoxDecoration(
                  color: config.backgroundColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: AppColorsV2.shadowMedium,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  config.icon,
                  color: config.iconColor,
                  size: cardWidth * 0.4,
                ),
              ),
              SizedBox(height: AppSpacing.xsVertical),
              SizedBox(
                width: cardWidth,
                child: Text(
                  service.name ?? '',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 11.sp,
                    height: 1.2,
                    color: AppColorsV2.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

}

