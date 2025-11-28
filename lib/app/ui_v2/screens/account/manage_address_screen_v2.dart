import 'package:flutter/services.dart';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/manage_address/controller/manage_address_controller.dart';
import 'package:ustahub/components/confirm_dialog.dart';
import '../../../components/buttons/primary_button_v2.dart';
import '../../../components/buttons/secondary_button_v2.dart';
import '../../../components/feedback/status_toast_v2.dart';
import '../../../components/navigation/app_app_bar_v2.dart';
import '../../../design_system/colors/app_colors_v2.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_text_styles.dart';

class ManageAddressScreenV2 extends StatefulWidget {
  const ManageAddressScreenV2({super.key});

  @override
  State<ManageAddressScreenV2> createState() => _ManageAddressScreenV2State();
}

class _ManageAddressScreenV2State extends State<ManageAddressScreenV2> {
  final ManageAddressController controller = Get.put(ManageAddressController());

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final role = await Sharedprefhelper.getRole() ?? 'consumer';
    controller.getAddresses(role);
  }

  Future<void> _refreshAddresses() => _loadAddresses();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      appBar: AppAppBarV2(
        title: AppLocalizations.of(context)!.manageAddress,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPaddingHorizontal,
          ),
          child: Column(
            children: [
              SizedBox(height: AppSpacing.mdVertical),
              SecondaryButtonV2(
                text: AppLocalizations.of(context)!.addAnotherAddress,
                onPressed: () {
                  controller.isEditMode.value = false;
                  controller.flatHouseController.clear();
                  controller.pinCodeController.clear();
                  controller.cityController.clear();
                  controller.stateController.clear();
                  controller.countryController.clear();
                  controller.selectedCountry.value = '';
                  _showAddressSheet(context);
                },
              ),
              SizedBox(height: AppSpacing.mdVertical),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.addressList.isEmpty) {
                    return Center(
                      child: StatusToastV2(
                        message: AppLocalizations.of(context)!.noServicesFound,
                        type: StatusToastType.info,
                      ),
                    );
                  }

                  final addresses = controller.addressList.toList();
                  return RefreshIndicator(
                    color: AppColorsV2.primary,
                    onRefresh: _refreshAddresses,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: addresses.length,
                      itemBuilder: (context, index) {
                        final address = addresses[index];
                        final subtitle =
                            "${address.addressLine1 ?? ''}, ${address.city}, ${address.state}, ${address.country} - ${address.postalCode}";

                        return Container(
                          margin: EdgeInsets.only(bottom: AppSpacing.mdVertical),
                          padding: EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColorsV2.background,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLarge,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColorsV2.shadowLight,
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      address.postalCode ?? '',
                                      style: AppTextStyles.heading4,
                                    ),
                                  ),
                                  if (address.isDefault ?? false)
                                    StatusToastV2(
                                      message: 'Default',
                                      type: StatusToastType.success,
                                    ),
                                ],
                              ),
                              SizedBox(height: AppSpacing.xsVertical),
                              Text(
                                subtitle,
                                style: AppTextStyles.bodySmall,
                              ),
                              SizedBox(height: AppSpacing.smVertical),
                              Row(
                                children: [
                                  Expanded(
                                    child: SecondaryButtonV2(
                                      text: AppLocalizations.of(context)!.edit,
                                      onPressed: () {
                                        controller.prefillAddressFields(address);
                                        controller.isEditMode.value = true;
                                        _showAddressSheet(context, address.id);
                                      },
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: PrimaryButtonV2(
                                      text: AppLocalizations.of(context)!.delete,
                                      onPressed: () {
                                        showConfirmDialog(
                                          context: context,
                                          title: AppLocalizations.of(context)!.areYouSure,
                                          message: AppLocalizations.of(context)!.doYouReallyWantToDelete,
                                          onConfirm: () {
                                            controller.deleteAddress(address.id!);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppSpacing.smVertical),
                              TextButton(
                                onPressed: address.isDefault ?? false
                                    ? null
                                    : () => controller.setDefaultAddress(address.id!),
                                child: Text(
                                  address.isDefault ?? false
                                      ? 'Default'
                                      : 'Set as default',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: address.isDefault ?? false
                                        ? AppColorsV2.textSecondary
                                        : AppColorsV2.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddressSheet(BuildContext context, [String? id]) {
    final formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXLarge),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColorsV2.borderLight,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusRound,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.mdVertical),
                Text(
                  controller.isEditMode.value
                      ? AppLocalizations.of(context)!.edit
                      : AppLocalizations.of(context)!.addAnotherAddress,
                  style: AppTextStyles.heading3,
                ),
                  SizedBox(height: AppSpacing.mdVertical),
                  Obx(
                    () => controller.isLocationFetching.value
                        ? StatusToastV2(
                            message: AppLocalizations.of(context)!.fetchingLocation,
                            type: StatusToastType.info,
                          )
                        : TextButton(
                            onPressed: controller.useCurrentLocation,
                            child: Text(
                              AppLocalizations.of(context)!.useMyCurrentLocation,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColorsV2.primary,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: AppSpacing.mdVertical),
                  _buildLabel(
                    context,
                    AppLocalizations.of(context)!.flatHouseBuilding,
                  ),
                  _buildField(
                    controller: controller.flatHouseController,
                    validator: (value) => value == null || value.isEmpty
                        ? AppLocalizations.of(context)!.thisFieldIsRequired
                        : null,
                  ),
                  SizedBox(height: AppSpacing.smVertical),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(context, AppLocalizations.of(context)!.pinCode),
                            _buildField(
                              controller: controller.pinCodeController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(8),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!.pinCodeIsRequired;
                                }
                                if (value.length < 4) {
                                  return AppLocalizations.of(context)!.enterValidPinCode;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(context, AppLocalizations.of(context)!.townCity),
                            _buildField(
                              controller: controller.cityController,
                              validator: (value) => value == null || value.isEmpty
                                  ? AppLocalizations.of(context)!.cityIsRequired
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.smVertical),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(context, AppLocalizations.of(context)!.state),
                            _buildField(
                              controller: controller.stateController,
                              validator: (value) => value == null || value.isEmpty
                                  ? AppLocalizations.of(context)!.stateIsRequired
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(context, AppLocalizations.of(context)!.country),
                            GestureDetector(
                              onTap: () {
                                showCountryPicker(
                                  context: context,
                                  showPhoneCode: false,
                                  onSelect: (country) {
                                    controller.selectedCountry.value = country.name;
                                    controller.countryController.text = country.name;
                                  },
                                );
                              },
                              child: AbsorbPointer(
                                child: _buildField(
                                  controller: controller.countryController,
                                  validator: (value) => value == null || value.isEmpty
                                      ? AppLocalizations.of(context)!.countryIsRequired
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.mdVertical),
                  Obx(
                    () => controller.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : PrimaryButtonV2(
                            text: controller.isEditMode.value
                                ? AppLocalizations.of(context)!.updateAddress
                                : AppLocalizations.of(context)!.saveAddress,
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) return;

                              if (controller.isEditMode.value) {
                                controller.updateAddress(id!);
                              } else {
                                await controller.addAddress();
                              }
                              Get.back();
                              _loadAddresses();
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(BuildContext context, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xsVertical),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColorsV2.textSecondary,
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        fillColor: AppColorsV2.inputBackground,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          borderSide: BorderSide(color: AppColorsV2.inputBorderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          borderSide: BorderSide(color: AppColorsV2.inputBorderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          borderSide: BorderSide(color: AppColorsV2.primary, width: 1.5),
        ),
      ),
    );
  }
}

