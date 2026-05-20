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

  // ================================================================
  // UI BUILD METHODS
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Assistant Application'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPersonalInfoSection(),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _buildModule1Section(),
              const SizedBox(height: 24),
              _buildModule2Section(),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _buildEligibilitySection(),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _buildDocumentSection(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // FORM SECTION BUILDERS
  // ================================================================

  /// Section 1: Personal Information (Name, Student Number, Year of Study)
  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Full Name Field
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Student Number Field
        TextFormField(
          controller: _studentNumberController,
          decoration: const InputDecoration(
            labelText: 'Student Number',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.numbers),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your student number';
            }
            if (value.length < 8) {
              return 'Enter a valid student number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Year of Study Dropdown
        DropdownButtonFormField<int>(
          value: _yearOfStudy,
          decoration: const InputDecoration(
            labelText: 'Year of Study',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.school),
          ),
          items: _years.map((year) {
            return DropdownMenuItem(value: year, child: Text('Year $year'));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _yearOfStudy = value!;
            });
          },
        ),
      ],
    );
  }

  /// Section 2: First Module (Required)
  Widget _buildModule1Section() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Module 1 (Required)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Module 1 Academic Level Dropdown
        DropdownButtonFormField<String>(
          value: _module1Level,
          decoration: const InputDecoration(
            labelText: 'Academic Level',
            border: OutlineInputBorder(),
          ),
          items: _levels.map((level) {
            return DropdownMenuItem(value: level, child: Text(level));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _module1Level = value!;
            });
          },
        ),
        const SizedBox(height: 16),

        // Module 1 Name/Code Field
        TextFormField(
          controller: _module1NameController,
          decoration: const InputDecoration(
            labelText: 'Module Name/Code',
            border: OutlineInputBorder(),
            hintText: 'e.g., TPG316C, SOD316C',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the module name';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Section 3: Second Module (Optional)
  /// Toggle checkbox determines if second module fields are shown
  Widget _buildModule2Section() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Checkbox to enable second module
        CheckboxListTile(
          title: const Text('Apply for a second module?'),
          value: _hasModule2,
          onChanged: (value) {
            setState(() {
              _hasModule2 = value!;
            });
          },
          activeColor: Colors.blue,
        ),

        // Conditional fields for second module
        if (_hasModule2) ...[
          const SizedBox(height: 8),

          // Module 2 Academic Level Dropdown
          DropdownButtonFormField<String>(
            value: _module2Level,
            decoration: const InputDecoration(
              labelText: 'Academic Level (Module 2)',
              border: OutlineInputBorder(),
            ),
            items: _levels.map((level) {
              return DropdownMenuItem(value: level, child: Text(level));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _module2Level = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          // Module 2 Name/Code Field
          TextFormField(
            controller: _module2NameController,
            decoration: const InputDecoration(
              labelText: 'Module Name/Code (Module 2)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ],
    );
  }

  /// Section 4: Eligibility Confirmation Checkbox
  Widget _buildEligibilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Eligibility Confirmation',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: const Text(
            'I confirm that I meet the minimum requirements for this position',
          ),
          value: _isEligible,
          onChanged: (value) {
            setState(() {
              _isEligible = value!;
            });
          },
          activeColor: Colors.blue,
        ),
      ],
    );
  }

  /// Section 5: Document Upload with visual feedback
  Widget _buildDocumentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Supporting Documentation',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Please upload a screenshot/image of your academic transcript or CV (JPEG, PNG only)',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),

        // Document upload area
        GestureDetector(
          onTap: _pickDocument,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: _imageData != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.insert_drive_file,
                        size: 40,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _fileName ?? 'Document selected',
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tap to change',
                        style: TextStyle(fontSize: 10, color: Colors.blue),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Tap to select image'),
                      Text(
                        '(JPEG, PNG)',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  /// Submit Button with loading state
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isUploading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Submit Application'),
      ),
    );
  }
}
