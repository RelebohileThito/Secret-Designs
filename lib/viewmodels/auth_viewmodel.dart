// ================================================================
// GROUP S - Student Assistant Application
// Members: Lebohang Molise (224078106), Relebohile Thito (221027701), Tshepo Masimong (223081118)
// ================================================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// AuthViewModel - Manages authentication state and user operations
/// Follows MVVM pattern as the ViewModel layer for authentication
/// Handles sign up, sign in, sign out, and role verification
class AuthViewModel extends ChangeNotifier {
  // ================================================================
  // PRIVATE PROPERTIES
  // ================================================================

  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = false; // Tracks async operation status
  String? _errorMessage; // Stores error messages for UI display

  // ================================================================
  // PUBLIC GETTERS - Expose auth state to Views
  // ================================================================

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Returns true if user has an active session
  bool get isLoggedIn => _supabase.auth.currentSession != null;

  /// Email of currently authenticated user
  String? get currentUserEmail => _supabase.auth.currentUser?.email;

  /// Unique ID of currently authenticated user from Supabase Auth
  String? get currentUserId => _supabase.auth.currentUser?.id;

  // ================================================================
  // SIGN UP - Create new user account
  // Uses Supabase Auth with email/password
  // Email confirmation is disabled for development
  // ================================================================

  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        return true;
      } else {
        _errorMessage = 'Sign up failed. Please try again.';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================================================================
  // SIGN IN - Authenticate existing user
  // Validates credentials with Supabase Auth
  // Returns true if authentication successful
  // ================================================================

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response.user != null;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================================================================
  // ADMIN VERIFICATION - Check if current user has admin privileges
  // Queries admin_users table for user_id
  // Used to determine which dashboard to show
  // ================================================================

  Future<bool> isAdmin() async {
    if (currentUserId == null) return false;

    try {
      final response = await _supabase
          .from('admin_users')
          .select()
          .eq('user_id', currentUserId!);
      return response.isNotEmpty;
    } catch (e) {
      debugPrint('Admin check error: $e');
      return false;
    }
  }

  // ================================================================
  // SIGN OUT - End user session
  // Clears local auth state and navigates to login
  // ================================================================

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    notifyListeners();
  }
}
