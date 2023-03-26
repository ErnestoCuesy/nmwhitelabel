import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_progress_indicator.dart';
import 'package:nmwhitelabel/app/utilities/logo_image_asset.dart';

class SplashScreen extends StatefulWidget {
  final LogoImageAsset imageAsset = LogoImageAsset();
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Theme.of(context).splashColor,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Container(
                    width: 300.0,
                    height: 300.0,
                    child: widget.imageAsset.image,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      PlatformProgressIndicator(),
                      Padding(
                        padding: EdgeInsets.only(top: 20.0),
                      ),
                      Text(
                        "Please wait...",
                        style: Theme.of(context).textTheme.subtitle2,
                      )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}