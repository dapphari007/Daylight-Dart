import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/timezone_item.dart';
import '../utils/theme_colors.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_svg/flutter_svg.dart';

class TimeZoneCard extends StatelessWidget {
  final TimeZoneItem timeZone;
  final double hourOffset;
  final TimeZoneItem? homeTimeZone;
  final bool showCenterLine;
  final ThemeColors theme;

  const TimeZoneCard({
    super.key,
    required this.timeZone,
    required this.hourOffset,
    required this.homeTimeZone,
    required this.showCenterLine,
    required this.theme,
  });

  bool get isHomeTimezone => homeTimeZone?.id == timeZone.id;

  String get formattedDayDate {
    final now = DateTime.now().toUtc().add(Duration(milliseconds: (hourOffset * 3600 * 1000).round()));
    final zonedDate = tz.TZDateTime.from(now, timeZone.location);

    final dayName = DateFormat('EEE').format(zonedDate);
    final dayNumber = zonedDate.day;

    String suffix;
    if (dayNumber >= 11 && dayNumber <= 13) {
      suffix = 'th';
    } else {
      switch (dayNumber % 10) {
        case 1: suffix = 'st'; break;
        case 2: suffix = 'nd'; break;
        case 3: suffix = 'rd'; break;
        default: suffix = 'th'; break;
      }
    }
    return "$dayName $dayNumber$suffix";
  }

  String? get offsetFromHomeText {
    if (homeTimeZone == null || isHomeTimezone) return null;

    final now = tz.TZDateTime.now(tz.local); // Actual now
    final homeOffset = tz.TZDateTime.now(homeTimeZone!.location).timeZoneOffset.inMinutes;
    final thisOffset = tz.TZDateTime.now(timeZone.location).timeZoneOffset.inMinutes;
    
    final diffMinutes = thisOffset - homeOffset;
    final hours = (diffMinutes.abs() / 60).floor();
    final minutes = diffMinutes.abs() % 60;
    
    final sign = diffMinutes >= 0 ? "+" : "-";
    if (minutes == 0) {
      return "$sign${hours}h";
    } else {
      return "$sign${hours}h ${minutes}m";
    }
  }

  double get currentTimeHours {
    // Current hour/minute based on offset
    return timeZone.currentHour(offsetBy: hourOffset) + timeZone.currentMinute(offsetBy: hourOffset) / 60.0;
  }

  double calculateOffsetX(double cardWidth) {
    // blockWidth = 190
    const blockWidth = 190.0;
    const blockSpacing = 2.0;

    // Normalize time: 6AM = 0, 6PM = 12, next 6AM = 24
    // Swift: (currentTimeHours - 6 + 24).truncatingRemainder(dividingBy: 24)
    double normalizedTime = (currentTimeHours - 6 + 24) % 24;

    // Swift: middleDayStart = (blockWidth + blockSpacing) * 6
    const middleDayStart = (blockWidth + blockSpacing) * 6;
    
    // Swift: posInCurrentBlock = (normalizedTime / 12.0) * blockWidth
    // Wait, checked Swift code: It assumes 12 hours per block?
    // Swift line 99: posInCurrentBlock = (normalizedTime / 12.0) * blockWidth
    // Yes.
    double posInCurrentBlock = (normalizedTime / 12.0) * blockWidth;
    
    double currentPosInTimeline = middleDayStart + posInCurrentBlock;

    return (cardWidth / 2) - currentPosInTimeline;
  }

  bool isBlockAtCenter(int dayIndex, bool isDayBlock, double offsetX, double cardWidth) {
    const blockWidth = 190.0;
    const blockSpacing = 2.0;
    const pairWidth = blockWidth * 2 + blockSpacing * 2;
    
    double blockStartX = offsetX + dayIndex * pairWidth;
    if (!isDayBlock) {
      blockStartX += blockWidth + blockSpacing;
    }
    
    double blockEndX = blockStartX + blockWidth;
    double centerX = cardWidth / 2;
    
    return blockStartX <= centerX && centerX <= blockEndX;
  }

  @override
  Widget build(BuildContext context) {
    const cardHeight = 108.0;
    const blockWidth = 190.0;
    const blockSpacing = 2.0;

    return SizedBox(
      height: cardHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth;
          final offsetX = calculateOffsetX(cardWidth);

          return Stack(
            children: [
              // Background Blocks (Custom Paint for performance)
              RepaintBoundary(
                child: CustomPaint(
                  painter: TimeZoneCardPainter(
                    offsetX: offsetX,
                    theme: theme,
                    blockWidth: blockWidth,
                    blockSpacing: blockSpacing,
                  ),
                  size: Size(cardWidth, cardHeight),
                ),
              ),
              
              // Overlay Text Labels (Only when at center)
              // We simulate the infinite list by rendering just 7 days centered loosely around the current one
              // but shifting them with the offset.
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Stack(
                  children: List.generate(7, (day) {
                    final pairWidth = blockWidth * 2 + blockSpacing * 2;
                    final dayBlockX = offsetX + day * pairWidth;
                    final nightBlockX = dayBlockX + blockWidth + blockSpacing;

                    return Stack(
                      children: [
                        // Day Block Content
                        Positioned(
                          left: dayBlockX,
                          top: 0,
                          width: blockWidth,
                          height: cardHeight,
                          child: Center(
                            child: isBlockAtCenter(day, true, offsetX, cardWidth)
                                ? _buildTimeLabel(true)
                                : const SizedBox(),
                          ),
                        ),
                        // Night Block Content
                        Positioned(
                          left: nightBlockX,
                          top: 0,
                          width: blockWidth,
                          height: cardHeight,
                          child: Center(
                            child: isBlockAtCenter(day, false, offsetX, cardWidth)
                                ? _buildTimeLabel(false)
                                : const SizedBox(),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),

              // Center Line
              if (showCenterLine)
                Center(
                  child: Container(
                    width: 2,
                    height: cardHeight,
                    color: theme.centerLine,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimeLabel(bool isDaylight) {
    final textColor = isDaylight ? const Color(0xFFBE3C00) : theme.nightText;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isDaylight
              ? SvgPicture.asset(
                  "assets/images/sun.svg",
                  height: 16,
                  width: 16,
                  colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                )
              : SvgPicture.asset(
                  "assets/images/moon.svg",
                  height: 14, // Moon is usually slightly smaller visually in SF Symbols
                  width: 14,
                  colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                ),
          const SizedBox(height: 3),
          Text(
            timeZone.formattedTime(offsetBy: hourOffset),
            style: GoogleFonts.outfit(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2), // Slight spacing
          Text(
            "${timeZone.cityName} (${timeZone.abbreviation})",
            style: GoogleFonts.outfit(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isHomeTimezone)
                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: SvgPicture.asset(
                    "assets/images/navigation.svg",
                    height: 12,
                    width: 12,
                    colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                  ),
                )
              else if (offsetFromHomeText != null)
                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Text(
                    "${offsetFromHomeText!},",
                    style: GoogleFonts.outfit(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              Text(
                formattedDayDate,
                style: GoogleFonts.outfit(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TimeZoneCardPainter extends CustomPainter {
  final double offsetX;
  final ThemeColors theme;
  final double blockWidth;
  final double blockSpacing;

  TimeZoneCardPainter({
    required this.offsetX,
    required this.theme,
    required this.blockWidth,
    required this.blockSpacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final nightPaint = Paint()..color = theme.nightBlock;
    final dayPaint = Paint()
      ..shader = const LinearGradient(
        colors: [ThemeColors.daylightStart, ThemeColors.daylightEnd],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)); // Gradient depends on position? Swift uses local rect.

    for (int day = 0; day < 7; day++) {
      final dayBlockX = offsetX + day * (blockWidth * 2 + blockSpacing * 2);
      final nightBlockX = dayBlockX + blockWidth + blockSpacing;

      // Draw Day Block
      final dayRect = Rect.fromLTWH(dayBlockX, 0, blockWidth, size.height);
      // Re-create shader for specific rect to match Swift logic (local gradient)
      dayPaint.shader = const LinearGradient(
        colors: [ThemeColors.daylightStart, ThemeColors.daylightEnd],
      ).createShader(dayRect);
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(dayRect, const Radius.circular(5)),
        dayPaint,
      );

      // Draw Night Block
      final nightRect = Rect.fromLTWH(nightBlockX, 0, blockWidth, size.height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(nightRect, const Radius.circular(5)),
        nightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant TimeZoneCardPainter oldDelegate) {
    return oldDelegate.offsetX != offsetX || oldDelegate.theme != theme;
  }
}
