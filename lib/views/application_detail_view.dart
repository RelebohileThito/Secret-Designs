// ================================================================
// GROUP S - Student Assistant Application
// Members: Lebohang Molise (224078106), Relebohile Thito (221027701), Tshepo Masimong (223081118)
// ================================================================

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../viewmodels/application_viewmodel.dart';
import '../models/application_model.dart';
import '../services/storage_service.dart';

/// ApplicationDetailView - Shows full details of a single application
/// Allows students to view, edit (if pending), and delete their applications
/// Supports document viewing and optional document replacement during editing
class ApplicationDetailView extends StatefulWidget {
  final String? applicationId; // ID of the application to display

  const ApplicationDetailView({super.key, this.applicationId});

  @override
  State<ApplicationDetailView> createState() => _ApplicationDetailViewState();
}

class _ApplicationDetailViewState extends State<ApplicationDetailView> {
  // ================================================================
  // STATE VARIABLES
  // ================================================================

  late ApplicationModel _application; // The application data being viewed
  bool _isLoading = true; // Loading indicator
  bool _isEditing = false; // Edit mode toggle

  // Form controllers for editing mode
  final _nameController = TextEditingController();
  final _studentNumberController = TextEditingController();
  final _module1NameController = TextEditingController();
  final _module2NameController = TextEditingController();
  String _module1Level = 'First Year';
  String _module2Level = 'First Year';
  int _yearOfStudy = 1;
  bool _hasModule2 = false;

  // Document upload state for editing
  Map<String, dynamic>? _newImageData; // New document data if replaced
  String? _newFileName; // Name of new document
  bool _isUploading = false; // Upload in progress flag

  // Static data sources
  final List<String> _levels = ['First Year', 'Second Year', 'Third Year'];
  final List<int> _years = [1, 2, 3];
  final StorageService _storageService = StorageService();

  // ================================================================
  // LIFECYCLE METHODS
  // ================================================================

  @override
  void initState() {
    super.initState();
    _loadApplication();
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _nameController.dispose();
    _studentNumberController.dispose();
    _module1NameController.dispose();
    _module2NameController.dispose();
    super.dispose();
  }

  // ================================================================
  // DATA LOADING
  // ================================================================

  /// Load application data from ViewModel using the provided ID
  Future<void> _loadApplication() async {
    final appVM = Provider.of<ApplicationViewModel>(context, listen: false);
    await appVM.fetchMyApplications();

    final app = appVM.getApplicationById(widget.applicationId!);
    if (app != null && mounted) {
      setState(() {
        _application = app;
        _isLoading = false;
        _hasModule2 = app.module2Name != null;

        // Populate form controllers
        _nameController.text = app.studentName;
        _studentNumberController.text = app.studentNumber;
        _module1NameController.text = app.module1Name;
        _module1Level = app.module1Level;
        _yearOfStudy = app.yearOfStudy;

        if (app.module2Name != null) {
          _module2NameController.text = app.module2Name!;
          _module2Level = app.module2Level ?? 'First Year';
        }
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // ================================================================
  // DOCUMENT HANDLING
  // ================================================================

  /// Open image picker to select a new document for replacement
  Future<void> _pickNewDocument() async {
    final result = await StorageService.pickImage(ImageSource.gallery);
    if (result != null && mounted) {
      setState(() {
        _newImageData = result;
        _newFileName = result['name'];
      });
    }
  }

  // ================================================================
  // CRUD OPERATIONS
  // ================================================================

  /// Save changes made during edit mode
  Future<void> _saveChanges() async {
    setState(() {
      _isUploading = true;
    });

    String? documentUrl = _application.documentUrl;

    // Upload new document if user selected one
    if (_newImageData != null) {
      final newUrl = await _storageService.uploadDocument(
        _application.id!,
        _newImageData!,
      );
      if (newUrl != null) {
        documentUrl = newUrl;
      }
    }

    // Create updated application object
    final updatedApplication = _application.copyWith(
      studentName: _nameController.text,
      studentNumber: _studentNumberController.text,
      yearOfStudy: _yearOfStudy,
      module1Level: _module1Level,
      module1Name: _module1NameController.text,
      module2Level: _hasModule2 ? _module2Level : null,
      module2Name: _hasModule2 ? _module2NameController.text : null,
      documentUrl: documentUrl,
      updatedAt: DateTime.now(),
    );

    final appVM = Provider.of<ApplicationViewModel>(context, listen: false);
    final success = await appVM.updateApplication(updatedApplication);

    if (mounted) {
      setState(() {
        _isUploading = false;
      });

      if (success) {
        setState(() {
          _application = updatedApplication;
          _isEditing = false;
          _newImageData = null;
          _newFileName = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${appVM.errorMessage}')));
      }
    }
  }

  /// Delete the current application after user confirmation
  Future<void> _deleteApplication() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Application'),
        content: const Text(
          'Are you sure you want to delete this application? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final appVM = Provider.of<ApplicationViewModel>(context, listen: false);
      final success = await appVM.deleteApplication(_application.id!);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Application deleted')));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${appVM.errorMessage}')),
          );
        }
      }
    }
  }

  // ================================================================
  // HELPER METHODS
  // ================================================================

  /// Returns color based on application status (pending/approved/rejected)
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

  /// Formats date and time for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // ================================================================
  // UI BUILD METHODS
  // ================================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusBadge(),
            const SizedBox(height: 24),
            _buildPersonalInfoSection(),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildModule1Section(),
            const SizedBox(height: 16),
            _buildModule2Section(),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildDocumentSection(),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildAdminNotesSection(),
            const SizedBox(height: 16),
            _buildTimestamps(),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // APP BAR
  // ================================================================

  /// Builds app bar with action buttons (edit, delete, save, cancel)
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Application Details'),
      centerTitle: true,
      actions: [
        if (_application.status == 'pending' && !_isEditing)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => setState(() => _isEditing = true),
          ),
        if (_application.status == 'pending' && !_isEditing)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteApplication,
          ),
        if (_isEditing)
          IconButton(
            icon: _isUploading
                ? const SizedBox.shrink()
                : const Icon(Icons.save),
            onPressed: _isUploading ? null : _saveChanges,
          ),
        if (_isEditing)
          IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () {
              setState(() {
                _isEditing = false;
                _newImageData = null;
                _newFileName = null;
              });
              _loadApplication(); // Reload original data
            },
          ),
      ],
    );
  }

  // ================================================================
  // STATUS BADGE
  // ================================================================

  /// Displays application status in a colored badge
  Widget _buildStatusBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: _getStatusColor(_application.status).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          _application.status.toUpperCase(),
          style: TextStyle(
            color: _getStatusColor(_application.status),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ================================================================
  // INFORMATION SECTIONS
  // ================================================================

  /// Personal information section (name, student number, year of study)
  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildTextRow(
          'Full Name',
          _application.studentName,
          _isEditing ? _nameController : null,
        ),
        _buildTextRow(
          'Student Number',
          _application.studentNumber,
          _isEditing ? _studentNumberController : null,
        ),
        _buildDropdownRow(
          'Year of Study',
          _yearOfStudy.toString(),
          _isEditing,
          _years.map((y) => y.toString()).toList(),
          (value) => setState(() => _yearOfStudy = int.parse(value!)),
        ),
      ],
    );
  }

  /// Module 1 section (required module)
  Widget _buildModule1Section() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Module 1 (Required)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildDropdownRow(
          'Academic Level',
          _module1Level,
          _isEditing,
          _levels,
          (value) => setState(() => _module1Level = value!),
        ),
        _buildTextRow(
          'Module Name',
          _application.module1Name,
          _isEditing ? _module1NameController : null,
        ),
      ],
    );
  }

  /// Module 2 section (optional module, only shown if exists or in edit mode)
  Widget _buildModule2Section() {
    if (_application.module2Name == null && !_isEditing) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        if (!_isEditing)
          const Text(
            'Module 2 (Optional)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        if (_isEditing)
          CheckboxListTile(
            title: const Text('Apply for a second module?'),
            value: _hasModule2,
            onChanged: (value) => setState(() => _hasModule2 = value!),
            activeColor: Colors.blue,
          ),
        const SizedBox(height: 12),
        if (_hasModule2 ||
            (!_isEditing && _application.module2Name != null)) ...[
          _buildDropdownRow(
            'Academic Level (Module 2)',
            _isEditing
                ? _module2Level
                : (_application.module2Level ?? 'First Year'),
            _isEditing,
            _levels,
            (value) => setState(() => _module2Level = value!),
          ),
          _buildTextRow(
            'Module Name (Module 2)',
            _isEditing
                ? _module2NameController.text
                : (_application.module2Name ?? ''),
            _isEditing ? _module2NameController : null,
          ),
        ],
      ],
    );
  }

  /// Document section with view button (or upload UI in edit mode)
  Widget _buildDocumentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Supporting Document',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        if (_isEditing) ...[
          // Current document status indicator
          if (_application.documentUrl != null && _newImageData == null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 12),
                  Expanded(child: Text('Current document will be kept')),
                ],
              ),
            ),

          // New document preview
          if (_newImageData != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(child: Text('New document: $_newFileName')),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Document upload button
          GestureDetector(
            onTap: _pickNewDocument,
            child: Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.blue[50],
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_file, size: 30, color: Colors.blue),
                    SizedBox(height: 4),
                    Text('Tap to upload new document'),
                    Text(
                      '(Optional - leave empty to keep current)',
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ] else ...[
          // View mode - show document button if exists
          if (_application.documentUrl != null &&
              _application.documentUrl!.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () {
                html.window.open(_application.documentUrl!, '_blank');
              },
              icon: const Icon(Icons.insert_drive_file),
              label: const Text('View Document'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            )
          else
            const Text(
              'No document uploaded',
              style: TextStyle(color: Colors.grey),
            ),
        ],
      ],
    );
  }

  /// Admin notes section (only shown if admin has added comments)
  Widget _buildAdminNotesSection() {
    if (_application.adminNotes == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Admin Comments',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(_application.adminNotes!),
        ),
      ],
    );
  }

  /// Timestamps for created and last updated dates
  Widget _buildTimestamps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Submitted: ${_formatDate(_application.createdAt)}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        if (_application.updatedAt != _application.createdAt)
          Text(
            'Last Updated: ${_formatDate(_application.updatedAt)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
      ],
    );
  }

  // ================================================================
  // FORM FIELD BUILDERS
  // ================================================================

  /// Builds a row with label and either text display or editable text field
  Widget _buildTextRow(
    String label,
    String value, [
    TextEditingController? controller,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: controller != null
                ? TextFormField(
                    controller: controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  )
                : Text(value),
          ),
        ],
      ),
    );
  }

  /// Builds a row with label and either dropdown selector or text display
  Widget _buildDropdownRow(
    String label,
    String currentValue,
    bool isEditing,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: isEditing
                ? DropdownButtonFormField<String>(
                    value: currentValue,
                    items: items.map((item) {
                      return DropdownMenuItem(value: item, child: Text(item));
                    }).toList(),
                    onChanged: onChanged,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                  )
                : Text(currentValue),
          ),
        ],
      ),
    );
  }
}
