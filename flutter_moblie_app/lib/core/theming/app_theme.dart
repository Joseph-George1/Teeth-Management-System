import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'Cairo',
      // Add other theme configurations here
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      textTheme: ThemeData.dark().textTheme.apply(
        fontFamily: 'Cairo',
      ),
      // Add other dark theme configurations here
    );
  }
}
