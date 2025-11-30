import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/quote/controller/quote_controller.dart';
import 'package:ustahub/app/modules/quote/model/quote_model.dart';
import 'package:ustahub/app/ui_v2/ui_v2_exports.dart';
import 'package:intl/intl.dart';
import 'quote_comparison_screen_v2.dart';

class QuoteRequestsListScreenV2 extends StatelessWidget {
  const QuoteRequestsListScreenV2({super.key});

  @override
  Widget build(BuildContext context) {
    final quoteController = Get.put(QuoteController());
    quoteController.getQuoteRequests();

    return Scaffold(
      backgroundColor: AppColorsV2.background,
      appBar: AppAppBarV2(
        title: 'My Quote Requests',
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColorsV2.primary),
            onPressed: () {
              // Navigate to create quote request
              // This will need service selection first
              CustomToast.info('Please select a service first from provider details');
            },
          ),
        ],
      ),
      body: Obx(() {
        if (quoteController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (quoteController.quoteRequests.isEmpty) {
          return Center(
            child: StatusToastV2(
              message: 'No quote requests yet. Create one from a provider\'s details page.',
              type: StatusToastType.info,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => quoteController.getQuoteRequests(),
          color: AppColorsV2.primary,
          child: ListView.builder(
            padding: EdgeInsets.all(AppSpacing.screenPadding),
            itemCount: quoteController.quoteRequests.length,
            itemBuilder: (context, index) {
              final request = quoteController.quoteRequests[index];
              return _QuoteRequestCard(
                request: request,
                onTap: () {
                  // Navigate to quote comparison if responses exist
                  quoteController.getQuoteResponses(request.id);
                  Get.to(() => QuoteComparisonScreenV2(quoteRequestId: request.id));
                },
              );
            },
          ),
        );
      }),
    );
  }
}

class _QuoteRequestCard extends StatelessWidget {
  final QuoteRequestModel request;
  final VoidCallback onTap;

  const _QuoteRequestCard({
    required this.request,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.mdVertical),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColorsV2.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColorsV2.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.service?.name ?? 'Service',
                      style: AppTextStyles.heading4,
                    ),
                    SizedBox(height: AppSpacing.xsVertical),
                    Text(
                      request.address?.addressLine1 ?? 'Address',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColorsV2.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: request.status),
            ],
          ),
          if (request.description != null && request.description!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.smVertical),
              child: Text(
                request.description!,
                style: AppTextStyles.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          SizedBox(height: AppSpacing.smVertical),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Created: ${DateFormat('MMM dd, yyyy').format(request.createdAt)}',
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColorsV2.textTertiary,
                ),
              ),
              if (request.status == 'responded')
                TextButton(
                  onPressed: onTap,
                  child: Text(
                    'View Quotes',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColorsV2.primary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = AppColorsV2.warning;
        break;
      case 'responded':
        color = AppColorsV2.success;
        break;
      case 'expired':
        color = AppColorsV2.error;
        break;
      case 'cancelled':
        color = AppColorsV2.textTertiary;
        break;
      default:
        color = AppColorsV2.textSecondary;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTextStyles.captionSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

