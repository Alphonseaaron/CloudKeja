import 'package:flutter/material.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:get/route_manager.dart';
import 'package:cloudkeja/screens/service_provider/view_service_provider_profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SPListTileMaterial extends StatelessWidget { // Renamed widget
  final UserModel serviceProvider;
  final bool isSkeleton; // To allow direct use in Skeletonizer if needed

  const SPListTileMaterial({ // Renamed constructor
    Key? key,
    required this.serviceProvider,
    this.isSkeleton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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
      child: InkWell(
        onTap: isSkeleton ? null : () {
          if (serviceProvider.userId != null) {
            Get.to(() => ViewServiceProviderProfileScreen(serviceProviderId: serviceProvider.userId!));
          } else {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Service provider ID is missing.', style: TextStyle(color: colorScheme.onError)), backgroundColor: colorScheme.error),
            );
          }
        },
        borderRadius: (theme.cardTheme.shape as RoundedRectangleBorder?)?.borderRadius ?? BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
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
                    ] else if (isSkeleton) ...[
                       const SizedBox(height: 4),
                       Container(height: 12, width: 100, color: Colors.transparent), // Placeholder for location
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
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

// Skeleton widget for SPListTileMaterial
class SPListTileMaterialSkeleton extends StatelessWidget { // Renamed skeleton
  const SPListTileMaterialSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SPListTileMaterial( // Uses SPListTileMaterial
      serviceProvider: UserModel(
        userId: 'skeleton',
        name: 'Service Provider Name',
        profile: '',
        serviceProviderTypes: ['Primary Service Type'],
        spCounty: 'Location County',
        spCountry: 'Country',
        isVerified: true
      ),
      isSkeleton: true,
    );
  }
}
