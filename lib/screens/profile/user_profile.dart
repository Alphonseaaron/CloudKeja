import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
// import 'package:google_fonts/google_fonts.dart'; // Replaced by textTheme
import 'package:provider/provider.dart';
// import 'package:cloudkeja/helpers/constants.dart'; // Replaced by theme
// import 'package:cloudkeja/helpers/loading_effect.dart'; // Replaced by Skeletonizer for main future
import 'package:cloudkeja/helpers/mpesa_helper.dart'; // For UserPaymentDialog
import 'package:cloudkeja/helpers/my_dropdown.dart'; // Assuming this is a custom dropdown, for UserPaymentDialog
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/tenancy_provider.dart';
import 'package:cloudkeja/screens/auth/login_page.dart'; // For logout navigation
import 'package:cloudkeja/screens/profile/tenant_details_screen.dart';
import 'package:cloudkeja/screens/user/user_payment_history_screen.dart';
import 'package:cloudkeja/screens/user/user_maintenance_history_screen.dart'; // Import new screen
import 'package:sliver_header_delegate/sliver_header_delegate.dart';
import 'package:skeletonizer/skeletonizer.dart'; // For skeleton loading
import 'package:cached_network_image/cached_network_image.dart'; // For profile image

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  // Helper method for creating themed ListTiles, similar to SettingsScreen
  Widget _buildListTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    Color iconColor = isDestructive ? colorScheme.error : colorScheme.primary;
    Color iconBackgroundColor = isDestructive ? colorScheme.errorContainer : colorScheme.primaryContainer;
    Color textColor = isDestructive ? colorScheme.error : colorScheme.onSurface;

    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: iconBackgroundColor,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(title, style: textTheme.bodyLarge?.copyWith(color: textColor)),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurface.withOpacity(0.5)),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(height: 1, color: theme.dividerColor),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: FutureBuilder<UserModel>(
        future: Provider.of<AuthProvider>(context, listen: false).getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData && snapshot.connectionState != ConnectionState.done) {
            return Skeletonizer( // Full page skeleton
              enabled: true,
              effect: ShimmerEffect(
                baseColor: colorScheme.surfaceVariant.withOpacity(0.4),
                highlightColor: colorScheme.surfaceVariant.withOpacity(0.8),
              ),
              child: CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: FlexibleHeaderDelegate(
                      backgroundColor: colorScheme.primary,
                      expandedHeight: size.height * 0.3,
                      background: MutableBackground(
                        expandedWidget: Container(color: colorScheme.surfaceVariant),
                        collapsedColor: colorScheme.primary,
                      ),
                      statusBarHeight: MediaQuery.of(context).padding.top,
                      children: [
                        FlexibleTextItem(
                          text: 'Loading Profile...',
                          expandedStyle: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary),
                          collapsedStyle: textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary),
                          expandedAlignment: Alignment.bottomCenter,
                          collapsedAlignment: Alignment.center,
                          expandedPadding: const EdgeInsets.all(16),
                        ),
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      _RecentUserSpaceSkeleton(theme: theme),
                      _UserProfileDetailsSkeleton(theme: theme),
                      // Skeleton for list tiles
                      Padding(padding: const EdgeInsets.all(16), child: Column(children: List.generate(4, (_) => _buildListTileSkeleton(theme)))), // Increased to 4 for new tile
                    ]),
                  )
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading profile: ${snapshot.error}', style: textTheme.bodyLarge?.copyWith(color: colorScheme.error)));
          }

          final user = snapshot.data;

          if (user == null) {
             return Center(child: Text('User data not available. Please try again.', style: textTheme.bodyLarge));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Provider.of<AuthProvider>(context, listen: false).getCurrentUser(forceRefresh: true);
              await Provider.of<TenancyProvider>(context, listen: false).getUserTenancy(user, forceRefresh: true);
            },
            child: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: FlexibleHeaderDelegate(
                    backgroundColor: colorScheme.surface,
                    expandedHeight: size.height * 0.3,
                    background: MutableBackground(
                      expandedWidget: (user.profile != null && user.profile!.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: user.profile!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: colorScheme.surfaceVariant),
                              errorWidget: (context, url, error) => Container(color: colorScheme.surfaceVariant, child: Icon(Icons.broken_image_outlined, size: 60, color: colorScheme.onSurfaceVariant)),
                            )
                          : Container(color: colorScheme.surfaceVariant, child: Icon(Icons.person_outline_rounded, size: 100, color: colorScheme.onSurfaceVariant)),
                      collapsedColor: colorScheme.primary,
                    ),
                    statusBarHeight: MediaQuery.of(context).padding.top,
                    children: [
                      FlexibleTextItem(
                        text: user.name ?? 'User Profile',
                        expandedStyle: textTheme.headlineSmall?.copyWith(color: colorScheme.onPrimary, shadows: [Shadow(blurRadius: 2, color: Colors.black.withOpacity(0.5))]),
                        collapsedStyle: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary),
                        expandedAlignment: Alignment.bottomLeft,
                        collapsedAlignment: Alignment.centerLeft,
                        expandedPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        collapsedPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    // General User Actions section
                    _buildListTile(context, 'Payment History', Icons.receipt_long_outlined, () {
                      Get.to(() => const UserPaymentHistoryScreen());
                    }),
                    _buildListTile(context, 'Maintenance History', Icons.build_circle_outlined, () { // New Tile Added
                      Get.to(() => const UserMaintenanceHistoryScreen());
                    }),

                    // Tenancy Details (if user has tenancy)
                    RecentUserSpace(user: user),

                    // About Me section
                    UserProfileDetails(user: user),

                    // Logout Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:16.0, vertical: 24.0),
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.logout_outlined, color: colorScheme.onErrorContainer),
                        label: Text('Logout', style: textTheme.labelLarge?.copyWith(color: colorScheme.onErrorContainer)),
                        onPressed: () async {
                          await Provider.of<AuthProvider>(context, listen: false).signOut();
                          Get.offAll(() => const LoginPage());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.errorContainer,
                          minimumSize: const Size(double.infinity, 48), // Full width button
                        ),
                      ),
                    ),
                     const SizedBox(height: 20),
                  ]),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- RecentUserSpace Widget (already themed from previous step) ---
class RecentUserSpace extends StatelessWidget {
  const RecentUserSpace({Key? key, required this.user}) : super(key: key);
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return FutureBuilder<List<SpaceModel>>(
      future: Provider.of<TenancyProvider>(context, listen: false).getUserTenancy(user),
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _RecentUserSpaceSkeleton(theme: theme);
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final space = snapshot.data!.first;
        return Card(
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Tenancy', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () => Get.to(() => TenantDetailsScreen(space: space)),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: colorScheme.surfaceVariant,
                    backgroundImage: (space.images != null && space.images!.isNotEmpty) ? CachedNetworkImageProvider(space.images!.first) : null,
                    child: (space.images == null || space.images!.isEmpty) ? Icon(Icons.home_work_outlined, color: colorScheme.onSurfaceVariant) : null,
                  ),
                  title: Text(space.spaceName ?? 'N/A', style: textTheme.titleMedium),
                  subtitle: Text(space.address ?? 'N/A', style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.7))),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurface.withOpacity(0.6)),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Due Amount:', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7))),
                    Text('KES ${space.price?.toStringAsFixed(0) ?? '0'}', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => showUserPaymentDialog(context, space),
                        child: const Text('Make Payment'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (space.needsAttention == true)
                      Chip(
                        label: Text('Needs Attention', style: textTheme.labelSmall?.copyWith(color: colorScheme.onErrorContainer)),
                        backgroundColor: colorScheme.errorContainer,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                  ],
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}

// --- UserProfileDetails Widget (already themed) ---
class UserProfileDetails extends StatelessWidget {
  const UserProfileDetails({Key? key, required this.user}) : super(key: key);
  final UserModel user;

  Widget _detailWidget(BuildContext context, IconData icon, String title, String? value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 22, color: colorScheme.primary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6))),
              const SizedBox(height: 2),
              Text(value ?? 'Not specified', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About Me', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _detailWidget(context, Icons.person_outline_rounded, "Full Name", user.name),
            Divider(color: theme.colorScheme.outline.withOpacity(0.5), height: 20),
            _detailWidget(context, Icons.email_outlined, "Email", user.email),
            Divider(color: theme.colorScheme.outline.withOpacity(0.5), height: 20),
            _detailWidget(context, Icons.phone_outlined, "Phone", user.phone),
            if (user.idnumber != null && user.idnumber!.isNotEmpty) ...[
              Divider(color: theme.colorScheme.outline.withOpacity(0.5), height: 20),
              _detailWidget(context, Icons.badge_outlined, "ID Number", user.idnumber),
            ]
          ],
        ),
      ),
    );
  }
}

// --- UserPaymentDialog Widget (already themed) ---
void showUserPaymentDialog(BuildContext context, SpaceModel space) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      child: UserPaymentDialog(space: space),
    ),
  );
}

class UserPaymentDialog extends StatefulWidget {
  const UserPaymentDialog({Key? key, required this.space}) : super(key: key);
  final SpaceModel space;

  @override
  State<UserPaymentDialog> createState() => _UserPaymentDialogState();
}

class _UserPaymentDialogState extends State<UserPaymentDialog> {
  String? _selectedPaymentOption;
  String? _selectedPaymentMethod;
  bool _isProcessingPayment = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Make Payment', style: textTheme.titleLarge),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                )
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: colorScheme.outline.withOpacity(0.5)),
            const SizedBox(height: 16),

            Text('Payment For', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            MyDropDown(
              selectedOption: (val) => setState(() => _selectedPaymentOption = val),
              options: const ['Total Due Amount', 'Custom Amount'],
              hintText: 'Amount to pay',
            ),
            const SizedBox(height: 16),

            Text('Payment Using', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            MyDropDown(
              selectedOption: (val) => setState(() => _selectedPaymentMethod = val),
              options: const ['Mpesa'],
              hintText: 'Select payment method',
            ),
            const SizedBox(height: 20),

            _buildSummaryRow(context, 'Amount Due:', 'KES ${widget.space.price?.toStringAsFixed(0) ?? '0'}'),
            const SizedBox(height: 8),

            Divider(color: colorScheme.outline.withOpacity(0.5), height: 20),
            _buildSummaryRow(context, 'Total to Pay:', 'KES ${widget.space.price?.toStringAsFixed(0) ?? '0'}', isTotal: true),
            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _isProcessingPayment ? null : () async {
                  if (user?.phone == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User phone number not available.', style: TextStyle(color: colorScheme.onError)), backgroundColor: colorScheme.error,));
                    return;
                  }
                  setState(() => _isProcessingPayment = true);
                  try {
                    await mpesaPayment(
                      amount: widget.space.price!.toDouble(),
                      phone: user!.phone!,
                    );
                    Navigator.of(context).pop(true);
                  } catch (e) {
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed: $e', style: TextStyle(color: colorScheme.onError)), backgroundColor: colorScheme.error,));
                  } finally {
                    if (mounted) {
                      setState(() => _isProcessingPayment = false);
                    }
                  }
                },
                child: _isProcessingPayment
                    ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: colorScheme.onPrimary))
                    : const Text('Confirm & Pay'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: isTotal ? textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold) : textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
        Text(value, style: isTotal ? textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold) : textTheme.bodyMedium),
      ],
    );
  }
}

// --- Skeleton Widgets for Profile Page (already themed) ---
class _RecentUserSpaceSkeleton extends StatelessWidget {
  final ThemeData theme;
  const _RecentUserSpaceSkeleton({Key? key, required this.theme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 20, width: 150, color: Colors.transparent),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(radius: 25),
              title: Container(height: 16, width: 120, color: Colors.transparent),
              subtitle: Container(height: 12, width: 150, color: Colors.transparent),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.outline.withOpacity(0.5)),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(height: 14, width: 100, color: Colors.transparent),
                Container(height: 14, width: 80, color: Colors.transparent),
              ],
            ),
            const SizedBox(height: 16),
            Row(children: [Expanded(child: Container(height: 40, color: Colors.transparent))]),
          ],
        ),
      ),
    );
  }
}

class _UserProfileDetailsSkeleton extends StatelessWidget {
  final ThemeData theme;
  const _UserProfileDetailsSkeleton({Key? key, required this.theme}) : super(key: key);

  Widget _detailWidgetSkeleton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(children: [
        const CircleAvatar(radius: 11, backgroundColor: Colors.transparent),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(height: 10, width: 80, color: Colors.transparent),
          const SizedBox(height: 4),
          Container(height: 12, width: 150, color: Colors.transparent),
        ]),
      ]),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(height: 20, width: 120, color: Colors.transparent),
          const SizedBox(height: 12),
          _detailWidgetSkeleton(context),
          Divider(color: theme.colorScheme.outline.withOpacity(0.2), height: 20),
          _detailWidgetSkeleton(context),
          Divider(color: theme.colorScheme.outline.withOpacity(0.2), height: 20),
          _detailWidgetSkeleton(context),
        ]),
      ),
    );
  }
}

// Helper method for ListTile in UserProfileScreen
Widget _buildListTileSkeleton(ThemeData theme) {
  return Column(
    children: [
      ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.transparent, // Skeletonizer handles color
          ),
          child: const Icon(Icons.circle, color: Colors.transparent, size: 22), // Placeholder shape
        ),
        title: Container(height: 16, width: 150, color: Colors.transparent),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),
      ),
    ],
  );
}


// Assuming LoginPage is defined elsewhere, e.g.:
// import 'package:cloudkeja/screens/auth/login_page.dart';
