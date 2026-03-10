import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_admin_desktop/providers/amenity_provider.dart';
import 'package:terminba_admin_desktop/providers/auth_provider.dart';
import 'package:terminba_admin_desktop/providers/city_provider.dart';
import 'package:terminba_admin_desktop/providers/role_provider.dart';
import 'package:terminba_admin_desktop/providers/sport_center_provider.dart';
import 'package:terminba_admin_desktop/providers/sport_provider.dart';
import 'package:terminba_admin_desktop/providers/turf_type_provider.dart';
import 'package:terminba_admin_desktop/providers/user_provider.dart';
import 'package:terminba_admin_desktop/screens/dashboard_screen.dart';
import 'package:terminba_admin_desktop/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  await authProvider.checkAuthStatus(); 

  runApp(
    MultiProvider(
      providers: [
        // ✅ Pass the pre-checked instance directly, don't create a new one
        ChangeNotifierProvider<AuthProvider>(create: (_) => authProvider),
        ChangeNotifierProvider<AmenityProvider>(create: (_) => AmenityProvider()),
        ChangeNotifierProvider<TurfTypeProvider>(create: (_) => TurfTypeProvider()),
        ChangeNotifierProvider<CityProvider>(create: (_) => CityProvider()),
        ChangeNotifierProvider<SportProvider>(create: (_) => SportProvider()),
        ChangeNotifierProvider<RoleProvider>(create: (_) => RoleProvider()),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProvider<SportCenterProvider>(create: (_) => SportCenterProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
   
    final authProvider = context.watch<AuthProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TerminBA Admin Desktop',
      theme: AppTheme.lightTheme,
      home: authProvider.isLoggedIn
          ? const DashboardScreen()
          : const LoginPage(),
    );
  }
}

class AppTheme {
  // Primary Colors from the Screenshots
  static const Color primaryGreen = Color(
    0xFF00C875,
  ); // Action buttons & Mobile navbar
  static const Color secondaryOrange = Color(
    0xFFFF5722,
  ); // Reviews & Delete buttons
  static const Color adminNavbarBg = Color(
    0xFFD9F2E6,
  ); // Light mint admin header
  static const Color backgroundGray = Color(0xFFF8F9FA); // Screen background
  static const Color cardShadow = Color(0x1A000000);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: backgroundGray,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: secondaryOrange,
        surface: Colors.white,
      ),

      // Card Theme for Facility & User containers
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Color.fromARGB(255, 79, 219, 161),
        elevation: 0.5,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        centerTitle: false,
        toolbarHeight: 75,
      ),

      // Input Decoration (Search Bars & Forms)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), // Rounded search bars
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      // Navigation Bar (User Mobile App)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: primaryGreen.withValues(alpha: 30),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryGreen);
          }
          return const IconThemeData(color: Colors.grey);
        }),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),

      // Custom Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
        labelSmall: TextStyle(fontSize: 11, color: Colors.grey),
      ),
    );
  }
}
