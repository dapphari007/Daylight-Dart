import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_settings.dart';

class AppearancePopup extends StatefulWidget {
  final Rect triggerRect;
  const AppearancePopup({super.key, required this.triggerRect});

  @override
  State<AppearancePopup> createState() => _AppearancePopupState();
}

class _AppearancePopupState extends State<AppearancePopup> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack, // Bouncy effect like iOS
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determine Y position: Try to center vertically on the trigger rect
    // Trigger Rect is the "Appearance" row.
    // Menu Height ~ approx 170 (3 items * 56 + dividers + padding)
    // Let's assume height is fluid.
    
    // We want the popup to act like a context menu popping OUT of the row.
    // Centering it horizontally on the trigger (or aligning edges).
    // The "Appearance" row is wide. The menu is 250 wide.
    // Let's center it horizontally on the screen for better aesthetics as per image 2 (which looks centered-ish or right aligned?).
    // Actually image 2 shows it over the row. Let's Center horizontally relative to the row.
    
    const double menuWidth = 250.0;
    final rowCenter = widget.triggerRect.center;
    final leftPos = rowCenter.dx - (menuWidth / 2);
    
    // Vertical position: Center of the menu should approximately match center of the row, 
    // unless it overflows.
    // Let's align top to (row.top - some padding) to cover it or float above.
    // Screenshot shows it floating OVER the existing content.
    final topPos = widget.triggerRect.top - 60; // Shift up slightly to show context

    return Stack(
      children: [
        // Dismiss tap
        Positioned.fill(
          child: GestureDetector(
            onTap: () async {
              await _controller.reverse();
              if (context.mounted) Navigator.pop(context);
            },
            behavior: HitTestBehavior.opaque,
            child: Container(color: Colors.transparent),
          ),
        ),
        
        Positioned(
          top: topPos,
          left: leftPos,
          child: ScaleTransition(
            scale: _scaleAnimation,
            alignment: Alignment.center,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(
                      width: menuWidth,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1C1C1E).withValues(alpha: 0.8) : const Color(0xFFF2F2F7).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 40,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildOption(context, settings, ThemeMode.system, "System", isDark, isFirst: true),
                          Divider(height: 1, thickness: 1, color: isDark ? Colors.grey.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2)),
                          _buildOption(context, settings, ThemeMode.light, "Light", isDark),
                          Divider(height: 1, thickness: 1, color: isDark ? Colors.grey.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2)),
                          _buildOption(context, settings, ThemeMode.dark, "Dark", isDark, isLast: true),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOption(BuildContext context, AppSettings settings, ThemeMode mode, String label, bool isDark, {bool isFirst = false, bool isLast = false}) {
    final isSelected = settings.themeMode == mode;
    final textColor = isDark ? Colors.white : Colors.black;

    return InkWell(
      onTap: () async {
        settings.themeMode = mode;
        await Future.delayed(const Duration(milliseconds: 150));
        await _controller.reverse();
        if (context.mounted) Navigator.pop(context);
      },
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(20) : Radius.zero,
        bottom: isLast ? const Radius.circular(20) : Radius.zero,
      ),
      child: Container( 
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: isSelected
                  ? Icon(Icons.check, color: textColor, size: 20)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.outfit(
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
