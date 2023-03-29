import 'package:flutter/material.dart';
import 'custom_raised_button.dart';

class FormSubmitButton extends CustomRaisedButton {
  FormSubmitButton({
    required BuildContext context,
    required String text,
    required Color color,
    VoidCallback? onPressed,
  }) : super(
          context: context,
          child: Text(
            text,
            style: Theme.of(context).primaryTextTheme.headlineSmall,
          ),
          height: 44.0,
          textColor: Theme.of(context).colorScheme.secondary,
          color: color,
          borderRadius: 4.0,
          onPressed: onPressed,
        );
}
