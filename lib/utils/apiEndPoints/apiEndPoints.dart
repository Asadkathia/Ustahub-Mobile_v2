class ApiConstants {
  static const String BASE_URL = 'https://api.ustahub.net/api/';
//   static const String BASE_URL = 'http://15.207.55.5/api/';

  static _AuthEndPoints authEndPoints = _AuthEndPoints();
  static String get providerBookings => '${BASE_URL}provider/get-bookings';
}

class _AuthEndPoints {
  // Consumer
  String consumerEmailLogin = '${ApiConstants.BASE_URL}user/auth/email';
  String consumerUpdateProfileInfo =
      '${ApiConstants.BASE_URL}user/profile-update';
  String consumerAddAddress = '${ApiConstants.BASE_URL}user/addresses';
  String consumerUpdateAddress = '${ApiConstants.BASE_URL}user/addresses/';
  String serviceCategories = '${ApiConstants.BASE_URL}get-services';
  String consumerLogout = '${ApiConstants.BASE_URL}user/logout';
  String consumerSetDefaultAddress =
      '${ApiConstants.BASE_URL}user/set-default-address/';
  String consumerGetProviders = "${ApiConstants.BASE_URL}user/get-providers";
  String consumerFavouriteProvider =
      "${ApiConstants.BASE_URL}user/favorite-provider";
  String getProviderById = "${ApiConstants.BASE_URL}user/get-provider-by-id/";
  String getBookingTimeSlots =
      "${ApiConstants.BASE_URL}user/get-booking-slots?provider_id=";
  String bookServie = "${ApiConstants.BASE_URL}user/book-service";
  String getConsumerBookings = "${ApiConstants.BASE_URL}user/get-bookings";
  String consumerProfile = "${ApiConstants.BASE_URL}user/profile";
  String consumerBookingDetails =
      "${ApiConstants.BASE_URL}user/get-booking-details/";
  String getBanners = "${ApiConstants.BASE_URL}banners";
  String consumerVerifyEmail = "${ApiConstants.BASE_URL}user/auth/verify";
  String searchProviders = "${ApiConstants.BASE_URL}user/search";
  String storeFcmToken = "${ApiConstants.BASE_URL}store-fcm-token";

  // Provider
  String providerEmailLogin = '${ApiConstants.BASE_URL}provider/auth/email';
  String providerAddAddress = '${ApiConstants.BASE_URL}provider/addresses';
  String providerUpdateAddress = '${ApiConstants.BASE_URL}provider/addresses/';
  String providerServiceAdd = '${ApiConstants.BASE_URL}provider/add-service';
  String providerSetupProfile = '${ApiConstants.BASE_URL}provider/profile';
  String providerLogout = '${ApiConstants.BASE_URL}provider/logout';
  String providerSetDefaultAddress =
      '${ApiConstants.BASE_URL}provider/set-default-address/';
  String providerGetServices = '${ApiConstants.BASE_URL}provider/my-services';
  String providerSetPlans = "${ApiConstants.BASE_URL}provider/set-plans";
  String providerMyPlans = "${ApiConstants.BASE_URL}provider/my-plans";
  String providerGetBookingsRequest =
      "${ApiConstants.BASE_URL}provider/get-booking-request";
  String providerGetProfile = "${ApiConstants.BASE_URL}provider/profile";
  String providerHomeScreenData =
      "${ApiConstants.BASE_URL}provider/get-home-screen-data";
  String providerAcceptOrReject =
      "${ApiConstants.BASE_URL}provider/accept-or-reject-booking";
  String providerStartWork =
      "${ApiConstants.BASE_URL}provider/start-booking-service";
  String providerCompleteBooking =
      "${ApiConstants.BASE_URL}provider/complete-booking";
  String providerBookingDetails =
      "${ApiConstants.BASE_URL}provider/get-booking-details/";
  String addNotesOnBooking = "${ApiConstants.BASE_URL}add-notes-on-booking/";
  String providerGetDocuments =
      "${ApiConstants.BASE_URL}provider/get-documents";
  String providerAddFunds = "${ApiConstants.BASE_URL}provider/wallet/add-funds";
  String providerWalletBalance =
      "${ApiConstants.BASE_URL}provider/wallet/balance";
  String providerBookingHistory =
      "${ApiConstants.BASE_URL}provider/get-booking-history";
  String consumerBookingHistory =
      "${ApiConstants.BASE_URL}user/get-booking-history";
  String rateProvider = "${ApiConstants.BASE_URL}user/rate-provider";
  String getProviderRatings = "${ApiConstants.BASE_URL}user/get-ratings/";
  String providerVerifyEmail = "${ApiConstants.BASE_URL}provider/auth/verify";

  // delete account

  String deleteConsumerAccount = "${ApiConstants.BASE_URL}user/delete-account"; 
  String deleteProviderAccount = "${ApiConstants.BASE_URL}provider/delete-account";
}
