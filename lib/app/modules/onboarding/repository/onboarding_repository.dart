import 'package:ustahub/app/modules/onboarding/model/onboarding_slide_model.dart';
import 'package:ustahub/network/supabase_api_services.dart';

class OnboardingRepository {
  final SupabaseApiServices _api = SupabaseApiServices();

  Future<List<OnboardingSlideModel>> getSlides({
    String? locale,
    String? audience,
    String? city,
    String? country,
  }) async {
    final response = await _api.getOnboardingSlides(
      locale: locale,
      audience: audience,
      city: city,
      country: country,
    );

    if (response['statusCode'] == 200 && response['body']?['status'] == true) {
      final data = response['body']?['data'] as List<dynamic>? ?? [];
      final slides =
          data
              .map(
                (json) =>
                    OnboardingSlideModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();

      bool matchesLocale(OnboardingSlideModel slide) {
        if (locale == null || locale.isEmpty) return true;
        final slideLocale = slide.locale?.toLowerCase();
        return slideLocale == null ||
            slideLocale == 'all' ||
            slideLocale == locale.toLowerCase();
      }

      bool matchesAudience(OnboardingSlideModel slide) {
        if (audience == null || audience.isEmpty) return true;
        final slideAudience = slide.audience.toLowerCase();
        return slideAudience == 'all' ||
            slideAudience == audience.toLowerCase();
      }

      return slides.where((slide) => matchesLocale(slide) && matchesAudience(slide)).toList();
    }

    final message =
        response['body']?['message']?.toString() ?? 'Failed to load onboarding slides';
    throw message;
  }
}

