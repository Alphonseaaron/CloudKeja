import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:cloudkeja/models/payment_model.dart'; // Import the actual PaymentModel
// import 'package:get/route_manager.dart'; // If navigation to details is added

class PaymentHistoryTile extends StatelessWidget {
  final PaymentModel paymentData;
  final bool isSkeleton; // To visually differentiate skeleton if needed

  const PaymentHistoryTile({
    Key? key,
    required this.paymentData,
    this.isSkeleton = false, // Default to not a skeleton
  }) : super(key: key);

  Color _getColorForStatus(BuildContext context, String? status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status?.toLowerCase()) { // Handle potential null status and case variations
      case 'successful':
      case 'completed': // Treat "completed" also as success for color
        return Colors.green.shade700;
      case 'pending':
        return Colors.orange.shade700;
      case 'failed':
      case 'cancelled': // Treat "cancelled" also as error for color
        return colorScheme.error;
      default: // 'Loading' or other statuses
        return colorScheme.onSurface.withOpacity(0.7);
    }
  }

  IconData _getIconForStatus(BuildContext context, String? status) {
    switch (status?.toLowerCase()) {
      case 'successful':
      case 'completed':
        return Icons.check_circle_outline_rounded;
      case 'pending':
        return Icons.hourglass_empty_rounded;
      case 'failed':
      case 'cancelled':
        return Icons.error_outline_rounded;
      default: // 'Loading' or other statuses
        return Icons.receipt_long_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    final statusColor = _getColorForStatus(context, paymentData.status);
    final statusIcon = _getIconForStatus(context, paymentData.status);

    // If it's a skeleton and data might be placeholder, ensure it looks like one
    // This can be handled by Skeletonizer directly if paymentData is PaymentModel.empty()
    // and its fields are placeholder strings.

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      // Card properties from theme
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        leading: CircleAvatar(
          backgroundColor: isSkeleton ? Colors.transparent : statusColor.withOpacity(0.15),
          child: isSkeleton ? null : Icon(statusIcon, color: statusColor, size: 24),
        ),
        title: Text(
          paymentData.description,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          // Convert Timestamp to DateTime before formatting
          DateFormat.yMMMd().add_jm().format(paymentData.date.toDate()), 
          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${paymentData.currency} ${paymentData.amount.toStringAsFixed(2)}',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface, 
              ),
            ),
            const SizedBox(height: 2),
            Text(
              paymentData.status,
              style: textTheme.bodySmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        onTap: isSkeleton ? null : () { // Disable tap for skeleton items
          // TODO: Navigate to specific payment details screen if available
          // Get.to(() => PaymentDetailsScreen(paymentId: paymentData.id)); 
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tapped on: ${paymentData.description}')),
          );
        },
      ),
    );
  }
}
