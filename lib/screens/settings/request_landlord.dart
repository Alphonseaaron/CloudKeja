import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
// import 'package:cloudkeja/helpers/constants.dart'; // Old constants, use theme
import 'package:cloudkeja/providers/admin_provider.dart';
import 'package:cloudkeja/providers/auth_provider.dart'; // For current user ID
// import '../auth/theme.dart'; // Old theme file

class RequestLandlord extends StatefulWidget {
  const RequestLandlord({Key? key}) : super(key: key);

  @override
  State<RequestLandlord> createState() => _RequestLandlordState();
}

class _RequestLandlordState extends State<RequestLandlord> {
  final _formKey = GlobalKey<FormState>();
  // Initialize with empty strings to avoid late initialization error if accessed before onChanged
  String _bankBusinessNumber = '';
  String _bankNumber = '';
  bool _isLoading = false;

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save(); // Save form fields

    setState(() => _isLoading = true);

    final theme = Theme.of(context); // For SnackBar theming
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // Update user document with bank details
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'bankBusinessNumber': _bankBusinessNumber,
        'bankNumber': _bankNumber,
        'isLandlordRequestPending': true, // Optional: Add a flag to indicate request is pending
        'landlordRequestDate': Timestamp.now(), // Optional: Track request date
      });

      // This call should now be to request becoming a landlord.
      // The actual approval (setting isLandlord = true) is an admin action.
      // For now, we'll assume this call informs the admin or sets a flag.
      // The original task was to change makeLandlord(uid, false) to setUserLandlordStatus(uid, true)
      // which would directly make them a landlord. This might be an admin action.
      // If this dialog is for USER to REQUEST, it should NOT directly set isLandlord = true.
      // It should create a request or set a flag like 'isLandlordRequestPending'.
      // For this task, I will follow the instruction to change the call,
      // but in a real app, this flow might be different (e.g., creating a request document).

      // The instruction "change ...makeLandlord(uid, false) To: ...setUserLandlordStatus(uid, true)"
      // implies the user directly becomes a landlord by this action.
      // This is likely an admin-level action being initiated by a user, which is unusual.
      // However, sticking to the literal instruction for the code change:
      await Provider.of<AdminProvider>(context, listen: false)
          .setUserLandlordStatus(uid, true); // Sets isLandlord to true

      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Landlord status request submitted and auto-approved (dev).')), // Adjusted message
      );
      Navigator.of(context).pop(); // Close the dialog

    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error submitting request: ${e.toString()}', style: TextStyle(color: theme.colorScheme.onError)),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView( // Ensure content is scrollable if it overflows
      child: Padding(
        padding: const EdgeInsets.all(24.0), // Consistent padding
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Fit content
            children: [
              Text(
                'Request to be a Landlord',
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120, // Adjusted size for Lottie
                child: Lottie.asset('assets/admin.json'), // Assuming this Lottie is suitable
              ),
              const SizedBox(height: 24),

              TextFormField(
                initialValue: _bankNumber,
                onSaved: (val) => _bankNumber = val ?? '',
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter your bank account number';
                  return null;
                },
                decoration: const InputDecoration( // Uses global InputDecorationTheme
                  labelText: 'Bank Account Number', // Use labelText for better M3 feel
                  hintText: 'e.g., 001234567890',
                  prefixIcon: Icon(Icons.account_balance_outlined),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _bankBusinessNumber,
                onSaved: (val) => _bankBusinessNumber = val ?? '',
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter Mpesa Till/Paybill (if applicable)';
                  // Add more specific validation if needed
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Bank Business No. (for Mpesa)',
                  hintText: 'e.g., Mpesa Paybill or Till Number',
                  prefixIcon: Icon(Icons.business_center_outlined),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              Text(
                'Your request will be reviewed by an administrator. If approved, you will gain landlord privileges.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _submitRequest,
                  child: const Text('Submit Request'), // Text uses ElevatedButtonTheme's text style
                  // Style comes from ElevatedButtonThemeData in AppTheme
                  style: theme.elevatedButtonTheme.style?.copyWith(
                     minimumSize: MaterialStateProperty.all(const Size(double.infinity, 48)) // Full width
                  )
                ),
            ],
          ),
        ),
      ),
    );
  }
}
