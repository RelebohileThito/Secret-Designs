// ================================================================
// Secret Design - Student Assistant Application
// Members: Lebohang Molise (224078106), Relebohile Thito (221027701), Tshepo Masimong (223081118)
// ================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/application_model.dart';

/// ApplicationCard - Reusable widget for displaying application summary
/// Shows student name, number, module info, status badge, and submission date
/// Used in both student home and admin dashboard lists
class ApplicationCard extends StatelessWidget {
  // ================================================================
  // PROPERTIES
  // ================================================================

  final ApplicationModel application; // Application data to display
  final VoidCallback onTap; // Callback when card is tapped

  const ApplicationCard({
    super.key,
    required this.application,
    required this.onTap,
  });

  // ================================================================
  // HELPER METHODS
  // ================================================================

  /// Returns color based on application status
  /// - Approved: Green
  /// - Rejected: Red
  /// - Pending: Orange
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  /// Formats date for display (day/month/year)
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // ================================================================
  // UI BUILD METHOD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                _getStatusColor(application.status).withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderRow(),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              _buildModuleRow(),
              const SizedBox(height: 8),
              _buildDateRow(),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // UI COMPONENT BUILDERS
  // ================================================================

  /// Header row with student avatar, name, number, and status badge
  Widget _buildHeaderRow() {
    return Row(
      children: [
        // Student avatar icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF4A6FA5).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.person_outline,
            size: 20,
            color: const Color(0xFF4A6FA5),
          ),
        ),
        const SizedBox(width: 12),

        // Student name and number
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                application.studentName,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              Text(
                application.studentNumber,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // Status badge with colored dot and text
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(application.status).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getStatusColor(application.status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                application.status.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(application.status),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Module information row (shows up to 2 modules)
  Widget _buildModuleRow() {
    return Row(
      children: [
        // Module 1 (always shown)
        Expanded(
          child: Row(
            children: [
              Icon(Icons.book_outlined, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  application.module1Name,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Module 2 (optional - only shown if exists)
        if (application.module2Name != null)
          Expanded(
            child: Row(
              children: [
                Icon(Icons.book_outlined, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    application.module2Name!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Date row showing submission date
  Widget _buildDateRow() {
    return Row(
      children: [
        Icon(Icons.calendar_today, size: 12, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(
          _formatDate(application.createdAt),
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500]),
        ),
      ],
    );
  }
}

