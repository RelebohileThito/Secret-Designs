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

   // ================================================================
  // UI BUILD METHOD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final appVM = Provider.of<ApplicationViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: Container(
        // Gradient background from primary blue to light grey
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF4A6FA5), // Primary brand color
              Colors.grey[50]!, // Light grey at bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(authVM),
              _buildStatsCard(appVM),
              _buildApplicationsList(appVM),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildGradientFAB(appVM),
    );
  }

  // ================================================================
  // HEADER SECTION
  // ================================================================

  /// Custom header with logo, title, user email, and logout button
  Widget _buildHeader(AuthViewModel authVM) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Logo icon container
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school, color: Color(0xFF4A6FA5), size: 28),
          ),
          const SizedBox(width: 12),
          // Title and user email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Assistant',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  authVM.currentUserEmail ?? 'Applications Portal',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await authVM.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, RouteManager.splash);
              }
            },
          ),
        ],
      ),
    );
  }

  // ================================================================
  // STATISTICS CARD
  // ================================================================

  /// Statistics card showing total applications, pending, and approved counts
  Widget _buildStatsCard(ApplicationViewModel appVM) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        builder: (context, value, child) {
          return Opacity(opacity: value, child: child);
        },
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  const Color(0xFF4A6FA5).withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  Icons.description_outlined,
                  appVM.applications.length.toString(),
                  'Applications',
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                _buildStatItem(
                  Icons.pending_actions,
                  appVM.applications
                      .where((a) => a.status == 'pending')
                      .length
                      .toString(),
                  'Pending',
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                _buildStatItem(
                  Icons.check_circle_outline,
                  appVM.applications
                      .where((a) => a.status == 'approved')
                      .length
                      .toString(),
                  'Approved',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Individual statistics item with icon, value, and label
  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF4A6FA5), size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // ================================================================
  // APPLICATIONS LIST SECTION
  // ================================================================

  /// Main scrollable list of student's applications with pull-to-refresh
  Widget _buildApplicationsList(ApplicationViewModel appVM) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.lightImpact(); // Haptic feedback on refresh
          await appVM.fetchMyApplications();
        },
        child: Consumer<ApplicationViewModel>(
          builder: (context, vm, child) {
            // Loading state
            if (vm.isLoading && vm.applications.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // Error state
            if (vm.errorMessage != null) {
              return _buildErrorState(vm);
            }

            // Empty state
            if (vm.applications.isEmpty) {
              return _buildEmptyState();
            }

            // List with animated cards
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: vm.applications.length,
              itemBuilder: (context, index) {
                final application = vm.applications[index];
                return _buildAnimatedApplicationCard(application, vm, index);
              },
            );
          },
        ),
      ),
    );
  }

  /// Error state UI with retry button
  Widget _buildErrorState(ApplicationViewModel vm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Error: ${vm.errorMessage}', style: GoogleFonts.poppins()),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => vm.fetchMyApplications(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Empty state UI when no applications exist
  Widget _buildEmptyState() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(scale: value, child: child),
        );
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Applications Yet',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to submit your first application',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, RouteManager.applicationForm),
              icon: const Icon(Icons.add),
              label: const Text('Submit Application'),
            ),
          ],
        ),
      ),
    );
  }

  /// Animated application card with fade-in and slide-up effect
  Widget _buildAnimatedApplicationCard(
    ApplicationModel application,
    ApplicationViewModel vm,
    int index,
  ) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(
        milliseconds: 200 + (index * 50),
      ), // Staggered animation
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: ApplicationCard(
        application: application,
        onTap: () {
          Navigator.pushNamed(
            context,
            RouteManager.applicationDetail,
            arguments: application.id,
          ).then((_) => vm.fetchMyApplications()); // Refresh on return
        },
      ),
    );
  }

  // ================================================================
  // FLOATING ACTION BUTTON
  // ================================================================

  /// Gradient Floating Action Button for submitting new applications
  /// Checks for existing application before allowing new submission
  Widget _buildGradientFAB(ApplicationViewModel appVM) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A6FA5), Color(0xFF6B9AC4)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A6FA5).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () async {
          // Enforce one application per student rule
          final hasExisting = await appVM.hasExistingApplication();
          if (hasExisting) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'You have already submitted an application. Only one allowed.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          } else {
            Navigator.pushNamed(
              context,
              RouteManager.applicationForm,
            ).then((_) => appVM.fetchMyApplications());
          }
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

