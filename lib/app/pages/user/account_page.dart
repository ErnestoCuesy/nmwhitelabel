import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nearbymenus/app/common_widgets/platform_alert_dialog.dart';
import 'package:nearbymenus/app/common_widgets/platform_progress_indicator.dart';
import 'package:nearbymenus/app/config/flavour_config.dart';
import 'package:nearbymenus/app/models/bundle.dart';
import 'package:nearbymenus/app/models/restaurant.dart';
import 'package:nearbymenus/app/models/user_details.dart';
import 'package:nearbymenus/app/pages/orders/locked_orders.dart';
import 'package:nearbymenus/app/pages/sign_in/conversion_process.dart';
import 'package:nearbymenus/app/pages/user/about_page.dart';
import 'package:nearbymenus/app/pages/user/upsell_screen.dart';
import 'package:nearbymenus/app/pages/user/user_details_form.dart';
import 'package:nearbymenus/app/services/auth.dart';
import 'package:nearbymenus/app/services/database.dart';
import 'package:nearbymenus/app/models/session.dart';
import 'package:nearbymenus/app/services/navigation_service.dart';
import 'package:nearbymenus/app/utilities/logo_image_asset.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  AuthBase? auth;
  Session? session;
  Database? database;
  NavigationService? navigationService;
  Restaurant restaurant =
      Restaurant(name: '', address1: '', acceptingStaffRequests: false);
  int _ordersLeft = 0;
  String _lastBundlePurchase = '';

  Future<void> _signOut() async {
    try {
      session!.userDetails!.orderOnHold = null;
      session!.currentOrder = null;
      session!.userProcessComplete = false;
      database!
          .setUserDetails(session!.userDetails)
          .then((value) => auth!.signOut());
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final didRequestSignOut = await PlatformAlertDialog(
      title: 'Logout',
      content: 'Are you sure you want to logout?',
      cancelActionText: 'Cancel',
      defaultActionText: 'Logout',
    ).show(context);
    if (didRequestSignOut == true) {
      _signOut();
    }
  }

  void _changeDetails(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Change your details',
            style:
                TextStyle(color: Theme.of(context).appBarTheme.backgroundColor),
          ),
          elevation: 2.0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: UserDetailsForm.create(
                context: context,
                userDetails: session!.userDetails,
              ),
            ),
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      );
    }));
  }

  void _upSell(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: false,
        builder: (context) => UpsellScreen(
          ordersLeft: _ordersLeft,
          blockedOrders: null,
        ),
      ),
    );
  }

  void _lockedOrders(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => LockedOrders(),
      ),
    );
  }

  void _convertUser(
      BuildContext context, Function(BuildContext) nextAction) async {
    if (!session!.userProcessComplete) {
      final ConversionProcess conversionProcess = ConversionProcess(
          navigationService: navigationService,
          session: session,
          auth: auth as Auth?,
          database: database,
          captureUserDetails: false);
      if (!await conversionProcess.userCanProceed()) {
        return;
      }
    }
    nextAction(context);
  }

  List<Widget> _buildAccountDetails(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageAsset = Provider.of<LogoImageAsset>(context);
    String? nameEmail = session!.userDetails!.name;
    if (!session!.isAnonymousUser) {
      if (session!.userDetails!.email != '') {
        nameEmail = nameEmail! + ' (${session!.userDetails!.email})';
      } else {
        nameEmail = 'Email not verified yet';
      }
    } else {
      nameEmail = 'Anonymous user';
    }
    return [
      Container(
        width: screenWidth / 4,
        height: screenHeight / 4,
        child: imageAsset.image,
      ),
      SizedBox(
        height: 16.0,
      ),
      // NAME AND ADDRESS
      _userDetailsSection(
        context: context,
        sectionTitle: 'Your details',
        cardTitle: nameEmail,
        cardSubtitle: session!.userDetails!.address1 == ''
            ? 'Address unknown'
            : '${session!.userDetails!.address1}\n'
                '${session!.userDetails!.address2}\n'
                '${session!.userDetails!.address3}\n'
                '${session!.userDetails!.address4}\n'
                '${session!.userDetails!.telephone}',
        onPressed: () => _convertUser(context, _changeDetails),
      ),
      // SUBSCRIPTION
      _bundleDetails(),
      if (FlavourConfig.isManager())
        _userDetailsSection(
          context: context,
          sectionTitle: 'Locked orders',
          cardTitle: 'Tap to see and unlock orders across all your restaurants',
          cardSubtitle: '',
          onPressed: () => _convertUser(context, _lockedOrders),
        ),
      // ABOUT
      _userDetailsSection(
        context: context,
        sectionTitle: 'About',
        cardTitle: 'Tap here for information about this app and other actions',
        cardSubtitle: '',
        onPressed: () => _aboutPage(context),
      ),
    ];
  }

  Widget _bundleDetails() {
    late Widget details;
    if (!kIsWeb) {
      if (FlavourConfig.isManager() && Platform.isAndroid) {
        details = _userDetailsSection(
          context: context,
          sectionTitle: 'Bundle details',
          cardTitle: 'Orders left: $_ordersLeft',
          cardSubtitle: 'Last purchase was on: $_lastBundlePurchase',
          onPressed: () => _convertUser(context, _upSell),
        );
      } else {
        details = _userDetailsSection(
          context: context,
          sectionTitle: 'Bundle details',
          cardTitle: 'Bundle information unavailable on this platform',
          cardSubtitle: '',
          onPressed: null,
        );
      }
    } else {
      details = _userDetailsSection(
        context: context,
        sectionTitle: 'Bundle details',
        cardTitle: 'Bundle information unavailable on this platform',
        cardSubtitle: '',
        onPressed: null,
      );
    }
    return details;
  }

  void _aboutPage(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: false,
        builder: (context) => AboutPage(),
      ),
    );
  }

  Future<int?> _loadOrdersLeft() async {
    int? ordersLeft;
    try {
      await database!.ordersLeft(database!.userId).then((value) {
        if (value != null) {
          ordersLeft = value;
        }
      });
    } catch (e) {
      print(e);
      ordersLeft = 0;
    }
    print('Orders left: $ordersLeft');
    return ordersLeft;
  }

  Widget _userDetailsSection(
      {required BuildContext context,
      required String sectionTitle,
      required String cardTitle,
      required String cardSubtitle,
      VoidCallback? onPressed}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0),
          child: Text(
            sectionTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        SizedBox(
          height: 8.0,
        ),
        Card(
          child: ListTile(
            title: Text(
              cardTitle,
            ),
            subtitle: Text(
              cardSubtitle,
            ),
            trailing: IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: onPressed,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContents(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: _buildAccountDetails(context),
        ),
      ),
    );
  }

  Future<String?> _reloadUser() async {
    String? emailString = '';
    try {
      await auth!.reloadUser();
      if (await auth!.userEmailVerified()) {
        emailString = await (auth!.userEmail());
      } else {
        emailString = 'Email not verified yet';
      }
    } catch (e) {
      emailString = 'An error occured while trying to reload user';
      print(e);
    }
    return emailString;
  }

  @override
  Widget build(BuildContext context) {
    auth = Provider.of<AuthBase>(context);
    session = Provider.of<Session>(context);
    database = Provider.of<Database>(context);
    navigationService = Provider.of<NavigationService>(context);
    if (FlavourConfig.isManager()) {
      _loadOrdersLeft().then((value) => _ordersLeft = value ?? 0);
    }
    _reloadUser().then((value) => session!.userDetails!.email = value);
    var accountText = 'Your profile';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          accountText,
          style: Theme.of(context).primaryTextTheme.titleLarge,
        ),
        actions: <Widget>[
          if (!session!.isAnonymousUser)
            TextButton(
              child: Text(
                'Logout',
                style: Theme.of(context).primaryTextTheme.labelLarge,
              ),
              onPressed: () => _confirmSignOut(context),
            ),
        ],
      ),
      body: StreamBuilder<UserDetails>(
          stream: database!.userDetailsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.active ||
                !snapshot.hasData) {
              return Center(child: PlatformProgressIndicator());
            } else {
              session!.userDetails = snapshot.data;
              if (FlavourConfig.isManager()) {
                _lastBundlePurchase = '\nYou haven\'t bought any bundles';
                return FutureBuilder<List<Bundle>>(
                    future:
                        database!.bundlesSnapshot(session!.userDetails!.email),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.waiting &&
                          snapshot.hasData) {
                        if (snapshot.data!.length > 0) {
                          final bundles = snapshot.data!;
                          bundles.removeWhere((element) => element.id == null);
                          bundles.sort((a, b) => b.id!.compareTo(a.id!));
                          if (bundles.length > 0) {
                            _lastBundlePurchase = '\n' + bundles[0].id!;
                          }
                        }
                        return _buildContents(context);
                      } else {
                        return Center(child: PlatformProgressIndicator());
                      }
                    });
              } else {
                return _buildContents(context);
              }
            }
          }),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}
