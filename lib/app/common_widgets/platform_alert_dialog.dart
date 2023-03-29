import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:nearbymenus/app/common_widgets/platform_widget.dart';

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
    if (!kIsWeb) {
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
    } else {
      return await showDialog<bool>(
        context: context!,
        barrierDismissible: false,
        builder: (context) => this,
      );
    }
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
  Widget buildMacOSWidget(BuildContext context) {
    return MacosTheme(
      data: MacosThemeData.light(),
      child: MacosAlertDialog(
        appIcon: Image.asset(
          'LauncherIcon.png',
        ),
        title: Text(title),
        message: Text(content),
        primaryButton: _buildMacOSPrimaryButton(context),
        secondaryButton: _buildMacOSSecondaryButton(context),
        horizontalActions: false,
      ),
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.background,
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
          style: Theme.of(context).textTheme.labelLarge,
        ),
        onPressed: () => Navigator.of(context).pop(false),
      ));
    }
    actions.add(PlatformAlertDialogAction(
      child: Text(
        defaultActionText,
        style: Theme.of(context).textTheme.labelLarge,
      ),
      onPressed: () => Navigator.of(context).pop(true),
    ));
    return actions;
  }

  Widget _buildMacOSPrimaryButton(BuildContext context) {
    return PlatformAlertDialogAction(
      child: Text(
        defaultActionText,
        style: Theme.of(context).textTheme.labelLarge,
      ),
      onPressed: () => Navigator.of(context).pop(true),
    );
  }

  Widget? _buildMacOSSecondaryButton(BuildContext context) {
    if (cancelActionText != null) {
      return PlatformAlertDialogAction(
        child: Text(
          cancelActionText!,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        onPressed: () => Navigator.of(context).pop(false),
      );
    }
    return null;
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

  @override
  Widget buildMacOSWidget(BuildContext context) {
    return PushButton(
      buttonSize: ButtonSize.large,
      child: child!,
      onPressed: onPressed,
    );
  }
}
