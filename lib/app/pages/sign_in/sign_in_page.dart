import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearbymenus/app/common_widgets/platform_alert_dialog.dart';
import 'package:nearbymenus/app/common_widgets/platform_exception_alert_dialog.dart';
import 'package:nearbymenus/app/config/flavour_config.dart';
import 'package:nearbymenus/app/services/auth.dart';
import 'package:nearbymenus/app/utilities/logo_image_asset.dart';
import 'package:provider/provider.dart';
import 'email_sign_in_page.dart';
import 'sign_in_button.dart';

class SignInPage extends StatelessWidget {
  final bool? allowAnonymousSignIn;
  final bool? convertAnonymous;

  const SignInPage({Key? key, this.allowAnonymousSignIn, this.convertAnonymous})
      : super(key: key);

  void _showSignInError(BuildContext context, PlatformException exception) {
    PlatformExceptionAlertDialog(
      title: 'Sign In failed',
      exception: exception,
    ).show(context);
  }

  Future<void> _signInAnonymously(BuildContext context) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    try {
      await auth.signInAnonymously();
    } on PlatformException catch (e) {
      _showSignInError(context, e);
    }
  }

  void _signInWithEmail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => EmailSignInPage(
          convertAnonymous: convertAnonymous,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildContent(context),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }

  Widget _buildContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageAsset = Provider.of<LogoImageAsset>(context);
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              width: screenWidth / 4,
              height: screenHeight / 4,
              child: imageAsset.image,
            ),
          ),
          SizedBox(height: 24.0),
          SizedBox(height: 50.0, child: _buildHeader(context)),
          SizedBox(height: 36.0),
          // EMAIL
          SignInButton(
            text: 'Sign in',
            textColor: Theme.of(context).buttonTheme.colorScheme!.onPrimary,
            color: Theme.of(context).colorScheme.primary,
            onPressed: () => _signInWithEmail(context),
          ),
          SizedBox(height: 24.0),
          // ANON
          if (allowAnonymousSignIn!)
            TextButton(
              child: Text(
                'I\'ll sign-in later',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              onPressed: () => _signInAnonymously(context),
            ),
          if (convertAnonymous!)
            TextButton(
              child: Text(
                'You\'re currently an anonymous user.\nYou need to sign-in or create an account. \nTap here to learn why.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              onPressed: () => _displayWhy(context),
            ),
          SizedBox(height: 36.0),
        ],
      ),
    );
  }

  void _displayWhy(BuildContext context) {
    String reason =
        'If you want to continue you need to register an account for the following reason(s): \n\n- We want to keep a clean database and discourage spammers\n\n- Nearby Menus will never share your details or spam you with unsolicited information\n';
    if (FlavourConfig.isManager()) {
      reason = reason +
          '\n\n- You will be able to purchase order bundles to unlock your restaurant orders\n\n- You will be able to add images to your restaurant gallery\n\n- You will be able to grant access to restaurant orders to NM Staff users';
    } else if (FlavourConfig.isStaff()) {
      reason = reason +
          '\n- Restaurant managers need to know who you are to grant you restaurant access';
    } else {
      reason = reason +
          '\n- Your contact details are needed for order deliveries and other notifications from restaurants';
    }
    PlatformAlertDialog(
      title: 'Why you need an account',
      content: reason,
      defaultActionText: 'I GET IT',
    ).show(context);
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      'Welcome',
      textAlign: TextAlign.center,
      style: Theme.of(context).primaryTextTheme.headlineMedium,
    );
  }
}
