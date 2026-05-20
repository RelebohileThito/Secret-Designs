// ================================================================
// Secret Design - Student Assistant Application
// Members: Lebohang Molise (224078106), Relebohile Thito (221027701), Tshepo Masimong (223081118)
// ================================================================

/// Model class representing a Student Assistant Application
/// Follows MVVM pattern - handles raw data structure and business logic
class ApplicationModel {
  // ================================================================
  // PROPERTIES - Application data fields
  // ================================================================
  
  final String? id;                    // Unique identifier from Supabase
  final String userId;                 // ID of the student who submitted
  final String studentName;            // Full name of the applicant
  final String studentNumber;          // Student ID number
  final int yearOfStudy;               // 1st, 2nd, or 3rd year
  final String module1Level;           // Academic level for first module
  final String module1Name;            // Name/code of first module
  final String? module2Level;          // Academic level for second module (optional)
  final String? module2Name;           // Name/code of second module (optional)
  final bool eligible;                 // Whether student meets requirements
  final String? documentUrl;           // Supabase Storage URL for uploaded document
  final String status;                 // pending, approved, or rejected
  final String? adminNotes;            // Comments from admin when approving/rejecting
  final DateTime createdAt;            // Timestamp when application was submitted
  final DateTime updatedAt;            // Timestamp when application was last modified

  // ================================================================
  // CONSTRUCTOR
  // ================================================================
  
  const ApplicationModel({
    this.id,
    required this.userId,
    required this.studentName,
    required this.studentNumber,
    required this.yearOfStudy,
    required this.module1Level,
    required this.module1Name,
    this.module2Level,
    this.module2Name,
    required this.eligible,
    this.documentUrl,
    required this.status,
    this.adminNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  // ================================================================
  // FACTORY METHOD - Convert JSON from Supabase to Model object
  // ================================================================
  
  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      studentName: json['student_name'] ?? '',
      studentNumber: json['student_number'] ?? '',
      yearOfStudy: json['year_of_study'] ?? 1,
      module1Level: json['module1_level'] ?? '',
      module1Name: json['module1_name'] ?? '',
      module2Level: json['module2_level'],
      module2Name: json['module2_name'],
      eligible: json['eligible'] ?? false,
      documentUrl: json['document_url'],
      status: json['status'] ?? 'pending',
      adminNotes: json['admin_notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // ================================================================
  // TO JSON - Convert Model object to JSON for Supabase storage
  // ================================================================
  
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'user_id': userId,
      'student_name': studentName,
      'student_number': studentNumber,
      'year_of_study': yearOfStudy,
      'module1_level': module1Level,
      'module1_name': module1Name,
      'eligible': eligible,
      'status': status,
      'updated_at': updatedAt.toIso8601String(),
    };
    
    // Add optional fields only if they contain values (prevents null errors)
    if (module2Level != null) data['module2_level'] = module2Level;
    if (module2Name != null) data['module2_name'] = module2Name;
    if (documentUrl != null) data['document_url'] = documentUrl;
    if (adminNotes != null) data['admin_notes'] = adminNotes;
    
    return data;
  }

  // ================================================================
  // COPY WITH - Creates modified copy while preserving immutability
  // Used when updating application data
  // ================================================================
  
  ApplicationModel copyWith({
    String? id,
    String? userId,
    String? studentName,
    String? studentNumber,
    int? yearOfStudy,
    String? module1Level,
    String? module1Name,
    String? module2Level,
    String? module2Name,
    bool? eligible,
    String? documentUrl,
    String? status,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      studentName: studentName ?? this.studentName,
      studentNumber: studentNumber ?? this.studentNumber,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      module1Level: module1Level ?? this.module1Level,
      module1Name: module1Name ?? this.module1Name,
      module2Level: module2Level ?? this.module2Level,
      module2Name: module2Name ?? this.module2Name,
      eligible: eligible ?? this.eligible,
      documentUrl: documentUrl ?? this.documentUrl,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
