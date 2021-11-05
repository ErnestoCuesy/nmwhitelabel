import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/common_widgets/purchase_button.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:provider/provider.dart';

class UpsellScreen extends StatefulWidget {
  final int? blockedOrders;
  final int? ordersLeft;

  const UpsellScreen({Key? key, this.blockedOrders, this.ordersLeft}) : super(key: key);

  @override
  _UpsellScreenState createState() => _UpsellScreenState();
}

class _UpsellScreenState extends State<UpsellScreen> {
  late Session session;
  int? get ordersLeft => widget.ordersLeft;
  int? get blockedOrders => widget.blockedOrders;

  List<Widget> buildPackages(BuildContext context) {
    print('Orders left: $ordersLeft');
    List<Widget> packages = [];
    if (ordersLeft != null) {
      packages.add(Text(
        'Orders left: ${ordersLeft.toString()}',
        style: Theme
            .of(context)
            .textTheme
            .headline4,
      ));
      packages.add(SizedBox(height: 16.0,));
    }
    if (blockedOrders != null) {
      packages.add(Text(
        'Orders locked: $blockedOrders',
        style: Theme
            .of(context)
            .textTheme
            .headline4,
      ));
      packages.add(SizedBox(height: 16.0,));
    }
    final excludeTrial = session.subscription!.purchaserInfo!.allPurchasedProductIdentifiers.contains('in_app_mp0');
    session.subscription!.availableOfferings!.forEach((pkg) {
      if (pkg.product.identifier == 'in_app_mp0' && excludeTrial) {
        print('Excluding trial package');
      } else {
        packages.add(PurchaseButton(
          package: pkg,
          blockedOrders: blockedOrders,
        ));
        packages.add(SizedBox(height: 24.0,));
      }
    });
    return packages;
  }

  @override
  Widget build(BuildContext context) {
    session = Provider.of<Session>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Buy a bundle to unlock your orders',
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: buildPackages(context),
            ),
          ),
        ));
  }
}
