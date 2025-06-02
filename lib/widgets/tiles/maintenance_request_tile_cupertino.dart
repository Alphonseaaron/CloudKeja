import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:cloudkeja/models/maintenance_request_model.dart';

class MaintenanceRequestTileCupertino extends StatelessWidget {
  final MaintenanceRequestModel maintenanceRequest;

  const MaintenanceRequestTileCupertino({
    Key? key,
    required this.maintenanceRequest,
  }) : super(key: key);

  // Helper methods for status color and icon, adapted for Cupertino
  Color _getStatusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return CupertinoColors.systemBlue.resolveFrom(context);
      case 'inprogress':
      case 'in progress':
        return CupertinoColors.systemOrange.resolveFrom(context);
      case 'completed':
        return CupertinoColors.systemGreen.resolveFrom(context);
      case 'cancelled':
        return CupertinoColors.systemRed.resolveFrom(context);
      default:
        return CupertinoColors.secondaryLabel.resolveFrom(context);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return CupertinoIcons.doc_text_fill; // Example, choose appropriate
      case 'inprogress':
      case 'in progress':
        return CupertinoIcons.time_solid; // Example
      case 'completed':
        return CupertinoIcons.check_mark_circled_solid;
      case 'cancelled':
        return CupertinoIcons.xmark_circle_fill;
      default:
        return CupertinoIcons.question_circle_fill;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    final statusColor = _getStatusColor(context, maintenanceRequest.status);
    final statusIcon = _getStatusIcon(maintenanceRequest.status);

    Widget statusWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        maintenanceRequest.status,
        style: cupertinoTheme.textTheme.caption1.copyWith(color: statusColor, fontWeight: FontWeight.w600),
      ),
    );


    return CupertinoListTile.notched(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      leading: Icon(statusIcon, color: statusColor, size: 28),
      title: Text(
        maintenanceRequest.propertyAddress,
        style: cupertinoTheme.textTheme.textStyle.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${maintenanceRequest.description}\nSubmitted: ${DateFormat.yMMMd().format(maintenanceRequest.dateSubmitted)}',
        style: cupertinoTheme.textTheme.tabLabelTextStyle,
        maxLines: 3, // Allow more lines for description and date
        overflow: TextOverflow.ellipsis,
      ),
      additionalInfo: statusWidget, // Using additionalInfo for the status chip-like text
      trailing: const CupertinoListTileChevron(),
      onTap: () {
        // TODO: Navigate to specific maintenance request details screen (Cupertino version)
        print('Tapped on Cupertino maintenance request: ${maintenanceRequest.id}');
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Request Details'),
            content: Text('Details for: ${maintenanceRequest.propertyAddress}'),
            actions: [CupertinoDialogAction(isDefaultAction: true, child: const Text('OK'), onPressed: () => Navigator.pop(ctx))],
          ),
        );
      },
    );
  }
}
