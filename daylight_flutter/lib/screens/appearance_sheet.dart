import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_settings.dart';

class AppearanceSheet extends StatelessWidget {
  const AppearanceSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // We want a glass list that shows Dark, Light, System
    // Each option should be a row.
    
    return Column(
      children: [
        _buildOption(context, settings, ThemeMode.dark, "Dark", isDark),
        _buildDivider(context, isDark),
        _buildOption(context, settings, ThemeMode.light, "Light", isDark),
        _buildDivider(context, isDark),
        _buildOption(context, settings, ThemeMode.system, "System", isDark),
      ],
    );
  }
  
  Widget _buildDivider(BuildContext context, bool isDark) {
    return Divider(
      height: 1, 
      color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)
    );
  }

  Widget _buildOption(BuildContext context, AppSettings settings, ThemeMode mode, String label, bool isDark) {
    final isSelected = settings.themeMode == mode;
    final textColor = isDark ? Colors.white : Colors.black;
    
    return InkWell(
      onTap: () {
        settings.themeMode = mode;
        Navigator.pop(context); // Close sheet after selection
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: textColor,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check, color: const Color(0xFFFFCC00), size: 20),
          ],
        ),
      ),
    );
  }
}
