import 'package:flutter/material.dart';
import 'package:nearbymenus/app/common_widgets/empty_content.dart';
import 'package:nearbymenus/app/common_widgets/form_submit_button.dart';
import 'package:nearbymenus/app/config/flavour_config.dart';

class LocationServicesError extends StatelessWidget {
  final Function? askPermission;
  final Function? continueWithoutLocation;
  final String? message;

  const LocationServicesError(
      {Key? key,
      this.askPermission,
      this.continueWithoutLocation,
      this.message})
      : super(key: key);

  Color _buttonColor() {
    Color buttonColor = Colors.green;
    if (FlavourConfig.isManager()) {
      buttonColor = Colors.black;
    } else if (FlavourConfig.isStaff()) {
      buttonColor = Colors.orange;
    }
    return buttonColor;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        //backgroundColor: Theme.of(context).splashColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nearby Menus',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Container(
              padding: EdgeInsets.all(32.0),
              child: EmptyContent(
                title: 'Unknown location',
                message: message,
              ),
            ),
            FormSubmitButton(
              context: context,
              color: Colors.grey,
              text: 'Retry',
              onPressed: askPermission as void Function()?,
            ),
            SizedBox(
              height: 16.0,
            ),
            FormSubmitButton(
              context: context,
              color: _buttonColor(),
              text: 'Continue',
              onPressed: continueWithoutLocation as void Function()?,
            ),
          ],
        ),
      ),
    );
  }
}
