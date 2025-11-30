import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/provider_portfolio/controller/portfolio_controller.dart';
import 'package:ustahub/app/modules/provider_portfolio/model/portfolio_model.dart';
import 'package:ustahub/app/ui_v2/components/cards/portfolio_card_v2.dart';
import 'package:ustahub/app/ui_v2/ui_v2_exports.dart';

class PortfolioGalleryScreenV2 extends StatelessWidget {
  final String providerId;
  final String? serviceId;

  const PortfolioGalleryScreenV2({
    super.key,
    required this.providerId,
    this.serviceId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PortfolioController());
    controller.initialize(providerId, serviceId: serviceId);

    return Scaffold(
      backgroundColor: AppColorsV2.background,
      appBar: const AppAppBarV2(
        title: 'Portfolio Gallery',
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.isError.value) {
          return Center(
            child: StatusToastV2(
              message: controller.errorMessage.value,
              type: StatusToastType.error,
            ),
          );
        }

        if (controller.portfolios.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: AppSpacing.iconXLarge * 2,
                  color: AppColorsV2.textTertiary,
                ),
                SizedBox(height: AppSpacing.mdVertical),
                Text(
                  'No portfolios yet',
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColorsV2.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.xsVertical),
                Text(
                  'Portfolio items will appear here',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColorsV2.textTertiary,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshPortfolios,
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPaddingHorizontal,
              vertical: AppSpacing.mdVertical,
            ),
            children: [
              // Featured portfolios section
              if (controller.featuredPortfolios.isNotEmpty) ...[
                Text(
                  'Featured',
                  style: AppTextStyles.heading3,
                ),
                SizedBox(height: AppSpacing.smVertical),
                ...controller.featuredPortfolios.map(
                  (portfolio) => PortfolioCardV2(
                    portfolio: portfolio,
                    onTap: () {
                      // Navigate to portfolio detail view
                      // TODO: Implement portfolio detail screen
                    },
                  ),
                ),
                SizedBox(height: AppSpacing.lgVertical),
              ],
              // All portfolios section
              Text(
                'All Work',
                style: AppTextStyles.heading3,
              ),
              SizedBox(height: AppSpacing.smVertical),
              ...controller.portfolios.map(
                (portfolio) => PortfolioCardV2(
                  portfolio: portfolio,
                  onTap: () {
                    // Navigate to portfolio detail view
                    // TODO: Implement portfolio detail screen
                  },
                ),
              ),
              SizedBox(height: AppSpacing.xlVertical),
            ],
          ),
        );
      }),
    );
  }
}

