import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_progress_indicator.dart';
import 'package:nmwhitelabel/app/models/bundle.dart';
import 'package:nmwhitelabel/app/pages/home/home_page_manager.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/pages/messages/messages_listener.dart';
import 'package:nmwhitelabel/app/services/database.dart';
import 'package:nmwhitelabel/app/services/iap_manager.dart';
import 'package:provider/provider.dart';

class CheckPurchases extends StatelessWidget {

  Future<void> _setBundleAndUnlock(String? email, Database database, List<Bundle> bundleSnapshot, Map<String, dynamic> allPurchasesDates) async {
    bundleSnapshot.forEach((bundle) {
      allPurchasesDates.removeWhere((key, value) => value.toString().contains(bundle.id.toString()));
    });
    String bundleDate;
    String bundleCode;
    int ordersInBundle = 0;
    int totalOrders = 0;
    allPurchasesDates.forEach((key, value) async {
      bundleCode = key;
      String date = value;
      var tempSplitDate = date.split('.');
      var tempDate = tempSplitDate[0].split('Z');
      bundleDate = tempDate[0];
      switch (bundleCode) {
        case 'in_app_mp0':
          ordersInBundle = 50;
          totalOrders += ordersInBundle;
          break;
        case 'in_app_mp1':
          ordersInBundle = 100;
          totalOrders += ordersInBundle;
          break;
        case 'in_app_mp2':
          ordersInBundle = 500;
          totalOrders += ordersInBundle;
          break;
        case 'in_app_mp3':
          ordersInBundle = 1000;
          totalOrders += ordersInBundle;
          break;
      }
      try {
        database.setBundle(email, Bundle(
          id: bundleDate,
          bundleCode: bundleCode,
          ordersInBundle: ordersInBundle,
        ));
      } catch (e) {
        print('DB Bundle set and unlock failed: $e');
      }
    });
    if (totalOrders > 0) {
      await database.setBundleCounterTransaction(
          database.userId, totalOrders);
    }
  }

  @override
  Widget build(BuildContext context) {
    final iap = Provider.of<IAPManagerBase>(context, listen: true);
    final session = Provider.of<Session>(context, listen: true);
    final database = Provider.of<Database>(context, listen: true);
    return StreamBuilder<Subscription?>(
      stream: iap.onSubscriptionChanged,
      builder: (context, snapshot) {
        Subscription? subscription;
        if (snapshot.connectionState == ConnectionState.active) {
          session.setSubscription(snapshot.data);
          if (snapshot.hasData) {
            subscription = snapshot.data;
            session.subscription = subscription;
          }
          return FutureBuilder<List<Bundle>>(
              future: database.bundlesSnapshot(session.userDetails!.email == '' || session.userDetails == null
                  ? 'anon'
                  : session.userDetails!.email),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.waiting &&
                    snapshot.hasData) {
                  _setBundleAndUnlock(session.userDetails!.email, database, snapshot.data!,
                      session.subscription!.purchaserInfo!.allPurchaseDates);
                  return MessagesListener(child: HomePageManager());
                } else {
                  return Scaffold(
                    body: Center(
                      child: PlatformProgressIndicator(),
                    ),
                  );
                }
              });
        } else {
          return Scaffold(
            body: Center(
              child: PlatformProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
