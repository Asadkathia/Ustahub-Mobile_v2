// Flutter Inbuilt
export 'dart:io';
export 'package:flutter/foundation.dart';
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';

// Firebase
export 'package:firebase_core/firebase_core.dart';
export 'package:firebase_messaging/firebase_messaging.dart';
export 'package:firebase_notifications_handler/firebase_notifications_handler.dart';

// Chat & Communication (Supabase-based)
export 'package:ustahub/app/modules/chat/view/chat_view.dart';

// External Packages
export 'package:shimmer_ai/shimmer_ai.dart';
export 'package:maps_launcher/maps_launcher.dart';
export 'package:country_picker/country_picker.dart';
export 'package:flutter_screenutil/flutter_screenutil.dart';
export 'package:carousel_slider/carousel_slider.dart';
export 'package:flutter_svg/flutter_svg.dart';
export 'package:google_fonts/google_fonts.dart';
export 'package:intl_phone_number_input/intl_phone_number_input.dart';
export 'package:pinput/pinput.dart';
export 'package:get/get.dart' hide HeaderValue;
export 'package:image_picker/image_picker.dart';
export 'package:flutter_localizations/flutter_localizations.dart';
export 'package:turkmen_localization_support/turkmen_localization_support.dart';
export 'package:dotted_border/dotted_border.dart';
export 'package:table_calendar/table_calendar.dart';
export 'package:fluttertoast/fluttertoast.dart';
export 'package:shimmer/shimmer.dart' hide ShimmerDirection;

// Custom Widgets or Utils
export 'package:ustahub/components/custom_toast.dart';
export 'package:ustahub/components/build_basic_button.dart';
export 'package:ustahub/components/build_form_field.dart';
export 'package:ustahub/components/custom_dotted_line.dart';
export 'package:ustahub/components/widgets.dart';
export 'package:ustahub/components/shimmers.dart';
export 'package:ustahub/components/custom_app_bar.dart';
export 'package:ustahub/components/safe_page_indicator.dart';
export 'package:ustahub/app/modules/upload_file/upload_file.dart';

// Utils & Theme
export 'package:ustahub/utils/assets/app_vectors.dart';
export 'package:ustahub/utils/contstants/constants.dart';
export 'package:ustahub/utils/theme/app_colors.dart';
export 'package:ustahub/utils/api_error_handler.dart';
export 'package:ustahub/utils/sharedPrefHelper/sharedPrefHelper.dart';
export 'package:ustahub/utils/theme/app_theme.dart';
export 'package:ustahub/generated/l10n/app_localizations.dart';

// Network & API
export 'package:ustahub/network/network_api_services.dart';
export 'package:ustahub/network/supabase_client.dart';
export 'package:ustahub/network/supabase_api_services.dart';
export 'package:ustahub/utils/apiEndPoints/apiEndPoints.dart';

// Controllers
export 'package:ustahub/app/modules/Auth/login/controller/login_controller.dart';
export 'package:ustahub/app/modules/Auth/OTP/controller/otp_controller.dart';
export 'package:ustahub/app/modules/language/controller/language_controller.dart';
export 'package:ustahub/app/modules/consumer_profile_setup/controller/consumer_profile_setup_controller.dart';
export 'package:ustahub/app/modules/provider_profile_setup/controller/provider_profile_setup_controller.dart';
export 'package:ustahub/app/modules/provider_addresss_setup/controller/provider_address_setup_controller.dart';
export 'package:ustahub/app/modules/provider_details/controller/plan_selection_controller.dart';
export 'package:ustahub/app/modules/provider_details/controller/provider_details_controller.dart';
export 'package:ustahub/app/modules/search/controller/search_controller.dart';
export 'package:ustahub/app/modules/bookings/controller/booking_controller.dart';
export 'package:ustahub/app/modules/consumer_edit_profile/controller/consumer_edit_profile_controller.dart';
export 'package:ustahub/app/modules/consumer_homepage/controller/consumer_homepage_controller.dart';
export 'package:ustahub/app/modules/provider_service_request_details/controller/provider_service_request_controller.dart';
export 'package:ustahub/app/modules/provider_bookings/controller/provider_bookings_controller.dart';
export 'package:ustahub/app/modules/common_controller.dart/provider_controller.dart';
export 'package:ustahub/app/modules/consumer_profile/controller/consumer_profile_controller.dart';
export 'package:ustahub/app/modules/favourite_providers/controller/favourite_provider_controller.dart';
export 'package:ustahub/app/modules/provider_profile/controller/provider_profile_controller.dart';
export 'package:ustahub/app/modules/provider_service_selection/controller/provider_service_selection_controller.dart';
export 'package:ustahub/app/modules/booking_request/controller/booking_request_controller.dart';
export 'package:ustahub/app/modules/checkout/controller/checkout_controller.dart';
export 'package:ustahub/app/modules/filter/controller/filter_controller.dart';
export 'package:ustahub/app/modules/nav_bar/controller/nav_bar_controller.dart';
export 'package:ustahub/app/modules/banners/controller/banner_controller.dart';
export 'package:ustahub/app/modules/provider_completed_booking_details/controller/booking_details_controller.dart';
export 'package:ustahub/app/modules/provider_completed_booking_details/controller/provider_complete_work_controller.dart';
export 'package:ustahub/app/modules/provider_completed_booking_details/controller/start_work_controller.dart';
export 'package:ustahub/app/modules/note_view/controller/note_view_controller.dart';
export 'package:ustahub/app/modules/note_view/controller/notes_controller.dart';
export 'package:ustahub/app/modules/provider_document/controller/document_controller.dart';
export 'package:ustahub/app/modules/wallet/controller/wallet_controller.dart';
export 'package:ustahub/app/modules/provider_bookings/controller/booking_history_controller.dart';
export 'package:ustahub/app/modules/bookings/controller/consumer_booking_history_controller.dart';
export 'package:ustahub/app/modules/rating/controller/rating_controller.dart';
export 'package:ustahub/app/modules/provider_details/controller/provider_ratings_controller.dart';
export 'package:ustahub/app/modules/fcm/controller/fcm_controller.dart';
export 'package:ustahub/app/modules/fcm/service/fcm_service.dart';
export 'package:ustahub/app/modules/account/controller/delete_account_controller.dart';

// Views/Pages
export 'package:ustahub/app/modules/Auth/OTP/view/otp_view.dart';
export 'package:ustahub/app/modules/Auth/login/view/login_view.dart';
export 'package:ustahub/app/modules/note_view/view/note_view_modal.dart';
export 'package:ustahub/app/modules/consumer_profile_setup/view/consumer_profile_setup_view.dart';
export 'package:ustahub/app/modules/nav_bar/view/custom_bottom_bar.dart';
export 'package:ustahub/app/modules/consumer_homepage/view/consumer_homepage.dart';
export 'package:ustahub/app/modules/provider_addresss_setup/view/provider_address_setup_view.dart';
export 'package:ustahub/app/modules/onboarding/view/onboarding_view.dart';
export 'package:ustahub/app/modules/provider_profile_setup/view/provider_profile_setup_view.dart';
export 'package:ustahub/app/modules/checkout/view/checkout_view.dart';
export 'package:ustahub/app/modules/provider_details/view/provider_details_screen.dart';
export 'package:ustahub/app/modules/rating/view/rating_view.dart';
export 'package:ustahub/app/modules/consumer_edit_profile/view/consumer_edit_profile_view.dart';
export 'package:ustahub/app/modules/favourite_providers/view/favourite_providers_view.dart';
export 'package:ustahub/app/modules/language/view/language_view.dart';
export 'package:ustahub/app/modules/manage_address/view/manage_address_view.dart';
export 'package:ustahub/app/modules/provider_service_selection/view/provider_service_selection_view.dart';
export 'package:ustahub/app/modules/provider_homepage/view/provider_homepage_view.dart';
export 'package:ustahub/app/modules/provider_service_request_details/view/provider_service_request_details_view.dart';
export 'package:ustahub/app/modules/splash/splash_view.dart';

// Repositories
export 'package:ustahub/app/modules/Auth/login/repository/login_repository.dart';
export 'package:ustahub/app/modules/service_selection_for_plan/repository/service_selection_for_plan_repository.dart';
export 'package:ustahub/app/modules/banners/repository/banner_repository.dart';
export 'package:ustahub/app/modules/note_view/repository/note_repository.dart';
export 'package:ustahub/app/modules/note_view/repository/notes_repository.dart';
export 'package:ustahub/app/modules/provider_document/repository/document_repository.dart';
export 'package:ustahub/app/modules/wallet/repository/wallet_repository.dart';
export 'package:ustahub/app/modules/provider_bookings/repository/booking_history_repository.dart';
export 'package:ustahub/app/modules/bookings/repository/consumer_booking_history_repository.dart';
export 'package:ustahub/app/modules/rating/repository/rating_repository.dart';
export 'package:ustahub/app/modules/provider_details/repository/provider_ratings_repository.dart';
export 'package:ustahub/app/modules/account/repository/account_respository.dart';

// Models
export 'package:ustahub/app/modules/provider_service_selection/model_class/service_model_class.dart';
export 'package:ustahub/app/modules/common_model_class/banner_model_class.dart';
export 'package:ustahub/app/modules/note_view/model/note_model.dart';
export 'package:ustahub/app/modules/provider_document/model/document_model.dart';
export 'package:ustahub/app/modules/wallet/model/wallet_model.dart';
export 'package:ustahub/app/modules/provider_bookings/model/booking_history_model.dart';
export 'package:ustahub/app/modules/bookings/model_class/consumer_booking_history_model.dart';
export 'package:ustahub/app/modules/rating/model/rating_model.dart';
export 'package:ustahub/app/modules/provider_details/model_class/provider_ratings_model.dart';
export 'package:ustahub/app/modules/provider_completed_booking_details/model_class/Booking_details_model_class.dart'
    hide Service;
