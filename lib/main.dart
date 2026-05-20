import 'package:flutter/material.dart';
import 'package:mobile_app/screens/login_screen.dart';
import 'package:mobile_app/screens/dashboard_screen.dart';
import 'package:mobile_app/theme/app_colors.dart';
import 'package:mobile_app/services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _authService = AuthService();
  bool _isAuthenticated = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isAuth = await _authService.isAuthenticated();
    setState(() {
      _isAuthenticated = isAuth;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ruangin - Smart Room Booking',
      debugShowCheckedModeBanner: false,
      theme: AppColorTheme.lightTheme(),
      darkTheme: AppColorTheme.darkTheme(),
      themeMode: ThemeMode.light,
      home: _isLoading
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            )
          : _isAuthenticated
              ? const DashboardScreen()
              : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
