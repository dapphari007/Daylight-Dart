import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timezone_store.dart';

class EditListScreen extends StatelessWidget {
  const EditListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<TimeZoneStore>(context);

    // ReorderableListView needs a list of items to key against.
    // The store needs a reorder method.
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit List"),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Done", style: TextStyle(color: Color(0xFFFF9900))),
          )
        ],
      ),
      body: ReorderableListView.builder(
        itemCount: store.timeZones.length,
        itemBuilder: (context, index) {
          final tz = store.timeZones[index];
          return ListTile(
            key: ValueKey(tz.id),
            leading: tz.isHome 
                ? const Icon(Icons.home, color: Color(0xFFFF9900)) 
                : const Icon(Icons.drag_handle, color: Colors.transparent), // Placeholder for alignment if we want
            // Actually ReorderableListView adds a handle at trailing by default.
            // We can put Home icon in content.
            
            title: Text(tz.cityName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(tz.abbreviation),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!tz.isHome)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      store.removeTimeZone(tz);
                    },
                  ),
                // Reorder handle is automatically added by ReorderableListView
              ],
            ),
            onTap: () {
                // Swift code didn't seem to allow tapping to set home in Edit mode, 
                // but let's check.
                // Swift: just onDelete and onMove.
                // But logically users might want to set home.
                // Swift's EditListView just shows the list. 
                // Wait, ContentView line 154 checks isHome to show house.fill.
                // It doesn't seem to have a button to change home in Edit mode explicitly shown in the code snippet,
                // but usually you might want that.
                // For direct port, we stick to Swift logic: just display.
            },
          );
        },
        onReorder: (oldIndex, newIndex) {
          // Flutter ReorderableListView eccentricities: 
          // if newIndex > oldIndex, newIndex -= 1;
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = store.timeZones.removeAt(oldIndex);
          store.timeZones.insert(newIndex, item);
          // We need to update the store to save
          store.saveAfterReorder(); 
        },
      ),
    );
  }
}
