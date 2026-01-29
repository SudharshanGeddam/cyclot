import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  Color get primaryColor => Theme.of(this).primaryColor;
  AppBarThemeData get appBarTheme => Theme.of(this).appBarTheme;
  Color get scaffoldBackground => Theme.of(this).scaffoldBackgroundColor;
  Color get cardColor => Theme.of(this).cardColor;
  CardThemeData get cardTheme => Theme.of(this).cardTheme;
}
