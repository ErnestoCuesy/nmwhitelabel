import 'package:flutter/material.dart';
import 'package:nearbymenus/app/init_firebase.dart';
import 'app/config/flavour_config.dart';

void main() {
  var flavour = Flavour.MANAGER;
  FlavourConfig(
    flavour: flavour,
    colorTheme: ColorTheme.BLACK,
    bannerColor: Colors.blue,
  );

  WidgetsFlutterBinding.ensureInitialized();

  runApp(InitFirebase());
}
