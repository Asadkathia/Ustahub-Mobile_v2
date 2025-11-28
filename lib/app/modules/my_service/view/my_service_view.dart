import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/my_service/controller/my_service_controller.dart';

class MyServiceView extends StatelessWidget {
  const MyServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyServiceController());

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myService),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: AppColors.green),
            onPressed: () async {
              await Get.to(ProviderServiceSelectionView(isManageService: true));
              controller.fetchMyServices(); // refresh after managing
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: AppColors.green));
        }
        if (controller.myServices.isEmpty) {
          return Center(
            child: Text(
              'No services added',
              style: GoogleFonts.ubuntu(fontSize: 14.sp, color: AppColors.grey),
            ),
          );
        }
        return Padding(
          padding: EdgeInsets.all(12.w),
          child: ListView.builder(
            itemCount: controller.myServices.length,
            itemBuilder: (context, index) {
              final service = controller.myServices[index];
              return Container(
                margin: EdgeInsets.symmetric(vertical: 6.h),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                  border: Border.all(color: AppColors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        service.name ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(Icons.check_circle, color: AppColors.green, size: 20.sp),
                  ],
                ),
              );
            },
          ),
        );
      }),
      backgroundColor: const Color(0xFFF8F8F8),
    );
  }
}
