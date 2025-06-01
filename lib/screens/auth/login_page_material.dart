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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0), // Consistent horizontal padding
          child: Form(
            key: _formKey,
            child: ListView( // Using ListView for scrollability on smaller screens
              children: [
                const SizedBox(height: 40), // Top spacing
                // Page Title Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Login to your\naccount',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8), // Reduced space to accent
                    Image.asset( // This accent image might need to be theme-aware or replaced
                      'assets/images/accent.png',
                      width: 99,
                      height: 4,
                      // Consider applying colorScheme.primary if it's an SVG or can be tinted
                      // color: colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 48),

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
                const SizedBox(height: 32),

                // Login Button
                CustomPrimaryButton( // Uses themed ElevatedButton internally
                  textValue: 'Login',
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      // Perform login
                      try {
                        // Show loading indicator
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logging in...')),
                        );
                        await Provider.of<AuthProvider>(context, listen: false)
                            .logIn(_email!, _password!);
                        Get.offAll(() => const InitialLoadingScreen()); // Use offAll to clear auth stack
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString(), style: TextStyle(color: colorScheme.onError)),
                            backgroundColor: colorScheme.error,
                          ),
                        );
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
