// ================================================================
// Secret Design - Student Assistant Application
// Members: Lebohang Molise (224078106), Relebohile Thito (221027701), Tshepo Masimong (223081118)
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:secret_design/models/application_model.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/application_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../routes/route_manager.dart';
import '../widgets/application_card.dart';

/// StudentHomeView - Main dashboard for authenticated student users
/// Displays application statistics, list of submitted applications, and navigation to submit new applications
/// Features statistics cards, animated list items, pull-to-refresh, and gradient FAB
class StudentHomeView extends StatefulWidget {
  const StudentHomeView({super.key});

  @override
  State<StudentHomeView> createState() => _StudentHomeViewState();
}

class _StudentHomeViewState extends State<StudentHomeView> {
  // ================================================================
  // STATE VARIABLES
  // ================================================================

  bool _isInitialized = false; // Prevents multiple initialization calls

  // ================================================================
  // LIFECYCLE METHODS
  // ================================================================

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch applications once when dependencies are ready
    if (!_isInitialized) {
      _isInitialized = true;
      // Wait for auth to be ready before fetching
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchApplications();
      });
    }
  }

  // ================================================================
  // DATA LOADING
  // ================================================================

  /// Fetches applications for the currently authenticated student
  /// Waits for auth to be ready before making the request
  Future<void> _fetchApplications() async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final appVM = Provider.of<ApplicationViewModel>(context, listen: false);

    // Only fetch if user is authenticated
    if (authVM.currentUserId != null) {
      await appVM.fetchMyApplications();
      if (mounted) {
        setState(() {});
      }
    }
  }

 

