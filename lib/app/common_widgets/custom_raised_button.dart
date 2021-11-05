import 'package:flutter/material.dart';

class CustomRaisedButton extends StatelessWidget {
  CustomRaisedButton({
    this.context,
    this.child,
    this.textColor,
    this.color,
    this.borderRadius : 6.0,
    this.height : 50.0,
    this.width,
    this.onPressed,
  });

  final BuildContext? context;
  final Widget? child;
  final Color? textColor;
  final Color? color;
  final double borderRadius;
  final double height;
  final double? width;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
          onPressed: onPressed,
          child: child,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed))
                  return Theme.of(context).buttonTheme.colorScheme!.background; //color;
                else if (states.contains(MaterialState.disabled))
                  return Theme.of(context).buttonTheme.colorScheme!.background; //color;
                return null; // Use the component's default.
              },
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    borderRadius,
                  )
                )
              )
            ),
          ),
      ),
    );
  }
}
