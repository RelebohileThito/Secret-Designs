// ================================================================
// GROUP S - Student Assistant Application
// Members: Lebohang Molise (224078106), Relebohile Thito (221027701), Tshepo Masimong (223081118)
// ================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../routes/route_manager.dart';

/// AuthWrapper - Authentication Router and Gatekeeper
/// Determines user authentication status and redirects to appropriate screen
/// Follows MVVM pattern as part of the View layer coordinating authentication flow
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // ================================================================
  // STATE VARIABLES
  // ================================================================

  bool _isChecking =
      true; // Shows loading indicator while verifying auth status

  // ================================================================
  // LIFECYCLE METHODS
  // ================================================================

  @override
  void initState() {
    super.initState();
    _checkAuth(); // Verify authentication when widget loads
  }

  // ================================================================
  // AUTHENTICATION LOGIC
  // ================================================================

  /// Checks user authentication status and redirects accordingly
  /// - Not logged in: Redirects to Login screen
  /// - Logged in as Admin: Redirects to Admin Dashboard
  /// - Logged in as Student: Redirects to Student Home
  Future<void> _checkAuth() async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);

    // Small delay ensures Supabase auth session is fully initialized
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    // Case 1: User not logged in
    if (!authVM.isLoggedIn) {
      Navigator.pushReplacementNamed(context, RouteManager.login);
    }
    // Case 2: User is logged in - determine role
    else {
      final isAdmin = await authVM.isAdmin();
      if (mounted) {
        if (isAdmin) {
          // Admin user goes to admin dashboard
          Navigator.pushReplacementNamed(context, RouteManager.adminDashboard);
        } else {
          // Regular student goes to student home
          Navigator.pushReplacementNamed(context, RouteManager.studentHome);
        }
      }
    }

    // Hide loading indicator after navigation
    setState(() {
      _isChecking = false;
    });
  }

  // ================================================================
  // UI BUILD METHOD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    // Show loading spinner while checking authentication status
    if (_isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Return empty widget after navigation (prevents flashing)
    return const SizedBox.shrink();
  }
}
