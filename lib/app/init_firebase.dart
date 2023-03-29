import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nearbymenus/app/app.dart';
import 'package:nearbymenus/app/common_widgets/platform_progress_indicator.dart';
import '../firebase_options.dart';

class InitFirebase extends StatelessWidget {
  final Future<FirebaseApp> _initialization =
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        } else {
          return PlatformProgressIndicator();
        }
      },
    );
  }
}
