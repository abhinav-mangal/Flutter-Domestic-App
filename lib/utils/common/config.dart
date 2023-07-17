import 'package:flutter/material.dart';

class SizeConfig {
  static const String localizationPath = 'resources/langs';
  static Size kSquareSize = const Size(1000, 1000);
  static Size kSquare400Size = const Size(100, 100);
  static Size kRactSize = const Size(500, 300);
  static Size kRactIdSize = const Size(300, 250);
  static String kCurrency = String.fromCharCode(8377);
}
GlobalKey<NavigatorState> kNavigatorKey = GlobalKey<NavigatorState>();
GlobalKey globalKeyBottomBard = GlobalKey(debugLabel: 'btm_app_bar');
