import 'package:flutter/material.dart';
import 'package:frontend/app_theme.dart';
import 'package:frontend/dashboard_screen.dart';
import 'package:frontend/database_service.dart';
import 'package:http/http.dart' as http;

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final httpClient = http.Client();
  DatabaseService.setClient(httpClient);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, _) {
        return MaterialApp(
          navigatorKey: navKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: const DashboardScreen(),
        );
      },
    );
  }
}
