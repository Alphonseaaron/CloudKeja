import 'package:flutter/cupertino.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:get/route_manager.dart';
import 'package:cloudkeja/screens/service_provider/view_service_provider_profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SPListTileCupertino extends StatelessWidget {
  final UserModel serviceProvider;
  final bool isSkeleton;

  const SPListTileCupertino({
    Key? key,
    required this.serviceProvider,
    this.isSkeleton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);

    String primaryServiceType = "Service Provider";
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

    return GestureDetector(
      onTap: isSkeleton ? null : () {
        if (serviceProvider.userId != null) {
          Get.to(() => ViewServiceProviderProfileScreen(serviceProviderId: serviceProvider.userId!));
        } else {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Error'),
              content: const Text('Service provider ID is missing.'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        }
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
          // No explicit card-like border radius for standard Cupertino list items,
          // but can be added if a carded look is desired.
          // borderRadius: BorderRadius.circular(8.0) 
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56, // Standard CupertinoListTile leading size can be ~40-44, this is larger like original
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSkeleton ? CupertinoColors.systemGrey5.resolveFrom(context) : CupertinoColors.lightBackgroundGray.resolveFrom(context),
              ),
              child: (serviceProvider.profile != null && serviceProvider.profile!.isNotEmpty && !isSkeleton)
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: serviceProvider.profile!,
                        placeholder: (context, url) => const CupertinoActivityIndicator(),
                        errorWidget: (context, url, error) => Icon(CupertinoIcons.person_solid, size: 28, color: CupertinoColors.secondaryLabel.resolveFrom(context)),
                        fit: BoxFit.cover,
                      ),
                    )
                  : (isSkeleton ? null : Icon(CupertinoIcons.person_solid, size: 28, color: CupertinoColors.secondaryLabel.resolveFrom(context))),
            ),
            const SizedBox(width: 12),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSkeleton ? "Service Provider Name" : (serviceProvider.name ?? 'N/A'),
                    style: cupertinoTheme.textTheme.textStyle.copyWith(fontWeight: FontWeight.w600, fontSize: 17),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSkeleton ? "Primary Service Type" : primaryServiceType,
                    style: cupertinoTheme.textTheme.textStyle.copyWith(color: cupertinoTheme.primaryColor, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!isSkeleton && location.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      location,
                      style: cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(fontSize: 13, color: CupertinoColors.secondaryLabel.resolveFrom(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ] else if (isSkeleton) ...[
                     const SizedBox(height: 4),
                     Container(
                        height: 12, 
                        width: 100, 
                        color: CupertinoColors.systemGrey5.resolveFrom(context)
                      ), // Placeholder for location
                  ]
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Verified Icon
            if (isSkeleton || (serviceProvider.isVerified == true))
              Icon(
                CupertinoIcons.checkmark_seal_fill, // Changed to Cupertino checkmark
                color: isSkeleton ? CupertinoColors.systemGrey4.resolveFrom(context) : cupertinoTheme.primaryColor,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

// Skeleton widget for SPListTileCupertino
class SPListTileCupertinoSkeleton extends StatelessWidget {
  const SPListTileCupertinoSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SPListTileCupertino(
      serviceProvider: UserModel(
        userId: 'skeleton',
        name: 'Service Provider Name',
        profile: '',
        serviceProviderTypes: ['Primary Service Type'],
        spCounty: 'Location County',
        spCountry: 'Country',
        isVerified: true,
      ),
      isSkeleton: true,
    );
  }
}
