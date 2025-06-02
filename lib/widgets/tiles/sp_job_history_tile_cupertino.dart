import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For fallback colors if not in CupertinoColors
import 'package:intl/intl.dart';
import 'package:cloudkeja/models/sp_job_model.dart'; // Import the model

class SPJobHistoryTileCupertino extends StatelessWidget {
  final SPJobModel job;
  final bool isSkeleton;

  const SPJobHistoryTileCupertino({
    Key? key,
    required this.job,
    this.isSkeleton = false,
  }) : super(key: key);

  // Helper to get color based on job status for Cupertino
  Color _getStatusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return CupertinoColors.systemBlue.resolveFrom(context);
      case 'inprogress':
      case 'in progress':
        return CupertinoColors.systemOrange.resolveFrom(context);
      case 'completed':
        return CupertinoColors.systemGreen.resolveFrom(context);
      case 'pendingpayment':
      case 'pending payment':
        return CupertinoColors.systemPurple.resolveFrom(context);
      case 'cancelled':
        return CupertinoColors.systemRed.resolveFrom(context);
      default:
        return CupertinoColors.secondaryLabel.resolveFrom(context);
    }
  }

  // Helper to get icon based on job status for Cupertino
  IconData _getStatusIcon(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'scheduled': return CupertinoIcons.calendar_badge_plus;
      case 'inprogress':
      case 'in progress': return CupertinoIcons.hammer;
      case 'completed': return CupertinoIcons.check_mark_circled;
      case 'pendingpayment':
      case 'pending payment': return CupertinoIcons.creditcard;
      case 'cancelled': return CupertinoIcons.clear_circled_solid;
      default: return CupertinoIcons.briefcase;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    final statusColor = _getStatusColor(context, job.status);
    final statusIcon = _getStatusIcon(context, job.status);

    return GestureDetector(
      onTap: isSkeleton ? null : () {
        print('Tapped on job: ${job.id} - ${job.serviceDescription}');
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('Job Details'),
            content: Text('Tapped on job for: ${job.clientName}\nStatus: ${job.status}'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isSkeleton ? CupertinoColors.systemGrey6.resolveFrom(context) : cupertinoTheme.scaffoldBackgroundColor,
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.separator.resolveFrom(context),
              width: 0.5,
            ),
          ),
           borderRadius: BorderRadius.circular(8.0) // Adding slight rounding for a card-like feel
        ),
        child: Row(
          children: <Widget>[
            // Leading Icon
            if (!isSkeleton)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
            if (isSkeleton)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5.resolveFrom(context),
                  shape: BoxShape.circle,
                ),
              ),
            const SizedBox(width: 12),

            // Middle Content (Title, Subtitle)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    job.serviceDescription,
                    style: cupertinoTheme.textTheme.textStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Client: ${job.clientName}',
                    style: cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (job.propertyAddress != null && job.propertyAddress!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'At: ${job.propertyAddress}',
                      style: cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(
                        fontSize: 14,
                        color: CupertinoColors.secondaryLabel.resolveFrom(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 5),
                  Text(
                    '${job.status == "Scheduled" ? "Scheduled" : "Completed"}: ${DateFormat.yMMMd().add_jm().format(job.dateCompleted)}',
                    style: cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(
                      fontSize: 12,
                      color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Trailing Content (Amount, Status)
            if (!isSkeleton)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    'KES ${job.amountEarned.toStringAsFixed(2)}',
                    style: cupertinoTheme.textTheme.textStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      job.status,
                      style: TextStyle(
                        color: statusColor, // Use the status color directly for text for better visibility on light opacity bg
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
