import 'package:ustahub/app/export/exports.dart';

class WalletController extends GetxController {
  final WalletRepository _repository = WalletRepository();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxDouble currentBalance = 0.0.obs;
  final RxList<WalletTransaction> transactions = <WalletTransaction>[].obs;
  final RxBool isLoadingBalance = false.obs;

  // Add funds to wallet
  Future<void> addFunds({required String amount}) async {
    try {
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';

      print('Adding $amount tokens to wallet...');

      final response = await _repository.addFunds(amount: amount);

      print('API Response: $response');

      // Check if the response is successful
      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        final responseBody = response['body'];

        // Handle successful response - check for 'status' field instead of 'success'
        if (responseBody['status'] == true) {
          // Update current balance if provided in response
          if (responseBody != null && responseBody['wallet_balance'] != null) {
            currentBalance.value =
                double.tryParse(responseBody['wallet_balance'].toString()) ??
                currentBalance.value;
          } else {
            // If balance not provided, add the amount to current balance
            currentBalance.value += double.tryParse(amount) ?? 0.0;
          }

          print(
            'Funds added successfully, new balance: ${currentBalance.value}',
          );

          // Show success message using CustomToast
          CustomToast.success("$amount tokens added successfully");

          // Refresh wallet balance and transactions
          await fetchWalletBalance();
        } else {
          // Handle API error response
          final errorMsg = responseBody['message'] ?? 'Failed to add funds';
          print('API Error: $errorMsg');

          isError.value = true;
          errorMessage.value = errorMsg;
          CustomToast.error(errorMsg);
          throw Exception(errorMsg);
        }
      } else {
        // Handle HTTP error response
        final errorMsg = response['body']?['message'] ?? 'Failed to add funds';
        print('HTTP Error: $errorMsg');

        isError.value = true;
        errorMessage.value = errorMsg;
        CustomToast.error(errorMsg);
        throw Exception(errorMsg);
      }
    } catch (e) {
      isError.value = true;
      print('Error adding funds: $e');

      // Show error message using CustomToast
      String errorMsg = 'Failed to add funds';
      if (e.toString().contains('Exception:')) {
        errorMsg = e.toString().replaceAll('Exception: ', '');
      } else {
        errorMsg = 'Failed to add funds: ${e.toString()}';
      }

      errorMessage.value = errorMsg;
      CustomToast.error(errorMsg);
      rethrow; // Re-throw to handle in UI
    } finally {
      isLoading.value = false;
    }
  }

  // Get formatted balance
  String get formattedBalance => currentBalance.value.toStringAsFixed(0);

  // Fetch wallet balance and transactions
  Future<void> fetchWalletBalance() async {
    try {
      isLoadingBalance.value = true;
      isError.value = false;
      errorMessage.value = '';

      print('Fetching wallet balance and transactions...');

      final response = await _repository.getWalletBalance();

      print('Wallet Balance API Response: $response');

      // Check if the response is successful
      if (response['statusCode'] == 200) {
        final responseBody = response['body'];

        // Handle successful response - check for 'status' field
        if (responseBody['status'] == true) {
          // Parse the response using WalletBalanceResponse model
          final walletData = WalletBalanceResponse.fromJson(responseBody);

          // Update current balance
          currentBalance.value = walletData.balanceAsDouble;

          // Update transactions list
          transactions.value = walletData.transactions;

          print('Wallet balance fetched successfully: ${currentBalance.value}');
          print('Transactions count: ${transactions.length}');
        } else {
          // Handle API error response
          final errorMsg =
              responseBody['message'] ?? 'Failed to fetch wallet data';
          print('API Error: $errorMsg');

          isError.value = true;
          errorMessage.value = errorMsg;
          CustomToast.error(errorMsg);
          throw Exception(errorMsg);
        }
      } else {
        // Handle HTTP error response
        final errorMsg =
            response['body']?['message'] ?? 'Failed to fetch wallet data';
        print('HTTP Error: $errorMsg');

        isError.value = true;
        errorMessage.value = errorMsg;
        CustomToast.error(errorMsg);
        throw Exception(errorMsg);
      }
    } catch (e) {
      isError.value = true;
      print('Error fetching wallet balance: $e');

      // Show error message using CustomToast
      String errorMsg = 'Failed to fetch wallet data';
      if (e.toString().contains('Exception:')) {
        errorMsg = e.toString().replaceAll('Exception: ', '');
      } else {
        errorMsg = 'Failed to fetch wallet data: ${e.toString()}';
      }

      errorMessage.value = errorMsg;
      CustomToast.error(errorMsg);
    } finally {
      isLoadingBalance.value = false;
    }
  }

  // Reset error state
  void clearError() {
    isError.value = false;
    errorMessage.value = '';
  }

  @override
  void onInit() {
    super.onInit();
    // Fetch current balance when controller initializes
    fetchWalletBalance();
  }

}
