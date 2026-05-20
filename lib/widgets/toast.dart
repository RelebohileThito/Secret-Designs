// ================================================================
// Secret Design - Student Assistant Application
// Members: Lebohang Molise (224078106), Relebohile Thito (221027701), Tshepo Masimong (223081118)
// ================================================================

import 'package:flutter/material.dart';

/// showToast - Displays a floating snackbar notification
/// Used for brief feedback messages after user actions (success, error, info)
/// Features colored backgrounds, icons, and rounded corners for better UX
///
/// @param context - BuildContext for accessing ScaffoldMessenger
/// @param message - The text message to display
/// @param isError - If true, shows red error style; if false, shows green success style
void showToast(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      // Row layout with icon and text
      content: Row(
        children: [
          // Success icon (check) or Error icon (warning)
          Icon(
            isError ? Icons.error_outline : Icons.check_circle,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      // Color coding: Red for errors, Green for success
      backgroundColor: isError ? Colors.red : Colors.green,
      // Floating behavior with rounded corners
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2), // Auto-dismiss after 2 seconds
    ),
  );
}
