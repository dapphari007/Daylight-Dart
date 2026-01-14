import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    // We use the app's theme instead of forcing dark, but the sheet has its own glass style.
    // However, user specifically asked for "Search bar at bottom".
    
    return Column(
      children: [
        // List (Expanded)
        Expanded(
          child: ListView.separated(
            controller: widget.scrollController, // Attach draggable controller
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            itemCount: filteredTimeZones.length,
            separatorBuilder: (c, i) => Divider(
              height: 1, 
              color: isDark ? Colors.grey.withOpacity(0.2) : Colors.black.withOpacity(0.1), 
              indent: 16
            ),
            itemBuilder: (context, index) {
              final tz = filteredTimeZones[index];
              final added = isAlreadyAdded(store, tz);
              
              return ListTile(
                title: Text(tz.cityName, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                subtitle: Text(tz.abbreviation, style: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade600)),
                trailing: added 
                    ? Container(
                        padding: const EdgeInsets.all(2), // Adjust for size
                        decoration: const BoxDecoration(
                          color: Color(0xFF34C759), // Bright Green
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 16),
                      )
                    : null,
                onTap: () => toggleTimeZone(context, tz),
              );
            },
          ),
        ),
        
        // Search Bar at Bottom (Safe Area)
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), // Padding around search bar
            child: TextField(
              controller: _searchController,
              autofocus: false, // Don't auto-open keyboard as it might cover sheet
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              cursorColor: const Color(0xFFFF9900),
              decoration: InputDecoration(
                hintText: "Search cities",
                hintStyle: TextStyle(color: isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.4)),
                prefixIcon: Icon(Icons.search, color: isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.4)),
                filled: true,
                fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade200, 
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
