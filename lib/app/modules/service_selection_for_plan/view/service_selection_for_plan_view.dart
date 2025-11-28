import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/create_plan/view/create_plan_view.dart';
import 'package:ustahub/app/modules/service_selection_for_plan/controller/service_selection_for_plan_controller.dart';

class ServiceSelectionForPlanView extends StatelessWidget {
  ServiceSelectionForPlanView({super.key});

  final controller = Get.put(ServiceSelectionForPlanController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Obx(
        () => InkWell(
          onTap: () {
            if (controller.selectedServiceName.value.isEmpty) {
              CustomToast.error("Please select a service");
            } else {
              Get.to(
                () => CreatePlanScreen(
                  serviceName: controller.selectedServiceName.value,
                  serviceId: controller.selectedServiceId.value,
                ),
              );
            }
          },
          child: Container(
            height: 50.h,
            width: double.infinity,
            color: AppColors.green,
            alignment: Alignment.center,
            child: Text(
              AppLocalizations.of(context)!.conti,
              style: GoogleFonts.ubuntu(
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.selectService),
      body: Obx(
        () =>
            controller.isLoading.value
                ? Center(
                  child: CircularProgressIndicator(color: AppColors.green),
                )
                : controller.serviceList.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.business_center_outlined,
                        size: 60.sp,
                        color: Colors.grey.shade400,
                      ),
                      10.ph,
                      Text(
                        "No services found",
                        style: GoogleFonts.ubuntu(
                          fontSize: 16.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      20.ph,
                      ElevatedButton.icon(
                        onPressed: () => controller.refreshServices(),
                        icon: Icon(Icons.refresh),
                        label: Text("Refresh"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
                : RefreshIndicator(
                  onRefresh: controller.refreshServices,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    itemCount: controller.serviceList.length,
                    itemBuilder: (context, index) {
                      final service = controller.serviceList[index];

                      return Obx(() {
                        final isSelected =
                            controller.selectedServiceId.value ==
                            service.id.toString();

                        return GestureDetector(
                          onTap:
                              () => controller.selectService(
                                service.name.toString(),
                                service.id.toString(),
                              ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                            margin: EdgeInsets.symmetric(
                              vertical: 6.h,
                              horizontal: 16.w,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.green
                                        : Colors.grey.shade300,
                                width: 1.5,
                              ),
                              color:
                                  isSelected
                                      ? AppColors.green.withOpacity(0.1)
                                      : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.build_circle_outlined,
                                  color:
                                      isSelected
                                          ? AppColors.green
                                          : Colors.grey.shade600,
                                  size: 24.sp,
                                ),
                                12.pw,
                                Expanded(
                                  child: Text(
                                    service.name ?? "Unknown Service",
                                    style: GoogleFonts.ubuntu(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16.sp,
                                      color:
                                          isSelected
                                              ? AppColors.green
                                              : Colors.black87,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: AppColors.green,
                                    size: 20.sp,
                                  ),
                              ],
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
      ),
    );
  }
}
