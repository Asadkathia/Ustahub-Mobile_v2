import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/quote/controller/quote_controller.dart';
import 'package:ustahub/app/modules/quote/model/quote_model.dart';
import 'package:ustahub/app/ui_v2/ui_v2_exports.dart';

class QuoteComparisonScreenV2 extends StatelessWidget {
  final String quoteRequestId;

  const QuoteComparisonScreenV2({
    super.key,
    required this.quoteRequestId,
  });

  @override
  Widget build(BuildContext context) {
    final quoteController = Get.find<QuoteController>();
    quoteController.getQuoteResponses(quoteRequestId);

    return Scaffold(
      backgroundColor: AppColorsV2.background,
      appBar: const AppAppBarV2(
        title: 'Compare Quotes',
      ),
      body: Obx(() {
        if (quoteController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (quoteController.quoteResponses.isEmpty) {
          return Center(
            child: StatusToastV2(
              message: 'No quotes received yet',
              type: StatusToastType.info,
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
          children: [
            ...quoteController.quoteResponses.map(
              (response) => _QuoteResponseCard(
                response: response,
                onAccept: () => quoteController.acceptQuoteResponse(
                  response.id!,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _QuoteResponseCard extends StatelessWidget {
  final QuoteResponseModel response;
  final VoidCallback onAccept;

  const _QuoteResponseCard({
    required this.response,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final provider = response.provider;
    final providerStats = response.providerStats;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.mdVertical),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColorsV2.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: response.isAccepted
            ? Border.all(color: AppColorsV2.primary, width: 2)
            : Border.all(color: AppColorsV2.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  provider?['avatar']?.toString() ?? blankProfileImage,
                ),
                radius: 24.r,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider?['name']?.toString() ?? 'Provider',
                      style: AppTextStyles.heading4,
                    ),
                    if (providerStats != null) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14.sp, color: Colors.amber),
                          SizedBox(width: 4.w),
                          Text(
                            '${(providerStats['average_rating'] as num?)?.toStringAsFixed(1) ?? '0.0'} (${providerStats['total_ratings'] ?? 0})',
                            style: AppTextStyles.captionSmall,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (response.isAccepted)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColorsV2.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                  ),
                  child: Text(
                    'Accepted',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColorsV2.textOnPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.mdVertical),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColorsV2.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '\$${response.price.toStringAsFixed(2)}',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColorsV2.primary,
                    ),
                  ),
                ],
              ),
              if (response.estimatedDuration != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Duration',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColorsV2.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      response.estimatedDuration!,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
            ],
          ),
          if (response.description != null &&
              response.description!.isNotEmpty) ...[
            SizedBox(height: AppSpacing.mdVertical),
            Text(
              response.description!,
              style: AppTextStyles.bodySmall,
            ),
          ],
          if (!response.isAccepted) ...[
            SizedBox(height: AppSpacing.mdVertical),
            PrimaryButtonV2(
              text: 'Accept Quote',
              onPressed: onAccept,
            ),
          ],
        ],
      ),
    );
  }
}

