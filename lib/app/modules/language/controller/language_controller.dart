
import 'package:ustahub/app/export/exports.dart';


class LanguageController extends GetxController {
  var selectedLocale = ''.obs;
  var isLocaleLoaded = false.obs;
  var hasInitialized = false;
  final languages = [
    {'name': 'English', 'locale': 'en'},
    {'name': 'Русский', 'locale': 'ru'},
    {'name': 'UZ', 'locale': 'uz'},
    {'name': 'TM', 'locale': 'tk'},
  ];


  

  @override
  void onInit() {
    super.onInit();
    getLocaleFromShared();
  }

  void getLocaleFromShared() async {
    if (hasInitialized) return; // prevent multiple runs
    hasInitialized = true;
    print("Called");
    String? localeName = await Sharedprefhelper.getSharedPrefHelper('Locale');
    selectedLocale.value = localeName ?? "en";
    isLocaleLoaded.value = true;
  }

  void selectLanguage(String locale) async {
    print("Selected Locale ${selectedLocale.value}");
    selectedLocale.value = locale;
    await Sharedprefhelper.setSharedPrefHelper("Locale", locale);

    Get.updateLocale(Locale(locale));
    debugPrint('Selected Locale: $locale');
    print("Selected Locale Varialble ${selectedLocale.value}");
  }
}
