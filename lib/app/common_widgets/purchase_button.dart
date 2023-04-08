import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearbymenus/app/common_widgets/custom_raised_button.dart';
import 'package:nearbymenus/app/common_widgets/platform_exception_alert_dialog.dart';
import 'package:nearbymenus/app/services/iap_manager.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseButton extends StatelessWidget {
  final Package? package;
  final int? blockedOrders;

  PurchaseButton({Key? key, this.package, this.blockedOrders})
      : super(key: key);

  Future<void> _buyPackage(BuildContext context) async {
    final iap = Provider.of<IAPManagerBase>(context, listen: false);
    String message = '';
    if (blockedOrders != null) {
      message = 'You can unlock your orders now.';
    }
    try {
      print('Trying to buy: ${package!.storeProduct.identifier}');
      await iap.purchaseProduct(package!.storeProduct.identifier);
      //_setBundleAndUnlock(context, 5);
      await PlatformExceptionAlertDialog(
        title: 'Thank you!',
        exception: PlatformException(
          code: 'ORDER_BUNDLED_PURCHASE_SUCCESS',
          message: 'Your purchase was successful. $message',
          details: 'Your purchase was successful. $message',
        ),
      ).show(context);
    } on PlatformException catch (e) {
      print('IAP purchase failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) => CustomRaisedButton(
        height: 150.0,
        width: 250.0,
        color: Theme.of(context).buttonTheme.colorScheme!.background,
        onPressed: () => _buyPackage(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              "${package!.storeProduct.description}",
              style: Theme.of(context).primaryTextTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            Text(
              "Buy for ${package!.storeProduct.priceString}",
              style: Theme.of(context).primaryTextTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
