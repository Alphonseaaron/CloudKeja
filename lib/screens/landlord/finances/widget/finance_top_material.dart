import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/models/user_model.dart'; // For UserModel type
import 'package:cloudkeja/screens/landlord/finances/widget/withdraw_widget.dart'; // Router
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class FinanceTopMaterial extends StatelessWidget {
  // Added user and isLoadingUser parameters as it seems parent passes them
  final UserModel? user;
  final bool isLoadingUser;

  const FinanceTopMaterial({
    Key? key,
    this.user, // Can be null if parent is still loading user
    this.isLoadingUser = true, // Default to true if not specified
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final balance = user?.balance ?? 0.0;
    // isLoadingUser from parameter determines skeletonization
    final bool showSkeleton = isLoadingUser || (user == null && isLoadingUser);


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), // Consistent shape
        color: colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            children: [
              SizedBox(
                height: 40,
                width: 40,
                child: Image.asset('assets/images/coin.png'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Available Balance',
                      style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 2),
                    Skeletonizer.zone(
                      enabled: showSkeleton,
                      child: Text(
                        'KES ${NumberFormat("#,##0.00", "en_US").format(balance)}',
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                icon: Icon(Icons.output_rounded, color: colorScheme.primary, size: 20),
                label: Text('Withdraw', style: textTheme.labelLarge?.copyWith(color: colorScheme.primary)),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    shape: theme.bottomSheetTheme.shape ?? RoundedRectangleBorder(
                       borderRadius: BorderRadius.only(
                         topLeft: Radius.circular(16),
                         topRight: Radius.circular(16),
                       )
                    ),
                    builder: (ctx) {
                      // Using WithdrawWidgetRouter to get platform-specific content
                      return WithdrawWidgetRouter(balance: user?.balance);
                    },
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
