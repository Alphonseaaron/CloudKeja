import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloudkeja/models/sp_job_model.dart'; // Import the SPJobModel

class SPEarningItemTileMaterial extends StatelessWidget { // Renamed widget
  final SPJobModel job;
  final bool isSkeleton; // Optional for specific skeleton styling

  const SPEarningItemTileMaterial({ // Renamed constructor
    Key? key,
    required this.job,
    this.isSkeleton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Use a specific success color for earnings amount, or fallback to primary
    final Color earningsColor = Colors.green.shade700; // Consistent success green

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      // Card properties from theme (elevation, shape, color)
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        // Leading icon can represent the service type or client initial
        leading: CircleAvatar(
          backgroundColor: isSkeleton ? Colors.transparent : colorScheme.primaryContainer,
          child: isSkeleton
            ? null
            : Text(
                job.clientName.isNotEmpty ? job.clientName[0].toUpperCase() : 'C',
                style: textTheme.titleMedium?.copyWith(color: colorScheme.onPrimaryContainer),
              ),
        ),
        title: Text(
          job.serviceDescription.isNotEmpty ? job.serviceDescription : 'Service Provided',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Client: ${job.clientName}',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.8)),
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
            const SizedBox(height: 4),
            Text(
              // Assuming dateCompleted refers to when the job was done/paid for this earning
              'Date: ${DateFormat.yMMMd().format(job.dateCompleted)}',
              style: textTheme.caption?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
        trailing: Text(
          'KES ${job.amountEarned.toStringAsFixed(2)}',
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: earningsColor, // Use the defined earnings color
          ),
        ),
        isThreeLine: true, // Allows more space for subtitle content
        onTap: isSkeleton ? null : () {
          // TODO: Navigate to specific job details or earning details if needed
          print('Tapped on earning item: ${job.id} - ${job.serviceDescription}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Earning from: ${job.clientName}')),
          );
        },
      ),
    );
  }
}
