import 'package:flutter/material.dart';
import 'package:nearbymenus/app/common_widgets/custom_raised_button.dart';

class SocialSignInButton extends CustomRaisedButton {
  SocialSignInButton({
    required String assetName,
    required String text,
    Color? color,
    Color? textColor,
    VoidCallback? onPressed,
  }) : super(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Image.asset(assetName),
                Text(
                  text,
                  style: TextStyle(color: textColor, fontSize: 20.0),
                ),
                Opacity(
                  opacity: 0.0,
                  child: Image.asset(assetName),
                ),
              ],
            ),
            color: color,
            height: 50.0,
            onPressed: onPressed);
}
