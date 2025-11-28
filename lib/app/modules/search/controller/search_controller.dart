import 'package:get/get.dart';
import 'package:ustahub/app/modules/search/model_class/seach_model.dart';
import 'package:ustahub/app/modules/search/services/search_db_services.dart';

class SearchDBController extends GetxController {
  final searches = <SearchModel>[].obs;

  @override
  void onInit() {
    fetchSearches();
    super.onInit();
  }

  Future<void> addSearch(String keyword) async {
    await SearchDBService().insertSearch(keyword);
    fetchSearches();
  }

  Future<void> fetchSearches() async {
    final data = await SearchDBService().getAllSearches();
    searches.value = data;
  }

  Future<void> deleteSearch(int id) async {
    await SearchDBService().deleteSearch(id);
    fetchSearches();
  }

  Future<void> clearAll() async {
    await SearchDBService().clearAll();
    fetchSearches();
  }


  
}
