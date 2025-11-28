import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/network/supabase_api_services.dart';
import 'package:ustahub/network/supabase_client.dart';
import 'package:ustahub/app/modules/common_model_class/ProviderListModelClass.dart';

class FavouriteProviderController extends GetxController {
  RxList<ProvidersListModelClass> favouriteProvidersList =
      <ProvidersListModelClass>[].obs;
  Future<void> getFavouriteProviders() async {
    isLoading.value = true;
    try {
      final supabase = SupabaseClientService.instance;
      final userId = SupabaseClientService.currentUserId;

      if (userId == null) {
        CustomToast.error('Please login to view favorites');
        return;
      }

      final favoritesResponse = await supabase
          .from('favorites')
          .select('provider_id')
          .eq('consumer_id', userId);

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
