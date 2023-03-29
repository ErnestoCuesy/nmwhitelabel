import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/common_widgets/custom_raised_button.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_alert_dialog.dart';
import 'package:nmwhitelabel/app/config/flavour_config.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/pages/sign_in/terms_and_conditions.dart';
import 'package:nmwhitelabel/app/services/auth.dart';
import 'package:nmwhitelabel/app/services/database.dart';
import 'package:provider/provider.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late AuthBase auth;
  late Session session;
  late Database database;

  void _deleteAccount(BuildContext context) async {
    String extraNotice = '';
    if (FlavourConfig.isManager()) {
      extraNotice = ' Any orders left in your purchased bundles will be lost.';
    }
    if (session.userDetails!.hasRestaurants!) {
      await PlatformAlertDialog(
        title: 'You have restaurants',
        content:
            'Please delete all your restaurants first with NM Manager before deleting your account.',
        defaultActionText: 'OK',
      ).show(context);
    } else if (await (PlatformAlertDialog(
      title: 'Confirm account deletion',
      content: 'Do you really want to delete your account?' + extraNotice,
      cancelActionText: 'No',
      defaultActionText: 'Yes',
    ).show(context) as FutureOr<bool>)) {
      try {
        database.deleteUser(database.userId).then((value) =>
            Future.delayed(Duration(seconds: 3))
                .then((value) => auth.deleteUser()));
      } catch (e) {
        print(e);
      }
    }
  }

  void _termsAndConditions(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => TermsAndConditions(
          askAgreement: false,
        ),
      ),
    );
  }

  List<Widget> _buildContents(BuildContext context) {
    return [
      CustomRaisedButton(
        height: 150.0,
        width: 250.0,
        color: Theme.of(context).buttonTheme.colorScheme!.surface,
        onPressed: () => _termsAndConditions(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Terms And Conditions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(
              height: 8.0,
            ),
            Icon(
              Icons.info_outline,
              size: 36.0,
            ),
          ],
        ),
      ),
      SizedBox(
        height: 32.0,
      ),
      if (!FlavourConfig.isAdmin())
        CustomRaisedButton(
          height: 150.0,
          width: 250.0,
          color: Theme.of(context).buttonTheme.colorScheme!.surface,
          onPressed: () => _deleteAccount(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Delete Account',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(
                height: 16.0,
              ),
              Icon(
                Icons.account_box,
                size: 36.0,
              ),
            ],
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    auth = Provider.of<AuthBase>(context);
    session = Provider.of<Session>(context);
    database = Provider.of<Database>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('About Nearby Menus'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildContents(context),
        ),
      ),
    );
  }
}
