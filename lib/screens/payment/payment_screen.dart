// import 'package:firebase_auth/firebase_auth.dart'; // Not directly used, but indirectly by PaymentProvider
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
// import 'package:cloudkeja/helpers/constants.dart'; // kPrimaryColor replaced by theme
import 'package:cloudkeja/helpers/mpesa_helper.dart'; // Assuming this is correctly set up
// import 'package:cloudkeja/helpers/my_loader.dart'; // MyLoader replaced by CircularProgressIndicator
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/payment_provider.dart';
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/screens/payment/payment_successfu_screen.dart'; // Will be renamed/themed later
import 'package:cloudkeja/widgets/space_tile.dart'; // Already themed
import 'package:skeletonizer/skeletonizer.dart'; // For skeleton loading

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key, required this.space}) : super(key: key);
  final SpaceModel space;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessingPayment = false; // Renamed from isLoading for clarity

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0, left: 4.0, right: 4.0), // Adjusted padding
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildUserDetail(BuildContext context, IconData icon, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0), // Adjusted padding
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary), // Themed icon
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: theme.textTheme.bodyMedium)), // Allow text to wrap
        ],
      ),
    );
  }

  Widget _buildLandlordDetailsSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    return Skeletonizer(
      enabled: true,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [const Icon(Icons.person_outline, size: 18), const SizedBox(width: 10), Container(height: 16, width: 150, color: Colors.transparent)]),
              const SizedBox(height: 10),
              Row(children: [const Icon(Icons.email_outlined, size: 18), const SizedBox(width: 10), Container(height: 14, width: 200, color: Colors.transparent)]),
              const SizedBox(height: 10),
              Row(children: [const Icon(Icons.credit_card, size: 18), const SizedBox(width: 10), Container(height: 14, width: 120, color: Colors.transparent)]),
              const SizedBox(height: 10),
              Row(children: [const Icon(Icons.call_outlined, size: 18), const SizedBox(width: 10), Container(height: 14, width: 100, color: Colors.transparent)]),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _processPayment() async {
    if (!mounted) return;
    setState(() => _isProcessingPayment = true);

    final theme = Theme.of(context); // For SnackBar theming
    final colorScheme = theme.colorScheme;
    final currentUser = Provider.of<AuthProvider>(context, listen: false).user;

    if (currentUser?.phone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your phone number is not available for Mpesa payment.', style: TextStyle(color: colorScheme.onError)), backgroundColor: colorScheme.error),
      );
      if (mounted) setState(() => _isProcessingPayment = false);
      return;
    }

    try {
      // Step 1: Initiate Mpesa Payment
      // The amount should ideally be widget.space.price, ensure it's correctly passed
      // For testing, mpesaPayment often uses a small amount like 1 KES.
      // Production should use widget.space.price!
      await mpesaPayment(amount: 1 /* widget.space.price ?? 1.0 */, phone: currentUser!.phone!);

      // Step 2: Record the rental/payment in your backend
      await Provider.of<PaymentProvider>(context, listen: false).rentSpace(
        currentUser.userId!, // Assuming userId is non-null
        widget.space,
      );

      // Step 3: Navigate to success screen
      if (mounted) {
        Get.off(() => const PaymentSuccessfulScreen()); // Ensure this screen exists and is named correctly
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: ${e.toString()}', style: TextStyle(color: colorScheme.onError)), backgroundColor: colorScheme.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final currentUser = Provider.of<AuthProvider>(context, listen: false).user;

    if (currentUser == null) {
      // Handle case where user data is not available (e.g., redirect or show error)
      return Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(title: const Text('Payment Details')),
        body: const Center(child: Text('User not logged in. Please restart the app.')),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.background, // Themed background
      appBar: AppBar(
        title: const Text('Payment Confirmation'), // Updated title
        // Styling from AppBarTheme
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // Consistent padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SpaceTile is already themed
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: SpaceTile(space: widget.space, isOwner: widget.space.ownerId == currentUser.userId),
            ),

            Expanded(
              child: ListView( // Use ListView for potentially long content
                children: [
                  _buildSectionTitle(context, 'Your Details'),
                  Card( // Use Card for details section
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person_outline_rounded, size: 22, color: colorScheme.primary),
                              const SizedBox(width: 12),
                              Text(currentUser.name ?? 'N/A', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildUserDetail(context, Icons.email_outlined, currentUser.email ?? 'N/A'),
                          const SizedBox(height: 12),
                          _buildUserDetail(context, Icons.phone_outlined, currentUser.phone ?? 'N/A'),
                          // Removed redundant user.name! text
                        ],
                      ),
                    ),
                  ),
                  _buildSectionTitle(context, 'Landlord Details'),
                  FutureBuilder<UserModel>(
                    future: Provider.of<PostProvider>(context, listen: false).fetchLandLordDetails(widget.space.ownerId!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLandlordDetailsSkeleton(context); // Themed skeleton
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return Card(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Could not load landlord details.', style: textTheme.bodyMedium?.copyWith(color: colorScheme.error))));
                      }
                      final owner = snapshot.data!;
                      return Card( // Use Card for landlord details
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.account_circle_outlined, size: 22, color: colorScheme.primary),
                                  const SizedBox(width: 12),
                                  Text(owner.name ?? 'N/A', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildUserDetail(context, Icons.email_outlined, owner.email ?? 'N/A'),
                              const SizedBox(height: 12),
                              _buildUserDetail(context, Icons.phone_outlined, owner.phone ?? 'N/A'),
                              if (owner.bankNumber != null && owner.bankNumber!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                _buildUserDetail(context, Icons.account_balance_wallet_outlined, 'Bank Acc: ${owner.bankNumber}'),
                              ],
                              // Removed redundant user.name! text
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20), // Spacer for bottom button
                ],
              ),
            ),
            // Bottom "Pay" button
            Padding(
              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).padding.bottom > 0 ? 0 : 16.0) // No extra padding if safe area already pads
                  .copyWith(bottom: MediaQuery.of(context).padding.bottom + 16.0), // Add safe area padding + own padding
              child: SizedBox(
                width: double.infinity,
                height: 50, // Standard button height
                child: ElevatedButton(
                  onPressed: _isProcessingPayment ? null : _processPayment,
                  // Style from ElevatedButtonThemeData
                  child: _isProcessingPayment
                      ? SizedBox(
                          height: 24, // Consistent size for loader
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: colorScheme.onPrimary, // Loader color on button
                          ),
                        )
                      : Text(
                          'Pay KES ${widget.space.price?.toStringAsFixed(0) ?? '0.00'} via Mpesa',
                          // Text style from ElevatedButtonThemeData
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
