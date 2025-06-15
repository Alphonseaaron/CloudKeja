import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:cloudkeja/helpers/constants.dart'; // kPrimaryColor will be replaced by theme
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/payment_provider.dart';
// Assuming showUserPaymentDialog is imported from user_profile_screen_material.dart or a shared helper
// For this example, let's assume it's available globally or via an import.
// If it's in user_profile_screen_material.dart, it would be:
import 'package:cloudkeja/screens/profile/user_profile_screen_material.dart' show showUserPaymentDialog;
import 'package:sliver_header_delegate/sliver_header_delegate.dart';

class TenantDetailsScreenMaterial extends StatelessWidget {
  const TenantDetailsScreenMaterial({Key? key, required this.space}) : super(key: key);
  final SpaceModel space;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context); // Get theme

    return Scaffold(
        body: CustomScrollView(slivers: [
      SliverPersistentHeader(
        pinned: true,
        delegate: FlexibleHeaderDelegate(
          backgroundColor: theme.colorScheme.primary, // Use theme color
          expandedHeight: size.height * 0.3,
          statusBarHeight: MediaQuery.of(context).padding.top,
          children: [
            FlexibleTextItem(
              text: space.spaceName!,
              expandedStyle: GoogleFonts.ibmPlexSans(
                  color: Colors.white, // Keep white for contrast on primary
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              collapsedStyle:
                  GoogleFonts.ibmPlexSans(color: theme.colorScheme.onPrimary, fontSize: 14), // onPrimary for collapsed
              expandedAlignment: Alignment.bottomCenter,
              collapsedAlignment: Alignment.center,
              expandedPadding: const EdgeInsets.all(15),
            ),
          ],
        ),
      ),
      SliverList(
          delegate: SliverChildListDelegate([
        _TenantDetailsRoomWidgetMaterial( // Renamed helper
          space: space,
        ),
        _DaysWidgetMaterial( // Renamed helper
          space: space,
        ),
        const _RentRepaymentHistoryMaterial(), // Renamed helper
      ]))
    ]));
  }
}

class _TenantDetailsRoomWidgetMaterial extends StatelessWidget {
  const _TenantDetailsRoomWidgetMaterial({Key? key, required this.space})
      : super(key: key);
  final SpaceModel space;
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final theme = Theme.of(context); // Get theme
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface, // Use surface color
        borderRadius: BorderRadius.circular(5),
        boxShadow: [ // Optional: add subtle shadow from theme
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
          )
        ]
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Icon(
              Icons.location_on,
              color: colorScheme.primary, // Use theme color
              size: 18,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(space.spaceName!),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: Colors.green, borderRadius: BorderRadius.circular(20)),
              child: const Text(
                'Checked in',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Text(
              'Total due Amount: ',
              style: TextStyle(color: colorScheme.onSurfaceVariant), // Use onSurfaceVariant
            ),
            Text(
              'KES ${space.price!.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        ElevatedButton(
            onPressed: () {
              // This function is expected to be available from an import
              showUserPaymentDialog(context, space);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary, // Use theme color
              foregroundColor: colorScheme.onPrimary, // Use theme color
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            ),
            child: const Text('Make payment')),
        const SizedBox(height: 15),
        _DateFieldMaterial( // Renamed helper
          value: DateFormat('dd/MM/yyyy').format(DateTime.now()),
        ),
        _DateFieldMaterial( // Renamed helper
          title: 'Check out',
          days: space.rentTime!,
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () async {
            await Provider.of<PaymentProvider>(context, listen: false)
                .checkOut(uid, space);
            // Consider showing a Material dialog/snackbar for confirmation before popping
            Navigator.of(context).pop(); // Pop current screen
            // Navigator.of(context).pop(); // Pop previous if needed, or manage navigation state
            Get.snackbar('Checked Out', // Get.snackbar is Material-like by default
                'You have successfully checked out from ${space.spaceName!}');
          },
          child: Text('Checkout Now',
              style:
                  TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600)), // Use theme color
        ),
        const SizedBox(height: 10),
      ]),
    );
  }
}

class _DateFieldMaterial extends StatelessWidget { // Renamed helper
  const _DateFieldMaterial({Key? key, this.title, this.value, this.days})
      : super(key: key);
  final String? title, value;
  final int? days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.5), // Use theme color
          borderRadius: BorderRadius.circular(3)),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title ?? 'Check in',
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12), // Use theme color
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                value ??
                    DateFormat('dd/MM/yyyy')
                        .format(DateTime.now().add(Duration(days: days ?? 30))), // Use days if provided
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Icon(
          Icons.calendar_month_rounded,
          color: colorScheme.onSurfaceVariant, // Use theme color
        ),
      ]),
    );
  }
}

class _DaysWidgetMaterial extends StatelessWidget { // Renamed helper
  const _DaysWidgetMaterial({Key? key, required this.space}) : super(key: key);
  final SpaceModel space;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
          color: colorScheme.surface, // Use theme color
          borderRadius: BorderRadius.circular(3),
          boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(0.05), spreadRadius: 1, blurRadius: 3)]),
      child: Row(
        children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(space.rentTime.toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 40,
                        color: colorScheme.primary)), // Use theme color
                const SizedBox(width: 3),
                const Text(
                  'Days',
                )
              ]),
              const SizedBox(height: 6),
              const Text('Total stay')
            ],
          )),
          SizedBox(
              height: 80,
              child: Opacity(
                opacity: 0.25,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.fitHeight,
                ),
              ))
        ],
      ),
    );
  }
}

class _RentRepaymentHistoryMaterial extends StatelessWidget { // Renamed helper
  const _RentRepaymentHistoryMaterial({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      decoration: BoxDecoration(
          color: colorScheme.surface, // Use theme color
          borderRadius: BorderRadius.circular(3),
          boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(0.05), spreadRadius: 1, blurRadius: 3)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rent Repayment History',
            style: TextStyle(
                fontSize: 15,
                color: colorScheme.primary, // Use theme color
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(15),
            color: colorScheme.surfaceVariant.withOpacity(0.5), // Use theme color
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Month',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Due date',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _rentDetailsMaterial('May', theme), // Pass theme
          _rentDetailsMaterial('April', theme), // Pass theme
          _rentDetailsMaterial('March', theme), // Pass theme
        ],
      ),
    );
  }

  Widget _rentDetailsMaterial(String month, ThemeData theme) { // Pass theme
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$month, 2022'),
              Text('06/$month/2022'),
              const Text(
                'Paid',
                style: TextStyle(color: Colors.green), // Keeping green for "Paid" status
              ),
            ],
          ),
        ),
        Divider(color: theme.dividerColor), // Use theme color
      ],
    );
  }
}
