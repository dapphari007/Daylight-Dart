import 'package:flutter/material.dart';

class ThemeColors {
  final Brightness brightness;

  ThemeColors(this.brightness);

  Color get background => brightness == Brightness.dark ? Colors.black : Colors.white;
  
  Color get headerText => brightness == Brightness.dark ? Colors.white : Colors.black;

  Color get nightBlock => brightness == Brightness.dark 
      ? const Color(0xFF1C1C1D) 
      : const Color(0xFFE5E5EA);

  Color get nightText => brightness == Brightness.dark 
      ? const Color(0xFF757575) 
      : const Color(0xFF3C3C43);

  Color get centerLine => brightness == Brightness.dark 
      ? Colors.white.withValues(alpha: 0.25) 
      : Colors.black.withValues(alpha: 0.15);

  Color get sliderTrackBackground => brightness == Brightness.dark 
      ? Colors.white.withValues(alpha: 0.2) 
      : Colors.black.withValues(alpha: 0.1);

  Color get sliderKnob => Colors.white;

  Color get sliderText => brightness == Brightness.dark ? Colors.white : Colors.black;

  Color get tickMark => brightness == Brightness.dark ? Colors.white : Colors.black;

  Color get closeButton => brightness == Brightness.dark 
      ? Colors.white.withValues(alpha: 0.6) 
      : Colors.black.withValues(alpha: 0.4);

  // Constants
  static const daylightStart = Color(0xFFFFD900);
  static const daylightEnd = Color(0xFFFF9900);
  static const homeIconColor = Color(0xFFFF9900);
}
