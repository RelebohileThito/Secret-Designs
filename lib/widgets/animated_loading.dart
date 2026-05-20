// ================================================================
// Secret Design - Student Assistant Application
// Members: Lebohang Molise (224078106), Relebohile Thito (221027701), Tshepo Masimong (223081118)
// ================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AnimatedLoading - Reusable loading indicator widget
/// Displays a centered circular progress indicator with an optional message
/// Used throughout the app for async operations (loading, uploading, etc.)
class AnimatedLoading extends StatelessWidget {
  // ================================================================
  // PROPERTIES
  // ================================================================

  final String? message; // Optional loading message to display below spinner

  const AnimatedLoading({super.key, this.message});

  // ================================================================
  // UI BUILD METHOD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular progress indicator with brand color
          const SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xFF4A6FA5), // Primary brand color
            ),
          ),
          const SizedBox(height: 20),

          // Optional loading message
          if (message != null)
            Text(
              message!,
              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
            ),
        ],
      ),
    );
  }
}
