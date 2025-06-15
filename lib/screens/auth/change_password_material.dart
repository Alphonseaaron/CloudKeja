import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/helpers/constants.dart';
import 'package:cloudkeja/providers/auth_provider.dart';

class ChangePasswordMaterial extends StatefulWidget {
  // static const routeName = '/change-password'; // Removed
  @override
  _ChangePasswordMaterialState createState() => _ChangePasswordMaterialState();
}

class _ChangePasswordMaterialState extends State<ChangePasswordMaterial> {
  String? _password;
  String? initialPassword;
  String? confirmPassword;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>(); // Added for form validation

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false); // Renamed user to authProvider for clarity
    final user = authProvider.user; // Get user from authProvider
    final size = MediaQuery.of(context).size;

    // Helper for SnackBar
    void _showSnackBar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ));
    }

    return Scaffold(
        body: SingleChildScrollView(
      child: Form( // Wrapped content in a Form widget
        key: _formKey,
        child: Column(
          children: [
            Container(
              // Constrained height to avoid overflow issues with keyboard
              height: size.height - MediaQuery.of(context).padding.top,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 50, // For spacing from top, consider AppBar for real apps
                  ),
                  GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.arrow_back_ios)
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      'Change Password',
                      style: GoogleFonts.openSans(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    thickness: 0.3,
                    height: 2,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                        obscureText: true, // Added for password fields
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Please enter your current password';
                          }
                          // It's generally not recommended to check password length here again if it's a current password
                          // Firebase re-authentication will handle if it's correct or not.
                          return null;
                        },
                        decoration: InputDecoration(
                            hintText: 'Current Password', // Changed to hintText
                            // prefixIcon: Icon(Icons.lock_outline), // Optional icon
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!)
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: kPrimaryColor, width: 1)
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        ),
                        onChanged: (text) => {
                              setState(() {
                                initialPassword = text;
                              })
                            }
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                        obscureText: true,
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Please enter your new password';
                          }
                          if (val.length < 6) {
                            return 'Password should have atleast 6 characters';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            hintText: 'New Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!)
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: kPrimaryColor, width: 1)
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        ),
                        onChanged: (text) => {
                              setState(() {
                                _password = text;
                              })
                            }
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                        obscureText: true,
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (val != _password) { // Check if it matches new password
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            hintText: 'Confirm New Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!)
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: kPrimaryColor, width: 1)
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        ),
                        onChanged: (text) => {
                              setState(() {
                                confirmPassword = text;
                              })
                            }
                  ),
                  const Spacer(), // Pushes button to the bottom
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    height: 45,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor, // Use backgroundColor
                        textStyle: const TextStyle(color: Colors.white),
                        shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: isLoading ? null : () async { // Disable button when loading
                        if (_formKey.currentState!.validate()) {
                          if (user == null) {
                             _showSnackBar('User not found. Please log in again.');
                            return;
                          }
                          // IMPORTANT: Re-authentication is needed before changing password
                          // The original code checks user.password which is insecure and likely incorrect.
                          // Assuming user.password was a local copy which is bad practice.
                          // Firebase requires recent login.

                          setState(() { isLoading = true; });

                          try {
                            // Step 1: Re-authenticate user
                            AuthCredential credential = EmailAuthProvider.credential(
                                email: user.email!, password: initialPassword!); // Ensure user.email is available

                            await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(credential);

                            // Step 2: If re-authentication is successful, update password
                            await FirebaseAuth.instance.currentUser!.updatePassword(_password!);

                            // Step 3: Update password in Firestore (if you store it there, be cautious)
                            // Storing passwords directly in Firestore is generally not recommended unless hashed securely.
                            // If it's just for reference or some other logic, ensure it's handled safely.
                            // The original code updates 'password' field, which might be a security risk.
                            // For this refactor, I'll keep it as it was but highlight the concern.
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.userId)
                                .update({'password': _password}); // Consider hashing or removing this

                            _showSnackBar('Password Changed Successfully. Please login again if prompted.');
                            Navigator.pop(context);

                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'wrong-password') {
                              _showSnackBar('Incorrect current password.');
                            } else if (e.code == 'weak-password') {
                              _showSnackBar('The new password is too weak.');
                            } else {
                              _showSnackBar('An error occurred: ${e.message}');
                            }
                          } catch (e) {
                            _showSnackBar('An unexpected error occurred. Please try again.');
                          } finally {
                             if (mounted) {
                              setState(() { isLoading = false; });
                            }
                          }
                        }
                      },
                      child: isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,))
                          : const Text(
                        'Change Password',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox( // Bottom padding
                    height: 40,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
