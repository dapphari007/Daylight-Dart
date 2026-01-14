import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_settings.dart';
import '../widgets/glass_bottom_sheet.dart';
import 'add_timezone_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Forces dark mode styling for the sheet content
    return Theme(
      data: Theme.of(context), // Inherit app theme for correct brightness
      child: ListView(
        shrinkWrap: true, // Important for BottomSheet
        padding: EdgeInsets.fromLTRB(0, 0, 0, 40 + MediaQuery.of(context).padding.bottom), // Safe area handling
        children: [
          // Theme Section
          _buildSectionHeader("Theme"),
          // Appearance
          ListTile(
            title: Text("Appearance", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.normal)),
            trailing: GestureDetector(
               onTap: () {
                 // Simple cycle for now or show dialog? Cycle is easiest.
                 ThemeMode nextMode;
                 if (settings.themeMode == ThemeMode.system) nextMode = ThemeMode.light;
                 else if (settings.themeMode == ThemeMode.light) nextMode = ThemeMode.dark;
                 else nextMode = ThemeMode.system;
                 settings.themeMode = nextMode;
               },
               child: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Text(
                     settings.themeMode == ThemeMode.system ? "System" : (settings.themeMode == ThemeMode.light ? "Light" : "Dark"),
                     style: TextStyle(
                       color: isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6),
                       fontSize: 17,
                     ),
                   ),
                   const SizedBox(width: 4),
                   Icon(Icons.unfold_more, color: isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6), size: 16),
                 ],
               ),
            ),
          ),

          // General
          _buildSectionHeader("General"),
          ListTile(
            title: Text("Add Timezone", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.normal)),
            leading: Icon(Icons.add_circle_outline, color: isDark ? Colors.white : Colors.black),
            onTap: () {
               showModalBottomSheet(
                  context: context,
                  isScrollControlled: true, // Needed for draggable sheet
                  backgroundColor: Colors.transparent,
                  builder: (context) => DraggableScrollableSheet(
                    initialChildSize: 0.5,
                    minChildSize: 0.4,
                    maxChildSize: 0.95,
                    builder: (context, scrollController) {
                      return GlassBottomSheet(
                        title: "Add Timezone",
                        actionText: "Done", 
                        onAction: () => Navigator.pop(context),
                        child: AddTimeZoneScreen(scrollController: scrollController),
                      );
                    },
                  ),
               );
            },
          ),
          
          // Display Section
          _buildSectionHeader("Display"),
          SwitchListTile(
            title: Text("Show Center Line", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.normal)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                "Shows a vertical line at the center of timezone cards to indicate current time position",
                style: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade600, fontSize: 13),
              ),
            ),
            value: settings.showCenterLine,
            onChanged: (bool value) {
              settings.showCenterLine = value;
            },
            activeColor: Colors.white,
            activeTrackColor: Colors.green, // iOS Green
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
