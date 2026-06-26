import 'package:flutter/material.dart';
import 'package:frontend/home_screen.dart';
import 'package:frontend/main.dart';
import 'package:frontend/notification_screen.dart';
import 'package:frontend/profile_screen.dart';
import 'package:frontend/shop_screen.dart';
import 'package:frontend/order_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _indexSelectedItems = 0;

  @override
  void initState() {
    super.initState();
  }

  void _onTabClick(int index) {
    setState(() {
      _indexSelectedItems = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const bottomNavBarItems = [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: "Home",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.shopping_bag),
        label: "Shop",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.notifications),
        label: "Notification",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.account_circle_rounded),
        label: "Profile",
      )
    ];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bottomNavBar = BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: isDark ? Colors.black : theme.colorScheme.primary,
      selectedItemColor: isDark ? Colors.white : Colors.white,
      unselectedItemColor: isDark ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.7),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(
        fontFamily: "Poetsen",
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: "Poetsen",
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
      currentIndex: _indexSelectedItems,
      items: bottomNavBarItems,
      onTap: _onTabClick,
    );

    return Scaffold(
      appBar: _indexSelectedItems == 0
          ? AppBar(
              title: Text(
                "Hi, SuperAdmin",
                style: TextStyle(
                  fontSize: 24,
                  color: theme.colorScheme.primary,
                  fontFamily: "Poetsen",
                  fontWeight: FontWeight.w500,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
                  },
                  icon: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: isDark ? Colors.orangeAccent : Colors.black87,
                  ),
                ),
                IconButton(
                  iconSize: 24.0,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OrderScreen()),
                    );
                  },
                  icon: Icon(Icons.shopping_bag_outlined,
                      color: theme.colorScheme.primary),
                ),
                IconButton(
                  padding: const EdgeInsets.only(right: 20.0),
                  icon: Image.asset('assets/profile.png',
                      width: 24.0, height: 24.0),
                  onPressed: () {},
                ),
              ],
            )
          : null,
      body: IndexedStack(
        index: _indexSelectedItems,
        children: [
          HomeScreen(isSelected: _indexSelectedItems == 0),
          ShopScreen(isSelected: _indexSelectedItems == 1),
          const NotificationScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: bottomNavBar,
    );
  }
}
