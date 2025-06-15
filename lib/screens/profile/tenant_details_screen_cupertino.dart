import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:get/route_manager.dart'; // For Get.snackbar replacement
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/payment_provider.dart';
import 'package:cloudkeja/widgets/dialogs/user_payment_dialog_cupertino_content.dart'; // For payment dialog

class TenantDetailsScreenCupertino extends StatelessWidget {
  const TenantDetailsScreenCupertino({Key? key, required this.space}) : super(key: key);
  final SpaceModel space;

  void _showCupertinoPaymentDialog(BuildContext context, SpaceModel space) {
    showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Make Payment'),
          content: UserPaymentDialogCupertinoContent(space: space),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              child: const Text('Cancel'),
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            )
          ],
        );
      },
    ).then((paymentSuccessful) {
      if (paymentSuccessful == true) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext alertContext) => CupertinoAlertDialog(
            title: const Text('Payment Successful'),
            content: const Text('Your payment has been processed.'),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(alertContext).pop();
                  // Optionally refresh data here if needed
                },
              )
            ],
          ),
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    // final cupertinoTheme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(space.spaceName ?? 'Tenancy Details'),
        // previousPageTitle: 'Profile', // Or based on actual navigation stack
      ),
      child: CustomScrollView(
        slivers: [
          // Placeholder for a flexible header if needed, similar to Material.
          // For now, using a simple header via navigationBar.
          // Could add CupertinoSliverNavigationBar for large title effects if desired.

          SliverList(
            delegate: SliverChildListDelegate([
              _TenantDetailsRoomWidgetCupertino(
                space: space,
                onMakePayment: () => _showCupertinoPaymentDialog(context, space),
              ),
              _DaysWidgetCupertino(space: space),
              const _RentRepaymentHistoryCupertino(),
              const SizedBox(height: 20), // Padding at the bottom
            ]),
          )
        ],
      ),
    );
  }
}

class _TenantDetailsRoomWidgetCupertino extends StatelessWidget {
  const _TenantDetailsRoomWidgetCupertino({
    Key? key,
    required this.space,
    required this.onMakePayment,
  }) : super(key: key);
  final SpaceModel space;
  final VoidCallback onMakePayment;

  void _showCheckoutConfirmation(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext dialogContext) => CupertinoActionSheet(
        title: const Text('Confirm Checkout'),
        message: Text('Are you sure you want to check out from ${space.spaceName ?? "this space"}?'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            child: const Text('Checkout Now'),
            onPressed: () async {
              Navigator.pop(dialogContext); // Dismiss action sheet
              try {
                 await Provider.of<PaymentProvider>(context, listen: false)
                  .checkOut(uid, space);
                // Show success alert
                showCupertinoDialog(context: context, builder: (ctx) => CupertinoAlertDialog(
                  title: const Text("Checked Out"),
                  content: Text("You have successfully checked out from ${space.spaceName!}."),
                  actions: [CupertinoDialogAction(child: const Text("OK"), onPressed: (){
                    Navigator.of(ctx).pop(); // Pop alert
                    // Potentially pop TenantDetailsScreen if that's the desired UX
                    if(Navigator.canPop(context)) Navigator.of(context).pop();
                    if(Navigator.canPop(context)) Navigator.of(context).pop(); // Assuming two pops needed
                  })],
                ));

              } catch (e) {
                 showCupertinoDialog(context: context, builder: (ctx) => CupertinoAlertDialog(
                  title: const Text("Checkout Failed"),
                  content: Text("An error occurred: ${e.toString()}"),
                  actions: [CupertinoDialogAction(child: const Text("OK"), onPressed: () => Navigator.of(ctx).pop())],
                ));
              }
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(dialogContext),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: cupertinoTheme.barBackgroundColor.withOpacity(0.5), // Subtle background
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.location_solid,
                      color: cupertinoTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(space.spaceName ?? 'N/A', style: cupertinoTheme.textTheme.textStyle.copyWith(fontWeight: FontWeight.w600))),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: CupertinoColors.systemGreen.resolveFrom(context),
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text(
                        'Checked in',
                        style: TextStyle(color: CupertinoColors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Total due Amount: ',
                      style: cupertinoTheme.textTheme.tabLabelTextStyle,
                    ),
                    Text(
                      'KES ${space.price?.toStringAsFixed(0) ?? '0'}',
                      style: cupertinoTheme.textTheme.textStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton.filled(
                    onPressed: onMakePayment,
                    child: const Text('Make Payment'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _DateFieldCupertino(
            value: DateFormat('dd MMM yyyy').format(DateTime.now()), // Format for Cupertino
          ),
          _DateFieldCupertino(
            title: 'Check out',
            value: DateFormat('dd MMM yyyy').format(DateTime.now().add(Duration(days: space.rentTime ?? 30))),
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text('Checkout Now', style: TextStyle(color: CupertinoColors.systemRed.resolveFrom(context), fontWeight: FontWeight.w600)),
            onPressed: () => _showCheckoutConfirmation(context),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _DateFieldCupertino extends StatelessWidget {
  const _DateFieldCupertino({Key? key, this.title, required this.value}) : super(key: key);
  final String? title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
          color: cupertinoTheme.barBackgroundColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title ?? 'Check in',
                style: cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: cupertinoTheme.textTheme.textStyle.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
          ),
          Icon(
            CupertinoIcons.calendar,
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
        ],
      ),
    );
  }
}

class _DaysWidgetCupertino extends StatelessWidget {
  const _DaysWidgetCupertino({Key? key, required this.space}) : super(key: key);
  final SpaceModel space;

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: cupertinoTheme.barBackgroundColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10.0)),
        child: Row(
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(
                    (space.rentTime ?? 0).toString(),
                    style: cupertinoTheme.textTheme.navLargeTitleTextStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 40, // Adjusted for prominence
                        color: cupertinoTheme.primaryColor),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0), // Align with baseline of number
                    child: Text('Days', style: cupertinoTheme.textTheme.textStyle),
                  )
                ]),
                const SizedBox(height: 6),
                Text('Total stay', style: cupertinoTheme.textTheme.tabLabelTextStyle)
              ],
            )),
            SizedBox(
                height: 60, // Adjusted size
                child: Opacity(
                  opacity: 0.15, // Softer opacity
                  child: Image.asset(
                    'assets/images/logo.png', // Assuming logo is still relevant
                    fit: BoxFit.fitHeight,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

class _RentRepaymentHistoryCupertino extends StatelessWidget {
  const _RentRepaymentHistoryCupertino({Key? key}) : super(key: key);

  Widget _rentDetailsCupertino(BuildContext context, String month, String dueDate, String status) {
    final cupertinoTheme = CupertinoTheme.of(context);
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'paid':
        statusColor = CupertinoColors.systemGreen.resolveFrom(context);
        break;
      case 'pending':
        statusColor = CupertinoColors.systemOrange.resolveFrom(context);
        break;
      default:
        statusColor = CupertinoColors.secondaryLabel.resolveFrom(context);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: CupertinoColors.separator.resolveFrom(context), width: 0.5))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 2, child: Text(month, style: cupertinoTheme.textTheme.textStyle)),
          Expanded(flex: 3, child: Text(dueDate, style: cupertinoTheme.textTheme.textStyle, textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(status, style: cupertinoTheme.textTheme.textStyle.copyWith(color: statusColor), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0, top: 16.0), // Adjust padding for title
            child: Text(
              'Rent Repayment History',
              style: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.label.resolveFrom(context)
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: cupertinoTheme.barBackgroundColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10.0)
            ),
            child: Column(
              children: [
                 Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                     border: Border(bottom: BorderSide(color: CupertinoColors.separator.resolveFrom(context), width: 0.5))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(flex: 2, child: Text('Month', style: cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(fontWeight: FontWeight.w600))),
                      Expanded(flex: 3, child: Text('Due date', style: cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                      Expanded(flex: 2, child: Text('Status', style: cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
                    ],
                  ),
                ),
                _rentDetailsCupertino(context, 'May, 2022', '06/May/2022', 'Paid'),
                _rentDetailsCupertino(context, 'April, 2022', '06/Apr/2022', 'Paid'),
                _rentDetailsCupertino(context, 'March, 2022', '06/Mar/2022', 'Paid'),
                // Add a way to see more if list is long, or ensure it's scrollable if parent is not already.
              ],
            ),
          ),
        ],
      ),
    );
  }
}
