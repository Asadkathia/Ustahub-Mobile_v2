import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/network/supabase_api_services.dart';
import 'package:ustahub/app/modules/quote/model/quote_model.dart';

class QuoteRepository {
  final _apiServices = SupabaseApiServices();

  /// Create a quote request
  Future<QuoteRequestModel?> createQuoteRequest(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiServices.createQuoteRequest(data);

      if (response['statusCode'] == 201 && response['body']['data'] != null) {
        return QuoteRequestModel.fromJson(
          response['body']['data'] as Map<String, dynamic>,
        );
      }

      return null;
    } catch (e) {
      debugPrint('[QUOTE_REPO] Error creating quote request: $e');
      return null;
    }
  }

  /// Get quote requests for current user
  Future<List<QuoteRequestModel>> getQuoteRequests({String? status}) async {
    try {
      final response = await _apiServices.getQuoteRequests(status: status);

      if (response['statusCode'] == 200 && response['body']['data'] != null) {
        final List<dynamic> data = response['body']['data'] as List<dynamic>;
        return data
            .map((json) => QuoteRequestModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('[QUOTE_REPO] Error fetching quote requests: $e');
      return [];
    }
  }

  /// Respond to a quote request
  Future<QuoteResponseModel?> respondToQuote(
    String quoteRequestId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiServices.respondToQuote(quoteRequestId, data);

      if (response['statusCode'] == 201 && response['body']['data'] != null) {
        return QuoteResponseModel.fromJson(
          response['body']['data'] as Map<String, dynamic>,
        );
      }

      return null;
    } catch (e) {
      debugPrint('[QUOTE_REPO] Error responding to quote: $e');
      return null;
    }
  }

  /// Get responses for a quote request
  Future<List<QuoteResponseModel>> getQuoteResponses(
    String quoteRequestId,
  ) async {
    try {
      final response = await _apiServices.getQuoteResponses(quoteRequestId);

      if (response['statusCode'] == 200 && response['body']['data'] != null) {
        final List<dynamic> data = response['body']['data'] as List<dynamic>;
        return data
            .map((json) => QuoteResponseModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('[QUOTE_REPO] Error fetching quote responses: $e');
      return [];
    }
  }

  /// Get price range for a service
  Future<PriceRangeModel?> getServicePriceRange(String serviceId) async {
    try {
      final response = await _apiServices.getServicePriceRange(serviceId);

      if (response['statusCode'] == 200 && response['body']['data'] != null) {
        return PriceRangeModel.fromJson(
          response['body']['data'] as Map<String, dynamic>,
        );
      }

      return null;
    } catch (e) {
      debugPrint('[QUOTE_REPO] Error fetching price range: $e');
      return null;
    }
  }

  /// Compare provider prices
  Future<List<ProviderPriceComparisonModel>> compareProviderPrices(
    List<String> providerIds,
    String serviceId,
  ) async {
    try {
      final response = await _apiServices.compareProviderPrices(
        providerIds,
        serviceId,
      );

      if (response['statusCode'] == 200 && response['body']['data'] != null) {
        final List<dynamic> data = response['body']['data'] as List<dynamic>;
        return data
            .map((json) => ProviderPriceComparisonModel.fromJson(
                json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('[QUOTE_REPO] Error comparing prices: $e');
      return [];
    }
  }

  /// Accept a quote response
  Future<bool> acceptQuoteResponse(String quoteResponseId) async {
    try {
      final response = await _apiServices.acceptQuoteResponse(quoteResponseId);

      return response['statusCode'] == 200;
    } catch (e) {
      debugPrint('[QUOTE_REPO] Error accepting quote: $e');
      return false;
    }
  }
}

