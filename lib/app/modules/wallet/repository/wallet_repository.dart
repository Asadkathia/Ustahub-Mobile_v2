import 'package:ustahub/network/supabase_api_services.dart';

class WalletRepository {
  final _api = SupabaseApiServices();

  Future<dynamic> addFunds({required String amount}) async {
    try {
      final amountDouble = double.tryParse(amount);
      if (amountDouble == null) {
        throw Exception('Invalid amount');
      }

      // Use Edge Function for wallet operations
      final response = await _api.walletAction(
        'add_funds',
        amount: amountDouble,
        description: 'Funds added to wallet',
      );

      return response;
    } catch (e) {
      print('[WALLET] ❌ Error adding funds: $e');
      throw Exception('Failed to add funds: $e');
    }
  }

  // Get wallet balance and transactions
  Future<dynamic> getWalletBalance() async {
    try {
      print('[WALLET] Fetching wallet balance...');

      // Use Edge Function
      final response = await _api.walletAction('get_balance');

      print('[WALLET] ✅ Balance response: $response');
      return response;
    } catch (e) {
      print('[WALLET] ❌ Error fetching balance: $e');
      throw Exception('Failed to fetch wallet balance: $e');
    }
  }

  // Get wallet transactions
  Future<dynamic> getWalletTransactions() async {
    try {
      final response = await _api.walletAction('get_transactions');
      return response;
    } catch (e) {
      print('[WALLET] ❌ Error fetching transactions: $e');
      throw Exception('Failed to fetch transactions: $e');
    }
  }
}
