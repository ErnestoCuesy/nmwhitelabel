import 'package:flutter/material.dart';
import 'package:nearbymenus/app/init_firebase.dart';
import 'app/config/flavour_config.dart';

void main() {
  var flavour = Flavour.PATRON;
  FlavourConfig(
    flavour: flavour,
    colorTheme: ColorTheme.GREEN,
    bannerColor: Colors.blue,
  );

  WidgetsFlutterBinding.ensureInitialized();

  runApp(InitFirebase());
}
