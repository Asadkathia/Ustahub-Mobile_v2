import 'package:ustahub/app/export/exports.dart';
import '../../../components/navigation/app_app_bar_v2.dart';
import '../../../design_system/colors/app_colors_v2.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_text_styles.dart';

class LanguageScreenV2 extends StatelessWidget {
  LanguageScreenV2({super.key});
  final LanguageController controller = Get.put(LanguageController());

  // All languages with flags and display names (ordered to match UI)
  final List<Map<String, dynamic>> allLanguages = [
    {'flag': '🇬🇧', 'name': 'English', 'locale': 'en', 'nativeName': 'English'},
    {'flag': '🇷🇺', 'name': 'Русский', 'locale': 'ru', 'nativeName': 'Русский (Russian)'},
    {'flag': '🇺🇿', 'name': 'O\'zbekcha', 'locale': 'uz', 'nativeName': 'O\'zbekcha (Uzbek)'},
    {'flag': '🇰🇬', 'name': 'Кыргызча', 'locale': 'ky', 'nativeName': 'Кыргызча (Kyrgyz)'},
    {'flag': '🇰🇿', 'name': 'Қазақша', 'locale': 'kk', 'nativeName': 'Қазақша (Kazakh)'},
    {'flag': '🇵🇰', 'name': 'اردو', 'locale': 'ur', 'nativeName': 'اردو (Urdu)'},
    {'flag': '🇸🇦', 'name': 'العربية', 'locale': 'ar', 'nativeName': 'العربية (Arabic)'},
    {'flag': '🇹🇯', 'name': 'Тоҷикӣ', 'locale': 'tg', 'nativeName': 'Тоҷикӣ (Tajik)'},
  ];

  // Available languages (all currently supported languages including Kyrgyz, Kazakh, Urdu, and Arabic)
  final List<String> availableLocales = ['en', 'ru', 'uz', 'ky', 'kk', 'ur', 'ar'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      appBar: AppAppBarV2(
        title: AppLocalizations.of(context)!.languge,
      ),
      body: Obx(() {
        if (!controller.isLocaleLoaded.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Separate available and upcoming languages
        final availableLanguages = allLanguages
            .where((lang) => availableLocales.contains(lang['locale']))
            .toList();
        
        final upcomingLanguages = allLanguages
            .where((lang) => !availableLocales.contains(lang['locale']))
            .toList();

        return SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.mdVertical),
              // Available Languages Section
              Text(
                'Available Languages',
                style: AppTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.mdVertical),
              ...availableLanguages.map((lang) => _buildLanguageTile(
                context: context,
                lang: lang,
                isSelected: controller.selectedLocale.value == lang['locale'],
                isUpcoming: false,
              )),
              SizedBox(height: AppSpacing.xlVertical),
              // Upcoming Languages Section
              if (upcomingLanguages.isNotEmpty) ...[
                Text(
                  'Upcoming Languages',
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColorsV2.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.mdVertical),
                ...upcomingLanguages.map((lang) => _buildLanguageTile(
                  context: context,
                  lang: lang,
                  isSelected: false,
                  isUpcoming: true,
                )),
              ],
              SizedBox(height: AppSpacing.xlVertical),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required Map<String, dynamic> lang,
    required bool isSelected,
    required bool isUpcoming,
  }) {
    return GestureDetector(
      onTap: isUpcoming ? null : () => controller.selectLanguage(lang['locale']),
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.smVertical),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.mdVertical,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColorsV2.primaryLight.withOpacity(0.1)
              : AppColorsV2.background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(
            color: isSelected
                ? AppColorsV2.primary
                : AppColorsV2.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Flag
            Text(
              lang['flag'] ?? '🌐',
              style: TextStyle(fontSize: 28.sp),
            ),
            SizedBox(width: AppSpacing.md),
            // Language Name
            Expanded(
              child: Text(
                lang['nativeName'] ?? lang['name'] ?? '',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isUpcoming
                      ? AppColorsV2.textSecondary
                      : AppColorsV2.textPrimary,
                ),
              ),
            ),
            // Checkmark or Coming Soon
            if (isSelected && !isUpcoming)
              Icon(
                Icons.check_circle,
                color: AppColorsV2.primary,
                size: 24.sp,
              )
            else if (isUpcoming)
              Text(
                'Coming soon',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColorsV2.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

