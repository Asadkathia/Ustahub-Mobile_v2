import 'package:url_launcher/url_launcher.dart';
import 'package:ustahub/app/export/exports.dart';
import '../../../components/buttons/primary_button_v2.dart';
import '../../../components/buttons/secondary_button_v2.dart';
import '../../../design_system/colors/app_colors_v2.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_text_styles.dart';

class RateUsSheetV2 extends StatelessWidget {
  const RateUsSheetV2({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColorsV2.borderLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
            ),
          ),
          SizedBox(height: AppSpacing.mdVertical),
          Text(
            AppLocalizations.of(context)!.rateUs,
            style: AppTextStyles.heading3,
          ),
          SizedBox(height: AppSpacing.smVertical),
          Text(
            'We would love to hear your feedback about Ustahub.',
            style: AppTextStyles.bodyMediumSecondary,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lgVertical),
          PrimaryButtonV2(
            text: 'Rate on Play Store',
            onPressed: () async {
              const url =
                  'https://play.google.com/store/apps/details?id=com.brownfish.ustahubb';
              await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            },
          ),
          SizedBox(height: AppSpacing.smVertical),
          SecondaryButtonV2(
            text: 'Rate on App Store',
            onPressed: () async {
              const url = 'https://apps.apple.com/app/ustahub/id6753018350';
              await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            },
          ),
        ],
      ),
    );
  }
}

