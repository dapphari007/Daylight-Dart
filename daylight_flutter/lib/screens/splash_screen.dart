import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import '../utils/theme_colors.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to Home after 5 seconds
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic background based on device theme (handled by main.dart theme data)
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Center: Application Name
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [ThemeColors.daylightStart, ThemeColors.daylightEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Text(
                    "Daylight",
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white, // Required for ShaderMask
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom: Footer
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Powered by".toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                // Kaaspro Logo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  // No background color for adaptive look, or transparent
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // "Reverse K" symbol
                      Text(
                        ">|", 
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black, 
                          fontSize: 20, 
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // "kaaspro" text
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: 'Sans', // Default system font
                            fontSize: 22, // Slightly larger to match standard logo visual
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          children: const [
                            TextSpan(text: "kaa"),
                            TextSpan(text: "s", style: TextStyle(color: Color(0xFFE91E63))), // Pink accent always
                            TextSpan(text: "pro"),
                          ]
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
