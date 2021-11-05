import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/config/flavour_config.dart';
import 'package:nmwhitelabel/app/utilities/black_theme.dart';
import 'package:nmwhitelabel/app/utilities/green_theme.dart';
import 'package:nmwhitelabel/app/utilities/orange_theme.dart';

class AppTheme {
  static ThemeData? createTheme(BuildContext context) {
    ThemeData? theme;
    switch (FlavourConfig.instance!.colorTheme) {
      case ColorTheme.BLACK: {
        theme = BlackTheme.theme;
      }
      break;
      case ColorTheme.ORANGE: {
        theme = OrangeTheme.theme;
      }
      break;
      case ColorTheme.GREEN: {
        theme = GreenTheme.theme;
      }
      break;
    }
    return theme;
  }
}
