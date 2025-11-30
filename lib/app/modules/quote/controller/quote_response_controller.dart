import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/quote/repository/quote_repository.dart';
import 'package:ustahub/app/modules/quote/model/quote_model.dart';

class QuoteResponseController extends GetxController {
  final QuoteRepository _repository = QuoteRepository();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<QuoteRequestModel> availableQuotes = <QuoteRequestModel>[].obs;

  /// Fetch available quote requests for provider
  Future<void> getAvailableQuotes() async {
    try {
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';

      // Get pending quote requests
      // Note: This would need to be filtered by provider's services
      // For now, we'll get all pending requests
      final result = await _repository.getQuoteRequests(status: 'pending');
      availableQuotes.value = result;
    } catch (e) {
      isError.value = true;
      errorMessage.value = e.toString();
      debugPrint('[QUOTE_RESPONSE_CONTROLLER] Error fetching quotes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Respond to a quote request
  Future<bool> respondToQuote(
    String quoteRequestId,
    Map<String, dynamic> data,
  ) async {
    try {
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';

      final result = await _repository.respondToQuote(quoteRequestId, data);

      if (result != null) {
        // Remove from available quotes
        availableQuotes.removeWhere((q) => q.id == quoteRequestId);
        CustomToast.success('Quote response submitted successfully');
        return true;
      } else {
        throw Exception('Failed to submit quote response');
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = e.toString();
      debugPrint('[QUOTE_RESPONSE_CONTROLLER] Error responding to quote: $e');
      CustomToast.error('Failed to submit quote response');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh available quotes
  Future<void> refreshAvailableQuotes() async {
    await getAvailableQuotes();
  }
}

