import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../data/Exceptions/exceptions.dart';
import 'base_api_services.dart';

class NetworkApiServices extends BaseApiServices {
  @override
  Future<dynamic> getApi(String url, {dynamic headersData}) async {
    if (kDebugMode) {
      print("🌐 GET URL: $url");
      print("📋 Headers: $headersData");
    }
    dynamic response;

    try {
      response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', ...headersData},
      );

      if (kDebugMode) {
        print("📊 Response Status: ${response.statusCode}");
        print("📄 Response Body: ${response.body}");
      }

      return _handleResponse(response);
    } on SocketException {
      print("❌ Network Error: No internet connection");
      throw InternetException('No internet connection');
    } on RequestTimeOut {
      print("⏱️ Request Timeout");
      throw RequestTimeOut('Request timeout');
    } catch (e) {
      print("💥 Unexpected Error: $e");
      rethrow;
    }
  }

  @override
  Future<dynamic> postApi(var data, String url, dynamic headerData) async {
    print("Api called Post");
    if (kDebugMode) {
      print("🌐 URL: $url");
      print("📤 Request Data: $data");
      print("📋 Headers: $headerData");
    }
    dynamic response;
    try {
      response = await http.post(
        Uri.parse(url),
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json',
          "Accept": "application/json",
          ...headerData,
        },
      );

      if (kDebugMode) {
        print("📊 Response Status: ${response.statusCode}");
        print("📄 Response Body: ${response.body}");
      }

      if (response.statusCode == 302 || response.statusCode == 301) {
        print("🔄 Redirecting to: ${response.headers['location']}");
      }

      // Handle different status codes
      return _handleResponse(response);
    } on SocketException {
      print("❌ Network Error: No internet connection");
      throw InternetException('No internet connection');
    } on RequestTimeOut {
      print("⏱️ Request Timeout");
      throw RequestTimeOut('Request timeout');
    } catch (e) {
      print("💥 Unexpected Error: $e");
      rethrow;
    }
  }

  /// Enhanced response handler with better error categorization
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    try {
      final jsonBody = jsonDecode(body);

      if (kDebugMode) {
        if (statusCode >= 400) {
          print("🚨 API Error Response:");
          print("   Status Code: $statusCode");
          print("   Error Message: ${jsonBody['message'] ?? 'Unknown error'}");
          if (jsonBody['exception'] != null) {
            print("   Exception: ${jsonBody['exception']}");
          }
          if (jsonBody['errors'] != null) {
            print("   Validation Errors: ${jsonBody['errors']}");
          }
        }
      }

      return {'statusCode': statusCode, 'body': jsonBody};
    } catch (e) {
      // If response is not valid JSON, return raw body
      print("⚠️ Response is not valid JSON: $body");
      return {
        'statusCode': statusCode,
        'body': {'message': body, 'raw_response': true},
      };
    }
  }

  // delete api

  Future<dynamic> deleteApi(String url, dynamic headerData) async {
    print("Api called DELETE");
    if (kDebugMode) {
      print("🌐 DELETE URL: $url");
      print("📋 Headers: $headerData");
    }

    dynamic response;
    try {
      response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', ...headerData},
      );

      if (kDebugMode) {
        print("📊 Response Status: ${response.statusCode}");
        print("📄 Response Body: ${response.body}");
      }

      return _handleResponse(response);
    } on SocketException {
      print("❌ Network Error: No internet connection");
      throw InternetException('No internet connection');
    } on RequestTimeOut {
      print("⏱️ Request Timeout");
      throw RequestTimeOut('Request timeout');
    } catch (e) {
      print("💥 Unexpected Error: $e");
      rethrow;
    }
  }

  /// ✅ PUT API
  Future<dynamic> putApi(var data, String url, dynamic headerData) async {
    print("Api called PUT");
    if (kDebugMode) {
      print("🌐 PUT URL: $url");
      print("📤 Request Data: $data");
      print("📋 Headers: $headerData");
    }
    dynamic response;
    try {
      response = await http.put(
        Uri.parse(url),
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json', ...headerData},
      );

      if (kDebugMode) {
        print("📊 Response Status: ${response.statusCode}");
        print("📄 Response Body: ${response.body}");
      }

      return _handleResponse(response);
    } on SocketException {
      print("❌ Network Error: No internet connection");
      throw InternetException('No internet connection');
    } on RequestTimeOut {
      print("⏱️ Request Timeout");
      throw RequestTimeOut('Request timeout');
    } catch (e) {
      print("💥 Unexpected Error: $e");
      rethrow;
    }
  }

  @override
  Future<dynamic> uploadMultipart(
    String url,
    Map<String, String> fields,
    List<http.MultipartFile>? files, {
    Map<String, String>? headers,
  }) async {
    try {
      print("📤 Uploading to: $url");
      print("📩 Fields: $fields");

      var uri = Uri.parse(url);
      var request = http.MultipartRequest('POST', uri);
      request.fields.addAll(fields);

      // Add headers if provided
      if (headers != null) {
        request.headers.addAll(headers);
      }

      // Add files only if they are present
      if (files != null && files.isNotEmpty) {
        print("📂 Uploading ${files.length} files...");
        request.files.addAll(files);
      } else {
        print("⚠️ No files to upload.");
      }

      print("🚀 Sending Request...");

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print("📊 Upload Response Status: ${response.statusCode}");
        print("� Upload Response Body: ${response.body}");
      }

      // Use the enhanced response handler
      return _handleResponse(response);
    } on SocketException {
      print("❌ Network Error: No internet connection");
      throw InternetException('No internet connection');
    } on RequestTimeOut {
      print("⏱️ Request Timeout");
      throw RequestTimeOut('Request timeout');
    } catch (e) {
      print("🔥 Upload Error: $e");
      throw Exception('Failed to upload: $e');
    }
  }

  dynamic returnresponse(http.Response response) {
    print(response.body.toString());
    switch (response.statusCode) {
      case 201:
      case 200:
        return {
          "statusCode": response.statusCode, // Include status code
          "body": jsonDecode(response.body), // Decode JSON body
        };
      case 400:
        return {
          "statusCode": response.statusCode, // Include status code
          "body": jsonDecode(response.body), // Decode JSON body
        };
      case 422:
        return {
          "statusCode": response.statusCode, // Include status code
          "body": jsonDecode(response.body), // Decode JSON body
        };
      default:
        FetchDataException(
          'Error occured while communication with server${response.statusCode}',
        );
    }
  }
}
