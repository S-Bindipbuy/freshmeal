import 'package:flutter/material.dart';
import 'package:frontend/login_screen.dart';
import 'package:frontend/order_screen.dart';
import 'package:frontend/register_screen.dart';
import 'package:frontend/dashboard_screen.dart';

void main() {
  orderScreen();
  dashboardScreen();
  registerScreen();

  final login = loginScreen();

  final app = MaterialApp(debugShowCheckedModeBanner: false, home: login);

  runApp(app);
}
