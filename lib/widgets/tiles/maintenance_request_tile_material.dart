import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:cloudkeja/models/maintenance_request_model.dart'; // Import the model

class MaintenanceRequestTileMaterial extends StatelessWidget { // Renamed class
  final MaintenanceRequestModel maintenanceRequest;

  const MaintenanceRequestTileMaterial({ // Renamed constructor
    Key? key,
    required this.maintenanceRequest,
  }) : super(key: key);

  // Helper methods for status color and icon (can be moved to a shared utility if used elsewhere)
  Color _getStatusColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status.toLowerCase()) {
      case 'submitted':
        return Colors.blue.shade600;
      case 'inprogress':
      case 'in progress':
        return Colors.orange.shade700;
      case 'completed':
        return Colors.green.shade700;
      case 'cancelled':
        return colorScheme.error;
      default:
        return colorScheme.onSurface.withOpacity(0.7);
    }
  }

  Color _getChipTextColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
     // Determine if chip background is light or dark for optimal contrast
    final chipBgColor = _getStatusColor(context, status);
    final bool isDarkBg = ThemeData.estimateBrightnessForColor(chipBgColor) == Brightness.dark;

    switch (status.toLowerCase()) {
      case 'submitted':
      case 'inprogress':
      case 'in progress':
      case 'completed':
         return isDarkBg ? Colors.white : Colors.black.withOpacity(0.8); // Good contrast on colored chips
      case 'cancelled':
        return colorScheme.onError; // Text color on error background
      default:
        return colorScheme.onSurface;
    }
  }

  IconData _getStatusIcon(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Icons.file_present_rounded;
      case 'inprogress':
      case 'in progress':
        return Icons.construction_rounded;
      case 'completed':
        return Icons.check_circle_outline_rounded;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final statusColor = _getStatusColor(context, maintenanceRequest.status);
    final statusIcon = _getStatusIcon(context, maintenanceRequest.status);
    final chipTextColor = _getChipTextColor(context, maintenanceRequest.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      // Card properties from theme
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.15),
          child: Icon(statusIcon, color: statusColor, size: 24),
        ),
        title: Text(
          maintenanceRequest.propertyAddress,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              maintenanceRequest.description,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.8)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              'Submitted: ${DateFormat.yMMMd().format(maintenanceRequest.dateSubmitted)}',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(maintenanceRequest.status, style: textTheme.labelSmall?.copyWith(color: chipTextColor)),
          backgroundColor: statusColor.withOpacity(0.15),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          visualDensity: VisualDensity.compact, // Make chip smaller
        ),
        isThreeLine: true, // Adjust based on content, true allows more space for subtitle
        onTap: () {
          // TODO: Navigate to specific maintenance request details screen
          // Get.to(() => MaintenanceRequestDetailsScreen(requestId: maintenanceRequest.id));
          print('Tapped on maintenance request: ${maintenanceRequest.id}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tapped on request for: ${maintenanceRequest.propertyAddress}')),
          );
        },
      ),
    );
  }
}
