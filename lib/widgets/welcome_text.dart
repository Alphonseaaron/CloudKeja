import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart'; // Not used if chat icon remains commented
// import 'package:get/get.dart'; // Not used if chat icon remains commented
// import 'package:get/get_core/src/get_main.dart'; // Not used
import 'package:provider/provider.dart';
import 'package:cloudkeja/providers/auth_provider.dart';

// import '../screens/chat/chat_screen.dart'; // Not used if chat icon remains commented

class WelcomeText extends StatelessWidget {
  const WelcomeText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    // final colorScheme = theme.colorScheme; // Not directly needed if text uses themed styles

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    // Extract only the first name for a more casual greeting
    final String firstName = user?.name?.split(' ').first ?? 'User';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello $firstName,', // Added comma for better flow
            style: textTheme.titleMedium?.copyWith(
                // fontWeight: FontWeight.bold, // titleMedium might be bold by default
                // color: colorScheme.onBackground // Default
                ),
          ),
          const SizedBox(height: 4.0), // Reduced spacing for closer association
          Text(
            'Find your perfect space',
            style: textTheme.headlineSmall?.copyWith(
                // fontWeight: FontWeight.bold, // headlineSmall is typically bold
                // color: colorScheme.onBackground // Default
                ),
          ),
          // If the chat icon were to be re-added:
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text(
          //           'Hello $firstName,',
          //           style: textTheme.titleMedium,
          //         ),
          //         const SizedBox(height: 4.0),
          //         Text(
          //           'Find your perfect space',
          //           style: textTheme.headlineSmall,
          //         ),
          //       ],
          //     ),
          //     IconButton(
          //       onPressed: () {
          //         Get.to(() => const ChatScreen());
          //       },
          //       icon: Icon(
          //         Icons.chat_bubble_outline, // Material Design icon
          //         color: colorScheme.primary, // Themed icon color
          //       ),
          //       tooltip: 'Messages',
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
