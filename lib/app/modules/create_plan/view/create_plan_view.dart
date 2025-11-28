import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/create_plan/controller/create_plan_controller.dart';

class CreatePlanScreen extends StatefulWidget {
  final String serviceName, serviceId;
  const CreatePlanScreen({
    super.key,
    required this.serviceName,
    required this.serviceId,
  });

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  late CreatePlanController controller;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CreatePlanController());
    // Prefill only once
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.fetchAndPrefillPlans(widget.serviceId);
      setState(() {
        _prefilled = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreatePlanController>(
      init: controller,
      builder: (controller) {
        return Scaffold(
          appBar: CustomAppBar(title: widget.serviceName),
          body:
              !_prefilled
                  ? Center(child: CircularProgressIndicator())
                  : Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      children: [
                        // Tab Buttons
                        Row(
                          children: List.generate(
                            controller.tabs.length,
                            (index) => Expanded(
                              child: Obx(
                                () => Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                  ),
                                  child: CustomTabButton(
                                    title: controller.tabs[index],
                                    isSelected:
                                        controller.selectedTabIndex.value ==
                                        index,
                                    onTap: () => controller.changeTab(index),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Tab Content
                        Obx(() {
                          final tabIndex = controller.selectedTabIndex.value;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              titleText(
                                title: AppLocalizations.of(context)!.planPrice,
                              ),
                              10.ph,
                              buildFormField(
                                radius: 10.r,
                                hint: AppLocalizations.of(context)!.planPrice,
                                controller:
                                    controller.plans[tabIndex].priceController,
                                keyboardType: TextInputType.number,
                              ),
                              15.ph,
                              titleText(
                                title: AppLocalizations.of(context)!.planTitle,
                              ),
                              10.ph,
                              buildFormField(
                                radius: 10.r,
                                hint: AppLocalizations.of(context)!.planTitle,
                                maxLines: 10,
                                controller:
                                    controller.plans[tabIndex].titleController,
                              ),
                              15.ph,
                              titleText(
                                title:
                                    AppLocalizations.of(
                                      context,
                                    )!.includedServices,
                              ),
                              10.ph,
                              // Services Fields
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount:
                                    controller
                                        .plans[tabIndex]
                                        .servicesControllers
                                        .length,
                                itemBuilder: (_, i) {
                                  final isLast =
                                      i ==
                                      controller
                                              .plans[tabIndex]
                                              .servicesControllers
                                              .length -
                                          1;
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 8.h),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: buildFormField(
                                            radius: 10.r,
                                            hint:
                                                AppLocalizations.of(
                                                  context,
                                                )!.typeHere,
                                            controller:
                                                controller
                                                    .plans[tabIndex]
                                                    .servicesControllers[i],
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        IconButton(
                                          onPressed:
                                              () => controller.modifyService(
                                                tabIndex,
                                                i,
                                              ),
                                          icon: Icon(
                                            isLast
                                                ? Icons.add_circle
                                                : Icons.remove_circle,
                                            color:
                                                isLast
                                                    ? Colors.green
                                                    : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        }),

                        const Spacer(),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed:
                                () => controller.addPlanForCurrentTab(
                                  widget.serviceId,
                                ),
                            child: Text(
                              AppLocalizations.of(context)!.saveChanges,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
        );
      },
    );
  }
}
