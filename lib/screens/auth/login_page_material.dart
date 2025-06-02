import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
// import 'package:cloudkeja/helpers/constants.dart'; // kPrimaryColor, textGrey etc. are replaced by theme
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/screens/auth/register_page.dart';
import 'package:cloudkeja/screens/auth/widgets/custom_checkbox.dart';
import 'package:cloudkeja/screens/auth/widgets/primary_button.dart';
import 'package:cloudkeja/widgets/initial_loading.dart';
import 'package:cloudkeja/screens/auth/forgot_password_page.dart'; // Import ForgotPasswordPage router

// import 'theme.dart'; // Old theme file, colors and styles will come from AppTheme

class LoginPageMaterial extends StatefulWidget { // Renamed class
  const LoginPageMaterial({Key? key}) : super(key: key); // Renamed constructor

  @override
  _LoginPageMaterialState createState() => _LoginPageMaterialState(); // Renamed state class
}

class _LoginPageMaterialState extends State<LoginPageMaterial> { // Renamed state class
  bool _passwordVisible = false;
  bool _rememberMe = false; // State for the checkbox

  String? _email;
  String? _password;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // Added for loading state
  String? _errorMessage; // Added for inline error messages

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background, // Use theme background color
      appBar: AppBar( // Added AppBar for consistency
        title: const Text('Log In'),
        elevation: 0, // Optional: for a flatter look matching Cupertino
        backgroundColor: colorScheme.background, // Match background
        foregroundColor: colorScheme.onBackground, // Ensure text is visible
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0), // Consistent horizontal padding
          child: Form(
            key: _formKey,
            child: ListView( // Using ListView for scrollability on smaller screens
              children: [
                const SizedBox(height: 48), // Adjusted top spacing after AppBar addition

                // Email TextFormField
                TextFormField(
                  onChanged: (val) => _email = val,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Please enter an email';
                    if (!val.contains('@') || !val.contains('.')) return 'Please enter a valid email';
                    return null;
                  },
                  decoration: const InputDecoration( // Will use global InputDecorationTheme
                    hintText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24), // Standard spacing

                // Password TextFormField
                TextFormField(
                  obscureText: !_passwordVisible,
                  onChanged: (val) => _password = val,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Please enter a password';
                    if (val.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                  decoration: InputDecoration( // Will use global InputDecorationTheme
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Remember Me & Forgot Password Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CustomCheckbox( // Uses themed Checkbox internally
                          initialValue: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        Text('Remember me', style: textTheme.bodyMedium),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => const ForgotPasswordPage()); // Navigate to ForgotPasswordPage router
                      },
                      child: Text(
                        'Forgot password?',
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16), // Reduced space a bit

                // Error Message Display
                if (_errorMessage != null && _errorMessage!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0), // Spacing before button
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
                    ),
                  ),
                
                // Login Button
                CustomPrimaryButton( // Uses themed ElevatedButton internally
                  textValue: 'Login',
                  isLoading: _isLoading, // Pass loading state
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = null;
                      });
                      try {
                        await Provider.of<AuthProvider>(context, listen: false)
                            .logIn(_email!, _password!);
                        // Navigation is handled by StreamBuilder or will remain on this page if login fails
                        // Forcing Get.offAll might be too aggressive if login silently fails without exception
                        // Let auth provider state changes handle navigation.
                        // If successful, MyApp's StreamBuilder should navigate away.
                        // If an error occurs, it's caught below.
                      } catch (e) {
                        if (mounted) {
                           setState(() {
                            // Extract a user-friendly message if possible
                            _errorMessage = e.toString().replaceFirst('Exception: ', '').replaceFirst('HttpException: ', '');
                          });
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Registration Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onBackground.withOpacity(0.8)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => const RegisterPage()); // Navigate using Get
                      },
                      child: Text(
                        'Register',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40), // Bottom spacing
              ],
            ),
          ),
        ),
      ),
    );
  }
}
