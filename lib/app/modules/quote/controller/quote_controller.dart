import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/quote/repository/quote_repository.dart';
import 'package:ustahub/app/modules/quote/model/quote_model.dart';

class QuoteController extends GetxController {
  final QuoteRepository _repository = QuoteRepository();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<QuoteRequestModel> quoteRequests = <QuoteRequestModel>[].obs;
  final RxList<QuoteResponseModel> quoteResponses = <QuoteResponseModel>[].obs;
  final Rx<PriceRangeModel?> priceRange = Rx<PriceRangeModel?>(null);

  /// Create a quote request
  Future<bool> createQuoteRequest(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';

      final result = await _repository.createQuoteRequest(data);

      if (result != null) {
        quoteRequests.insert(0, result);
        CustomToast.success('Quote request created successfully');
        return true;
      } else {
        throw Exception('Failed to create quote request');
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = e.toString();
      debugPrint('[QUOTE_CONTROLLER] Error creating quote request: $e');
      CustomToast.error('Failed to create quote request');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch quote requests
  Future<void> getQuoteRequests({String? status}) async {
    try {
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';

      final result = await _repository.getQuoteRequests(status: status);
      quoteRequests.value = result;
    } catch (e) {
      isError.value = true;
      errorMessage.value = e.toString();
      debugPrint('[QUOTE_CONTROLLER] Error fetching quote requests: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch quote responses for a request
  Future<void> getQuoteResponses(String quoteRequestId) async {
    try {
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';

      final result = await _repository.getQuoteResponses(quoteRequestId);
      quoteResponses.value = result;
    } catch (e) {
      isError.value = true;
      errorMessage.value = e.toString();
      debugPrint('[QUOTE_CONTROLLER] Error fetching quote responses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get price range for a service
  Future<void> getServicePriceRange(String serviceId) async {
    try {
      final result = await _repository.getServicePriceRange(serviceId);
      priceRange.value = result;
    } catch (e) {
      debugPrint('[QUOTE_CONTROLLER] Error fetching price range: $e');
    }
  }

  /// Accept a quote response
  Future<bool> acceptQuoteResponse(String quoteResponseId) async {
    try {
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';

      final success = await _repository.acceptQuoteResponse(quoteResponseId);

      if (success) {
        // Update the response in the list
        final index = quoteResponses.indexWhere((r) => r.id == quoteResponseId);
        if (index != -1) {
          quoteResponses[index] = QuoteResponseModel(
            id: quoteResponses[index].id,
            quoteRequestId: quoteResponses[index].quoteRequestId,
            providerId: quoteResponses[index].providerId,
            price: quoteResponses[index].price,
            description: quoteResponses[index].description,
            estimatedDuration: quoteResponses[index].estimatedDuration,
            isAccepted: true,
            createdAt: quoteResponses[index].createdAt,
            updatedAt: quoteResponses[index].updatedAt,
            provider: quoteResponses[index].provider,
            providerStats: quoteResponses[index].providerStats,
          );
        }
        CustomToast.success('Quote accepted successfully');
        return true;
      } else {
        throw Exception('Failed to accept quote');
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = e.toString();
      debugPrint('[QUOTE_CONTROLLER] Error accepting quote: $e');
      CustomToast.error('Failed to accept quote');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh quote requests
  Future<void> refreshQuoteRequests({String? status}) async {
    await getQuoteRequests(status: status);
  }
}

