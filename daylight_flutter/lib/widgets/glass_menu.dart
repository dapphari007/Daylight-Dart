import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GlassMenu extends StatelessWidget {
  final VoidCallback onAddTimeZone;
  final VoidCallback onSettings;

  const GlassMenu({
    super.key,
    required this.onAddTimeZone,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Close when tapping outside
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),
          // Positioned menu (Top Right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 60, // Below header
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: 220,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.05),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMenuItem(
                        context,
                        icon: CupertinoIcons.plus, // Matches "plus" system image
                        text: "Add Timezone",
                        onTap: () {
                          Navigator.pop(context);
                          onAddTimeZone();
                        },
                        textColor: textColor,
                      ),
                      Divider(
                        height: 1, 
                        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)
                      ),
                      _buildMenuItem(
                        context,
                        icon: CupertinoIcons.gear_alt, // Matches "gearshape" system image
                        text: "Settings",
                        onTap: () {
                          Navigator.pop(context);
                          onSettings();
                        },
                        textColor: textColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required Color textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 22, color: textColor.withValues(alpha: 0.9)),
            const SizedBox(width: 14),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Outfit', // Use local font asset
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
