import 'package:ustahub/app/modules/booking_summary/view/booking_summary_view.dart';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/manage_address/controller/manage_address_controller.dart';

class CheckoutModalBottomSheet extends StatefulWidget {
  final String providerId, serviceId;
  const CheckoutModalBottomSheet({
    super.key,
    required this.providerId,
    required this.serviceId,
  });

  @override
  State<CheckoutModalBottomSheet> createState() =>
      _CheckoutModalBottomSheetState();
}

class _CheckoutModalBottomSheetState extends State<CheckoutModalBottomSheet> {
  final controller = Get.put(CheckoutController());

  final addressController = Get.find<ManageAddressController>();

  @override
  void initState() {
    super.initState();
    // Reset time slots and selected time for new booking
    controller.timeSlotsLists.clear();
    controller.selectedTime.value = "00:00";
    controller.selectedDate.value = DateTime.now();
    controller.selectDate(DateTime.now(), widget.providerId);
    addressController.getRoleBySharedPref();
    // Set the selected service name from ProviderDetailsScreen
    final plansController = Get.find<PlanSelectionController>();
    controller.setSelectedServiceName(
      plansController.selectedService.value?.name ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    // final DateTime today = DateTime.now();
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 15.r,
            top: 15.r,
            right: 15.r,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                if (addressController.isLoading.value) {
                  return addressRowShimmer();
                }

                if (addressController.addressList.isEmpty) {
                  return Row(
                    children: [
                      SvgPicture.asset(
                        AppVectors.svgLocation,
                        height: 20.h,
                        width: 20.h,
                      ),
                      5.pw,
                      Expanded(
                        child: Text(
                          "No address found. Please add an address.",
                          style: GoogleFonts.ubuntu(
                            fontSize: 14.sp,
                            color: AppColors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    SvgPicture.asset(
                      AppVectors.svgLocation,
                      height: 20.h,
                      width: 20.h,
                    ),
                    5.pw,
                    Expanded(
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "${addressController.addressList.first.city ?? ""} - ",
                              style: GoogleFonts.ubuntu(
                                fontSize: 14.sp,
                                color: AppColors.blackText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text:
                          "${addressController.addressList.first.addressLine1 ?? ""} ${addressController.addressList.first.city ?? ""} ${addressController.addressList.first.state ?? ""} ${addressController.addressList.first.country ?? ""} - ${addressController.addressList.first.postalCode ?? ""}",
                              style: GoogleFonts.ubuntu(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
              5.ph,
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    Get.to(() => ManageAddressView());
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                      color: AppColors.green.withAlpha(80),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.h,
                      vertical: 3.w,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.changeAddress,
                      style: GoogleFonts.ubuntu(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              15.ph,
              Text(
                AppLocalizations.of(context)!.selectDate,
                style: GoogleFonts.ubuntu(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              15.ph,
              Obx(
                () => TableCalendar(
                  calendarFormat: CalendarFormat.week,
                  headerVisible: false,
                  focusedDay: controller.selectedDate.value,
                  firstDay: controller.firstDay,
                  lastDay: controller.lastDay,
                  selectedDayPredicate:
                      (day) => isSameDay(day, controller.selectedDate.value),
                  onDaySelected: (selected, focused) {
                    controller.selectDate(selected, widget.providerId);
                    debugPrint(selected.toString());
                  },
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              15.ph,
              Text(
                AppLocalizations.of(context)!.selectTime,
                style: GoogleFonts.ubuntu(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              10.ph,
              Obx(
                () {
                  if (controller.isLoading.value) {
                    return timeSlotShimmerGrid();
                  }
                  
                  final validSlots = controller.timeSlotsLists
                      .where((slot) => slot.startTime != null && slot.startTime!.isNotEmpty)
                      .toList();
                  
                  if (validSlots.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Text(
                        "No time slots available for this date",
                        style: GoogleFonts.ubuntu(
                          fontSize: 14.sp,
                          color: AppColors.grey,
                        ),
                      ),
                    );
                  }
                  
                  return GridView(
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 13.w,
                          mainAxisSpacing: 8.h,
                          mainAxisExtent: 40.h, // Controls item height
                        ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: validSlots.map((slot) {
                                final startTime = slot.startTime ?? '';
                                final isSelected =
                                    controller.selectedTime.value == startTime;
                                final isDisabled = (slot.isBooked ?? false);

                                return InkWell(
                                  onTap:
                                      isDisabled
                                          ? null // Disable tap if booked
                                          : () {
                                            controller.selectTimeSlot(startTime);
                                            print(slot);
                                          },
                                  splashColor:
                                      isDisabled
                                          ? Colors.transparent
                                          : null, // Disable splash if disabled
                                  highlightColor:
                                      isDisabled ? Colors.transparent : null,
                                  child: Container(
                                    padding: EdgeInsets.all(5.r),
                                    decoration: BoxDecoration(
                                      color:
                                          isDisabled
                                              ? Colors
                                                  .grey
                                                  .shade300 // Disabled color
                                              : isSelected
                                              ? AppColors.green
                                              : AppColors.background,
                                      border: Border.all(
                                        color:
                                            isDisabled
                                                ? Colors.grey.shade400
                                                : AppColors.green.withOpacity(
                                                  0.2,
                                                ),
                                      ),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      convertTo12HourFormat(startTime),
                                      style: GoogleFonts.ubuntu(
                                        color:
                                            isDisabled
                                                ? Colors.grey
                                                : isSelected
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                  );
                },
              ),

              20.ph,
              buildFormField(
                maxLines: null,
                controller: controller.noteController.value,
                prefixIcon: SvgPicture.asset(
                  AppVectors.svgNote,
                  fit: BoxFit.scaleDown,
                ),
                radius: 10.r,
                hint: AppLocalizations.of(context)!.addANote,
                hintstyle: GoogleFonts.ubuntu(
                  color: AppColors.green,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              // 15.ph,
              // Text(
              //   "${AppLocalizations.of(context)!.visitingCharge} - \$$visitingCharge",
              //   style: GoogleFonts.ubuntu(
              //     fontSize: 14.sp,
              //     fontWeight: FontWeight.w500,
              //   ),
              // ),
              // 15.ph,
              // Row(
              //   children: [
              //     Transform.scale(
              //       scale: 1.2,
              //       child: Checkbox(
              //         shape: const CircleBorder(),
              //         side: BorderSide(
              //           color: Colors.green.withOpacity(
              //             0.5,
              //           ), // Green border when unchecked
              //           width: 2,
              //         ),
              //         value: true,
              //         onChanged: (val) {
              //           print(val);
              //         },
              //         // onChanged: controller.toggleCharge,
              //         activeColor: Colors.green, // Fill color when checked
              //       ),
              //     ),
              //     5.pw,
              //     Text(
              //       AppLocalizations.of(context)!.includeVisitingCharge,
              //       style: GoogleFonts.ubuntu(
              //         fontSize: 14.sp,
              //         color: AppColors.grey,
              //       ),
              //     ),
              //   ],
              // ),
              30.ph,
              BuildBasicButton(
                onPressed: () {
                  if (addressController.addressList.isEmpty) {
                    CustomToast.error(
                      "Please add an address first",
                    );
                  } else if (controller.selectedTime.value == "00:00") {
                    CustomToast.error(
                      AppLocalizations.of(context)!.pleaseSelectTime,
                    );
                  } else {
                    final selectedAddress = addressController.addressList.first;
                    final addressId = selectedAddress.id;
                    if (addressId == null || addressId.isEmpty) {
                      CustomToast.error("Address ID is missing. Please select a valid address.");
                      return;
                    }
                    Get.to(
                      BookingSummaryView(
                        note: controller.noteController.value.text,
                        addressId: addressId,
                        bookingDate: controller.selectedYmdDate.value,
                        bookingTime: controller.selectedTime.value,
                        serviceId: widget.serviceId,
                        serviceName: controller.selectedServiceName.value,
                        fullAddress:
                            "${selectedAddress.addressLine1 ?? ''}, ${selectedAddress.city ?? ''}, ${selectedAddress.state ?? ''}, ${selectedAddress.country ?? ''} - ${selectedAddress.postalCode ?? ''}",
                        providerId: widget.providerId,
                      ),
                    );
                  }
                },
                title: AppLocalizations.of(context)!.proceedToCheckout,
              ),
            ],
          ),
        );
      },
    );
  }
}
