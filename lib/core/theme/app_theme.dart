import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: Colors.purpleAccent,
    scaffoldBackgroundColor: Colors.white38,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.purple,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.purpleAccent),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.black, fontSize: 18),
      bodyMedium: TextStyle(color: Colors.black, fontSize: 16),
      bodySmall: TextStyle(color: Colors.black, fontSize: 14),
      labelMedium: TextStyle(color: Colors.black38, fontSize: 14),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.purpleAccent,
      textTheme: ButtonTextTheme.primary,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white30,
      selectedColor: Colors.purpleAccent,
      labelStyle: TextStyle(color: Colors.black),
      secondaryLabelStyle: TextStyle(color: Colors.black38),
      padding: EdgeInsets.all(8),
    ),
    dividerColor: Colors.purple,
    cardColor: Colors.white,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.purple),
      ),
    ),
  );
}
