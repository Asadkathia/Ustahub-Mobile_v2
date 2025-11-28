import 'package:ustahub/app/export/exports.dart';

class ConsumerProfileSetupView extends StatelessWidget {
  ConsumerProfileSetupView({super.key});

  final controller = Get.put(ConsumerProfileSetupController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              30.ph,
              // const BackButton(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.profileSetup,
                        style: GoogleFonts.ubuntu(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.blackText,
                        ),
                      ),
                      5.ph,
                      Text(
                        AppLocalizations.of(context)!.pleaseCarefully,
                        style: GoogleFonts.ubuntu(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.grey,
                        ),
                      ),
                      15.ph,
                      ProfileSetupImageUploadContainer(controller: controller),
                      20.ph,
                      titleText(title: AppLocalizations.of(context)!.name),
                      5.ph,
                      buildFormField(
                        hint: AppLocalizations.of(context)!.enterName,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Name is required";
                          }
                          return null;
                        },
                        controller: controller.nameController,
                      ),
                      15.ph,
                      Text(
                        "Fill your address details",
                        style: GoogleFonts.ubuntu(
                          fontSize: 20.sp,
                          color: AppColors.grey,
                        ),
                      ),
                      10.ph,
                      titleText(
                        title: "Flat, House no. Building, Company, Apartment",
                      ),
                      5.ph,
                      buildFormField(
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "This field is required";
                          }
                          return null;
                        },
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
                                titleText(title: "Pin Code"),
                                5.ph,
                                buildFormField(
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Pin Code is required";
                                    } else if (value.length < 4) {
                                      return "Enter valid Pin Code";
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  inputFormatter: [
                                    LengthLimitingTextInputFormatter(8),
                                  ],
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
                                titleText(title: "Town/City"),
                                5.ph,
                                buildFormField(
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "City is required";
                                    }
                                    return null;
                                  },
                                  // hint: "Karachi",
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
                                titleText(title: "State"),
                                5.ph,
                                buildFormField(
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "State is required";
                                    }
                                    return null;
                                  },
                                  // hint: "Sindh",
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
                                titleText(title: "Country"),
                                5.ph,
                                Obx(
                                  () => GestureDetector(
                                    onTap: () {
                                      showCountryPicker(
                                        countryListTheme: CountryListThemeData(
                                          margin: EdgeInsets.all(20.h),
                                        ),
                                        context: context,
                                        showPhoneCode: false,

                                        onSelect: (Country country) {
                                          controller.selectedCountry.value =
                                              country.name;
                                          controller.countryController.text =
                                              country.name;
                                          print(country.name);
                                        },
                                      );
                                    },
                                    child: AbsorbPointer(
                                      child: buildFormField(
                                        hint: "Select Country",
                                        controller: TextEditingController(
                                          text:
                                              controller.selectedCountry.value,
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return "Country is required";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: titleText(
                          title: AppLocalizations.of(context)!.or,
                        ),
                      ),
                      10.ph,
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
                                        "Fetching location...",
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

                      100.ph,
                      Obx(
                        () =>
                            controller.isLoading.value
                                ? Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.green,
                                  ),
                                )
                                : BuildBasicButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      controller.setupProfile();
                                    }
                                  },
                                  title: AppLocalizations.of(context)!.conti,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
