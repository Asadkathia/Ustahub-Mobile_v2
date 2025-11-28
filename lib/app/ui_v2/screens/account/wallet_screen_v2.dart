import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/wallet/view/wallet_view.dart';
import '../../../components/navigation/app_app_bar_v2.dart';
import '../../../design_system/colors/app_colors_v2.dart';

class WalletScreenV2 extends StatelessWidget {
  const WalletScreenV2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      appBar: AppAppBarV2(
        title: AppLocalizations.of(context)!.wallet,
      ),
      body: const WalletView(),
    );
  }
}

