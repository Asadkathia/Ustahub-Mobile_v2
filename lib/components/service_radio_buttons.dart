import 'package:ustahub/app/modules/provider_details/model_class/provider_details_model_class.dart';
import 'package:ustahub/app/export/exports.dart';

class ServiceRadioButtons extends StatelessWidget {
  final List<Service> services;
  final ProviderDetailsController controlle;
  final PlanSelectionController serviceController =
      Get.find<PlanSelectionController>();

  ServiceRadioButtons({
    super.key,
    required this.services,
    required this.controlle,
  });

  String _capitalizeLabel(String? str) {
    if (str == null || str.isEmpty) return "";
    final lower = str.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () =>
          controlle.isLoading.value
              ? Center(child: SizedBox.shrink())
              : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      services.map((service) {
                        final isSelected =
                            serviceController.selectedService.value?.id ==
                            service.id;
                        final label = _capitalizeLabel(service.name);
                        return GestureDetector(
                          onTap: () {
                            serviceController.selectServiceAndPlan(
                              service,
                              controlle
                                      .providerDetails
                                      .value
                                      ?.provider
                                      ?.plans ??
                                  [],
                            );
                          },
                          child: Container(
                            height: 42.h,
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            margin: EdgeInsets.only(right: 8.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.green
                                        : AppColors.green.withOpacity(0.2),
                                width: 1.5,
                              ),
                              color: Colors.white,
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Radio<Service>(
                                    value: service,
                                    groupValue:
                                        serviceController.selectedService.value,
                                    onChanged:
                                        (val) =>
                                            serviceController
                                                .selectedService
                                                .value = val!,
                                    activeColor: AppColors.green,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  Text(
                                    label,
                                    style: GoogleFonts.ubuntu(
                                      fontSize: 12.sp,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                      color:
                                          isSelected
                                              ? AppColors.green
                                              : AppColors.blackText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
    );
  }
}
