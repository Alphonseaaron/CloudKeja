import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:cloudkeja/models/payment_model.dart';

class PaymentHistoryTileCupertino extends StatelessWidget {
  final PaymentModel paymentData;

  const PaymentHistoryTileCupertino({
    Key? key,
    required this.paymentData,
  }) : super(key: key);

  Color _getStatusColor(BuildContext context, String? status) {
    switch (status?.toLowerCase()) {
      case 'successful':
      case 'completed':
        return CupertinoColors.systemGreen.resolveFrom(context);
      case 'pending':
        return CupertinoColors.systemOrange.resolveFrom(context);
      case 'failed':
      case 'cancelled':
        return CupertinoColors.systemRed.resolveFrom(context);
      default:
        return CupertinoColors.secondaryLabel.resolveFrom(context);
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'successful':
      case 'completed':
        return CupertinoIcons.check_mark_circled_solid;
      case 'pending':
        return CupertinoIcons.time_solid;
      case 'failed':
      case 'cancelled':
        return CupertinoIcons.xmark_circle_fill;
      default:
        return CupertinoIcons.creditcard_fill; // Default icon for payment
    }
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    final statusColor = _getStatusColor(context, paymentData.status);
    final statusIcon = _getStatusIcon(paymentData.status);

    return CupertinoListTile.notched(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      leading: Icon(statusIcon, color: statusColor, size: 28),
      title: Text(
        paymentData.description,
        style: cupertinoTheme.textTheme.textStyle.copyWith(fontWeight: FontWeight.w600),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        DateFormat.yMMMd().add_jm().format(paymentData.date.toDate()),
        style: cupertinoTheme.textTheme.tabLabelTextStyle,
      ),
      additionalInfo: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${paymentData.currency} ${paymentData.amount.toStringAsFixed(2)}',
            style: cupertinoTheme.textTheme.textStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            paymentData.status,
            style: cupertinoTheme.textTheme.caption1.copyWith(color: statusColor, fontWeight: FontWeight.w500),
          ),
        ],
      ),
      // Trailing chevron can be added if it navigates to a detail screen
      // trailing: const CupertinoListTileChevron(), 
      onTap: () {
        // TODO: Navigate to specific payment details screen (Cupertino version)
        print('Tapped on Cupertino payment: ${paymentData.description}');
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Payment Details'),
            content: Text('Details for: ${paymentData.description} - ${paymentData.currency} ${paymentData.amount}'),
            actions: [CupertinoDialogAction(isDefaultAction: true, child: const Text('OK'), onPressed: () => Navigator.pop(ctx))],
          ),
        );
      },
    );
  }
}
