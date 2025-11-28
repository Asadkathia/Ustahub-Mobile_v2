import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/wallet/view/all_transactions_view.dart';

class WalletView extends StatefulWidget {
  const WalletView({super.key});

  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  final WalletController _walletController = Get.put(WalletController());

  void _showAddTokenDialog(BuildContext context) {
    final TextEditingController tokenController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Add Tokens',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter the amount of tokens you want to add:',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: tokenController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter token amount',
                  prefixIcon: Icon(
                    Icons.monetization_on,
                    color: AppColors.green,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.green),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.green,
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'One rupee = One Token',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
              ),
            ),
            Obx(
              () => ElevatedButton(
                onPressed:
                    _walletController.isLoading.value
                        ? null
                        : () async {
                          final tokenAmount = tokenController.text.trim();
                          if (tokenAmount.isNotEmpty &&
                              int.tryParse(tokenAmount) != null) {
                            Navigator.of(context).pop();
                            await _walletController.addFunds(
                              amount: tokenAmount,
                            );
                          } else {
                            CustomToast.error(
                              'Please enter a valid token amount',
                            );
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                ),
                child:
                    _walletController.isLoading.value
                        ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.wallet),
      body: RefreshIndicator(
        onRefresh: () async {
          await _walletController.fetchWalletBalance();
        },
        child: Obx(() {
          if (_walletController.isLoadingBalance.value &&
              _walletController.transactions.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.green),
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          _walletController.formattedBalance,
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.green,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Available Token",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),

                    Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Obx(
                        () => ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            shape: StadiumBorder(),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                          ),
                          onPressed:
                              _walletController.isLoading.value
                                  ? null
                                  : () => _showAddTokenDialog(context),
                          icon:
                              _walletController.isLoading.value
                                  ? SizedBox(
                                    width: 16.w,
                                    height: 16.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 16.sp,
                                  ),
                          label: Text(
                            "Add Token",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Text(
                  "Recent transaction",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Divider(height: 20.h),
                Expanded(
                  child:
                      _walletController.transactions.isEmpty
                          ? Center(
                            child: Text(
                              'No transactions found',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                          : Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  itemCount:
                                      _walletController.transactions.length > 5
                                          ? 5
                                          : _walletController
                                              .transactions
                                              .length,
                                  itemBuilder: (context, index) {
                                    final transaction =
                                        _walletController.transactions[index];
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10.h,
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20.r,
                                            backgroundColor:
                                                transaction.isCredit
                                                    ? AppColors.green
                                                        .withValues(alpha: 0.1)
                                                    : Colors.red.withValues(
                                                      alpha: 0.1,
                                                    ),
                                            child: Text(
                                              transaction.transactionInitials,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    transaction.isCredit
                                                        ? AppColors.green
                                                        : Colors.red,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  transaction.description,
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  transaction.formattedDate,
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            transaction.displayAmount,
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  transaction.isCredit
                                                      ? AppColors.green
                                                      : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Always show "View All Transactions" button if there are any transactions
                              if (_walletController.transactions.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        print(
                                          'Button tapped! Transactions count: ${_walletController.transactions.length}',
                                        );
                                        Get.to(
                                          () => const AllTransactionsView(),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: AppColors.green,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12.h,
                                          horizontal: 16.w,
                                        ),
                                      ),
                                      icon: Icon(
                                        Icons.list_alt,
                                        color: AppColors.green,
                                        size: 20.sp,
                                      ),
                                      label: Text(
                                        'View All Transactions',
                                        style: TextStyle(
                                          color: AppColors.green,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            
                            ],
                          ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
