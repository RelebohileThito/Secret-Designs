// ================================================================
// Secret Design - Student Assistant Application
// Members: Lebohang Molise (224078106), Relebohile Thito (221027701), Tshepo Masimong (223081118)
// ================================================================

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

/// StorageService - Handles file storage operations with Supabase Storage
/// Manages image picking, uploading, and deleting of supporting documents
/// Following Unit 5 notes for Supabase Storage integration
class StorageService {
  
  // ================================================================
  // PRIVATE PROPERTIES
  // ================================================================
  
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _bucketName = 'application_documents';  // Supabase storage bucket name
  
  // ================================================================
  // PICK IMAGE - Select image from device gallery or camera
  // Supports both web and mobile platforms
  // Returns image bytes and metadata for Supabase upload
  // ================================================================
  
  static Future<Map<String, dynamic>?> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    
    try {
      // Launch device image picker with optimization settings
      final pickedFile = await picker.pickImage(
        source: source,           // Gallery or Camera
        maxWidth: 1024,           // Resize to reduce bandwidth
        maxHeight: 1024,          // Maintain aspect ratio
        imageQuality: 85,         // Compress to 85% quality
      );
      
      if (pickedFile != null) {
        // Read file as bytes (compatible with web and mobile)
        final bytes = await pickedFile.readAsBytes();
        return {
          'bytes': bytes,          // Raw image data for upload
          'name': pickedFile.name, // Original filename with extension
          'path': pickedFile.path, // Local file path reference
        };
      }
      return null;
    } catch (e) {
      debugPrint('Pick image error: $e');
      return null;
    }
  }
  
  // ================================================================
  // UPLOAD DOCUMENT - Store image in Supabase Storage bucket
  // Creates unique filename using timestamp to avoid collisions
  // Returns public URL for database storage
  // ================================================================
  
  Future<String?> uploadDocument(String applicationId, Map<String, dynamic> imageData) async {
    try {
      // Generate unique filename using timestamp
      final originalName = imageData['name'] as String;
      final extension = originalName.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
      final filePath = 'applications/$applicationId/$fileName';
      
      debugPrint('Uploading to bucket: $_bucketName');
      debugPrint('File path: $filePath');
      
      // Upload binary data to Supabase Storage
      await _supabase.storage.from(_bucketName).uploadBinary(
        filePath,
        imageData['bytes'] as Uint8List,
        fileOptions: const FileOptions(
          cacheControl: '3600',  // Cache for 1 hour
          upsert: true,          // Overwrite if exists
        ),
      );
      
      // Generate publicly accessible URL
      final publicUrl = _supabase.storage.from(_bucketName).getPublicUrl(filePath);
      debugPrint('Public URL: $publicUrl');
      
      return publicUrl;
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }
  
  // ================================================================
  // DELETE DOCUMENT - Remove file from Supabase Storage
  // Extracts file path from URL and deletes from bucket
  // Used when application is deleted or document is replaced
  // ================================================================
  
  Future<bool> deleteDocument(String imageUrl) async {
    try {
      // Parse URL to extract storage file path
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      // Remove bucket name prefix to get relative path
      final filePath = pathSegments.sublist(3).join('/');
      
      // Delete file from storage bucket
      await _supabase.storage.from(_bucketName).remove([filePath]);
      return true;
    } catch (e) {
      debugPrint('Delete error: $e');
      return false;
    }
  }
}
