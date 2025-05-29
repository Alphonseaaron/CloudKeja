import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/screens/landlord/landlord_profile.dart';
import 'package:skeletonizer/skeletonizer.dart'; // For loading state

class OwnerTile extends StatelessWidget {
  const OwnerTile({Key? key, this.userId}) : super(key: key);
  final String? userId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (userId == null || userId!.isEmpty) {
      // Optionally return a placeholder or an error message if userId is crucial and missing
      return const SizedBox.shrink(); 
    }

    return FutureBuilder<UserModel>(
      future: Provider.of<AuthProvider>(context, listen: false).getOwnerDetails(userId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Skeleton for OwnerTile
          return Skeletonizer(
            enabled: true,
            effect: ShimmerEffect(
              baseColor: colorScheme.surfaceVariant.withOpacity(0.4),
              highlightColor: colorScheme.surfaceVariant.withOpacity(0.8),
            ),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ListTile(
                leading: const CircleAvatar(radius: 25, backgroundColor: Colors.transparent), // Placeholder for avatar
                title: Container(height: 16, width: 120, color: Colors.transparent), // Placeholder for name
                subtitle: Container(height: 12, width: 150, color: Colors.transparent), // Placeholder for email
                trailing: Icon(Icons.arrow_forward_ios, size: 18, color: colorScheme.outline),
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          // Optionally, show an error state or a subtle 'Could not load owner' message
          return Card(
             margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(title: Text('Owner details unavailable.', style: textTheme.bodyMedium)),
          );
        }

        final user = snapshot.data!;
        return Card(
          // Uses CardTheme from AppTheme (elevation, shape, color)
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Consistent margin
          clipBehavior: Clip.antiAlias, // Ensures content respects card shape
          child: ListTile(
            leading: CircleAvatar(
              radius: 25, // Standard size
              backgroundImage: (user.profile != null && user.profile!.isNotEmpty)
                  ? NetworkImage(user.profile!)
                  : null, // Handles null or empty profile URL
              backgroundColor: colorScheme.surfaceVariant, // Fallback background
              child: (user.profile == null || user.profile!.isEmpty)
                  ? Icon(Icons.person_outline, color: colorScheme.onSurfaceVariant) // Fallback icon
                  : null,
            ),
            onTap: () {
              Get.to(() => LandlordProfile(user: user));
            },
            title: Text(
              user.name ?? 'Owner Name', // Handle null name
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              user.email ?? 'owner@example.com', // Handle null email
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: colorScheme.onSurface.withOpacity(0.6), // Themed icon color
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Standard ListTile padding
          ),
        );
      },
    );
  }
}
