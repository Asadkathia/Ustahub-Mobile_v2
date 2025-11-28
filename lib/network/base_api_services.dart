import 'package:http/http.dart' as http;

abstract class BaseApiServices {
  Future<dynamic> getApi(String url);

  Future<dynamic> postApi(dynamic data, String url, dynamic headerData);

  Future<dynamic> uploadMultipart(
    String url,
    Map<String, String> fields,
    List<http.MultipartFile>? files, {
    Map<String, String>? headers,
  });
}
