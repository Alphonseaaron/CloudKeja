import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:cloudkeja/helpers/loading_effect.dart'; // Will be replaced
import 'package:cloudkeja/providers/payment_provider.dart';
import 'package:cloudkeja/providers/tenant_model.dart'; // Assuming TenantModel is in this path
import 'package:cloudkeja/models/user_model.dart'; // Assuming UserModel is in this path for TenantModel.user
import 'package:cloudkeja/models/space_model.dart'; // Assuming SpaceModel is in this path for TenantModel.space

class AllTenantsScreenMaterial extends StatelessWidget {
  const AllTenantsScreenMaterial({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    // Assuming AppBarTheme handles titleTextStyle globally, or use:
    // final appBarTitleStyle = theme.appBarTheme.titleTextStyle ?? textTheme.titleLarge;

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Tenants', style: theme.appBarTheme.titleTextStyle ?? textTheme.titleLarge), // Themed title
      ),
      body: FutureBuilder<List<TenantModel>>(
          future: Provider.of<PaymentProvider>(context, listen: false)
              .fetchTenants(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator()); // Replaced LoadingEffect
            }
            if (snapshot.hasError) { // Added error handling
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error fetching tenants: ${snapshot.error}', style: textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error)),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) { // Added empty state
              return Center(
                child: Text(
                  'No tenants found.',
                  style: textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              );
            }

            return ListView.separated( // Using ListView.separated for clarity
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) => Divider(indent: 16, endIndent: 16, color: theme.dividerColor),
                itemBuilder: (context, index) {
                  final tenant = snapshot.data![index];
                  return ListTile(
                    title: Text(tenant.user?.name ?? 'N/A Tenant', style: textTheme.titleMedium), // Themed text
                    onTap: () {
                      _userDetailsDialogMaterial(context, tenant, theme); // Pass theme
                    },
                    subtitle: Text(tenant.space?.spaceName ?? 'N/A Space', style: textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)), // Themed text
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.secondaryContainer, // Themed background
                      backgroundImage: tenant.user?.profile != null && tenant.user!.profile!.isNotEmpty
                          ? NetworkImage(tenant.user!.profile!)
                          : null,
                      child: (tenant.user?.profile == null || tenant.user!.profile!.isEmpty)
                          ? Icon(Icons.person, color: theme.colorScheme.onSecondaryContainer) // Placeholder icon
                          : null,
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  );
                },
            );
          }),
    );
  }

  // Extracted dialog to a private method within the Material screen class
  void _userDetailsDialogMaterial(BuildContext context, TenantModel tenant, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    showDialog(
        context: context,
        builder: (context) => Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), // Themed shape
              child: SingleChildScrollView( // Ensure content is scrollable if it overflows
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Important for Dialog content
                    crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
                    children: [
                      Text(
                        'Tenant Details',
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), // Themed title
                      ),
                      const SizedBox(height: 16), // Adjusted spacing
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: colorScheme.secondaryContainer, // Themed background
                            backgroundImage: tenant.user?.profile != null && tenant.user!.profile!.isNotEmpty
                                ? NetworkImage(tenant.user!.profile!)
                                : null,
                            radius: 28, // Slightly larger avatar
                             child: (tenant.user?.profile == null || tenant.user!.profile!.isEmpty)
                                ? Icon(Icons.person, size: 28, color: colorScheme.onSecondaryContainer)
                                : null,
                          ),
                          const SizedBox(width: 16), // Adjusted spacing
                          Expanded( // Allow text to wrap if too long
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tenant.user?.name ?? 'N/A Tenant',
                                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600), // Themed text
                                ),
                                const SizedBox(height: 4),
                                Text(tenant.user?.phone ?? 'No phone', style: textTheme.bodyMedium), // Themed text
                                const SizedBox(height: 2),
                                Text(tenant.user?.email ?? 'No email', style: textTheme.bodyMedium), // Themed text
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Align( // Align button to the right
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('DISMISS'), // Standard dialog action text
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ));
  }
}
