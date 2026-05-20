// ================================================================
// Secret Design - Student Assistant Application
// Members: Lebohang Molise (224078106), Relebohile Thito (221027701), Tshepo Masimong (223081118)
// ================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../viewmodels/application_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../models/application_model.dart';
import '../routes/route_manager.dart';
import '../services/storage_service.dart';

/// ApplicationFormView - Multi-step form for submitting Student Assistant applications
/// Allows students to apply for up to 2 modules with supporting documentation
/// Features form validation, optional second module, and image/document upload
class ApplicationFormView extends StatefulWidget {
  const ApplicationFormView({super.key});

  @override
  State<ApplicationFormView> createState() => _ApplicationFormViewState();
}

class _ApplicationFormViewState extends State<ApplicationFormView> {
  // ================================================================
  // FORM STATE VARIABLES
  // ================================================================

  final _formKey =
      GlobalKey<FormState>(); // Unique form identifier for validation

  // Personal Information Fields
  final _nameController = TextEditingController();
  final _studentNumberController = TextEditingController();
  int _yearOfStudy = 1; // 1st, 2nd, or 3rd year

  // Module 1 (Required) Fields
  String _module1Level = 'First Year';
  final _module1NameController = TextEditingController();

  // Module 2 (Optional) Fields
  bool _hasModule2 = false; // Toggle for second module visibility
  String _module2Level = 'First Year';
  final _module2NameController = TextEditingController();

  // Eligibility & Documentation
  bool _isEligible = false; // Student confirms meeting requirements

  // Document Upload State
  Map<String, dynamic>? _imageData; // Stores image bytes and metadata
  bool _isUploading = false; // Upload in progress indicator
  String? _fileName; // Name of selected file

  // Static Data Sources for Dropdowns
  final List<String> _levels = ['First Year', 'Second Year', 'Third Year'];
  final List<int> _years = [1, 2, 3];
  final StorageService _storageService = StorageService();

  // ================================================================
  // LIFECYCLE METHODS
  // ================================================================

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
  // DOCUMENT HANDLING
  // ================================================================

  /// Opens device gallery to select a document/image for upload
  /// Updates UI with selected file information
  Future<void> _pickDocument() async {
    final result = await StorageService.pickImage(ImageSource.gallery);
    if (result != null && mounted) {
      setState(() {
        _imageData = result;
        _fileName = result['name'];
      });
    }
  }

  // ================================================================
  // FORM SUBMISSION
  // ================================================================

  /// Validates form, uploads document, and submits application to Supabase
  /// Handles loading states and navigation on success/failure
  Future<void> _submitForm() async {
    // Validate all form fields
    if (_formKey.currentState!.validate()) {
      // Check if document was uploaded
      if (_imageData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload supporting documentation'),
          ),
        );
        return;
      }

      setState(() {
        _isUploading = true;
      });

      // Get current authenticated user
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final userId = authVM.currentUserId;

      if (userId == null) return;

      // Step 1: Upload document to Supabase Storage
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final documentUrl = await _storageService.uploadDocument(
        tempId,
        _imageData!,
      );

      if (documentUrl == null) {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload document. Please try again.'),
            ),
          );
        }
        return;
      }

      // Step 2: Create application model with document URL
      final application = ApplicationModel(
        userId: userId,
        studentName: _nameController.text,
        studentNumber: _studentNumberController.text,
        yearOfStudy: _yearOfStudy,
        module1Level: _module1Level,
        module1Name: _module1NameController.text,
        module2Level: _hasModule2 ? _module2Level : null,
        module2Name: _hasModule2 ? _module2NameController.text : null,
        eligible: _isEligible,
        documentUrl: documentUrl,
        status: 'pending', // All new applications start as pending
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Step 3: Save application to Supabase database
      final appVM = Provider.of<ApplicationViewModel>(context, listen: false);
      final success = await appVM.submitApplication(application);

      if (mounted) {
        setState(() {
          _isUploading = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Application submitted successfully!'),
            ),
          );
          // Navigate back to student home on success
          Navigator.pushReplacementNamed(context, RouteManager.studentHome);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${appVM.errorMessage}')),
          );
        }
      }
    }
  }


