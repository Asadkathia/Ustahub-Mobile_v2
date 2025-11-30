import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/network/supabase_api_services.dart';
import 'package:ustahub/app/modules/provider_portfolio/model/portfolio_model.dart';

class PortfolioRepository {
  final _apiServices = SupabaseApiServices();

  /// Get portfolios for a provider
  Future<List<PortfolioModel>> getPortfolios(
    String providerId, {
    String? serviceId,
  }) async {
    try {
      final response = await _apiServices.getProviderPortfolios(
        providerId,
        serviceId: serviceId,
      );

      if (response['statusCode'] == 200 && response['body']['data'] != null) {
        final List<dynamic> data = response['body']['data'] as List<dynamic>;
        return data
            .map((json) => PortfolioModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('[PORTFOLIO_REPO] Error fetching portfolios: $e');
      return [];
    }
  }

  /// Create a new portfolio
  Future<PortfolioModel?> createPortfolio(Map<String, dynamic> data) async {
    try {
      final response = await _apiServices.createPortfolio(data);

      if (response['statusCode'] == 201 && response['body']['data'] != null) {
        return PortfolioModel.fromJson(
          response['body']['data'] as Map<String, dynamic>,
        );
      }

      return null;
    } catch (e) {
      debugPrint('[PORTFOLIO_REPO] Error creating portfolio: $e');
      return null;
    }
  }

  /// Update an existing portfolio
  Future<PortfolioModel?> updatePortfolio(
    String portfolioId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiServices.updatePortfolio(portfolioId, data);

      if (response['statusCode'] == 200 && response['body']['data'] != null) {
        return PortfolioModel.fromJson(
          response['body']['data'] as Map<String, dynamic>,
        );
      }

      return null;
    } catch (e) {
      debugPrint('[PORTFOLIO_REPO] Error updating portfolio: $e');
      return null;
    }
  }

  /// Delete a portfolio
  Future<bool> deletePortfolio(String portfolioId) async {
    try {
      final response = await _apiServices.deletePortfolio(portfolioId);

      return response['statusCode'] == 200;
    } catch (e) {
      debugPrint('[PORTFOLIO_REPO] Error deleting portfolio: $e');
      return false;
    }
  }
}

