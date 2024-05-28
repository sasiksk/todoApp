import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final String selectedListType;
  final Function(String) onItemTap;

  const CustomDrawer({
    super.key,
    required this.selectedListType,
    required this.onItemTap,
  });

  final List<Map<String, String>> drawerItems = const [
    {'title': 'Full List', 'type': 'Full List'},
    {'title': 'Overdue', 'type': 'Overdue'},
    {'title': 'Today', 'type': 'Today'},
    {'title': 'Tomorrow', 'type': 'Tomorrow'},
    {'title': 'This Week', 'type': 'This Week'},
    {'title': 'This Month', 'type': 'This Month'},
    {'title': 'Beyond This Month', 'type': 'Beyond This Month'},
    {'title': 'No Due', 'type': 'No Due'},
    {'title': 'Completed', 'type': 'Completed'},
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 16.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 100,
              child: const DrawerHeader(
                decoration: BoxDecoration(color: Colors.teal),
                child: Text(
                  'Select Option',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              itemCount: drawerItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(drawerItems[index]['title']!),
                  onTap: () {
                    Navigator.pop(context);
                    onItemTap(drawerItems[index]['type']!);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
