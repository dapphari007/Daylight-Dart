import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_settings.dart';
import 'appearance_popup.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});
  
  final GlobalKey _appearanceKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Matching the glass container from Image
    final cardColor = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.5);

    return Theme(
      data: Theme.of(context),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(16, 0, 16, 40 + MediaQuery.of(context).padding.bottom),
        children: [
          // Theme Section
          _buildSectionHeader(context, "Theme"),
          
          Container(
            key: _appearanceKey,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text(
                  "Appearance", 
                  style: GoogleFonts.outfit(
                      color: isDark ? Colors.white : Colors.black, 
                      fontSize: 17,
                      fontWeight: FontWeight.w400
                  )
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Text(
                     _getThemeLabel(settings.themeMode),
                     style: GoogleFonts.outfit(
                       color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.6),
                       fontSize: 17,
                       fontWeight: FontWeight.w400,
                     ),
                   ),
                   const SizedBox(width: 4),
                   Icon(
                     Icons.unfold_more,
                     color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.6),
                     size: 16,
                   ),
                ],
              ),
              onTap: () {
                 final RenderBox renderBox = _appearanceKey.currentContext!.findRenderObject() as RenderBox;
                 final offset = renderBox.localToGlobal(Offset.zero);
                 final rect = offset & renderBox.size;
                 
                 Navigator.of(context).push(
                   PageRouteBuilder(
                     opaque: false,
                     transitionDuration: const Duration(milliseconds: 300),
                     reverseTransitionDuration: const Duration(milliseconds: 200),
                     barrierColor: Colors.transparent, 
                     pageBuilder: (context, animation, secondaryAnimation) => AppearancePopup(triggerRect: rect),
                   ),
                 );
              },
            ),
          ),
          
          // Display Section
          _buildSectionHeader(context, "Display"),
          
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24), 
            ),
            child: SwitchListTile(
              title: Text("Show Center Line", style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black, fontSize: 17, fontWeight: FontWeight.normal)),
              value: settings.showCenterLine,
              onChanged: (bool value) {
                settings.showCenterLine = value;
              },
              activeThumbColor: Colors.white,
              activeTrackColor: Colors.green, // iOS Green
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 20, right: 20),
            child: Text(
              "Shows a vertical line at the center of timezone cards to indicate current time position",
              style: GoogleFonts.outfit(
                  color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.6),
                  fontSize: 14,
                  height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.6),
          fontSize: 14,
          fontWeight: FontWeight.w400, 
        ),
      ),
    );
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system: return "System";
      case ThemeMode.light: return "Light";
      case ThemeMode.dark: return "Dark";
    }
  }
}
