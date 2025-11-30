import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/network/supabase_api_services.dart';
import 'package:ustahub/network/supabase_client.dart';
import 'package:ustahub/app/modules/common_model_class/ProviderListModelClass.dart';
import 'package:ustahub/app/ui_v2/screens/guest/login_required_screen_v2.dart';

class FavouriteProviderController extends GetxController {
  RxList<ProvidersListModelClass> favouriteProvidersList =
      <ProvidersListModelClass>[].obs;
  /// Check authentication and role
  Future<bool> _checkAuth({required String requiredRole}) async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) {
      Get.to(() => LoginRequiredScreenV2(feature: 'Favorites'));
      return false;
    }
    final role = await Sharedprefhelper.getRole();
    if (requiredRole == 'consumer' && role != 'consumer') {
      CustomToast.error('This feature is only available for consumers');
      return false;
    }
    if (requiredRole == 'provider' && role != 'provider') {
      CustomToast.error('This feature is only available for providers');
      return false;
    }
    return true;
  }

  Future<void> getFavouriteProviders() async {
    // Check authentication before proceeding
    if (!await _checkAuth(requiredRole: 'consumer')) {
      return;
    }
    
    isLoading.value = true;
    try {
      final supabase = SupabaseClientService.instance;
      final userId = SupabaseClientService.currentUserId;

      final favoritesResponse = await supabase
          .from('favorites')
          .select('provider_id')
          .eq('consumer_id', userId!);

      if (favoritesResponse.isEmpty) {
        favouriteProvidersList.clear();
        return;
      }

      final providerIds = (favoritesResponse as List)
          .map((e) => e['provider_id'] as String)
          .toList();

      final providerResponses =
          await Future.wait(providerIds.map((id) => _api.getProviderById(id)));

      final providers = providerResponses
          .where((res) => res['statusCode'] == 200)
          .map((res) => res['body']['data'])
          .whereType<Map<String, dynamic>>()
          .toList();

      favouriteProvidersList.value = providers
          .map((e) => ProvidersListModelClass.fromJson(e))
          .toList();
    } catch (e) {
      print('[FAVORITES] ❌ Error: $e');
      CustomToast.error('Error fetching favorites');
    } finally {
      isLoading.value = false;
    }
  }

  RxBool isLoading = false.obs;

  final _api = SupabaseApiServices();

  Future<void> favouriteToggle({required String id}) async {
    // Check authentication before proceeding
    if (!await _checkAuth(requiredRole: 'consumer')) {
      return;
    }
    
    isLoading.value = true;

    try {
      final response = await _api.toggleFavorite(id);
      
      if (response['statusCode'] == 200) {
        final isFavorite = response['body']['data']?['is_favorite'] ?? false;
        if (isFavorite) {
          CustomToast.success('Added to favorites');
        } else {
          CustomToast.success('Removed from favorites');
        }
        // Refresh favorites list
        getFavouriteProviders();
      } else {
        CustomToast.error(
          response['body']['message'] ?? 'Failed to update favorite'
        );
      }
    } catch (e) {
      print('[FAVORITES] ❌ Error: $e');
      CustomToast.error('Error updating favorite');
    } finally {
      isLoading.value = false;
    }
  }

  // Get All Favourite Providers
}
