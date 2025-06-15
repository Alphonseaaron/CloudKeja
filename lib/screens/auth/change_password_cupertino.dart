import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For kPrimaryColor, consider moving to a shared theme const
import 'package:provider/provider.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/helpers/constants.dart'; // For kPrimaryColor

class ChangePasswordCupertino extends StatefulWidget {
  @override
  _ChangePasswordCupertinoState createState() => _ChangePasswordCupertinoState();
}

class _ChangePasswordCupertinoState extends State<ChangePasswordCupertino> {
  String? _newPassword;
  String? _currentPassword;
  String? _confirmNewPassword;
  bool _isLoading = false;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  // To manage focus
  final FocusNode _currentPasswordFocus = FocusNode();
  final FocusNode _newPasswordFocus = FocusNode();
  final FocusNode _confirmNewPasswordFocus = FocusNode();

  // Validation error messages
  String? _currentPasswordError;
  String? _newPasswordError;
  String? _confirmNewPasswordError;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    _currentPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    _confirmNewPasswordFocus.dispose();
    super.dispose();
  }

  void _validateCurrentPassword(String val) {
    setState(() {
      if (val.isEmpty) {
        _currentPasswordError = 'Please enter your current password';
      } else {
        _currentPasswordError = null;
      }
    });
  }

  void _validateNewPassword(String val) {
    setState(() {
      if (val.isEmpty) {
        _newPasswordError = 'Please enter your new password';
      } else if (val.length < 6) {
        _newPasswordError = 'Password should have at least 6 characters';
      } else {
        _newPasswordError = null;
      }
    });
  }

  void _validateConfirmNewPassword(String val) {
    setState(() {
      if (val.isEmpty) {
        _confirmNewPasswordError = 'Please confirm your password';
      } else if (val != _newPasswordController.text) {
        _confirmNewPasswordError = 'Passwords do not match';
      } else {
        _confirmNewPasswordError = null;
      }
    });
  }

  bool _validateForm() {
    _validateCurrentPassword(_currentPasswordController.text);
    _validateNewPassword(_newPasswordController.text);
    _validateConfirmNewPassword(_confirmNewPasswordController.text);
    return _currentPasswordError == null && _newPasswordError == null && _confirmNewPasswordError == null;
  }

  Future<void> _handleChangePassword() async {
    if (!_validateForm()) {
      _showErrorDialog('Validation Error', 'Please correct the errors in the form.');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null || user.email == null) {
      _showErrorDialog('Error', 'User not found or email is missing. Please log in again.');
      return;
    }

    setState(() { _isLoading = true; });

    _currentPassword = _currentPasswordController.text;
    _newPassword = _newPasswordController.text;

    try {
      AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!, password: _currentPassword!);

      await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(credential);
      await FirebaseAuth.instance.currentUser!.updatePassword(_newPassword!);

      // Firestore update (consider security implications as mentioned before)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.userId)
          .update({'password': _newPassword});

      _showSuccessDialog('Success', 'Password Changed Successfully. Please login again if prompted.');
      // Navigator.pop(context); // Pop after dialog is dismissed

    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect current password.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The new password is too weak.';
      } else {
        errorMessage = 'An error occurred: ${e.message}';
      }
      _showErrorDialog('Error', errorMessage);
    } catch (e) {
      _showErrorDialog('Error', 'An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  void _showErrorDialog(String title, String content) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

   void _showSuccessDialog(String title, String content) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss dialog
              Navigator.of(context).pop(); // Pop the ChangePassword screen
            }
          ),
        ],
      ),
    );
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String placeholder,
    bool obscureText = false,
    TextInputAction textInputAction = TextInputAction.next,
    ValueChanged<String>? onChanged,
    FocusNode? nextFocusNode,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoTextField(
          controller: controller,
          focusNode: focusNode,
          placeholder: placeholder,
          obscureText: obscureText,
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: errorText != null ? CupertinoColors.systemRed : CupertinoColors.inactiveGray,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
            color: CupertinoColors.systemBackground.resolveFrom(context),
          ),
          textInputAction: textInputAction,
          onChanged: onChanged,
          onSubmitted: (_) {
            if (nextFocusNode != null) {
              FocusScope.of(context).requestFocus(nextFocusNode);
            } else {
              focusNode.unfocus();
              if (_validateForm()) _handleChangePassword();
            }
          },
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 5.0, left: 10.0),
            child: Text(
              errorText,
              style: TextStyle(color: CupertinoColors.systemRed.resolveFrom(context), fontSize: 12),
            ),
          ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Change Password'),
        previousPageTitle: 'Settings', // Or appropriate back title
      ),
      child: SafeArea(
        child: ListView( // Changed to ListView for scrollability on small screens
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          children: <Widget>[
            _buildTextField(
              controller: _currentPasswordController,
              focusNode: _currentPasswordFocus,
              placeholder: 'Current Password',
              obscureText: true,
              onChanged: _validateCurrentPassword,
              nextFocusNode: _newPasswordFocus,
              errorText: _currentPasswordError,
            ),
            const SizedBox(height: 20.0),
            _buildTextField(
              controller: _newPasswordController,
              focusNode: _newPasswordFocus,
              placeholder: 'New Password',
              obscureText: true,
              onChanged: _validateNewPassword,
              nextFocusNode: _confirmNewPasswordFocus,
              errorText: _newPasswordError,
            ),
            const SizedBox(height: 20.0),
            _buildTextField(
              controller: _confirmNewPasswordController,
              focusNode: _confirmNewPasswordFocus,
              placeholder: 'Confirm New Password',
              obscureText: true,
              onChanged: _validateConfirmNewPassword,
              textInputAction: TextInputAction.done,
              errorText: _confirmNewPasswordError,
            ),
            const SizedBox(height: 40.0),
            CupertinoButton.filled(
              child: _isLoading
                  ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                  : const Text('Change Password'),
              onPressed: _isLoading ? null : _handleChangePassword,
            ),
          ],
        ),
      ),
    );
  }
}
