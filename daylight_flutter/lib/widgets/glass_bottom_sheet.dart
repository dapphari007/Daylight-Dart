  import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlassBottomSheet extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;
  final VoidCallback? onAdd;
  final Widget child;

  const GlassBottomSheet({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
    this.onAdd,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Floating margins: Left/Right 12, Top (Safe Area + 12), Bottom (Safe Area + 12)
      padding: EdgeInsets.fromLTRB(12, MediaQuery.of(context).padding.top + 12, 12, MediaQuery.of(context).padding.bottom + 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32), // Fully rounded corners
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black.withOpacity(0.5) 
                : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.12)
                  : Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grabber Handle
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white.withOpacity(0.3) 
                      : Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(height: 10),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Left Spacer for centering
                    const Spacer(),
                    // Centered Title
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Right Spacer for centering
                    const Spacer(),
                    // Action Buttons on the right
                    if (onAdd != null) ...[
                      GestureDetector(
                        onTap: onAdd,
                        child: Icon(
                          Icons.add, 
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, 
                          size: 28
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (actionText != null) ...[
                      GestureDetector(
                        onTap: onAction,
                        child: Text(
                          actionText!,
                          style: const TextStyle(
                            color: Color(0xFFFFCC00), // Matching TimeSlider accent
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              Divider(
                  height: 1, 
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white.withOpacity(0.1) 
                      : Colors.black.withOpacity(0.1)
              ),
              
              // Content
              Flexible(child: child),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
