import 'package:flutter/material.dart';
import 'package:nearbymenus/app/common_widgets/custom_raised_button.dart';
import 'package:nearbymenus/app/common_widgets/platform_alert_dialog.dart';
import 'package:nearbymenus/app/config/flavour_config.dart';
import 'package:nearbymenus/app/models/session.dart';
import 'package:nearbymenus/app/pages/sign_in/terms_and_conditions.dart';
import 'package:nearbymenus/app/services/auth.dart';
import 'package:nearbymenus/app/services/database.dart';
import 'package:provider/provider.dart';

import '../sign_in/privacy_policy.dart';

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
    } else {
      var deleteConfirmed = await (PlatformAlertDialog(
        title: 'Confirm account deletion',
        content: 'Do you really want to delete your account?' + extraNotice,
        cancelActionText: 'No',
        defaultActionText: 'Yes',
      ).show(context));
      if (deleteConfirmed!) {
        var okToContinue = await (PlatformAlertDialog(
          title: 'Account will be scheduled for deletion',
          content:
              'You\'ll be logged out and you\'ll have to log back in again within 5 minutes in order for the account deletion process to complete. Do you want to continue?',
          cancelActionText: 'No',
          defaultActionText: 'Yes',
        ).show(context));
        if (okToContinue!) {
          session.userDetails!.deletionTimeStamp =
              DateTime.now().millisecondsSinceEpoch;
          database.setUserDetails(session.userDetails);
          auth.signOut();
        }
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

  void _privacyPolicy(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => PrivacyPolicy(
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
              style: Theme.of(context).primaryTextTheme.titleLarge,
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
      CustomRaisedButton(
        height: 150.0,
        width: 250.0,
        color: Theme.of(context).buttonTheme.colorScheme!.surface,
        onPressed: () => _privacyPolicy(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Privacy Policy',
              style: Theme.of(context).primaryTextTheme.titleLarge,
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
                style: Theme.of(context).primaryTextTheme.titleLarge,
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
