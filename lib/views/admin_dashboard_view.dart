// ================================================================
// GROUP S - Student Assistant Application
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

  // ================================================================
  // UI BUILD METHODS
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final appVM = Provider.of<ApplicationViewModel>(context);
    final filteredApps = _getFilteredApplications(appVM.applications);

    // Calculate statistics for dashboard cards
    final pending = appVM.applications
        .where((a) => a.status == 'pending')
        .length;
    final approved = appVM.applications
        .where((a) => a.status == 'approved')
        .length;
    final rejected = appVM.applications
        .where((a) => a.status == 'rejected')
        .length;
    final total = appVM.applications.length;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2C3E50), // Dark header color
              Colors.grey[50]!, // Light background
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildStatsRow(pending, approved, rejected, total),
              _buildSearchBar(),
              _buildFilterChips(),
              _buildResultSummary(appVM, filteredApps),
              const SizedBox(height: 8),
              _buildApplicationsList(filteredApps, appVM),
              _buildConfettiWidget(),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // HEADER SECTION
  // ================================================================

  /// Admin header with logo, title, refresh, and logout buttons
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Color(0xFF2C3E50),
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Dashboard',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Manage Applications',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadApplications,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final authVM = context.read<AuthViewModel>();
              await authVM.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, RouteManager.splash);
              }
            },
          ),
        ],
      ),
    );
  }

  // ================================================================
  // STATISTICS CARDS
  // ================================================================

  /// Row of statistics cards showing application counts by status
  Widget _buildStatsRow(int pending, int approved, int rejected, int total) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatCard('Total', total.toString(), Colors.blue),
          _buildStatCard('Pending', pending.toString(), Colors.orange),
          _buildStatCard('Approved', approved.toString(), Colors.green),
          _buildStatCard('Rejected', rejected.toString(), Colors.red),
        ],
      ),
    );
  }

  /// Individual statistics card widget
  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // SEARCH AND FILTERS
  // ================================================================

  /// Search bar for filtering applications by name or student number
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by name or student number...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  /// Status filter chips (All, Pending, Approved, Rejected)
  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('All', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('Pending', 'pending'),
          const SizedBox(width: 8),
          _buildFilterChip('Approved', 'approved'),
          const SizedBox(width: 8),
          _buildFilterChip('Rejected', 'rejected'),
        ],
      ),
    );
  }

  /// Individual filter chip widget
  Widget _buildFilterChip(String label, String filterValue) {
    return Expanded(
      child: FilterChip(
        label: Text(label),
        selected: _currentFilter == filterValue,
        onSelected: (selected) {
          setState(() {
            _currentFilter = filterValue;
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: const Color(0xFF4A6FA5).withValues(alpha: 0.2),
        checkmarkColor: const Color(0xFF4A6FA5),
      ),
    );
  }

  /// Summary text showing total and filtered counts
  Widget _buildResultSummary(
    ApplicationViewModel appVM,
    List<ApplicationModel> filteredApps,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total: ${appVM.applications.length}',
            style: GoogleFonts.poppins(),
          ),
          Text('Showing: ${filteredApps.length}', style: GoogleFonts.poppins()),
        ],
      ),
    );
  }

  // ================================================================
  // APPLICATIONS LIST
  // ================================================================

  /// Main scrollable list of filtered applications
  Widget _buildApplicationsList(
    List<ApplicationModel> filteredApps,
    ApplicationViewModel appVM,
  ) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: _loadApplications,
        child: Consumer<ApplicationViewModel>(
          builder: (context, vm, child) {
            // Loading state
            if (vm.isLoading && vm.applications.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // Error state
            if (vm.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${vm.errorMessage}',
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadApplications,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Empty state
            if (filteredApps.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'No matching applications'
                          : 'No applications found',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Application list with animated cards
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredApps.length,
              itemBuilder: (context, index) {
                final application = filteredApps[index];
                return _buildAnimatedApplicationCard(application, vm, index);
              },
            );
          },
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
      duration: Duration(milliseconds: 300 + (index * 50)),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: _buildApplicationCard(application, vm),
    );
  }

  /// Expandable application card showing all details and admin actions
  Widget _buildApplicationCard(
    ApplicationModel application,
    ApplicationViewModel vm,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              application.studentName,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            Text(
              application.studentNumber,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            _buildStatusBadge(application.status),
            const SizedBox(width: 8),
            Text(
              _formatDate(application.createdAt),
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF4A6FA5).withValues(alpha: 0.1),
          child: Text(
            application.studentName.isNotEmpty
                ? application.studentName[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: Color(0xFF4A6FA5),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  'Year of Study',
                  'Year ${application.yearOfStudy}',
                ),
                _buildDetailRow(
                  'Module 1',
                  '${application.module1Name} (${application.module1Level})',
                ),
                if (application.module2Name != null)
                  _buildDetailRow(
                    'Module 2',
                    '${application.module2Name} (${application.module2Level})',
                  ),
                _buildDetailRow(
                  'Eligible',
                  application.eligible ? 'Yes' : 'No',
                ),

                const SizedBox(height: 12),
                const Text('Document', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                _buildDocumentButton(application),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                if (application.status == 'pending') ...[
                  _buildAdminActions(application, vm),
                ],

                if (application.status != 'pending' &&
                    application.adminNotes != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow('Admin Notes', application.adminNotes!),
                ],

                const SizedBox(height: 16),
                _buildDeleteButton(application, vm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // UI COMPONENT BUILDERS
  // ================================================================

  /// Status badge with colored dot and text
  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Document view button that opens in new tab
  Widget _buildDocumentButton(ApplicationModel application) {
    if (application.documentUrl != null &&
        application.documentUrl!.isNotEmpty) {
      return ElevatedButton.icon(
        onPressed: () {
          html.window.open(application.documentUrl!, '_blank');
        },
        icon: const Icon(Icons.insert_drive_file, size: 18),
        label: const Text('View Document'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A6FA5),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      );
    } else {
      return const Text(
        'No document uploaded',
        style: TextStyle(color: Colors.grey),
      );
    }
  }

  /// Admin approve/reject buttons for pending applications
  Widget _buildAdminActions(
    ApplicationModel application,
    ApplicationViewModel vm,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Admin Actions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () =>
                    _showApprovalDialog(application.id!, 'approved', vm),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Approve'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () =>
                    _showApprovalDialog(application.id!, 'rejected', vm),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reject'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Delete application button with confirmation dialog
  Widget _buildDeleteButton(
    ApplicationModel application,
    ApplicationViewModel vm,
  ) {
    return TextButton.icon(
      onPressed: () => _deleteApplication(application.id!, vm),
      icon: const Icon(Icons.delete, color: Colors.red),
      label: const Text(
        'Delete Application',
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  /// Detail row with label and value
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  /// Confetti animation widget that triggers on successful approval
  Widget _buildConfettiWidget() {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        colors: const [Colors.green, Colors.blue, Colors.orange, Colors.red],
      ),
    );
  }

  // ================================================================
  // HELPER METHODS
  // ================================================================

  /// Returns color based on application status
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

  /// Shows approval/rejection dialog with optional notes
  Future<void> _showApprovalDialog(
    String appId,
    String newStatus,
    ApplicationViewModel vm,
  ) async {
    final notesController = TextEditingController();
    final isApproving = newStatus == 'approved';

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isApproving ? 'Approve Application' : 'Reject Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isApproving
                  ? 'Add any approval notes (optional):'
                  : 'Reason for rejection:',
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                hintText: isApproving
                    ? 'Approval notes...'
                    : 'Rejection reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Require reason for rejection
              if (!isApproving && notesController.text.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason for rejection'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext);
              final success = await vm.updateApplicationStatus(
                appId,
                newStatus,
                notes: notesController.text.isNotEmpty
                    ? notesController.text
                    : null,
              );

              if (mounted) {
                if (success) {
                  if (isApproving)
                    _confettiController.play(); // Celebrate approvals!
                  await _loadApplications();
                  setState(() {});
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Application ${isApproving ? 'approved' : 'rejected'}'
                          : 'Error: ${vm.errorMessage}',
                    ),
                    backgroundColor: success
                        ? (isApproving ? Colors.green : Colors.orange)
                        : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApproving ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(isApproving ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }

  /// Shows delete confirmation dialog and deletes application if confirmed
  Future<void> _deleteApplication(String appId, ApplicationViewModel vm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Application'),
        content: const Text(
          'Are you sure you want to delete this application?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await vm.deleteApplication(appId);
      if (mounted) {
        if (success) {
          await _loadApplications();
          setState(() {});
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Application deleted' : 'Error: ${vm.errorMessage}',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  /// Formats date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
