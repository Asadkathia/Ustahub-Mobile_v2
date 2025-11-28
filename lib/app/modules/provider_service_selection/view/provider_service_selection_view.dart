import 'package:ustahub/app/export/exports.dart';

class ProviderServiceSelectionView extends StatelessWidget {
  bool isManageService;
  final controller = Get.put(ProviderServiceSelectionController());

  ProviderServiceSelectionView({super.key, this.isManageService = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.selectYourServiceCategory),
      ),
      body: Obx(
        () =>
            controller.isLoading.value
                ? Center(
                  child: CircularProgressIndicator(color: AppColors.green),
                )
                : RefreshIndicator(
                  onRefresh: () async {
                    controller.getServices();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.selectThreeServices,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 12),
                        _buildSearchField(),
                        const SizedBox(height: 10),
                        _buildSelectedChips(),
                        const SizedBox(height: 10),
                        Expanded(
                          child: Obx(() {
                            if (controller.isLoading.value) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final filtered = controller.filteredServices;

                            if (filtered.isEmpty) {
                              return Center(
                                child: Text(
                                  AppLocalizations.of(context)!.noServicesFound,
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final service = filtered[index];
                                final isSelected = controller.selectedServices
                                    .contains(service.name);
                                final isDisabled =
                                    !controller.isSelectable(service.name!);

                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 6.h),
                                  child: ElevatedButton.icon(
                                    label: Text(
                                      service.name!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.green,
                                      ),
                                    ),
                                    icon: Icon( getServiceIcon(service.name!),
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.green,
                                    ),
                                    onPressed:
                                        isDisabled
                                            ? null
                                            : () => controller.toggleService(
                                              service.name!,
                                            ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          isSelected
                                              ? AppColors.green.withOpacity(0.4)
                                              : isDisabled
                                              ? Colors.grey.shade300
                                              : Colors.white,
                                      foregroundColor:
                                          isSelected
                                              ? Colors.white
                                              : isDisabled
                                              ? Colors.grey
                                              : Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      elevation: 0,
                                      side: BorderSide(
                                        color:
                                            isSelected
                                                ? Colors.green
                                                : Colors.grey.shade300,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 14,
                                      ),
                                    ),

                                  ),
                                );
                              },
                            );
                          }),
                        ),
                        controller.isAddingService.value
                            ? Center(
                              child: CircularProgressIndicator(
                                color: AppColors.green,
                              ),
                            )
                            : BuildBasicButton(
                              onPressed: () {
                                if (controller.selectedServices.isEmpty) {
                                  CustomToast.error(
                                    AppLocalizations.of(
                                      context,
                                    )!.pleaseSelectAtLeastOneService,
                                  );
                                } else {
                                  print("IsManageService: $isManageService");
                                  controller.addService(isManageService);
                                }
                              },
                              title: AppLocalizations.of(context)!.conti,
                            ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildSearchField() {
    return buildFormField(
      fillColor: AppColors.green.withOpacity(0.2),
      onChanged: (value) => controller.searchText.value = value,
      prefixIcon: const Icon(Icons.search),
      hint: AppLocalizations.of(Get.context!)!.search,
    );
  }

  Widget _buildSelectedChips() {
    return Wrap(
      spacing: 8,
      children:
          controller.selectedServices
              .map(
                (service) => Chip(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  label: Text(
                    service,
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  deleteIcon: Icon(
                    Icons.close,
                    size: 16.sp,
                    color: AppColors.green,
                  ),
                  onDeleted: () => controller.toggleService(service),
                  backgroundColor: AppColors.green.withOpacity(0.2),
                ),
              )
              .toList(),
    );
  }
}




IconData getServiceIcon(String name) {
  // Normalize name
  final key = name.trim().toLowerCase();

  const map = {
    "electrician": Icons.electrical_services,
    "plumber": Icons.plumbing,
    "ac & refrigerator technician": Icons.ac_unit,
    "gas fitters": Icons.gas_meter,
    "solar panel installation": Icons.solar_power,
    "vehicle mechanics": Icons.car_repair,
    "hvac (heating & cooling)": Icons.device_thermostat,
    "roofing": Icons.home_repair_service,
    "moving services": Icons.local_shipping,
    "landscaping & gardening": Icons.grass,
    "painting services": Icons.format_paint,
    "home cleaning": Icons.cleaning_services,
    "handyman services": Icons.handyman,
    "pest control": Icons.bug_report,
    "flooring installation": Icons.home_work,
    "interior design": Icons.chair_alt,
    "security & cctv installation": Icons.videocam,
    "window & glass services": Icons.window,
    "carpentry": Icons.construction,
    "home remodeling / contractors": Icons.build,
    "junk removal & hauling": Icons.delete_sweep,
    "car repair & maintenance": Icons.car_repair,
    "car wash & detailing": Icons.local_car_wash,
    "towing services": Icons.two_wheeler, // OR icons.tow_hook if you have custom
    "tire & battery services": Icons.electric_car,
    "mobile mechanic": Icons.engineering,
    "beauty & salon services": Icons.face_retouching_natural,
    "barbers & grooming": Icons.cut,
    "massage & spa": Icons.spa,
    "fitness & personal training": Icons.fitness_center,
    "photographers": Icons.photo_camera,
    "videographers": Icons.videocam,
    "event planners": Icons.event_available,
    "wedding services": Icons.favorite,
    "catering services": Icons.restaurant,
    "legal services (lawyers)": Icons.gavel,
    "accounting & tax services": Icons.calculate,
    "it support / computer repair": Icons.computer,
    "web & graphic design": Icons.design_services,
    "marketing & advertising": Icons.campaign,
    "real estate services": Icons.home,
    "insurance services": Icons.verified,
    "home health care": Icons.health_and_safety,
    "medical & dental clinics": Icons.local_hospital,
    "tuition & educational coaching": Icons.school,
    "driving schools": Icons.drive_eta,
    "pet grooming & pet care": Icons.pets,
    "veterinarians": Icons.medical_services,
    "travel agents & tour guides": Icons.travel_explore,
    "tailoring & alteration services": Icons.checkroom,
    "locksmith services": Icons.lock,
  };

  return map[key] ?? Icons.miscellaneous_services;
}
