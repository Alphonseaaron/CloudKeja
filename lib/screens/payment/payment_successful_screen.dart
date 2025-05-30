import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:lottie/lottie.dart'; // For Lottie animations
// import 'package:cloudkeja/helpers/constants.dart'; // kPrimaryColor replaced by theme
import 'package:cloudkeja/screens/home/my_nav.dart'; // For navigation

class PaymentSuccessfulScreen extends StatelessWidget {
  const PaymentSuccessfulScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // A success color, can be defined in AppTheme or used directly
    final Color successColor = Colors.green.shade700;

    return Scaffold(
      backgroundColor: colorScheme.background, // Themed background
      // No AppBar for a success screen is common, focuses user on the message.
      body: Center( // Center the content vertically and horizontally
        child: Padding(
          padding: const EdgeInsets.all(24.0), // Consistent padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Lottie Animation
              SizedBox(
                height: 220, // Adjusted height for better balance
                // Ensure the Lottie animation has a transparent background or one that matches.
                // If Lottie.asset takes a 'background' color, set it to Colors.transparent.
                child: Lottie.asset(
                  'assets/pay_success.json',
                  repeat: false, // Play animation once
                ),
              ),
              const SizedBox(height: 32), // Increased spacing

              // Success Title
              Text(
                'Payment Successful!', // Slightly more enthusiastic
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith( // More prominent style
                  color: successColor, // Use a distinct success color
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Descriptive Text
              Text(
                'You have successfully paid for the space. Please contact the space owner for more information on checking in.\n\nThank you for using CloudKeja!',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith( // Slightly larger body text
                  color: colorScheme.onBackground.withOpacity(0.8),
                  height: 1.5, // Improved line height for readability
                ),
              ),
              const SizedBox(height: 48), // Increased spacing before button

              // Action Button
              SizedBox(
                width: double.infinity, // Make button take full available width within padding
                child: ElevatedButton.icon( // Added icon for better UX
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Back to Home'),
                  onPressed: () {
                    Get.offAll(() => const MainPage()); // Navigate and clear stack
                  },
                  // Style will come from ElevatedButtonThemeData in AppTheme
                  // Ensure ElevatedButtonThemeData provides sufficient padding and text style
                  style: theme.elevatedButtonTheme.style?.copyWith(
                     padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
