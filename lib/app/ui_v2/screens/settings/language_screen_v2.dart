import 'package:ustahub/app/export/exports.dart';
import '../../../components/navigation/app_app_bar_v2.dart';
import '../../../design_system/colors/app_colors_v2.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_text_styles.dart';

class LanguageScreenV2 extends StatelessWidget {
  LanguageScreenV2({super.key});
  final LanguageController controller = Get.put(LanguageController());

  final List<Locale> supportedLocales = const [
    Locale('en'),
    Locale('ru'),
    Locale('tk'),
    Locale('uz'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      appBar: AppAppBarV2(
        title: AppLocalizations.of(context)!.languge,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPaddingHorizontal,
        ),
        child: Obx(() {
          if (!controller.isLocaleLoaded.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.separated(
            itemCount: supportedLocales.length,
            separatorBuilder: (_, __) => Divider(color: AppColorsV2.borderLight),
            itemBuilder: (context, index) {
              final locale = supportedLocales[index];
              final isSelected =
                  controller.selectedLocale.value == locale.languageCode;
              final displayName = _localeDisplayName(locale.languageCode);

              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  displayName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: AppColorsV2.primary)
                    : Icon(Icons.circle_outlined, color: AppColorsV2.borderLight),
                onTap: () => controller.selectLanguage(locale.languageCode),
              );
            },
          );
        }),
      ),
    );
  }

  String _localeDisplayName(String code) {
    switch (code) {
      case 'ru':
        return 'Русский';
      case 'tk':
        return 'Türkmençe';
      case 'uz':
        return 'Oʻzbekcha';
      case 'en':
      default:
        return 'English';
    }
  }
}

