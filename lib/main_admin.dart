
import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/init_firebase.dart';
import 'app/config/flavour_config.dart';

void main() {
  var flavour = Flavour.ADMIN;
  FlavourConfig(
    flavour: flavour,
    colorTheme: ColorTheme.BLACK,
    bannerColor: Colors.blue,
  );

  WidgetsFlutterBinding.ensureInitialized();

  runApp(InitFirebase());
}
