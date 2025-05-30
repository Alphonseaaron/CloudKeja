import 'package:flutter/material.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:get/route_manager.dart';
import 'package:cloudkeja/screens/service_provider/view_service_provider_profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SPListTile extends StatelessWidget {
  final UserModel serviceProvider;
  final bool isSkeleton; // To allow direct use in Skeletonizer if needed

  const SPListTile({
    Key? key,
    required this.serviceProvider,
    this.isSkeleton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Skeletonizer will handle the visual appearance if isSkeleton is true
    // and this widget is wrapped in a Skeletonizer widget.
    // If not wrapped, this flag allows some manual placeholder visuals if desired.

    String primaryServiceType = "Service Provider"; // Default
    if (serviceProvider.serviceProviderTypes != null && serviceProvider.serviceProviderTypes!.isNotEmpty) {
      primaryServiceType = serviceProvider.serviceProviderTypes!.first;
    }

    String location = "";
    if (serviceProvider.spCounty != null && serviceProvider.spCounty!.isNotEmpty) {
      location += serviceProvider.spCounty!;
      if (serviceProvider.spCountry != null && serviceProvider.spCountry!.isNotEmpty) {
        location += ", ${serviceProvider.spCountry}";
      }
    } else if (serviceProvider.spCountry != null && serviceProvider.spCountry!.isNotEmpty) {
      location = serviceProvider.spCountry!;
    }


    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      // Card properties from theme
      child: InkWell(
        onTap: isSkeleton ? null : () {
          if (serviceProvider.userId != null) {
            Get.to(() => ViewServiceProviderProfileScreen(serviceProviderId: serviceProvider.userId!));
          } else {
            // Handle case where userId is null, though unlikely for non-skeleton
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Service provider ID is missing.', style: TextStyle(color: colorScheme.onError)), backgroundColor: colorScheme.error),
            );
          }
        },
        borderRadius: (theme.cardTheme.shape as RoundedRectangleBorder?)?.borderRadius ?? BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Inner padding for tile content
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: isSkeleton ? Colors.transparent : colorScheme.surfaceVariant,
                backgroundImage: (serviceProvider.profile != null && serviceProvider.profile!.isNotEmpty && !isSkeleton)
                    ? CachedNetworkImageProvider(serviceProvider.profile!)
                    : null,
                child: (isSkeleton || serviceProvider.profile == null || serviceProvider.profile!.isEmpty)
                    ? (isSkeleton ? null : Icon(Icons.person_outline_rounded, size: 28, color: colorScheme.onSurfaceVariant))
                    : null,
              ),
              const SizedBox(width: 12),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSkeleton ? "Service Provider Name" : (serviceProvider.name ?? 'N/A'),
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSkeleton ? "Primary Service Type" : primaryServiceType,
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                     if (!isSkeleton && location.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        location,
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else if (isSkeleton) ...[ // Placeholder for location
                       const SizedBox(height: 4),
                       Container(height: 12, width: 100, color: Colors.transparent),
                    ]
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Verified Icon (Trailing)
              if (isSkeleton || (serviceProvider.isVerified == true))
                Icon(
                  Icons.verified_rounded,
                  color: isSkeleton ? Colors.transparent : colorScheme.primary,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}


// Skeleton widget for SPListTile
class SPListTileSkeleton extends StatelessWidget {
  const SPListTileSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This widget relies on being wrapped by Skeletonizer for the shimmer effect
    // and placeholder painting. It just provides the layout structure.
    return const SPListTile(
      serviceProvider: UserModel( // Pass dummy/empty data
        userId: 'skeleton',
        name: 'Service Provider Name', // Placeholder text for sizing
        profile: '', // Empty profile
        serviceProviderTypes: ['Primary Service Type'],
        spCounty: 'Location County',
        spCountry: 'Country',
        isVerified: true // To show icon placeholder if it's part of layout
      ),
      isSkeleton: true, // Indicate it's for skeleton rendering
    );
  }
}
