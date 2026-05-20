// ================================================================
// Secret Design - Student Assistant Application
// Members: Lebohang Molise (224078106), Relebohile Thito (221027701), Tshepo Masimong (223081118)
// ================================================================

import 'package:flutter/material.dart';
import '../views/auth_wrapper.dart';
import '../views/login_view.dart';
import '../views/student_home_view.dart';
import '../views/application_form_view.dart';
import '../views/application_detail_view.dart';
import '../views/admin_dashboard_view.dart';

/// RouteManager - Centralized navigation handler
/// Manages all app routes and screen navigation using named routes
/// Follows MVVM pattern as part of the View layer coordination
class RouteManager {
  // ================================================================
  // ROUTE NAMES - String constants for all screens in the app
  // ================================================================

  static const String splash = '/'; // Initial route - checks auth status
  static const String login = '/login'; // Login/Sign up screen
  static const String studentHome = '/student-home'; // Student dashboard
  static const String applicationForm =
      '/application-form'; // Submit new application
  static const String applicationDetail =
      '/application-detail'; // View/edit application
  static const String adminDashboard =
      '/admin-dashboard'; // Admin management panel

  // ================================================================
  // GENERATE ROUTE - Dynamic route builder
  // Creates appropriate MaterialPageRoute based on route name
  // Supports passing arguments to screens (e.g., application ID)
  // ================================================================

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const AuthWrapper());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginView());

      case studentHome:
        return MaterialPageRoute(builder: (_) => const StudentHomeView());

      case applicationForm:
        return MaterialPageRoute(builder: (_) => const ApplicationFormView());

      case applicationDetail:
        // Extract application ID passed as argument
        final applicationId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ApplicationDetailView(applicationId: applicationId),
        );

      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardView());

      default:
        // Handle undefined routes gracefully
        throw FormatException("Route not found: ${settings.name}");
    }
  }
}
