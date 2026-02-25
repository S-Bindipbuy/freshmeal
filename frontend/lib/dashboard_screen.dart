import 'package:flutter/material.dart';
import 'package:frontend/home_screen.dart';
import 'package:frontend/notification_screen.dart';
import 'package:frontend/profile_screen.dart';
import 'package:frontend/shop_screen.dart';

class dashboardScreen extends StatefulWidget{
  const dashboardScreen({super.key});

  @override
  State<dashboardScreen> createState() => dashboardScreenState();
}

class dashboardScreenState extends State<dashboardScreen>{
  int _indexSelectedItems = 0;

  List<Widget> screen = [
    homeScreen(),
    shopScreen(),
    notificationScreen(),
    profileScreen(),
  ];

  void _onTabClick(int index){
    print("Index : $index");
    setState(() {
      _indexSelectedItems = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<BottomNavigationBarItem> bottomNavBarItems = [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home", backgroundColor: Color(0xFFF79926)),
      BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: "Shop", backgroundColor: Color(0xFFF79926)),
      BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notification", backgroundColor: Color(0xFFF79926)),
      BottomNavigationBarItem(icon: Icon(Icons.account_circle_rounded), label: "Profile", backgroundColor: Color(0xFFF79926))
    ];
    final bottomNavBar = BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Color(0xFFF79926),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withOpacity(0.7),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: TextStyle(
        fontFamily: "Poetsen",
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: "Poetsen",
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
      currentIndex: _indexSelectedItems,
      items: bottomNavBarItems,
      onTap: (index) {
        _onTabClick(index);
      },
    );

    return Scaffold(
      appBar: _indexSelectedItems == 0
          ? AppBar(
        title: const Text(
          "Hi, SuperAdmin",
          style: TextStyle(
            fontSize: 24,
            color: Color(0xFFF79926),
            fontFamily: "Poetsen",
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            iconSize: 24.0,
            onPressed: () {},
            icon: const Icon(Icons.notifications_active),
          ),
          IconButton(
            padding: const EdgeInsets.only(right: 20.0),
            icon: Image.asset('assets/profile.png', width: 24.0, height: 24.0),
            onPressed: () {},
          ),
        ],
      )
          : null,
      body: screen.elementAt(_indexSelectedItems),
      bottomNavigationBar: bottomNavBar,
    );
  }
}

