import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloudkeja/models/sp_job_model.dart'; // Import the model

class SPJobHistoryTileMaterial extends StatelessWidget { // Renamed widget
  final SPJobModel job;
  final bool isSkeleton; // Optional, if specific skeleton styling is needed beyond Skeletonizer

  const SPJobHistoryTileMaterial({ // Renamed constructor
    Key? key,
    required this.job,
    this.isSkeleton = false,
  }) : super(key: key);

  // Helper to get color based on job status
  Color _getStatusColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue.shade600;
      case 'inprogress':
      case 'in progress':
        return Colors.orange.shade700;
      case 'completed':
        return Colors.green.shade700;
      case 'pendingpayment':
      case 'pending payment':
        return Colors.purple.shade400;
      case 'cancelled':
        return colorScheme.error;
      default: // 'Loading' or other statuses
        return colorScheme.onSurface.withOpacity(0.7);
    }
  }

  // Helper to get chip text color for good contrast
  Color _getChipTextColor(BuildContext context, String status) {
    final chipBgColor = _getStatusColor(context, status);
    // Determine if chip background is light or dark for optimal contrast
    return ThemeData.estimateBrightnessForColor(chipBgColor) == Brightness.dark
        ? Colors.white
        : Colors.black.withOpacity(0.8);
  }

  IconData _getStatusIcon(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'scheduled': return Icons.event_note_outlined;
      case 'inprogress':
      case 'in progress': return Icons.construction_outlined;
      case 'completed': return Icons.check_circle_outline_rounded;
      case 'pendingpayment':
      case 'pending payment': return Icons.payment_outlined;
      case 'cancelled': return Icons.cancel_outlined;
      default: return Icons.work_history_outlined;
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final statusColor = _getStatusColor(context, job.status);
    final chipTextColor = _getChipTextColor(context, job.status);
    final statusIcon = _getStatusIcon(context, job.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      // Card properties from theme
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        leading: CircleAvatar(
          backgroundColor: isSkeleton ? Colors.transparent : statusColor.withOpacity(0.15),
          child: isSkeleton ? null : Icon(statusIcon, color: statusColor, size: 24),
        ),
        title: Text(
          job.serviceDescription,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Client: ${job.clientName}',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.8)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (job.propertyAddress != null && job.propertyAddress!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                'At: ${job.propertyAddress}',
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 6),
            Text(
              // Display appropriate date label based on status
              '${job.status == "Scheduled" ? "Scheduled" : "Completed"}: ${DateFormat.yMMMd().add_jm().format(job.dateCompleted)}',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'KES ${job.amountEarned.toStringAsFixed(2)}',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Chip(
              label: Text(job.status, style: textTheme.labelSmall?.copyWith(color: chipTextColor)),
              backgroundColor: statusColor.withOpacity(0.20), // Slightly more opaque background
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), // M3 chip shape
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        isThreeLine: true, // Allows more space for subtitle content
        onTap: isSkeleton ? null : () {
          // TODO: Navigate to specific job details screen if available
          // Get.to(() => SPJobDetailsScreen(jobId: job.id));
          print('Tapped on job: ${job.id} - ${job.serviceDescription}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tapped on job for: ${job.clientName}')),
          );
        },
      ),
    );
  }
}
