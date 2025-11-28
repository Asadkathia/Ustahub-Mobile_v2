import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/manage_address/controller/manage_address_controller.dart';
import 'package:ustahub/components/confirm_dialog.dart';

class ManageAddressView extends StatelessWidget {
  ManageAddressView({super.key});

  final controller = Get.put(ManageAddressController());

  @override
  Widget build(BuildContext context) {
    controller.getRoleBySharedPref();

    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.manageAddress),
      body: Obx(
        () =>
            controller.isLoading.value
                ? const Center(
                  child: CircularProgressIndicator(color: AppColors.green),
                )
                : WillPopScope(
                  onWillPop: () async {
                    String? role = await Sharedprefhelper.getRole();
                    controller.getAddresses(role!);
                    return true;
                  },
                  child: RefreshIndicator(
                    onRefresh: () async {
                      String? role = await Sharedprefhelper.getRole();
                      controller.getAddresses(role!);
                    },
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: 13.w,
                        vertical: 10.h,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: controller.addressList.length + 2,
                      separatorBuilder: (context, index) {
                        if (index == 0 ||
                            index == controller.addressList.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: CustomDottedLine(),
                        );
                      },
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // Add Address button
                          return Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: InkWell(
                              onTap: () {
                                controller.isEditMode.value = false;
                                controller.flatHouseController.clear();
                                controller.pinCodeController.clear();
                                controller.cityController.clear();
                                controller.stateController.clear();
                                controller.selectedCountry.value = "";
                                _showAddressBottomSheet(context, null);
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: AppColors.green,
                                    size: 25.sp,
                                  ),
                                  4.pw,
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.addAnotherAddress,
                                    style: GoogleFonts.ubuntu(
                                      color: AppColors.green,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final reversedList = controller.addressList;

                        if (index == controller.addressList.length + 1) {
                          return const SizedBox(height: 50); // Bottom padding
                        }

                        final address = reversedList[index - 1];
                        final isDefault = address.isDefault!;

                        return AddressCardForManageAddress(
                          isDefault: isDefault,
                          title: address.postalCode!,
                          address:
                              "${address.addressLine1 ?? ''}, ${address.city}, ${address.state}, \n${address.country} - ${address.postalCode}",
                          onEdit: () {
                            controller.prefillAddressFields(address);
                            controller.isEditMode.value = true;
                            _showAddressBottomSheet(context, address.id);
                          },
                          onDelete: () {
                            showConfirmDialog(
                              context: context,
                              title: AppLocalizations.of(context)!.areYouSure,
                              message: AppLocalizations.of(context)!.doYouReallyWantToDelete,
                              confirmText: AppLocalizations.of(context)!.delete,
                              cancelText: AppLocalizations.of(context)!.cancel,
                              onConfirm: () {
                                controller.deleteAddress(address.id!);
                              },
                            );
                          },
                          onSetDefault:
                              isDefault
                                  ? null
                                  : () {
                                    controller.setDefaultAddress(address.id!);
                                  },
                        );
                      },
                    ),
                  ),
                ),
      ),
    );
  }
}

// Show Modal Bottom Sheet for Adding Address

void _showAddressBottomSheet(BuildContext context, String? id) {
  final controller = Get.find<ManageAddressController>();
  final formKey = GlobalKey<FormState>();

  showModalBottomSheet(
    scrollControlDisabledMaxHeightRatio: 0.6,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    context: context,
    builder:
        (context) => Padding(
          padding: EdgeInsets.only(
            left: 20.r,
            right: 20.r,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20.r,
            top: 20.r,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () =>
                      controller.isLocationFetching.value
                          ? Container(
                            height: 50.h,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: AppColors.green),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: CircularProgressIndicator(
                                    color: AppColors.green,
                                    strokeWidth: 2,
                                  ),
                                ),
                                10.pw,
                                Text(
                                  AppLocalizations.of(context)!.fetchingLocation,
                                  style: GoogleFonts.ubuntu(
                                    fontSize: 16.sp,
                                    color: AppColors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : BuildBasicButton(
                            onPressed: () async {
                              // Use current location functionality
                              await controller.useCurrentLocation();
                            },
                            title:
                                AppLocalizations.of(
                                  context,
                                )!.useMyCurrentLocation,
                            buttonColor: Colors.white,
                            textStyle: GoogleFonts.ubuntu(
                              fontSize: 16.sp,
                              color: AppColors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
                15.ph,
                Text(
                  AppLocalizations.of(context)!.or,
                  style: GoogleFonts.ubuntu(
                    color: AppColors.blackText,
                    fontWeight: FontWeight.w500,
                    fontSize: 15.sp,
                  ),
                ),
                15.ph,

                titleText(
                  title: AppLocalizations.of(context)!.flatHouseBuilding,
                ),
                5.ph,
                buildFormField(
                  validator:
                      (value) =>
                          value == null || value.trim().isEmpty
                              ? AppLocalizations.of(context)!.thisFieldIsRequired
                              : null,
                  controller: controller.flatHouseController,
                ),
                10.ph,

                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          titleText(title: AppLocalizations.of(context)!.pinCode),
                          5.ph,
                          buildFormField(
                            keyboardType: TextInputType.number,
                            inputFormatter: [
                              LengthLimitingTextInputFormatter(8),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppLocalizations.of(context)!.pinCodeIsRequired;
                              } else if (value.length < 4) {
                                return AppLocalizations.of(context)!.enterValidPinCode;
                              }
                              return null;
                            },
                            controller: controller.pinCodeController,
                          ),
                        ],
                      ),
                    ),
                    10.pw,
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          titleText(title: AppLocalizations.of(context)!.townCity),
                          5.ph,
                          buildFormField(
                            validator:
                                (value) =>
                                    value == null || value.trim().isEmpty
                                        ? AppLocalizations.of(context)!.cityIsRequired
                                        : null,
                            controller: controller.cityController,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                10.ph,

                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          titleText(title: AppLocalizations.of(context)!.state),
                          5.ph,
                          buildFormField(
                            validator:
                                (value) =>
                                    value == null || value.trim().isEmpty
                                        ? AppLocalizations.of(context)!.stateIsRequired
                                        : null,
                            controller: controller.stateController,
                          ),
                        ],
                      ),
                    ),
                    10.pw,
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          titleText(title: AppLocalizations.of(context)!.country),
                          5.ph,
                          Obx(
                            () => GestureDetector(
                              onTap: () {
                                showCountryPicker(
                                  context: context,
                                  showPhoneCode: false,
                                  countryListTheme: CountryListThemeData(
                                    margin: EdgeInsets.all(20.h),
                                  ),
                                  onSelect: (country) {
                                    controller.selectedCountry.value =
                                        country.name;
                                    controller.countryController.text =
                                        country.name;
                                  },
                                );
                              },
                              child: AbsorbPointer(
                                child: buildFormField(
                                  hint: AppLocalizations.of(context)!.selectCountry,
                                  controller: TextEditingController(
                                    text: controller.selectedCountry.value,
                                  ),
                                  validator:
                                      (value) =>
                                          value == null || value.trim().isEmpty
                                              ? AppLocalizations.of(context)!.countryIsRequired
                                              : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                20.ph,

                Obx(
                  () =>
                      controller.isLoading.value
                          ? const CircularProgressIndicator(
                            color: AppColors.green,
                          )
                          : BuildBasicButton(
                            title:
                                controller.isEditMode.value
                                    ? AppLocalizations.of(context)!.updateAddress
                                    : AppLocalizations.of(context)!.saveAddress,
                            onPressed: () async {
                              String? role = await Sharedprefhelper.getRole();
                              if (formKey.currentState!.validate()) {
                                if (controller.isEditMode.value) {
                                  controller.updateAddress(id!);
                                } else {
                                  await controller.addAddress();
                                  // Address list refresh is handled in addAddress method
                                }

                                controller.isEditMode.value = false;
                              }
                            },
                          ),
                ),
              ],
            ),
          ),
        ),
  );
}
