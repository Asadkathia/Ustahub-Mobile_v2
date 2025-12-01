import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/booking_summary/controller/booking_summary_controller.dart';
import 'package:ustahub/app/modules/provider_details/controller/provider_details_controller.dart';
import 'package:ustahub/app/modules/provider_details/controller/plan_selection_controller.dart';
import 'package:ustahub/app/ui_v2/ui_v2_exports.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ustahub/utils/contstants/constants.dart';
import 'package:ustahub/app/ui_v2/components/cards/app_card.dart';
import 'package:ustahub/app/ui_v2/components/feedback/skeleton_loader_v2.dart';

class BookingSummaryScreenV2 extends StatelessWidget {
  final String providerId,
      serviceId,
      serviceName,
      addressId,
      bookingDate,
      bookingTime,
      fullAddress,
      note;

  late final ProviderDetailsController providerController;
  final BookingSummaryController bookingController = Get.put(
    BookingSummaryController(),
  );
  late final PlanSelectionController plansController;

  BookingSummaryScreenV2({
    super.key,
    required this.addressId,
    required this.bookingDate,
    required this.bookingTime,
    required this.providerId,
    required this.serviceId,
    required this.serviceName,
    required this.fullAddress,
    required this.note,
  }) {
    // Initialize provider controller safely
    try {
      providerController = Get.find<ProviderDetailsController>();
    } catch (e) {
      // If controller doesn't exist, create it
      providerController = Get.put(ProviderDetailsController());
    }
    // Get plan selection controller
    try {
      plansController = Get.find<PlanSelectionController>();
    } catch (e) {
      plansController = Get.put(PlanSelectionController(), permanent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safely get services string with null checks
    final servicesString = (providerController.providerDetails.value?.provider?.services ?? [])
        .map((s) => s.name ?? '')
        .where((name) => name.isNotEmpty)
        .join(', ');

    final providerName = providerController.providerDetails.value?.provider?.name ?? '';
    final providerImage = providerController.providerDetails.value?.provider?.avatar ?? blankProfileImage;
    final averageRating = double.tryParse(
      providerController.providerDetails.value?.provider?.averageRating ?? '0',
    ) ?? 0.0;

    return Scaffold(
      backgroundColor: AppColorsV2.background,
      appBar: AppAppBarV2(
        title: AppLocalizations.of(context)!.bookingSummary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSpacing.mdVertical),
            // Provider Card
            _buildProviderCard(
              name: providerName,
              imageUrl: providerImage,
              category: servicesString,
              rating: averageRating,
            ),
            SizedBox(height: AppSpacing.lgVertical),
            // Address and Booking Details Card
            _buildBookingDetailsCard(
              address: fullAddress,
              dateTime: "$bookingDate - ${convertTo12HourFormat(bookingTime)}",
              serviceName: serviceName,
            ),
            SizedBox(height: AppSpacing.lgVertical),
            // Price Breakdown Card
            Obx(() => _buildPriceBreakdownCard()),
            SizedBox(height: AppSpacing.xlVertical * 2), // Space for bottom button
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
        decoration: BoxDecoration(
          color: AppColorsV2.background,
          boxShadow: [
            BoxShadow(
              color: AppColorsV2.shadowLight,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Obx(
          () => PrimaryButtonV2(
            text: bookingController.isLoading.value
                ? "Processing..."
                : AppLocalizations.of(context)!.conti,
            onPressed: bookingController.isLoading.value
                ? null
                : () async {
                    // Ensure a plan is selected before proceeding
                    final selectedPlan = plansController.selectedPlan.value;
                    if (selectedPlan == null) {
                      CustomToast.error('Please select a plan before continuing');
                      return;
                    }

                    final planId = selectedPlan.id;

                    // Safely handle visiting charge
                    final double safeVisitCharge =
                        (visitingCharge as num?)?.toDouble() ?? 0.0;

                    final bookingData = {
                      "booking_id":
                          "BOOK-${DateTime.now().millisecondsSinceEpoch}",
                      "provider_id": providerId,
                      "service_id": serviceId,
                      "plan_id": planId,
                      "address_id": addressId,
                      "booking_date": bookingDate,
                      "booking_time": bookingTime,
                      "visiting_charge": safeVisitCharge,
                      "note": note,
                      "provider_name": providerName,
                      "service_name": serviceName,
                      "service_fee": 0,
                      "total": 0,
                      "item_total": 0,
                    };
                    await bookingController.bookService(
                      bookingData: bookingData,
                    );
                  },
            isLoading: bookingController.isLoading.value,
          ),
        ),
      ),
    );
  }

  Widget _buildProviderCard({
    required String name,
    required String imageUrl,
    required String category,
    required double rating,
  }) {
    return AppCard(
      enableShadow: true,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 80.w,
              height: 80.h,
              fit: BoxFit.cover,
              placeholder: (context, url) => SkeletonLoaderV2(
                width: 80.w,
                height: 80.h,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              errorWidget: (context, url, error) => Container(
                width: 80.w,
                height: 80.h,
                color: AppColorsV2.surface,
                child: Icon(
                  Icons.person,
                  color: AppColorsV2.textTertiary,
                  size: AppSpacing.iconXLarge,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.heading3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xsVertical),
                Text(
                  category,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColorsV2.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xsVertical),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      rating.toStringAsFixed(1),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailsCard({
    required String address,
    required String dateTime,
    required String serviceName,
  }) {
    return AppCard(
      enableShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.home_outlined,
            title: "Address",
            subtitle: address,
          ),
          SizedBox(height: AppSpacing.mdVertical),
          if (serviceName.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.miscellaneous_services,
              title: "Service",
              subtitle: serviceName,
            ),
            SizedBox(height: AppSpacing.mdVertical),
          ],
          _buildInfoRow(
            icon: Icons.access_time,
            title: "Date & Time",
            subtitle: dateTime,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String subtitle,
    String? title,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColorsV2.primaryLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          ),
          child: Icon(
            icon,
            color: AppColorsV2.primary,
            size: AppSpacing.iconMedium,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColorsV2.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
              ],
              Text(
                subtitle,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceBreakdownCard() {
    // Get selected plan
    final selectedPlan = plansController.selectedPlan.value;

    // If no plan is selected yet, show a friendly message instead of calculating
    if (selectedPlan == null) {
      return AppCard(
        enableShadow: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColorsV2.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: AppColorsV2.primary,
                    size: AppSpacing.iconMedium,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Text(
                  'Price Breakdown',
                  style: AppTextStyles.heading3,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.mdVertical),
            Text(
              'Select a plan to see the full price breakdown.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColorsV2.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final planPrice =
        double.tryParse(selectedPlan.planPrice ?? '0') ?? 0.0;

    // Safely handle visiting charge in case of configuration issues
    final double visitFee =
        (visitingCharge as num?)?.toDouble() ?? 0.0;

    final itemTotal = planPrice + visitFee;
    final serviceFee = itemTotal * 0.05;
    final totalAmount = itemTotal + serviceFee;

    return AppCard(
      enableShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColorsV2.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: AppColorsV2.primary,
                  size: AppSpacing.iconMedium,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Text(
                'Price Breakdown',
                style: AppTextStyles.heading3,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.mdVertical),
          _buildPriceRow('Service Price', planPrice),
          SizedBox(height: AppSpacing.smVertical),
          _buildPriceRow('Visit Fee', visitFee),
          SizedBox(height: AppSpacing.smVertical),
          _buildPriceRow('Service Fee (5%)', serviceFee),
          SizedBox(height: AppSpacing.mdVertical),
          Divider(color: AppColorsV2.borderLight),
          SizedBox(height: AppSpacing.smVertical),
          _buildPriceRow('Total Amount', totalAmount, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.heading4
              : AppTextStyles.bodyMedium.copyWith(
                  color: AppColorsV2.textSecondary,
                ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: isTotal
              ? AppTextStyles.heading4.copyWith(
                  color: AppColorsV2.primary,
                  fontWeight: FontWeight.bold,
                )
              : AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
        ),
      ],
    );
  }
}

