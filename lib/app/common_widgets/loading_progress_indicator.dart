import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_progress_indicator.dart';

class LoadingProgressIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: PlatformProgressIndicator(),
        ),
      ),
    );
  }
}
