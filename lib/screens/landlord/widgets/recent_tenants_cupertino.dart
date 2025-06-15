import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/providers/payment_provider.dart'; // Assuming this fetches tenants
import 'package:cloudkeja/providers/tenant_model.dart';   // For TenantModel
import 'package:cloudkeja/models/user_model.dart';      // For UserModel details
import 'package:cached_network_image/cached_network_image.dart'; // For network images

class RecentTenantsCupertinoWidget extends StatelessWidget {
  const RecentTenantsCupertinoWidget({Key? key}) : super(key: key);

  Widget _buildCupertinoTenantTile(BuildContext context, TenantModel tenant) {
    final cupertinoTheme = CupertinoTheme.of(context);
    return CupertinoListTile.notched(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: CupertinoColors.systemGrey5.resolveFrom(context),
        backgroundImage: (tenant.user?.profile != null && tenant.user!.profile!.isNotEmpty)
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
        'Property: ${tenant.space?.spaceName ?? 'N/A'}',
        style: cupertinoTheme.textTheme.tabLabelTextStyle,
      ),
      // trailing: const CupertinoListTileChevron(), // Optional: if navigates to details
      // onTap: () { /* Handle tap if needed */ },
    );
  }

  Widget _buildCupertinoTenantTileSkeleton(BuildContext context) {
    final placeholderColor = CupertinoColors.systemGrey4.resolveFrom(context);
    return CupertinoListTile.notched(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      leading: CircleAvatar(radius: 22, backgroundColor: placeholderColor),
      title: Container(height: 14, width: 120, decoration: BoxDecoration(color: placeholderColor, borderRadius: BorderRadius.circular(4))),
      subtitle: Container(height: 12, width: 180, decoration: BoxDecoration(color: placeholderColor, borderRadius: BorderRadius.circular(4))),
    );
  }


  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);

    return FutureBuilder<List<TenantModel>>(
      future: Provider.of<PaymentProvider>(context, listen: false).fetchTenants(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Shimmer for Cupertino: Use simple list tiles with placeholders
          return CupertinoListSection.insetGrouped(
            header: Padding( // Optional header for the section
              padding: const EdgeInsets.only(left: 16.0, top:16.0, bottom: 8.0),
              child: Text('Recent Tenants', style: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(fontSize: 18)),
            ),
            backgroundColor: CupertinoColors.transparent, // Transparent to show page background
            children: List.generate(3, (index) => _buildCupertinoTenantTileSkeleton(context)),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: CupertinoColors.destructiveRed.resolveFrom(context)))),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return CupertinoListSection.insetGrouped(
             header: Padding(
              padding: const EdgeInsets.only(left: 16.0, top:16.0, bottom: 8.0),
              child: Text('Recent Tenants', style: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(fontSize: 18)),
            ),
            backgroundColor: CupertinoColors.transparent,
            children: [
              Container(
                padding: const EdgeInsets.all(24.0),
                alignment: Alignment.center,
                child: Text(
                  'No recent tenants found.',
                  style: cupertinoTheme.textTheme.tabLabelTextStyle,
                ),
              )
            ],
          );
        }

        final tenants = snapshot.data!;
        return CupertinoListSection.insetGrouped(
          header: Padding(
            padding: const EdgeInsets.only(left: 16.0, top:16.0, bottom: 8.0),
            child: Text('Recent Tenants', style: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(fontSize: 18)),
          ),
          backgroundColor: CupertinoColors.transparent, // To see page background, or theme.scaffoldBackgroundColor
          // footer: Text("Showing up to ${tenants.length} tenants."), // Optional footer
          children: tenants.map((tenant) => _buildCupertinoTenantTile(context, tenant)).toList(),
          // If using ListView.builder for many items:
          // itemCount: tenants.length,
          // itemBuilder: (context, index) => _buildCupertinoTenantTile(context, tenants[index]),
        );
      },
    );
  }
}
