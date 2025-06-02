import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For TextInputType and SnackBar (can be replaced with Cupertino alternatives later if needed)
import 'package:provider/provider.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/screens/auth/register_page.dart'; // For navigation to RegisterPage router
import 'package:cloudkeja/screens/auth/forgot_password_page.dart'; // Import ForgotPasswordPage router
import 'package:get/get.dart'; // For Get.to for navigation

class CupertinoLoginPage extends StatefulWidget {
  const CupertinoLoginPage({super.key});

  @override
  State<CupertinoLoginPage> createState() => _CupertinoLoginPageState();
}

class _CupertinoLoginPageState extends State<CupertinoLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _passwordVisible = false; // Added for password visibility

  Future<void> _handleLogin() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password.';
        _isLoading = false;
      });
      return;
    }

    try {
      await Provider.of<AuthProvider>(context, listen: false).logIn(email, password);
      // Navigation is handled by StreamBuilder in MyAppCupertino/MyAppMaterial
      // If successful, this widget might be disposed, so check mounted status.
      if (mounted) {
        // No explicit navigation needed here as StreamBuilder will react
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context); // For accessing Cupertino theme properties

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Log In'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          children: [
            // Optional: App Logo (Placeholder for now)
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 40.0),
            //   child: FlutterLogo(size: 80), // Replace with actual logo
            // ),

            CupertinoTextField(
              controller: _emailController,
              placeholder: 'Email Address',
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              prefix: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0), // Adjusted padding
                child: Icon(CupertinoIcons.mail, size: 24), // Adjusted size
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0), // Standard padding
              decoration: BoxDecoration(
                border: Border.all(
                  color: CupertinoColors.inactiveGray.withOpacity(0.5), // Subtle border
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              onSubmitted: (_) => FocusScope.of(context).nextFocus(),
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: _passwordController,
              placeholder: 'Password',
              obscureText: !_passwordVisible, // Changed to use state variable
              textInputAction: TextInputAction.done,
              prefix: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                child: Icon(CupertinoIcons.lock_fill, size: 24),
              ),
              suffix: CupertinoButton( // Added suffix for visibility toggle
                padding: EdgeInsets.zero,
                child: Icon(
                  _passwordVisible ? CupertinoIcons.eye_slash_fill : CupertinoIcons.eye_fill,
                  size: 24,
                  color: CupertinoColors.inactiveGray, // Standard icon color
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              // This custom decoration is kept for app-wide visual consistency,
              // harmonizing with Material text fields or by team preference.
              decoration: BoxDecoration(
                border: Border.all(
                  color: CupertinoColors.inactiveGray.withOpacity(0.5), // Subtle border
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              onSubmitted: (_) => _handleLogin(),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CupertinoActivityIndicator(radius: 15))
            else
              CupertinoButton.filled(
                onPressed: _handleLogin,
                child: const Text('Log In'),
              ),
            if (_errorMessage != null && _errorMessage!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Center(
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    // Changed to a more appropriate text style for errors
                    style: theme.textTheme.caption1TextStyle.copyWith(color: CupertinoColors.destructiveRed, fontSize: 14),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            CupertinoButton(
              onPressed: () {
                Get.to(() => const ForgotPasswordPage()); // Navigate to ForgotPasswordPage router
              },
              child: const Text('Forgot Password?'),
            ),
            const SizedBox(height: 8),
            CupertinoButton(
              onPressed: () {
                // This will navigate to the RegisterPage router, which will then
                // decide whether to show CupertinoRegisterPage or MaterialRegisterPage.
                Get.to(() => const RegisterPage());
              },
              child: const Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
