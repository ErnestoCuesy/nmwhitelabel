import 'dart:io';
import 'package:flutter/material.dart';

abstract class PlatformWidget extends StatelessWidget {

  Widget buildCupertinoWidget(BuildContext context);
  Widget buildMaterialWidget(BuildContext context);
  Widget buildMacOSWidget(BuildContext context);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return buildCupertinoWidget(context);
    } else if (Platform.isMacOS) {
      return buildMacOSWidget(context);
    }
    return buildMaterialWidget(context);
  }
}
