// ================================================================
// GROUP S - Student Assistant Application
// Members: Lebohang Molise (224078106), Relebohile Thito (221027701), Tshepo Masimong (223081118)
// ================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/application_viewmodel.dart';
import 'routes/route_manager.dart';

/// Main entry point of the Student Assistant Application
/// Initializes Supabase backend connection and starts the app
void main() async {
  // Ensures Flutter binding is initialized before async operations
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase connection with project credentials
  await Supabase.initialize(
    url: 'https://yjxcrjbcidsgkefamsbo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlqeGNyamJjaWRzZ2tlZmFtc2JvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg1OTU2NzYsImV4cCI6MjA5NDE3MTY3Nn0.dLGDSTAtN-fQ6MgfcQ_mZVcZMoDiUFmPBOg_cF0S8Ys',
  );
  
  runApp(const MyApp());
}

/// MyApp - Root widget of the application
/// Sets up MultiProvider for state management (MVVM pattern)
/// Configures app theme, routing, and global providers
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Register all ViewModels for dependency injection
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ApplicationViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,  // Removes debug banner in top-right
        title: 'Student Assistant App',
        initialRoute: RouteManager.splash,   // Start with auth check
        onGenerateRoute: RouteManager.generateRoute,  // Centralized navigation
        theme: _buildTheme(),  // Custom light theme with brand colors
      ),
    );
  }
  
  // ================================================================
  // THEME CONFIGURATION
  // ================================================================
  
  /// Builds custom light theme for consistent app styling
  /// Uses Material 3 design with Poppins font and brand colors
  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: const Color(0xFF4A6FA5),
      
      // Color scheme based on seed color
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4A6FA5),
        primary: const Color(0xFF4A6FA5),
        secondary: const Color(0xFF6B9AC4),
        tertiary: const Color(0xFF2C3E50),
      ),
      
      // Global font family
      textTheme: GoogleFonts.poppinsTextTheme(),
      
      // AppBar styling
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF4A6FA5),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      
      // Elevated button styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A6FA5),
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // Card styling
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
      ),
      
      // Input field styling
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A6FA5), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
}
