// ================================================================
// Secret Design - Student Assistant Application
// Members: Lebohang Molise (224078106), Relebohile Thito (221027701), Tshepo Masimong (223081118)
// ================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../routes/route_manager.dart';

/// LoginView - Authentication screen for login and account creation
/// Provides both Login and Sign Up functionality with form validation
/// Features animated entrance, password visibility toggle, and mode switching
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // ================================================================
  // FORM STATE VARIABLES
  // ================================================================

  final _formKey = GlobalKey<FormState>(); // Form validation key
  final _emailController = TextEditingController(); // Email input field
  final _passwordController = TextEditingController(); // Password input field
  final _confirmPasswordController =
      TextEditingController(); // Confirm password (Sign Up only)

  bool _obscurePassword = true; // Hide/show password text
  bool _obscureConfirmPassword = true; // Hide/show confirm password text
  bool _isSignUp = false; // Toggle between Login and Sign Up modes
  bool _isLoading = false; // Loading state during async operations

  // ================================================================
  // LIFECYCLE METHODS
  // ================================================================

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ================================================================
  // AUTHENTICATION HANDLERS
  // ================================================================

  /// Handles user login with email and password
  /// Validates form, calls AuthViewModel.signIn(), and navigates on success
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final success = await authVM.signIn(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          // Navigate to auth wrapper which will redirect based on role
          Navigator.pushReplacementNamed(context, RouteManager.splash);
        } else {
          // Show error message on login failure
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authVM.errorMessage ?? 'Login failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Handles new user account creation
  /// Validates form, checks password match, creates account, then switches to login mode
  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      // Validate passwords match
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final success = await authVM.signUp(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          // Show success message and switch to login mode
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created! Please login.'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _isSignUp = false;
            _confirmPasswordController.clear();
          });
        } else {
          // Show error message on sign up failure
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authVM.errorMessage ?? 'Sign up failed'),
              backgroundColor: Colors.red,
            ),
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
      body: Container(
        // Gradient background from blue to light blue/white
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF4A6FA5), // Primary blue
              const Color(0xFF6B9AC4), // Lighter blue
              Colors.white.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildAnimatedCard(),
            ),
          ),
        ),
      ),
    );
  }


