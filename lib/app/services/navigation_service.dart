import 'package:flutter/cupertino.dart';

class NavigationService {
  final GlobalKey<NavigatorState>? navigatorKey;

  NavigationService({this.navigatorKey});

  Future<dynamic> push(Route<Object> route) {
    return navigatorKey!.currentState!.push(route);
  }

  BuildContext? get context => navigatorKey!.currentContext;
}