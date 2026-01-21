import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/timezone_store.dart';
import '../models/timezone_item.dart';
import '../models/available_timezones.dart';

import 'package:vibration/vibration.dart';

class AddTimeZoneScreen extends StatefulWidget {
  final ScrollController? scrollController;
  
  const AddTimeZoneScreen({super.key, this.scrollController});

  @override
  State<AddTimeZoneScreen> createState() => _AddTimeZoneScreenState();
}

class _AddTimeZoneScreenState extends State<AddTimeZoneScreen> {
  String searchText = "";
  final TextEditingController _searchController = TextEditingController();

  List<AvailableTimeZone> get filteredTimeZones {
    if (searchText.isEmpty) {
      return AvailableTimeZone.all;
    }
    return AvailableTimeZone.all.where((tz) {
      return tz.cityName.toLowerCase().contains(searchText.toLowerCase()) ||
          tz.abbreviation.toLowerCase().contains(searchText.toLowerCase());
    }).toList();
  }

  bool isAlreadyAdded(TimeZoneStore store, AvailableTimeZone tz) {
    return store.timeZones.any((item) => item.cityName == tz.cityName);
  }

  void toggleTimeZone(BuildContext context, AvailableTimeZone tz) {
    final store = Provider.of<TimeZoneStore>(context, listen: false);
    final isAdded = isAlreadyAdded(store, tz);
    
    if (isAdded) {
       // Remove
       final item = store.timeZones.firstWhere((element) => element.cityName == tz.cityName);
       store.removeTimeZone(item);
    } else {
       // Add
       final newItem = TimeZoneItem(
         identifier: tz.identifier,
         cityName: tz.cityName,
         abbreviation: tz.abbreviation,
         isHome: false, 
       );
       store.addTimeZone(newItem);
    }

    // Vibrate
    Vibration.vibrate(duration: 100);
  }

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<TimeZoneStore>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Search Bar at Top
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : const Color(0x1F767680), // iOS Search Field Fill
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _searchController,
              textAlignVertical: TextAlignVertical.center,
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 17,
              ),
              cursorColor: const Color(0xFFFF9900),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                prefixIcon: Icon(
                  CupertinoIcons.search,
                  size: 20,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                hintText: "Search cities",
                hintStyle: GoogleFonts.outfit(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                  fontSize: 17,
                ),
                border: InputBorder.none,
                suffixIcon: searchText.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            searchText = "";
                          });
                        },
                        child: Icon(
                          CupertinoIcons.clear_circled_solid,
                          size: 18,
                          color: isDark ? Colors.grey : Colors.grey.shade600,
                        ),
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),
        ),

        // List (Expanded)
        Expanded(
          child: ListView.separated(
            controller: widget.scrollController, 
            padding: const EdgeInsets.symmetric(horizontal: 16), // Boxed list style? No, usually edge to edge or 16pad. Screenshot shows full width separators? No, inset.
            // But wait, the screenshot shows the list content. It looks like standard iOS List.
            itemCount: filteredTimeZones.length,
            separatorBuilder: (c, i) => Divider(
              height: 1, 
              color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.1), 
              indent: 0 // Screenshot seems to have full width or slight indent. I'll use 0 or standard 16. iOS uses 16 indent generally.
            ),
            itemBuilder: (context, index) {
              final tz = filteredTimeZones[index];
              final added = isAlreadyAdded(store, tz);
              
              return InkWell(
                onTap: added ? null : () {
                   // Add and Dismiss
                   final newItem = TimeZoneItem(
                     identifier: tz.identifier,
                     cityName: tz.cityName,
                     abbreviation: tz.abbreviation,
                     isHome: false, 
                   );
                   store.addTimeZone(newItem);
                   Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               tz.cityName, 
                               style: GoogleFonts.outfit(
                                 fontWeight: FontWeight.w600, 
                                 fontSize: 17,
                                 color: isDark ? Colors.white : Colors.black
                               )
                             ),
                             const SizedBox(height: 2),
                             Text(
                               tz.abbreviation, 
                               style: GoogleFonts.outfit(
                                 color: isDark ? Colors.grey : Colors.grey.shade600,
                                 fontSize: 13,
                               )
                             ),
                           ],
                         ),
                       ),
                       if (added)
                         Icon(
                           CupertinoIcons.checkmark_alt_circle_fill, 
                           color: const Color(0xFFFF9900), 
                           size: 22
                         ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
