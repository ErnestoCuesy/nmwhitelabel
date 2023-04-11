import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearbymenus/app/common_widgets/platform_alert_dialog.dart';
import 'package:nearbymenus/app/common_widgets/platform_exception_alert_dialog.dart';
import 'package:nearbymenus/app/config/flavour_config.dart';
import 'package:nearbymenus/app/models/session.dart';
import 'package:nearbymenus/app/pages/sign_in/email_sign_in_page.dart';
import 'package:nearbymenus/app/pages/user/user_details_form.dart';
import 'package:nearbymenus/app/services/auth.dart';
import 'package:nearbymenus/app/services/database.dart';
import 'package:nearbymenus/app/services/navigation_service.dart';

class ConversionProcess {
  final NavigationService? navigationService;
  final Session? session;
  final Auth? auth;
  final Database? database;
  final bool? captureUserDetails;

  ConversionProcess(
      {this.navigationService,
      this.session,
      this.auth,
      this.database,
      this.captureUserDetails});

  Future<bool?> _askForSignIn() async {
    return await PlatformAlertDialog(
      title: 'Sign In required',
      content:
          'You need to sign-in to continue. Verification of your email address may be required.',
      cancelActionText: 'Keep browsing',
      defaultActionText: 'Sign In',
    ).show(navigationService!.context);
  }

  Future<bool?> _confirmDetailsCapture() async {
    String content =
        '\nWe\'re missing your contact details. Your contact details ';
    if (FlavourConfig.isManager()) {
      content = content +
          'are needed to prevent abuse of the platform when uploading images as per our Ts and Cs.';
    } else if (FlavourConfig.isStaff()) {
      content = content +
          'are needed so restaurant managers can identify you when you request access to restaurants.';
    } else {
      content = content + 'are needed so we can deliver orders to you.';
    }
    content = content + '\nYour details will not be shared with anyone else.';
    return await PlatformAlertDialog(
      title: 'Contact details missing',
      content: content,
      cancelActionText: 'Keep browsing',
      defaultActionText: 'Capture my details',
    ).show(navigationService!.context);
  }

  Future<void> _exceptionDialog(
      String title, String code, String message) async {
    await PlatformExceptionAlertDialog(
      title: title,
      exception: PlatformException(
        code: code,
        message: message,
        details: message,
      ),
    ).show(navigationService!.context);
  }

  void _convertUser() async {
    //await Navigator.of(context).push(
    await navigationService!.push(
      MaterialPageRoute<bool>(
        fullscreenDialog: false,
        builder: (BuildContext context) => EmailSignInPage(
          convertAnonymous: true,
        ),
      ),
    );
  }

  Future<bool> userCanProceed() async {
    bool emailVerified = false;
    bool? detailsCaptured = false;
    session!.isAnonymousUser = await auth!.userIsAnonymous();
    if (session!.isAnonymousUser) {
      var continueToSignIn = await (_askForSignIn());
      if (continueToSignIn!) {
        _convertUser();
      }
    } else {
      await auth!.reloadUser();
      session!.userDetails!.email = 'Email not verified yet';
      emailVerified = await auth!.userEmailVerified();
      if (emailVerified) {
        database!
            .setUserId(await auth!.currentUser().then((value) => value!.uid));
        session!.userDetails!.email = await auth!.userEmail();
        database!.setUserDetails(session!.userDetails);
        if (session!.currentOrder != null) {
          session!.updateDeliveryDetails();
        }
        if (captureUserDetails!) {
          if (!session!.userDetailsCaptured()) {
            var detailsCaptureConfirmed = await (_confirmDetailsCapture());
            if (detailsCaptureConfirmed!) {
              detailsCaptured = await (navigationService!.push(
                MaterialPageRoute<bool>(
                  fullscreenDialog: false,
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: Text('Please enter your contact details'),
                    ),
                    body: SingleChildScrollView(
                      child: UserDetailsForm.create(
                          context: context, userDetails: session!.userDetails),
                    ),
                  ),
                ),
              ) as FutureOr<bool>);
            }
          } else {
            detailsCaptured = true;
          }
        } else {
          detailsCaptured = true;
        }
      } else {
        _exceptionDialog(
          'Email address not verified yet',
          'EMAIL_NOT_VERIFIED',
          'Please check your inbox and follow the link we sent you to verify your email address.',
        );
      }
    }
    return detailsCaptured;
  }
}
