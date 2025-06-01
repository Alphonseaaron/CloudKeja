import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:get/get.dart'; // For Get.back() if needed, or direct Navigator.pop

class CupertinoForgotPasswordPage extends StatefulWidget {
  const CupertinoForgotPasswordPage({super.key});

  @override
  State<CupertinoForgotPasswordPage> createState() => _CupertinoForgotPasswordPageState();
}

class _CupertinoForgotPasswordPageState extends State<CupertinoForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _feedbackMessage;
  bool _isSuccess = false;

  Future<void> _handleSendResetLink() async {
    if (!mounted) return;
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _feedbackMessage = 'Please enter a valid email address.';
        _isSuccess = false;
        _isLoading = false; // Ensure loading is stopped
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _feedbackMessage = null;
      _isSuccess = false;
    });

    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .sendPasswordResetEmail(email);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
          _feedbackMessage = 'Password reset email sent! Please check your inbox (and spam folder).';
          _emailController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSuccess = false;
          _feedbackMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Reset Password'),
        previousPageTitle: 'Log In', // Provides context for the back button
      ),
      child: SafeArea(
        child: ListView( // Using ListView for content that might exceed screen height
          padding: const EdgeInsets.all(20.0),
          children: [
            const SizedBox(height: 20),
            Text(
              "Enter your email address below. If an account exists, we'll send you a link to reset your password.",
              style: theme.textTheme.textStyle.copyWith(color: CupertinoColors.secondaryLabel),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CupertinoTextField(
              controller: _emailController,
              placeholder: 'Email Address',
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              prefix: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                child: Icon(CupertinoIcons.mail, size: 24, color: CupertinoColors.placeholderText),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: CupertinoColors.inactiveGray.withOpacity(0.5),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              onSubmitted: (_) => _isLoading ? null : _handleSendResetLink(),
            ),
            const SizedBox(height: 32),
            if (_isLoading)
              const Center(child: CupertinoActivityIndicator(radius: 15))
            else
              CupertinoButton.filled(
                onPressed: _handleSendResetLink,
                child: const Text('Send Reset Link'),
              ),
            if (_feedbackMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  _feedbackMessage!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.tabLabelTextStyle.copyWith( // tabLabelTextStyle is small by default
                    fontSize: 14, // Explicitly set a slightly larger size for feedback
                    color: _isSuccess ? CupertinoColors.systemGreen : CupertinoColors.destructiveRed,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
