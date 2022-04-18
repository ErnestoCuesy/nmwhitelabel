import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlatformTrailingIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return Platform.isAndroid ? Icon(Icons.arrow_forward) : Icon(Icons.arrow_forward_ios);
    } else {
      return Icon(Icons.arrow_forward);
    }
  }
}
