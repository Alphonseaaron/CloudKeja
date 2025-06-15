import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart'; // Though not directly used if user is passed
import 'package:cloudkeja/models/user_model.dart'; // For UserModel type
import 'package:cloudkeja/screens/landlord/finances/widget/withdraw_widget.dart'; // Router
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart'; // Assuming MyShimmer used by Skeletonizer is adaptive
import 'package:cloudkeja/helpers/my_shimmer.dart'; // For explicit use if needed, or if Skeletonizer's default effect is not good

class FinanceTopCupertino extends StatelessWidget {
  final UserModel? user;
  final bool isLoadingUser;

  const FinanceTopCupertino({
    Key? key,
    this.user,
    this.isLoadingUser = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    final balance = user?.balance ?? 0.0;
    final bool showSkeleton = isLoadingUser || (user == null && isLoadingUser);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: cupertinoTheme.barBackgroundColor.withOpacity(0.8), // Typical list section bg
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            SizedBox( // Coin image - keeping it consistent for now
              height: 36,
              width: 36,
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
                    style: cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(
                      color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Skeletonizer( // Assuming MyShimmer (used by Skeletonizer) is adaptive
                    enabled: showSkeleton,
                     effect: MyShimmerEffect( // Use MyShimmerEffect if Skeletonizer needs explicit effect
                        baseColor: CupertinoColors.systemGrey5.resolveFrom(context),
                        highlightColor: CupertinoColors.systemGrey4.resolveFrom(context),
                     ),
                    child: Text(
                      'KES ${NumberFormat("#,##0.00", "en_US").format(balance)}',
                      style: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(
                        color: CupertinoColors.label.resolveFrom(context),
                        fontSize: 20, // Prominent balance
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              // color: cupertinoTheme.primaryColor.withOpacity(0.1), // Subtle button bg
              onPressed: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (modalCtx) {
                    // WithdrawWidgetRouter will provide WithdrawWidgetCupertinoContent
                    return Container( // Container to give shape and background to the modal content
                       height: MediaQuery.of(context).size.height * 0.6, // Adjust as needed
                       decoration: BoxDecoration(
                         color: cupertinoTheme.scaffoldBackgroundColor, // Or systemGrey6 for sheet
                         borderRadius: const BorderRadius.only(
                           topLeft: Radius.circular(16.0),
                           topRight: Radius.circular(16.0),
                         ),
                       ),
                       child: WithdrawWidgetRouter(balance: user?.balance),
                    );
                  },
                );
              },
              child: Row( // Icon and text for button
                children: [
                  Icon(CupertinoIcons.arrow_down_to_line_alt, size: 20, color: cupertinoTheme.primaryColor),
                  const SizedBox(width: 6),
                  Text('Withdraw', style: TextStyle(color: cupertinoTheme.primaryColor, fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }
}

// Helper for Skeletonizer if MyShimmer is not directly used by it or needs specific setup
// This is based on MyShimmer's adaptive logic.
class MyShimmerEffect extends ShimmerEffect {
  MyShimmerEffect({
    required BuildContext context, // To get theme
    Duration period = const Duration(milliseconds: 1500),
    ShimmerDirection direction = ShimmerDirection.ltr,
    // Gradient? gradient, // Not using custom gradient
  }) : super(
          baseColor: _getBaseColor(context),
          highlightColor: _getHighlightColor(context),
          period: period,
          direction: direction,
        );

  static Color _getBaseColor(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);
    if (platformService.useCupertino) {
      return CupertinoColors.systemGrey5.resolveFrom(context);
    } else {
      return Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5);
    }
  }

  static Color _getHighlightColor(BuildContext context) {
     final platformService = Provider.of<PlatformService>(context, listen: false);
    if (platformService.useCupertino) {
      return CupertinoColors.systemGrey4.resolveFrom(context);
    } else {
      return Theme.of(context).colorScheme.surfaceVariant;
    }
  }
}
