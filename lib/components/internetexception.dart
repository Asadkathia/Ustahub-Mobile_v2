
import 'package:app_settings/app_settings.dart';

import 'package:ustahub/app/export/exports.dart';


class NoInternet extends GetView {
  const NoInternet({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (S) {
       Get.offAll(()=> SplashScreen());
      },
      child: Scaffold(
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_outlined,
                color: AppColors.grey, size: 100),
            2.ph,
            const Text("Internet Unavailable"),
            2.ph,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: BuildBasicButton(
                  onPressed: () {
                    Get.offAll(()=> SplashScreen());
                  },
                  title: "Retry"),
            ),
            2.ph,
            ElevatedButton(
              onPressed: () =>
                  AppSettings.openAppSettings(type: AppSettingsType.wifi),
              child: const Text('Open Network Settings'),
            )
          ],
        )),
      ),
    );
  }
}
