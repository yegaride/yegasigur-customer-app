import 'package:flutter/cupertino.dart';

class DrawerRoute {
  DrawerRoute(
    this.route,
    this.drawerIcon, [
    this.screen,
  ]);

  final String route;
  final IconData drawerIcon;
  final Widget? screen;
}
