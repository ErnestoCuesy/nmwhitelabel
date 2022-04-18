import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlatformProgressIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isIOS || Platform.isMacOS) {
        return CupertinoActivityIndicator();
      } else {
        return CircularProgressIndicator();
      }
    } else {
      return CircularProgressIndicator();
    }
  }
}
