import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/favourite_providers/controller/favourite_provider_controller.dart';
import 'package:ustahub/app/modules/provider_details/model_class/provider_details_model_class.dart';
import 'package:ustahub/app/modules/provider_details/model_class/provider_ratings_model.dart';
import 'package:ustahub/app/modules/provider_document/view/provider_document_view.dart';
import 'package:ustahub/app/ui_v2/ui_v2_exports.dart';
import 'package:ustahub/app/ui_v2/components/feedback/empty_state_v2.dart';
import 'package:ustahub/app/ui_v2/components/feedback/skeleton_loader_v2.dart';

class ProviderDetailsScreenV2 extends StatefulWidget {
  final String id;
  const ProviderDetailsScreenV2({super.key, required this.id});

  @override
  State<ProviderDetailsScreenV2> createState() =>
      _ProviderDetailsScreenV2State();
}

class _ProviderDetailsScreenV2State extends State<ProviderDetailsScreenV2> {
  late final ProviderDetailsController controller;
  final plansController = Get.put(PlanSelectionController(), permanent: true);
  final FavouriteProviderController favouriteController =
      Get.put(FavouriteProviderController());

  @override
  void initState() {
    super.initState();
    final tag = 'provider_v2_${widget.id}';
    if (Get.isRegistered<ProviderDetailsController>(tag: tag)) {
      controller = Get.find<ProviderDetailsController>(tag: tag);
      controller.providerDetails.value = null;
    } else {
      controller = Get.put(ProviderDetailsController(), tag: tag);
    }
    controller.getProviderById(widget.id);
  }

  @override
  void dispose() {
    final tag = 'provider_v2_${widget.id}';
    if (Get.isRegistered<ProviderDetailsController>(tag: tag)) {
      Get.delete<ProviderDetailsController>(tag: tag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      appBar: const AppAppBarV2(
        title: 'Provider Details',
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: 5,
            itemBuilder: (_, __) => SkeletonListItemV2(),
          );
        }

        final providerDetails = controller.providerDetails.value;
        if (providerDetails == null) {
          return EmptyStateV2(
            icon: Icons.person_off,
            title: 'Provider unavailable',
            subtitle: 'This provider profile could not be loaded',
            actionLabel: 'Retry',
            onAction: () => controller.getProviderById(widget.id),
          );
        }

        final provider = providerDetails.provider;
        final services = provider?.services ?? [];
        final plans = provider?.plans ?? [];
        plansController.selectInitial(services, plans);

        return Stack(
          children: [
            ListView(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingHorizontal,
                vertical: AppSpacing.mdVertical,
              ),
              children: [
                _ProviderHeader(
                  name: provider?.name ?? '',
                  imageUrl: provider?.avatar ?? blankProfileImage,
                  rating: double.tryParse(provider?.averageRating ?? '0') ?? 0,
                  isFavorite: provider?.isFavorite ?? false,
                  category: services
                      .map((s) => s.name ?? '')
                      .where((name) => name.isNotEmpty)
                      .join(', '),
                  onFavoriteTap: _toggleFavorite,
                ),
                SizedBox(height: AppSpacing.mdVertical),
                _buildTrustSignals(providerDetails),
                SizedBox(height: AppSpacing.mdVertical),
                _buildRatingSummary(context, provider),
                SizedBox(height: AppSpacing.mdVertical),
                Text(
                  AppLocalizations.of(context)!.services,
                  style: AppTextStyles.heading3,
                ),
                SizedBox(height: AppSpacing.smVertical),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: services
                      .map(
                        (service) => ServiceChipV2(
                          label: service.name ?? '',
                          icon: Icons.build,
                          isSelected:
                              plansController.selectedService.value?.id ==
                                  service.id,
                          onTap: () {
                            plansController.selectServiceAndPlan(service, plans);
                          },
                        ),
                      )
                      .toList(),
                ),
                SizedBox(height: AppSpacing.mdVertical),
                if (providerDetails.overview != null)
                  _buildOverviewCard(providerDetails.overview!),
                if (providerDetails.overview != null)
                  SizedBox(height: AppSpacing.mdVertical),
                Text(
                  'About',
                  style: AppTextStyles.heading3,
                ),
                SizedBox(height: AppSpacing.xsVertical),
                Text(
                  provider?.bio?.isNotEmpty == true ? provider!.bio! : 'N/A',
                  style: AppTextStyles.bodyMedium,
                ),
                SizedBox(height: AppSpacing.mdVertical),
                Text(
                  'Ratings',
                  style: AppTextStyles.heading3,
                ),
                SizedBox(height: AppSpacing.smVertical),
                _buildRatingsSection(),
                SizedBox(height: AppSpacing.lgVertical),
                SecondaryButtonV2(
                  text: 'View provider documents',
                  onPressed: () {
                    Get.to(() => ProviderDocumentView());
                  },
                ),
                SizedBox(height: AppSpacing.xlVertical * 3),
              ],
            ),
            Positioned(
              left: AppSpacing.screenPaddingHorizontal,
              right: AppSpacing.screenPaddingHorizontal,
              bottom: AppSpacing.lgVertical,
              child: PrimaryButtonV2(
                text: AppLocalizations.of(context)!.book,
                onPressed: () => _showBookingSheet(context, services),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _toggleFavorite() async {
    final details = controller.providerDetails.value;
    final provider = details?.provider;
    if (provider == null) return;
    controller.providerDetails.value = ProviderDetailsModelClass(
      provider: ProviderModel(
        id: provider.id,
        name: provider.name,
        email: provider.email,
        phone: provider.phone,
        avatar: provider.avatar,
        bio: provider.bio,
        isFavorite: !(provider.isFavorite ?? false),
        isVerified: provider.isVerified,
        businessName: provider.businessName,
        averageRating: provider.averageRating,
        services: provider.services,
        plans: provider.plans,
        addresses: provider.addresses,
      ),
      overview: details?.overview,
    );
    final providerId = provider.id?.toString();
    if (providerId == null || providerId.isEmpty) return;
    await favouriteController.favouriteToggle(id: providerId);
  }

  void _showBookingSheet(BuildContext context, List<Service> services) {
    if (services.isEmpty) {
      CustomToast.error('Please select a service before booking');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXLarge),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          builder: (_, controllerSheet) => CheckoutModalBottomSheet(
            providerId: widget.id,
            serviceId: services.first.id ?? '',
          ),
        );
      },
    );
  }

  Widget _buildTrustSignals(ProviderDetailsModelClass? providerDetails) {
    final provider = providerDetails?.provider;
    final overview = providerDetails?.overview;
    
    // Extract year from registeredSince
    String? memberSinceYear;
    if (overview?.registeredSince != null) {
      // registeredSince is in format like "2 years ago", extract year
      final since = overview!.registeredSince!;
      if (since.contains('year')) {
        final match = RegExp(r'(\d+)').firstMatch(since);
        if (match != null) {
          final yearsAgo = int.parse(match.group(1)!);
          final year = DateTime.now().year - yearsAgo;
          memberSinceYear = year.toString();
        }
      }
    }
    
    final hiredCount = overview?.totalBookings ?? 0;
    final city = overview?.city;
    final isVerified = provider?.isVerified ?? false;
    
    // Only show if we have at least one signal
    if (!isVerified && memberSinceYear == null && hiredCount == 0 && (city == null || city == 'N/A')) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColorsV2.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColorsV2.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trust Signals',
            style: AppTextStyles.heading4,
          ),
          SizedBox(height: AppSpacing.mdVertical),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              if (isVerified)
                _TrustSignalChip(
                  icon: Icons.verified,
                  label: 'Verified',
                  color: AppColorsV2.success,
                ),
              if (memberSinceYear != null)
                _TrustSignalChip(
                  icon: Icons.calendar_today,
                  label: 'Member since $memberSinceYear',
                  color: AppColorsV2.primary,
                ),
              if (hiredCount > 0)
                _TrustSignalChip(
                  icon: Icons.work,
                  label: 'Hired $hiredCount times',
                  color: AppColorsV2.warning,
                ),
              if (city != null && city != 'N/A')
                _TrustSignalChip(
                  icon: Icons.location_on,
                  label: city,
                  color: AppColorsV2.info,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(BuildContext context, ProviderModel? provider) {
    final average = double.tryParse(provider?.averageRating ?? '0') ?? 0;
    final ratingController = controller.ratingsController;
    final totalRatings = ratingController.ratingsCount;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColorsV2.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColorsV2.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColorsV2.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star_rounded,
              color: AppColorsV2.primary,
              size: AppSpacing.iconLarge,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer rating',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColorsV2.textSecondary,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Text(
                    average.toStringAsFixed(1),
                    style: AppTextStyles.heading3,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    '($totalRatings)',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(Overview overview) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColorsV2.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColorsV2.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _OverviewStat(
            label: 'City',
            value: overview.city ?? 'N/A',
          ),
          _OverviewStat(
            label: 'Hired',
            value:
                overview.totalBookings != null ? '${overview.totalBookings}x' : '0',
          ),
          _OverviewStat(
            label: 'Member since',
            value: overview.registeredSince ?? '—',
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsSection() {
    final ratingsController = controller.ratingsController;
    return Obx(() {
      if (ratingsController.isLoadingRatings.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final ratings = ratingsController.latestFiveRatings;
      if (ratings.isEmpty) {
        return StatusToastV2(
          message: 'No reviews yet',
          type: StatusToastType.info,
        );
      }

      return Column(
        children: ratings
            .map(
              (rating) => _RatingTile(rating: rating),
            )
            .toList(),
      );
    });
  }
}

class _ProviderHeader extends StatelessWidget {
  final String name;
  final String imageUrl;
  final double rating;
  final String category;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  const _ProviderHeader({
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.category,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColorsV2.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColorsV2.shadowMedium,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            child: Image.network(
              imageUrl,
              width: 90.w,
              height: 90.h,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 90.w,
                height: 90.h,
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
                ),
                SizedBox(height: AppSpacing.xsVertical),
                Text(
                  category,
                  style: AppTextStyles.bodySmall,
                ),
                SizedBox(height: AppSpacing.xsVertical),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 18.sp),
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
          IconButton(
            onPressed: onFavoriteTap,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppColorsV2.primary : AppColorsV2.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewStat extends StatelessWidget {
  final String label;
  final String value;

  const _OverviewStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColorsV2.textSecondary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _TrustSignalChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _TrustSignalChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
        border: Border.all(
          color: AppColorsV2.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: color,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingTile extends StatelessWidget {
  final ProviderRating rating;

  const _RatingTile({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColorsV2.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              rating.consumer.avatar ?? blankProfileImage,
            ),
            radius: 22.r,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rating.consumer.name ?? '',
                  style: AppTextStyles.bodyMedium,
                ),
                SizedBox(height: 4.h),
                Text(
                  rating.review ?? '',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 18.sp),
              SizedBox(width: 4.w),
              Text(
                rating.starRating.toStringAsFixed(1),
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

