import 'package:flutter/material.dart';
import 'package:nearbymenus/app/common_widgets/custom_raised_button.dart';

class SignInButton extends CustomRaisedButton {
  SignInButton({
    required String text,
    Color? color,
    Color? textColor,
    VoidCallback? onPressed,
  }) : super(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 20.0,
              ),
            ),
            color: color,
            height: 50.0,
            onPressed: onPressed);
}
