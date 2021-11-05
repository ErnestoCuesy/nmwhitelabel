import 'dart:io';

import 'package:flutter/material.dart';

class PlatformTrailingIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid ? Icon(Icons.arrow_forward) : Icon(Icons.arrow_forward_ios);
  }
}
