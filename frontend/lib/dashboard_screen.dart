import 'package:flutter/material.dart';
import 'package:frontend/home_screen.dart';
import 'package:frontend/main.dart';
import 'package:frontend/profile_screen.dart';
import 'package:frontend/shop_screen.dart';
import 'package:frontend/order_screen.dart';
import 'package:frontend/database_service.dart';

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
    DatabaseService.authNotifier.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    DatabaseService.authNotifier.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
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
        icon: Icon(Icons.receipt_long),
        label: "Orders",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.account_circle_rounded),
        label: "Profile",
      ),
    ];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bottomNavBar = BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.colorScheme.surface,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
                "FreshMeal",
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
                    themeNotifier.value =
                        isDark ? ThemeMode.light : ThemeMode.dark;
                  },
                  icon: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            )
          : null,
      body: IndexedStack(
        index: _indexSelectedItems,
        children: [
          HomeScreen(
            isSelected: true,
            onNavigateToShop: () => _onTabClick(1),
            onNavigateToProfile: () => _onTabClick(3),
          ),
          const ShopScreen(),
          OrderScreen(key: ValueKey(DatabaseService.token)),
          ProfileScreen(key: ValueKey(DatabaseService.token)),
        ],
      ),
      bottomNavigationBar: bottomNavBar,
    );
  }
}
