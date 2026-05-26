import 'package:flutter/material.dart';
import 'package:mobile_app/screens/splash_screen.dart';
import 'package:mobile_app/screens/login_screen.dart';
import 'package:mobile_app/screens/dashboard_screen.dart';
import 'package:mobile_app/theme/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ruangin - Smart Room Booking',
      debugShowCheckedModeBanner: false,
      theme: AppColorTheme.lightTheme(),
      darkTheme: AppColorTheme.darkTheme(),
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
