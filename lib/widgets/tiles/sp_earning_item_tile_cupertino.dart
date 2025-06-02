import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For Colors.green (can be replaced with CupertinoColors)
import 'package:intl/intl.dart';
import 'package:cloudkeja/models/sp_job_model.dart';

class SPEarningItemTileCupertino extends StatelessWidget {
  final SPJobModel job;
  final bool isSkeleton;

  const SPEarningItemTileCupertino({
    Key? key,
    required this.job,
    this.isSkeleton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    final Color earningsColor = CupertinoColors.activeGreen; // Using Cupertino's green

    return GestureDetector(
      onTap: isSkeleton ? null : () {
        print('Tapped on earning item: ${job.id} - ${job.serviceDescription}');
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('Earning Details'),
            content: Text('Earning from: ${job.clientName}\nService: ${job.serviceDescription}'),
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSkeleton ? CupertinoColors.systemGrey6 : cupertinoTheme.scaffoldBackgroundColor,
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.separator.resolveFrom(context),
              width: 0.5, // Standard iOS separator width
            ),
          ),
        ),
        child: Row(
          children: <Widget>[
            // Leading
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: isSkeleton ? CupertinoColors.systemGrey5 : cupertinoTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: isSkeleton
                  ? null
                  : Center(
                      child: Text(
                        job.clientName.isNotEmpty ? job.clientName[0].toUpperCase() : 'C',
                        style: TextStyle(
                          color: cupertinoTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 16.0), // Spacing

            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    job.serviceDescription.isNotEmpty ? job.serviceDescription : 'Service Provided',
                    style: cupertinoTheme.textTheme.textStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16, // Slightly larger for title
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
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
                  const SizedBox(height: 2),
                  Text(
                    'Date: ${DateFormat.yMMMd().format(job.dateCompleted)}',
                     style: cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(
                        fontSize: 12,
                        color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                      ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0), // Spacing before trailing

            // Trailing
            if (!isSkeleton)
              Text(
                'KES ${job.amountEarned.toStringAsFixed(2)}',
                style: cupertinoTheme.textTheme.textStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: earningsColor,
                  fontSize: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
