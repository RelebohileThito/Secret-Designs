// ================================================================
// GROUP S - Student Assistant Application
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

  // ================================================================
  // UI COMPONENT BUILDERS
  // ================================================================

  /// Animated login/signup card with fade-in and scale animation
  Widget _buildAnimatedCard() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(scale: value, child: child),
        );
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIcon(),
                const SizedBox(height: 24),
                _buildTitle(),
                const SizedBox(height: 8),
                _buildSubtitle(),
                const SizedBox(height: 32),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                if (_isSignUp) ...[
                  const SizedBox(height: 16),
                  _buildConfirmPasswordField(),
                ],
                const SizedBox(height: 32),
                _buildSubmitButton(),
                const SizedBox(height: 16),
                _buildToggleModeButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Logo icon that changes based on mode (Sign Up vs Login)
  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A6FA5).withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _isSignUp ? Icons.person_add_alt_1 : Icons.school,
        size: 60,
        color: const Color(0xFF4A6FA5),
      ),
    );
  }

  /// Main title text ("Welcome Back" or "Create Account")
  Widget _buildTitle() {
    return Text(
      _isSignUp ? 'Create Account' : 'Welcome Back',
      style: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF2C3E50),
      ),
    );
  }

  /// Subtitle text ("Login to continue" or "Sign up to get started")
  Widget _buildSubtitle() {
    return Text(
      _isSignUp ? 'Sign up to get started' : 'Login to continue',
      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
    );
  }

  /// Email input field with validation
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.email_outlined),
        labelText: 'Email',
        hintText: 'your@email.com',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Enter your email';
        if (!value.contains('@')) return 'Enter valid email';
        return null;
      },
    );
  }

  /// Password input field with visibility toggle
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline),
        labelText: 'Password',
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Enter your password';
        if (value.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }

  /// Confirm password field (only shown in Sign Up mode)
  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline),
        labelText: 'Confirm Password',
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () => setState(
            () => _obscureConfirmPassword = !_obscureConfirmPassword,
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Confirm your password';
        return null;
      },
    );
  }

  /// Submit button (Login or Sign Up) with loading indicator
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : (_isSignUp ? _handleSignUp : _handleLogin),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                _isSignUp ? 'Sign Up' : 'Login',
                style: const TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  /// Toggle button to switch between Login and Sign Up modes
  Widget _buildToggleModeButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          _isSignUp = !_isSignUp;
          // Clear form fields when switching modes
          _emailController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
        });
      },
      child: Text(
        _isSignUp
            ? 'Already have an account? Login'
            : "Don't have an account? Sign Up",
        style: GoogleFonts.poppins(color: const Color(0xFF4A6FA5)),
      ),
    );
  }
}
