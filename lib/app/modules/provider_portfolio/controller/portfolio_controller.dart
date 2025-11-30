import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/provider_portfolio/repository/portfolio_repository.dart';
import 'package:ustahub/app/modules/provider_portfolio/model/portfolio_model.dart';

class PortfolioController extends GetxController {
  final PortfolioRepository _repository = PortfolioRepository();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<PortfolioModel> portfolios = <PortfolioModel>[].obs;

  // Current provider ID
  final RxString providerId = ''.obs;
  final RxString serviceId = ''.obs;

  /// Initialize controller with provider ID
  void initialize(String providerId, {String? serviceId}) {
    this.providerId.value = providerId;
    this.serviceId.value = serviceId ?? '';
    getPortfolios();
  }

  /// Fetch portfolios for the current provider
  Future<void> getPortfolios() async {
    if (providerId.value.isEmpty) return;

    try {
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';

      final result = await _repository.getPortfolios(
        providerId.value,
        serviceId: serviceId?.value,
      );

      portfolios.value = result;
    } catch (e) {
      isError.value = true;
      errorMessage.value = e.toString();
      debugPrint('[PORTFOLIO_CONTROLLER] Error fetching portfolios: $e');
      CustomToast.error('Failed to load portfolios');
    } finally {
      isLoading.value = false;
    }
  }

  /// Create a new portfolio
  Future<bool> createPortfolio(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';

      final result = await _repository.createPortfolio(data);

      if (result != null) {
        portfolios.add(result);
        CustomToast.success('Portfolio created successfully');
        return true;
      } else {
        throw Exception('Failed to create portfolio');
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = e.toString();
      debugPrint('[PORTFOLIO_CONTROLLER] Error creating portfolio: $e');
      CustomToast.error('Failed to create portfolio');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update an existing portfolio
  Future<bool> updatePortfolio(
    String portfolioId,
    Map<String, dynamic> data,
  ) async {
    try {
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';

      final result = await _repository.updatePortfolio(portfolioId, data);

      if (result != null) {
        final index = portfolios.indexWhere((p) => p.id == portfolioId);
        if (index != -1) {
          portfolios[index] = result;
        }
        CustomToast.success('Portfolio updated successfully');
        return true;
      } else {
        throw Exception('Failed to update portfolio');
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = e.toString();
      debugPrint('[PORTFOLIO_CONTROLLER] Error updating portfolio: $e');
      CustomToast.error('Failed to update portfolio');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete a portfolio
  Future<bool> deletePortfolio(String portfolioId) async {
    try {
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';

      final success = await _repository.deletePortfolio(portfolioId);

      if (success) {
        portfolios.removeWhere((p) => p.id == portfolioId);
        CustomToast.success('Portfolio deleted successfully');
        return true;
      } else {
        throw Exception('Failed to delete portfolio');
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = e.toString();
      debugPrint('[PORTFOLIO_CONTROLLER] Error deleting portfolio: $e');
      CustomToast.error('Failed to delete portfolio');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh portfolios
  Future<void> refreshPortfolios() async {
    await getPortfolios();
  }

  /// Get featured portfolios
  List<PortfolioModel> get featuredPortfolios =>
      portfolios.where((p) => p.isFeatured).toList();

  /// Get portfolios by service
  List<PortfolioModel> getPortfoliosByService(String serviceId) =>
      portfolios.where((p) => p.serviceId == serviceId).toList();
}

