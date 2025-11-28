import 'package:ustahub/app/export/exports.dart';

class LanguageView extends StatelessWidget {
  LanguageView({super.key});
  final LanguageController controller = Get.find<LanguageController>();

  final List<Map<String, String>> allLanguages = [
    {'flag': '🇺🇿', 'name': 'O‘zbekcha (Uzbek)', 'locale': 'uz'},
    {'flag': '🇹🇯', 'name': 'Тоҷикӣ (Tajik)', 'locale': 'tg'},
    {'flag': '🇰🇬', 'name': 'Кыргызча (Kyrgyz)', 'locale': 'ky'},
    {'flag': '🇰🇿', 'name': 'Қазақша (Kazakh)', 'locale': 'kk'},
    {'flag': '🇹🇲', 'name': 'Türkmençe (Turkmen)', 'locale': 'tk'},
    {'flag': '🇷🇺', 'name': 'Русский (Russian)', 'locale': 'ru'},
    {'flag': '🇬🇪', 'name': 'ქართული (Georgian)', 'locale': 'ka'},
    {'flag': '🇦🇲', 'name': 'Հայերեն (Armenian)', 'locale': 'hy'},
    {'flag': '🇵🇰', 'name': 'اردو (Urdu)', 'locale': 'ur'},
    {'flag': '🇸🇦', 'name': 'العربية (Arabic)', 'locale': 'ar'},
    {'flag': '🇬🇧', 'name': 'English', 'locale': 'en'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.selectLanguage,
          style: GoogleFonts.ubuntu(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: SvgPicture.asset(AppVectors.back, height: 24.h, width: 24.h),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 13.w),
        child: Obx(() {
          if (!controller.isLocaleLoaded.value) {
            return const Center(child: CircularProgressIndicator());
          }

          // Extract available locales from controller.languages
          final availableLocales = controller.languages
              .map((lang) => lang['locale'])
              .whereType<String>()
              .toList();

          // Filter upcoming languages (not in availableLocales)
          final upcomingLanguages = allLanguages
              .where((lang) => !availableLocales.contains(lang['locale']))
              .toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                20.ph,
                Text(
                  AppLocalizations.of(context)!.chooseYourPreferredLanguage,
                  style: GoogleFonts.ubuntu(
                    color: AppColors.grey,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                15.ph,

                /// ✅ Available Languages Section
                Text(
                  "Available Languages",
                  style: GoogleFonts.ubuntu(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                10.ph,
                Column(
                  children: controller.languages.map((lang) {
                    final isSelected =
                        controller.selectedLocale.value == lang['locale'];
                    final flag = allLanguages
                            .firstWhere(
                              (l) => l['locale'] == lang['locale'],
                              orElse: () => {'flag': '🌐'},
                            )['flag'] ??
                        '🌐';

                    return GestureDetector(
                      onTap: () =>
                          controller.selectLanguage(lang['locale'] ?? 'en'),
                      child: Container(
                        height: 52.h,
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        margin: EdgeInsets.symmetric(vertical: 6.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.green.shade100
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Colors.green
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(flag, style: TextStyle(fontSize: 22.sp)),
                            12.pw,
                            Expanded(
                              child: Text(
                                lang['name'] ?? '',
                                style: GoogleFonts.ubuntu(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle,
                                  color: Colors.green, size: 22.sp),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                25.ph,

                /// 🚀 Upcoming Languages Section
                Text(
                  "Upcoming Languages",
                  style: GoogleFonts.ubuntu(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey,
                  ),
                ),
                10.ph,
                Column(
                  children: upcomingLanguages.map((lang) {
                    return Container(
                      height: 52.h,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      margin: EdgeInsets.symmetric(vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Text(lang['flag']!, style: TextStyle(fontSize: 22.sp)),
                          12.pw,
                          Expanded(
                            child: Text(
                              lang['name']!,
                              style: GoogleFonts.ubuntu(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          const Text(
                            "Coming soon",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
