import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/providers/payment_provider.dart'; // Assuming this fetches tenants
import 'package:cloudkeja/providers/tenant_model.dart';   // For TenantModel
import 'package:cloudkeja/models/user_model.dart';      // For UserModel details
import 'package:cached_network_image/cached_network_image.dart'; // For network images

class AllTenantsScreenCupertino extends StatelessWidget {
  const AllTenantsScreenCupertino({Key? key}) : super(key: key);

  void _showCupertinoUserDetailsDialog(BuildContext context, TenantModel tenant) {
    final cupertinoTheme = CupertinoTheme.of(context);
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text("Tenant Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            CircleAvatar(
              radius: 30,
              backgroundColor: CupertinoColors.systemGrey5.resolveFrom(context),
              backgroundImage: tenant.user?.profile != null && tenant.user!.profile!.isNotEmpty
                  ? CachedNetworkImageProvider(tenant.user!.profile!)
                  : null,
              child: (tenant.user?.profile == null || tenant.user!.profile!.isEmpty)
                  ? Icon(CupertinoIcons.person_fill, size: 30, color: CupertinoColors.systemGrey.resolveFrom(context))
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              tenant.user?.name ?? 'N/A Tenant',
              style: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(fontSize: 17),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            if (tenant.user?.phone != null && tenant.user!.phone!.isNotEmpty)
              Text(
                tenant.user!.phone!,
                style: cupertinoTheme.textTheme.textStyle.copyWith(color: CupertinoColors.secondaryLabel.resolveFrom(context)),
                textAlign: TextAlign.center,
              ),
            if (tenant.user?.email != null && tenant.user!.email!.isNotEmpty)
              Text(
                tenant.user!.email!,
                style: cupertinoTheme.textTheme.textStyle.copyWith(color: CupertinoColors.secondaryLabel.resolveFrom(context)),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 8),
             Text(
              "Property: ${tenant.space?.spaceName ?? 'N/A'}",
              style: cupertinoTheme.textTheme.tabLabelTextStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("Dismiss"),
            isDefaultAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Your Tenants'),
      ),
      child: FutureBuilder<List<TenantModel>>(
        future: Provider.of<PaymentProvider>(context, listen: false).fetchTenants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator(radius: 15));
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: ${snapshot.error}', style: TextStyle(color: CupertinoColors.destructiveRed.resolveFrom(context))),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No tenants found.',
                style: cupertinoTheme.textTheme.textStyle.copyWith(color: CupertinoColors.secondaryLabel.resolveFrom(context)),
              ),
            );
          }

          final tenants = snapshot.data!;
          return ListView.separated(
            itemCount: tenants.length,
            separatorBuilder: (context, index) => const Divider(indent: 16 + 44 + 12, height: 0.5), // Align divider with title
            itemBuilder: (context, index) {
              final tenant = tenants[index];
              return CupertinoListTile.notched( // Using notched for a slightly more distinct look
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                leading: CircleAvatar(
                  radius: 22,
                  backgroundColor: CupertinoColors.systemGrey5.resolveFrom(context),
                  backgroundImage: tenant.user?.profile != null && tenant.user!.profile!.isNotEmpty
                      ? CachedNetworkImageProvider(tenant.user!.profile!)
                      : null,
                  child: (tenant.user?.profile == null || tenant.user!.profile!.isEmpty)
                      ? Icon(CupertinoIcons.person_fill, size: 22, color: CupertinoColors.systemGrey.resolveFrom(context))
                      : null,
                ),
                title: Text(
                  tenant.user?.name ?? 'N/A Tenant',
                  style: cupertinoTheme.textTheme.textStyle,
                ),
                subtitle: Text(
                  tenant.space?.spaceName ?? 'N/A Space',
                  style: cupertinoTheme.textTheme.tabLabelTextStyle,
                ),
                trailing: const CupertinoListTileChevron(),
                onTap: () => _showCupertinoUserDetailsDialog(context, tenant),
              );
            },
          );
        },
      ),
    );
  }
}
