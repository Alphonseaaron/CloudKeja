import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/providers/payment_provider.dart';
import 'package:cloudkeja/providers/tenant_model.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloudkeja/models/user_model.dart'; // For TenantModel.user
import 'package:cloudkeja/models/space_model.dart'; // For TenantModel.space


class RecentTenantsMaterialWidget extends StatelessWidget {
  const RecentTenantsMaterialWidget({Key? key}) : super(key: key);

  Widget _buildMaterialTenantTile(BuildContext context, TenantModel tenant) {
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
      // trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.outline),
      // onTap: () { /* Navigate to tenant details or chat */ },
    );
  }

  Widget _buildMaterialTenantTileSkeleton(BuildContext context) {
    // final theme = Theme.of(context); // Not strictly needed if Skeletonizer handles colors
    return ListTile(
      leading: const CircleAvatar(radius: 22),
      title: Container(height: 14, width: 100, color: Colors.transparent),
      subtitle: Container(height: 12, width: 150, color: Colors.transparent),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: List.generate(3, (index) => _buildMaterialTenantTileSkeleton(context)),
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

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: snapshot.data!.map((tenant) {
              return Column(
                children: [
                  _buildMaterialTenantTile(context, tenant),
                  if (snapshot.data!.last != tenant)
                    Divider(indent: 16 + 44 + 12.0, endIndent: 16, height: 1, color: colorScheme.outline.withOpacity(0.3)), // Align divider with title
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
