import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/timezone_item.dart';
import '../utils/theme_colors.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';


class TimeSlider extends StatefulWidget {
  final double hourOffset;
  final ValueChanged<double> onHourOffsetChanged;
  final TimeZoneItem? homeTimeZone;
  final ThemeColors theme;

  const TimeSlider({
    super.key,
    required this.hourOffset,
    required this.onHourOffsetChanged,
    required this.homeTimeZone,
    required this.theme,
  });

  @override
  State<TimeSlider> createState() => _TimeSliderState();
}

class _TimeSliderState extends State<TimeSlider> {
  bool isDragging = false;
  double dragStartOffset = 0;
  int lastHapticHour = 0;

  @override
  void initState() {
    super.initState();
    lastHapticHour = (widget.hourOffset * 4).round();
  }

  double get currentHomeHour {
    if (widget.homeTimeZone == null) return 12;
    final now = DateTime.now().toUtc();
    final zonedDate = tz.TZDateTime.from(now, widget.homeTimeZone!.location);
    return zonedDate.hour + zonedDate.minute / 60.0;
  }
  
  String formatTimeLabel() {
     if (widget.homeTimeZone == null) return "Now";
     final zonedDate = tz.TZDateTime.now(widget.homeTimeZone!.location).add(Duration(minutes: (widget.hourOffset * 60).round()));
     return DateFormat('h:mm a').format(zonedDate);
  }

  @override
  Widget build(BuildContext context) {
    // These constants define the inner layout
    const trackPadding = 25.5;
    // We wrap everything in a glass container with padding around it
     final isDark = Theme.of(context).brightness == Brightness.dark;
     final bottomPadding = MediaQuery.of(context).padding.bottom;
     final containerDecoration = _buildContainerDecoration(isDark);
     // settings variable removed as it was unused
    
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 20 + bottomPadding), // Increased side padding for floating look
      child: ClipRRect(
        borderRadius: BorderRadius.circular(64), // Full rounded pill shape (Height 128 / 2 = 64)
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            height: 128, // Compact height for pill look
            decoration: containerDecoration,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(builder: (context, constraints) {
              final sliderWidth = constraints.maxWidth;
              final trackWidth = sliderWidth - (trackPadding * 2);
              final centerX = trackWidth / 2;
              final pixelsPerHour = trackWidth / 24.0;
              final knobX = centerX + (widget.hourOffset * pixelsPerHour);

              return GestureDetector(
                onDoubleTap: () => widget.onHourOffsetChanged(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     _buildSliderLabels(),
                     const SizedBox(height: 12),
                     
                     // Track
                     _buildSliderTrack(trackWidth, knobX, pixelsPerHour, isDark),
                     
                     // Ticks
                     const SizedBox(height: 12),
                     SizedBox(
                       width: trackWidth,
                       height: 4,
                       child: CustomPaint(
                          painter: TickPainter(trackWidth: trackWidth, knobX: knobX, theme: widget.theme, isDark: isDark),
                       ),
                     ),
                     
                     // Current Time below
                     const SizedBox(height: 12),
                     if (widget.homeTimeZone != null)
                       _buildHomeTimeLabel(isDark),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildContainerDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(64),
      border: Border.all(
        color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.4),
        width: 1,
      ),
    );
  }

  Widget _buildSliderLabels() {
    return Row(
       mainAxisAlignment: MainAxisAlignment.center,
       children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFFD900), Color(0xFFFF9900)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds),
            child: Text(
              (widget.hourOffset.abs() < 0.01) ? "Now" : formatTimeLabel(),
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white, // Required for ShaderMask
              ),
            ),
          ),
         if (widget.hourOffset.abs() >= 0.01) ...[
           const SizedBox(width: 8),
           GestureDetector(
             onTap: () => widget.onHourOffsetChanged(0),
             child: Container(
               width: 20, 
               height: 20,
               decoration: const BoxDecoration( // iOS System Grey
                 color: Color(0xFF8E8E93),
                 shape: BoxShape.circle,
               ),
               child: const Icon(Icons.close, size: 14, color: Colors.white),
             ),
           ),
         ],
       ],
     );
  }
  
  Widget _buildSliderTrack(double trackWidth, double knobX, double pixelsPerHour, bool isDark) {
    const double knobWidth = 38.0;
    return SizedBox(
       width: trackWidth,
       height: 24,
       child: Stack(
         alignment: Alignment.centerLeft,
         clipBehavior: Clip.none,
         children: [
           CustomPaint(
             size: Size(trackWidth, 6),
             painter: SliderTrackPainter(
               currentHour: currentHomeHour,
               pixelsPerHour: pixelsPerHour,
               centerX: (trackWidth / 2),
               trackWidth: trackWidth,
               theme: widget.theme,
               isDark: isDark,
             ),
           ),
            Positioned(
              left: knobX - (knobWidth / 2),
              top: 0,
              child: GestureDetector(
               onHorizontalDragStart: (details) {
                 setState(() {
                   isDragging = true;
                   dragStartOffset = widget.hourOffset;
                 });
               },
               onHorizontalDragUpdate: (details) {
                   // Sensitivity factor: 2.5x (increased from 1.5x)
                   const sensitivity = 2.5; 
                   final dragHours = (details.primaryDelta! * sensitivity) / pixelsPerHour;
                   
                   double newOffset = widget.hourOffset + dragHours;
                   newOffset = newOffset.clamp(-12.0, 12.0);
                   
                   // Snap logic for Haptic
                   final currentMinuteFraction = DateTime.now().minute / 60.0;
                   final targetTime = currentMinuteFraction + newOffset;
                   final snappedTarget = (targetTime * 4).round() / 4.0;
                   final snappedOffset = snappedTarget - currentMinuteFraction;
                   
                   // Haptic
                   final currentInterval = (snappedOffset * 4).round();
                   if (currentInterval != lastHapticHour) {
                     Vibration.vibrate(duration: 50);
                     lastHapticHour = currentInterval;
                   }
                   
                   widget.onHourOffsetChanged(snappedOffset);
               },
               onHorizontalDragEnd: (details) {
                 setState(() {
                   isDragging = false;
                 });
               },
               child: _buildKnob(),
             )
           )
         ],
       ),
     );
  }

  Widget _buildHomeTimeLabel(bool isDark) {
      return Row(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           SvgPicture.asset(
             "assets/images/navigation.svg",
             height: 14,
             width: 14,
               colorFilter: ColorFilter.mode(
                   isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.6), 
                   BlendMode.srcIn
               ),
           ),
           const SizedBox(width: 4),
            Text(
              widget.homeTimeZone!.formattedTime(), // Removed offsetBy to keep it constant
              style: GoogleFonts.outfit(
                fontSize: 15, 
                fontWeight: FontWeight.w400, 
                color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
              ),
            ),
         ],
       );
  }

  Widget _buildKnob() {
     final isDark = Theme.of(context).brightness == Brightness.dark;
     
     // Determine knob color
     Color knobColor;
     if (isDragging) {
       knobColor = isDark ? Colors.black : const Color(0xFF8E8E93); // Dark Black or Grey while sliding
     } else {
       knobColor = Colors.white; // White while stable
     }

     // Determine border color
     final Color? borderColor;
     if (isDragging) {
       borderColor = isDark ? Colors.grey : Colors.white;
     } else {
       borderColor = null;
     }

     return AnimatedContainer(
       duration: const Duration(milliseconds: 200),
       width: 40,
       height: 24,
       decoration: BoxDecoration(
         color: knobColor,
         borderRadius: BorderRadius.circular(12),
         border: borderColor != null ? Border.all(color: borderColor, width: 1) : null,
         boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
            if (isDragging)
              BoxShadow(
                color: const Color(0xFFFFCC00).withValues(alpha: 0.3), // Reduced yellow glow
                blurRadius: 8,
                spreadRadius: 1,
              )
         ],
       ),
     );
  }
}

class SliderTrackPainter extends CustomPainter {
  final double currentHour;
  final double pixelsPerHour;
  final double centerX;
  final double trackWidth;
  final ThemeColors theme;

  SliderTrackPainter({
    required this.currentHour,
    required this.pixelsPerHour,
    required this.centerX,
    required this.trackWidth,
    required this.theme,
    required this.isDark,
  });
  
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final trackY = (size.height - 4) / 2; // Thinner track
    final trackRect = Rect.fromLTWH(0, trackY, trackWidth, 4);
    final trackRRect = RRect.fromRectAndRadius(trackRect, const Radius.circular(2));
    
    // Draw Background Track (Black in Dark, White in Light)
    // Draw Background Track (White in Dark, Light Grey in Light for visibility)
    final bgPaint = Paint()..color = isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFFE0E0E0);
    canvas.drawRRect(trackRRect, bgPaint);

    // Calculate Segments for Daylight
    final segments = _calculateDaySegments();
    
    final dayPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFD900), Color(0xFFFF9900)] // Strong Yellow/Orange
      ).createShader(trackRect);
          
    for (final segment in segments) {
       final startX = max(0.0, segment.startX);
       final endX = min(trackWidth, segment.endX);
       final width = endX - startX;
       
       if (width > 0) {
         final dayRect = Rect.fromLTWH(startX, trackY, width, 4);
         
         final leftRadius = startX <= 0 ? const Radius.circular(2) : Radius.zero;
         final rightRadius = endX >= trackWidth ? const Radius.circular(2) : Radius.zero;
         
         final dayRRect = RRect.fromRectAndCorners(
           dayRect,
           topLeft: leftRadius, bottomLeft: leftRadius,
           topRight: rightRadius, bottomRight: rightRadius,
         );
         
         canvas.drawRRect(dayRRect, dayPaint);
       }
    }
  }

  List<_DaySegment> _calculateDaySegments() {
    List<_DaySegment> segments = [];
    for (int dayOffset = -1; dayOffset <= 1; dayOffset++) {
       final dayOffsetHours = dayOffset * 24.0;
       final dayStart = 6.0 + dayOffsetHours;
       final dayEnd = 18.0 + dayOffsetHours;
       
       final hoursToStart = dayStart - currentHour;
       final hoursToEnd = dayEnd - currentHour;
       
       if (hoursToEnd >= -12 && hoursToStart <= 12) {
         final clampedStart = max(-12.0, hoursToStart);
         final clampedEnd = min(12.0, hoursToEnd);
         
         final startX = centerX + clampedStart * pixelsPerHour;
         final endX = centerX + clampedEnd * pixelsPerHour;
         
         if (endX > startX) {
           segments.add(_DaySegment(startX, endX));
         }
       }
    }
    return segments;
  }

  @override
  bool shouldRepaint(covariant SliderTrackPainter oldDelegate) {
     return oldDelegate.currentHour != currentHour || oldDelegate.theme != theme;
  }
}

class TickPainter extends CustomPainter {
  final double trackWidth;
  final double knobX;
  final ThemeColors theme;
  final bool isDark;

  TickPainter({required this.trackWidth, required this.knobX, required this.theme, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final totalTicks = 17;
    for (int i = 0; i < totalTicks; i++) {
       final tickX = i * (trackWidth / (totalTicks - 1));
       final isAtKnob = (tickX - knobX).abs() < (trackWidth / (totalTicks - 1) / 2);
       
       final Color tickColor;
       if (isAtKnob) {
         tickColor = const Color(0xFFFFCC00); // Active tick yellow
       } else {
         tickColor = isDark ? Colors.white : Colors.black; // Solid Black/White as requested
       }
       
       final paint = Paint()
         ..color = tickColor
         ..style = PaintingStyle.fill;
         
        // Uniform size as requested
        const radius = 2.0;
        
        canvas.drawCircle(Offset(tickX, size.height / 2), radius, paint);
     } 
  }

  @override
  bool shouldRepaint(covariant TickPainter oldDelegate) {
    return oldDelegate.knobX != knobX;
  }
}

class _DaySegment {
  final double startX;
  final double endX;
  _DaySegment(this.startX, this.endX);
}
