// ================================================================
// GROUP S - Student Assistant Application
// Members: Lebohang Molise (224078106), Relebohile Thito (221027701), Tshepo Masimong (223081118)
// ================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// SplashView - Initial loading screen displayed while authentication is verified
/// Shows app branding with animated gradient background and loading indicator
/// Serves as the entry point before redirecting to Login or Dashboard
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Gradient background from primary blue to lighter blue
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [
              Color(0xFF4A6FA5), // Primary brand color
              Color(0xFF6B9AC4), // Secondary lighter blue
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogo(),
              const SizedBox(height: 32),
              _buildTitle(),
              const SizedBox(height: 8),
              _buildSubtitle(),
              const SizedBox(height: 48),
              _buildLoadingIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // UI COMPONENT BUILDERS
  // ================================================================

  /// App logo icon with semi-transparent circular background
  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2), // Translucent white circle
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.school, // School/education icon representing students
        size: 60,
        color: Colors.white,
      ),
    );
  }

  /// Main app title text
  Widget _buildTitle() {
    return Text(
      'Student Assistant',
      style: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  /// App subtitle text
  Widget _buildSubtitle() {
    return Text(
      'Application Portal',
      style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
    );
  }

  /// Loading indicator to show authentication in progress
  Widget _buildLoadingIndicator() {
    return const CircularProgressIndicator(color: Colors.white);
  }
}

