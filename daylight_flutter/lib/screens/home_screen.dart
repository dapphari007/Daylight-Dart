import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/timezone_store.dart';
import '../models/timezone_item.dart';
import '../utils/app_settings.dart';
import '../utils/theme_colors.dart';
import '../widgets/timezone_card.dart';
import '../widgets/time_slider.dart';
import 'add_timezone_screen.dart';
import 'settings_screen.dart';
import '../widgets/glass_bottom_sheet.dart';
import '../widgets/glass_menu.dart';
import '../widgets/bouncing_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double hourOffset = 0;
  late Timer _updateTimer;

  TimeZoneItem? get homeTimeZone {
    final store = Provider.of<TimeZoneStore>(context, listen: false);
    try {
      return store.timeZones.firstWhere((element) => element.isHome);
    } catch (e) {
      if (store.timeZones.isNotEmpty) return store.timeZones.first;
      return null;
    }
  }

  List<TimeZoneItem> get sortedTimeZones {
    final store = Provider.of<TimeZoneStore>(context);
    final home = homeTimeZone;
    if (home == null) return store.timeZones;

    final homeOffset = home.secondsFromGMT;
    
    final sorted = List<TimeZoneItem>.from(store.timeZones);
    sorted.sort((a, b) {
       final offset1 = a.secondsFromGMT - homeOffset;
       final offset2 = b.secondsFromGMT - homeOffset;
       return offset1.compareTo(offset2);
    });
    return sorted;
  }

  @override
  void initState() {
    super.initState();
    // Update timezone displays every second to show current time
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Debug: HomeScreen building...");
    final settings = Provider.of<AppSettings>(context);
    // Determine brightness based on settings
    final brightness = settings.themeMode == ThemeMode.dark ? Brightness.dark : 
                       (settings.themeMode == ThemeMode.light ? Brightness.light : MediaQuery.of(context).platformBrightness);
                       
    final theme = ThemeColors(brightness);
    debugPrint("Debug: Theme brightness: $brightness, Background: ${theme.background}");

    return Scaffold(
      backgroundColor: theme.background,
      body: Stack(
        children: [
          // Main Content Layer
          SafeArea(
            bottom: false, // Slider handles bottom safe area
            child: Column(
              children: [
                _buildHeader(theme, context),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 220 + MediaQuery.of(context).padding.bottom),
                    itemCount: sortedTimeZones.length,
                    itemBuilder: (context, index) {
                      final tzItem = sortedTimeZones[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: TimeZoneCard(
                          timeZone: tzItem,
                          hourOffset: hourOffset,
                          homeTimeZone: homeTimeZone,
                          showCenterLine: settings.showCenterLine,
                          theme: theme,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Slider Layer
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: TimeSlider(
              hourOffset: hourOffset,
              onHourOffsetChanged: (val) {
                setState(() {
                  hourOffset = val;
                });
              },
              homeTimeZone: homeTimeZone,
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeColors theme, BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        child: Row(
          children: [
            Text(
              "Daylight",
              style: GoogleFonts.outfit(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: theme.headerText,
              ),
            ),
            const Spacer(),

             const SizedBox(width: 8),
              BouncingButton(
                onTap: () {
                  Navigator.of(context).push(
                   PageRouteBuilder(
                     opaque: false,
                     transitionDuration: const Duration(milliseconds: 300),
                     reverseTransitionDuration: const Duration(milliseconds: 200),
                     barrierColor: Colors.transparent, 
                     pageBuilder: (context, animation, secondaryAnimation) => GlassMenu(
                       onAddTimeZone: () {
                         showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              bool isFullScreen = false;
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return NotificationListener<DraggableScrollableNotification>(
                                    onNotification: (notification) {
                                      final newIsFull = notification.extent >= 0.92;
                                      if (newIsFull != isFullScreen) {
                                        setState(() {
                                          isFullScreen = newIsFull;
                                        });
                                      }
                                      return false;
                                    },
                                    child: DraggableScrollableSheet(
                                      initialChildSize: 0.5,
                                      minChildSize: 0.4,
                                      maxChildSize: 0.95,
                                      builder: (context, scrollController) {
                                        return GlassBottomSheet(
                                          title: "Add Timezone",
                                          actionText: "Done", 
                                          onAction: () => Navigator.pop(context),
                                          expandContent: true,
                                          isFullScreen: isFullScreen,
                                          child: AddTimeZoneScreen(scrollController: scrollController),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                         );
                       },
                       onSettings: () {
                         showModalBottomSheet(
                           context: context,
                           isScrollControlled: true,
                           backgroundColor: Colors.transparent,
                           barrierColor: Colors.black.withValues(alpha: 0.5),
                           builder: (context) => GlassBottomSheet(
                             title: "Settings",
                             actionText: "Done",
                             onAction: () => Navigator.pop(context),
                             child: SettingsScreen(),
                           ),
                         );
                       },
                     ),
                     transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
                        return ScaleTransition(
                          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curve),
                          alignment: Alignment.topRight, // Originating from the settings icon
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                     },
                   ),
                 );
               },
               child: Container(
                 width: 52, height: 52, 
                 decoration: BoxDecoration(
                   color: theme.headerText.withValues(alpha: 0.1),
                   shape: BoxShape.circle,
                   border: Border.all(
                     color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.4),
                     width: 1,
                   ),
                 ),
                 padding: const EdgeInsets.all(10), 
                 child: SvgPicture.asset(
                   "assets/images/brand.svg",
                   colorFilter: ColorFilter.mode(theme.headerText, BlendMode.srcIn),
                 ),
               ),
             ),
          ],
        ),
      ),
    );
  }
}
