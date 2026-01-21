  import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bouncing_button.dart';

class GlassBottomSheet extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;
  final VoidCallback? onAdd;
  final Widget child;
  final bool expandContent;

  final bool isFullScreen;

  const GlassBottomSheet({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
    this.onAdd,
    required this.child,
    this.expandContent = false,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    // Define glass colors with reduced opacity for "More Transparent" look
    final glassColor = Theme.of(context).brightness == Brightness.dark 
        ? Colors.white.withValues(alpha: 0.12) // Reverted to match original/glass menu
        : Colors.white.withValues(alpha: 0.65); // Reverted to match original/glass menu

    // Define "Normal" (Full Screen) color - Opaque or higher opacity
    final normalColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1C1C1E) // iOS Dark System Background-ish
        : const Color(0xFFF2F2F7); // iOS Light System Background-ish

    return Padding(
      // Floating margins: Left/Right 12, Top (Safe Area + 12), Bottom (Safe Area + 12)
      // If full screen, we might want to reduce margins? uniqueness of "Full Screen" usually means it covers more. 
      // But user said "let it be normal" while in full screen. 
      // Keeping margins as is for consistency unless requested.
      padding: EdgeInsets.fromLTRB(12, MediaQuery.of(context).padding.top + 12, 12, MediaQuery.of(context).padding.bottom + 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32), // Fully rounded corners
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isFullScreen ? normalColor : glassColor,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: expandContent ? MainAxisSize.max : MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20), // Increased top padding since handle is gone
                  child: SizedBox(
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Centered Title
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        
                        // Right-aligned Actions using Positioned
                        Positioned(
                          right: 0,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (onAdd != null) ...[
                                BouncingButton(
                                  onTap: onAdd!,
                                  child: Icon(
                                    Icons.add, 
                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, 
                                    size: 28
                                  ),
                                ),
                                const SizedBox(width: 16),
                              ],
                              if (actionText != null) ...[
                                BouncingButton(
                                  onTap: onAction!,
                                  child: Padding( // Keep some padding for touch target
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    child: Text(
                                      actionText!,
                                      style: GoogleFonts.outfit(
                                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                        fontSize: 17, 
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Divider Removed as requested
                
                // Content
                expandContent ? Expanded(child: child) : Flexible(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
