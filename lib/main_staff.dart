
import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/init_firebase.dart';
import 'app/config/flavour_config.dart';

void main() {
  var flavour = Flavour.STAFF;
  FlavourConfig(
    flavour: flavour,
    colorTheme: ColorTheme.ORANGE,
    bannerColor: Colors.blue,
  );

  WidgetsFlutterBinding.ensureInitialized();

  runApp(InitFirebase());
}
