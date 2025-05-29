import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/providers/payment_provider.dart';
import 'package:cloudkeja/providers/tenant_model.dart'; // Assuming this path is correct
import 'package:skeletonizer/skeletonizer.dart'; // For skeleton loading
import 'package:cached_network_image/cached_network_image.dart'; // For avatar

class RecentTenantsWidget extends StatelessWidget {
  const RecentTenantsWidget({Key? key}) : super(key: key);

  Widget _buildTenantTile(BuildContext context, TenantModel tenant) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return ListTile(
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: colorScheme.surfaceVariant,
        backgroundImage: (tenant.user?.profile != null && tenant.user!.profile!.isNotEmpty)
            ? CachedNetworkImageProvider(tenant.user!.profile!)
            : null,
        child: (tenant.user?.profile == null || tenant.user!.profile!.isEmpty)
            ? Icon(Icons.person_outline, color: colorScheme.onSurfaceVariant)
            : null,
      ),
      title: Text(tenant.user?.name ?? 'N/A Tenant', style: textTheme.titleSmall),
      subtitle: Text(
        'Property: ${tenant.space?.spaceName ?? 'N/A'}',
        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
      ),
      // trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.outline), // Optional: for navigation
      // onTap: () { /* Navigate to tenant details or chat */ },
    );
  }

  Widget _buildTenantTileSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: const CircleAvatar(radius: 22), // Skeletonizer will color this
      title: Container(height: 14, width: 100, color: Colors.transparent), // Skeletonizer colors
      subtitle: Container(height: 12, width: 150, color: Colors.transparent),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // final textTheme = theme.textTheme; // Not directly used here, but in _buildTenantTile

    return FutureBuilder<List<TenantModel>>(
      future: Provider.of<PaymentProvider>(context, listen: false).fetchTenants(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Skeletonizer(
            enabled: true,
            effect: ShimmerEffect(
              baseColor: colorScheme.surfaceVariant.withOpacity(0.4),
              highlightColor: colorScheme.surfaceVariant.withOpacity(0.8),
            ),
            child: Card( // Match the structure of the loaded content for consistent skeleton
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0), // Padding for list tiles
                child: Column(
                  children: List.generate(3, (index) => _buildTenantTileSkeleton(context)),
                ),
              ),
            )
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error fetching tenants: ${snapshot.error}', style: TextStyle(color: colorScheme.error)),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'No recent tenants found.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
                ),
              ),
            ),
          );
        }

        // Display list of tenants in a Card
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Consistent margin
          // Card properties from theme (elevation, shape, color)
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: snapshot.data!.map((tenant) {
              return Column( // Wrap ListTile with Column to add Divider easily
                children: [
                  _buildTenantTile(context, tenant),
                  if (snapshot.data!.last != tenant) // Don't add divider after the last item
                    Divider(indent: 16, endIndent: 16, height: 1, color: colorScheme.outline.withOpacity(0.3)),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
