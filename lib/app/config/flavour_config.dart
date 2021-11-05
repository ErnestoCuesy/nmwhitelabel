import 'package:flutter/material.dart';

enum Flavour { PATRON, MANAGER, STAFF, ADMIN }
enum ColorTheme { BLACK, ORANGE, GREEN }

class StringUtils {
  static String enumName(String enumToString) {
    List<String> paths = enumToString.split('.');
    return paths[paths.length - 1];
  }
}

class FlavourConfig {
  final Flavour flavour;
  final ColorTheme colorTheme;
  final String name;
  final Color bannerColor;
  static FlavourConfig? _instance;

  factory FlavourConfig(
      {required Flavour flavour,
      required ColorTheme colorTheme,
      Color bannerColor: Colors.blue,}) {
      _instance ??= FlavourConfig._internal(
      flavour,
      colorTheme,
      StringUtils.enumName(flavour.toString()),
      bannerColor,
    );
    return _instance!;
  }

  FlavourConfig._internal(
    this.flavour,
    this.colorTheme,
    this.name,
    this.bannerColor,
  );
  static FlavourConfig? get instance => _instance;
  static bool isPatron() => _instance!.flavour == Flavour.PATRON;
  static bool isManager() => _instance!.flavour == Flavour.MANAGER;
  static bool isStaff() => _instance!.flavour == Flavour.STAFF;
  static bool isAdmin() => _instance!.flavour == Flavour.ADMIN;
}
