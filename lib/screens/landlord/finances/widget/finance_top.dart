// import 'package:cloud_firestore/cloud_firestore.dart'; // Not directly used
// import 'package:firebase_auth/firebase_auth.dart'; // Not directly used
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:cloudkeja/helpers/constants.dart'; // kPrimaryColor replaced by theme
import 'package:cloudkeja/providers/auth_provider.dart'; // For user balance
import 'package:cloudkeja/screens/landlord/finances/widget/withdraw_widget.dart'; // Assuming this is themed separately or simple
import 'package:intl/intl.dart'; // For currency formatting
import 'package:skeletonizer/skeletonizer.dart'; // For balance loading

class FinanceTop extends StatelessWidget {
  const FinanceTop({Key? key}) : super(key: key);

  // amount formatter is not used here, balance is directly formatted.
  // String amount(String amount) {
  //   return amount.replaceAllMapped(
  //       RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Access balance via Consumer or directly if it's already loaded and not changing frequently here
    // For simplicity, assuming AuthProvider.user is available and balance is part of it.
    // If balance itself can change and needs to update this widget, use Consumer<AuthProvider>.
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final balance = user?.balance ?? 0.0;
    final bool isLoadingBalance = user == null; // Basic check if user data (and thus balance) is still loading

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Standard padding
      child: Card( // Use Card for better structure and theming
        elevation: 2.0, // Subtle elevation from CardTheme or override
        // shape: cardTheme.shape, // from theme
        color: colorScheme.surfaceContainerHighest, // A distinct surface color from M3 palette
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0), // Inner padding
          child: Row(
            children: [
              SizedBox( // Coin image
                height: 40, // Adjusted size
                width: 40,
                child: Image.asset('assets/images/coin.png'), // Keep asset or replace with themed icon
              ),
              const SizedBox(width: 16),
              Expanded( // Allow text to take available space
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Available Balance',
                      style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant), // Themed label
                    ),
                    const SizedBox(height: 2),
                    Skeletonizer.zone( // Skeletonize only the balance text part
                      enabled: isLoadingBalance,
                      child: Text(
                        'KES ${NumberFormat("#,##0.00", "en_US").format(balance)}',
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface, // Themed text color
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16), // Spacer
              // Withdraw Button
              TextButton.icon( // Changed to TextButton.icon for a less prominent action here
                icon: Icon(Icons.output_rounded, color: colorScheme.primary, size: 20),
                label: Text('Withdraw', style: textTheme.labelLarge?.copyWith(color: colorScheme.primary)),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent, // Sheet content will have its own background
                    shape: theme.bottomSheetTheme.shape, // Themed shape
                    builder: (ctx) {
                      // Assuming WithdrawWidget is simple or will be themed separately.
                      // If it's complex, it needs its own theming pass.
                      return const WithdrawWidget();
                    },
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  // side: BorderSide(color: colorScheme.outline.withOpacity(0.5)), // Optional border
                  // backgroundColor: colorScheme.primaryContainer, // Alternative style
                  // foregroundColor: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
