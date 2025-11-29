import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/favourite_providers/controller/favourite_provider_controller.dart';
import '../../../components/cards/recommendation_card_v2.dart';
import '../../../components/feedback/status_toast_v2.dart';
import '../../../components/navigation/app_app_bar_v2.dart';
import '../../../design_system/colors/app_colors_v2.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../config/ui_config.dart';
import '../provider/provider_details_screen_v2.dart';

class FavouriteProvidersScreenV2 extends StatefulWidget {
  const FavouriteProvidersScreenV2({super.key});

  @override
  State<FavouriteProvidersScreenV2> createState() =>
      _FavouriteProvidersScreenV2State();
}

class _FavouriteProvidersScreenV2State
    extends State<FavouriteProvidersScreenV2> {
  final FavouriteProviderController controller =
      Get.put(FavouriteProviderController());

  @override
  void initState() {
    super.initState();
    _fetchFavourites();
  }

  Future<void> _fetchFavourites() async {
    await controller.getFavouriteProviders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      appBar: AppAppBarV2(
        title: AppLocalizations.of(context)!.favouriteProviders,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.favouriteProvidersList.isEmpty) {
          return Center(
            child: StatusToastV2(
              message: AppLocalizations.of(context)!.noServicesFound,
              type: StatusToastType.info,
            ),
          );
        }

        return RefreshIndicator(
          color: AppColorsV2.primary,
          onRefresh: _fetchFavourites,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPaddingHorizontal,
              vertical: AppSpacing.mdVertical,
            ),
            itemCount: controller.favouriteProvidersList.length,
            itemBuilder: (context, index) {
              final data = controller.favouriteProvidersList[index];
              final servicesString = (data.services ?? [])
                  .map((s) => s.name ?? '')
                  .where((name) => name.isNotEmpty)
                  .join(', ');

              return RecommendationCardV2(
                title: data.name ?? '',
                subtitle: servicesString,
                imageUrl: data.avatar ?? blankProfileImage,
                badgeText: AppLocalizations.of(context)!.favouriteProviders,
                rating: double.tryParse(data.averageRating?.toString() ?? '0') ?? 0,
                location: data.bio ?? '',
                onTap: () {
                  // Always use V2 provider details screen for consumer flow
                  Get.to(() => ProviderDetailsScreenV2(id: data.id.toString()));
                },
              );
            },
          ),
        );
      }),
    );
  }
}

