// ================================================================
// Secret Design - Student Assistant Application
// Members: Lebohang Molise (224078106), Relebohile Thito (221027701), Tshepo Masimong (223081118)
// ================================================================

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import '../viewmodels/application_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../models/application_model.dart';
import '../routes/route_manager.dart';

/// AdminDashboardView - Administrative interface for managing applications
/// Allows admins to view, filter, search, approve, reject, and delete all applications
/// Features statistics cards, search bar, status filters, and celebratory confetti on approvals
class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  // ================================================================
  // STATE VARIABLES
  // ================================================================

  String _currentFilter =
      'all'; // Active status filter (all/pending/approved/rejected)
  String _searchQuery = ''; // Search query for filtering by name/number
  late ConfettiController _confettiController; // Controls celebration animation

  // ================================================================
  // LIFECYCLE METHODS
  // ================================================================

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    // Load applications after first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadApplications();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose(); // Clean up animation controller
    super.dispose();
  }

  // ================================================================
  // DATA LOADING
  // ================================================================

  /// Fetch all applications from Supabase and update UI
  Future<void> _loadApplications() async {
    final appVM = Provider.of<ApplicationViewModel>(context, listen: false);
    await appVM.fetchAllApplications();
    if (mounted) {
      setState(() {});
    }
  }

  // ================================================================
  // FILTERING LOGIC
  // ================================================================

  /// Apply status filter and search query to application list
  List<ApplicationModel> _getFilteredApplications(
    List<ApplicationModel> applications,
  ) {
    List<ApplicationModel> result = applications;

    // Apply status filter
    if (_currentFilter != 'all') {
      result = result.where((app) => app.status == _currentFilter).toList();
    }

    // Apply search filter (case-insensitive)
    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
            (app) =>
                app.studentName.toLowerCase().contains(_searchQuery) ||
                app.studentNumber.toLowerCase().contains(_searchQuery),
          )
          .toList();
    }

    return result;
  }




