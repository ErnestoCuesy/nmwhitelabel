import 'package:flutter/material.dart';
import 'package:nearbymenus/app/config/flavour_config.dart';
import 'package:rate_my_app/rate_my_app.dart';

class RateApp {
  static void displayDialog(
      {BuildContext? context, RateMyApp? rateMyApp, bool? forceDialog}) {
    if (FlavourConfig.isAdmin()) {
      return;
    }
    if (rateMyApp!.shouldOpenDialog || forceDialog!) {
      rateMyApp.showRateDialog(
        context!,
        title: 'Rate this app',
        // The dialog title.
        message:
            'If you like this app, please take a little bit of your time to review it.\nIt really helps us and it shouldn\'t take you more than one minute.',
        // The dialog message.
        rateButton: 'RATE',
        // The dialog "rate" button text.
        noButton: 'NO THANKS',
        // The dialog "no" button text.
        laterButton: 'MAYBE LATER',
        // The dialog "later" button text.
        listener: (button) {
          // The button click listener (useful if you want to cancel the click event).
          switch (button) {
            case RateMyAppDialogButton.rate:
              print('Clicked on "Rate".');
              break;
            case RateMyAppDialogButton.later:
              print('Clicked on "Later".');
              break;
            case RateMyAppDialogButton.no:
              print('Clicked on "No".');
              break;
          }

          return true; // Return false if you want to cancel the click event.
        },
        ignoreNativeDialog: false,
        // Set to false if you want to show the Apple's native app rating dialog on iOS or Google's native app rating dialog (depends on the current Platform).
        dialogStyle: DialogStyle(),
        // Custom dialog styles.
        onDismissed: () => rateMyApp.callEvent(RateMyAppEventType
            .laterButtonPressed), // Called when the user dismissed the dialog (either by taping outside or by pressing the "back" button).
        // contentBuilder: (context, defaultContent) => content, // This one allows you to change the default dialog content.
        // actionsBuilder: (context) => [], // This one allows you to use your own buttons.
      );
    }
  }
}
