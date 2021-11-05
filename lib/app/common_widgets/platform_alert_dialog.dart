import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_widget.dart';

class PlatformAlertDialog extends PlatformWidget {
  PlatformAlertDialog({
    required this.title,
    required this.content,
    this.cancelActionText,
    required this.defaultActionText,
  });

  final String title;
  final String content;
  final String? cancelActionText;
  final String defaultActionText;

  Future<bool?> show(BuildContext? context) async {
    return Platform.isIOS
        ? await showCupertinoDialog<bool>(
            context: context!,
            builder: (context) => this,
          )
        : await showDialog<bool>(
            context: context!,
            barrierDismissible: false,
            builder: (context) => this,
          );
  }

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _buildActions(context),
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).backgroundColor,
      title: Text(title),
      content: Text(content),
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final actions = <Widget>[];
    if (cancelActionText != null) {
      actions.add(PlatformAlertDialogAction(
        child: Text(
          cancelActionText!,
          style: Theme.of(context).textTheme.button,
        ),
        onPressed: () => Navigator.of(context).pop(false),
      ));
    }
    actions.add(PlatformAlertDialogAction(
      child: Text(
        defaultActionText,
        style: Theme.of(context).textTheme.button,
      ),
      onPressed: () => Navigator.of(context).pop(true),
    ));
    return actions;
  }
}

class PlatformAlertDialogAction extends PlatformWidget {
  PlatformAlertDialogAction({this.child, this.onPressed});

  final Widget? child;
  final VoidCallback? onPressed;

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return CupertinoDialogAction(
      child: child!,
      onPressed: onPressed,
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return TextButton(
      child: child!,
      onPressed: onPressed,
    );
  }
}
