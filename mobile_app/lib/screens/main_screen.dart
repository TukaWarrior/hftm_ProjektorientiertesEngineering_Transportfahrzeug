import 'package:flutter/material.dart';
import 'package:mobile_app/screens/page2_screen.dart';
import 'package:mobile_app/screens/settings_screen.dart';

class MainMenuItem {
  static final List<MainMenuItem> items = _getMenuItems();
  final IconData icon;
  final String text;
  final Widget page;
  final GlobalKey<NavigatorState> navigatorKey;
  MainMenuItem({required this.icon, required this.text, required this.page}) : navigatorKey = GlobalKey<NavigatorState>();
}

List<MainMenuItem> _getMenuItems() => [
      // MainMenuItem(icon: Icons.article_rounded, text: "Home", page: const ESP32Screen()),
      MainMenuItem(icon: Icons.home_rounded, text: "HomeScreen", page: const ESP32Screen()),
      MainMenuItem(icon: Icons.settings_rounded, text: "Settings", page: const SettingsPage()),
    ];

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  void _onMenuItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
    Navigator.pop(context); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    final selectedMenuItem = MainMenuItem.items[selectedIndex];

    // The container for the current page, with its background color
    // and subtle switching animation.
    var mainArea = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Navigator(
          key: selectedMenuItem.navigatorKey,
          onGenerateRoute: (settings) => MaterialPageRoute(builder: (context) => selectedMenuItem.page),
        ),
      ),
    );

    final menuItems = MainMenuItem.items
        .map((m) => ListTile(
              leading: Icon(m.icon),
              selected: selectedIndex == MainMenuItem.items.indexOf(m),
              onTap: () => _onMenuItemSelected(MainMenuItem.items.indexOf(m)),
            ))
        .toList();

    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 450) {
              return Scaffold(
                drawer: Drawer(
                  child: ListView(
                    children: menuItems,
                  ),
                ),
                body: mainArea,
                bottomNavigationBar: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  showUnselectedLabels: false,
                  items: MainMenuItem.items
                      .map((m) => BottomNavigationBarItem(
                            icon: Icon(m.icon),
                            label: '',
                          ))
                      .toList(),
                  currentIndex: selectedIndex,
                  onTap: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              );
            } else {
              return Row(
                children: [
                  NavigationRail(
                    minWidth: 56,
                    extended: false,
                    destinations: MainMenuItem.items.map((m) => NavigationRailDestination(icon: Icon(m.icon), label: Text(''))).toList(),
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                  Expanded(child: mainArea),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
