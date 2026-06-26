import 'package:flutter/material.dart';
import 'package:frontend/app_theme.dart';
import 'package:frontend/login_screen.dart';
import 'package:frontend/database_service.dart';
import 'package:rhttp/rhttp.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Rhttp.init();
    final rhttpClient = await RhttpClient.create(
      settings: const ClientSettings(
        throwOnStatusCode: false,
      ),
    );
    DatabaseService.setClient(rhttpClient);
  } catch (e) {
    debugPrint("Failed to initialize Rhttp: $e");
  }
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
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: const LoginScreen(),
        );
      },
    );
  }
}
