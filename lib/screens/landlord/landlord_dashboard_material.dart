import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/tenant_analytics_provider.dart';
import 'package:cloudkeja/screens/landlord/add_space_router.dart'; // Use router
import 'package:cloudkeja/screens/landlord/all_tenants_screen_router.dart'; // Use router
import 'package:cloudkeja/screens/landlord/finances/finance_overview_screen.dart'; // Assuming this is Material or adaptive
import 'package:cloudkeja/screens/landlord/landlord_spaces.dart'; // Assuming this is Material or adaptive
import 'package:cloudkeja/screens/landlord/widgets/recent_tenants.dart'; // Adaptive router
import 'package:cloudkeja/screens/landlord/landlord_view_tenant_details_screen.dart'; // Assuming this is Material or adaptive
import 'package:skeletonizer/skeletonizer.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:cloudkeja/services/walkthrough_service.dart';

class LandlordDashboardMaterial extends StatefulWidget {
  const LandlordDashboardMaterial({Key? key}) : super(key: key);

  @override
  State<LandlordDashboardMaterial> createState() => _LandlordDashboardMaterialState();
}

class _LandlordDashboardMaterialState extends State<LandlordDashboardMaterial> {
  UserModel? _user;
  bool _isLoadingUser = true;

  final _balanceCardKey = GlobalKey();
  final _actionButtonsRowKey = GlobalKey();
  final _recentTenantsSectionKey = GlobalKey();
  late List<GlobalKey> _showcaseKeys;

  @override
  void initState() {
    super.initState();
    _showcaseKeys = [
      _balanceCardKey,
      _actionButtonsRowKey,
      _recentTenantsSectionKey,
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { // Check if widget is still in the tree
        WalkthroughService.startShowcaseIfNeeded(
          context: context,
          walkthroughKey: 'landlordDashboardOverview_v1_material', // Unique key for Material
          showcaseGlobalKeys: _showcaseKeys,
        );
      }
    });
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    // Ensure provider calls are safe if widget is disposed during async operation
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = await authProvider.getCurrentUser();
    if (mounted) {
      setState(() {
        _user = user;
        _isLoadingUser = false;
      });
    }
  }

  Widget _buildBalanceSection(BuildContext context, UserModel? user) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      elevation: 2.0, // Keep some elevation for Material
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), // Consistent shape
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'AVAILABLE BALANCE',
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant, // Use onSurfaceVariant
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Skeletonizer.zone(
              enabled: _isLoadingUser || user == null,
              child: Text(
                'KES ${user?.balance?.toStringAsFixed(2) ?? "0.00"}',
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onPressed,
    required Color iconContainerColor, // This will be the themed color
    // required Color iconColor, // iconColor can be derived or set to contrast iconContainerColor
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    // Determine icon color for good contrast with its container
    final iconColor = ThemeData.estimateBrightnessForColor(iconContainerColor) == Brightness.dark
        ? Colors.white
        : Colors.black;


    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iconContainerColor.withOpacity(0.15), // Keep opacity for distinct look
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(icon, color: iconContainerColor, size: 28), // Icon takes the direct color
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(height: 1.2, color: theme.colorScheme.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 12.0),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    TextStyle? showcaseTitleStyle = textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary);
    TextStyle? showcaseDescStyle = textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary.withOpacity(0.9));

    final List<Map<String, dynamic>> actions = [
      {
        'icon': Icons.add_business_outlined,
        'title': 'List\nSpace',
        'onPressed': () => Get.to(() => const AddSpaceRouter()), // Use router
        'color': colorScheme.primary,
      },
      {
        'icon': Icons.holiday_village_outlined,
        'title': 'View\nSpaces',
        'onPressed': () => Get.to(() => const LandlordSpaces()),
        'color': colorScheme.secondary,
      },
      {
        'icon': Icons.analytics_outlined,
        'title': 'View\nFinances',
        'onPressed': () => Get.to(() => const FinanceOverviewScreen()),
        'color': colorScheme.tertiary,
      },
      {
        'icon': Icons.people_alt_outlined,
        'title': 'All\nTenants',
        'onPressed': () => Get.to(() => const AllTenantsScreenRouter()), // Use router
        'color': colorScheme.tertiaryContainer, // Themed color
      },
    ];

    return ShowCaseWidget(
      onFinish: () {
        WalkthroughService.markAsSeen('landlordDashboardOverview_v1_material');
      },
      builder: Builder(builder: (context) {
        return Scaffold(
          backgroundColor: colorScheme.background,
          appBar: AppBar(
            title: const Text('Landlord Dashboard'),
            // AppBar theming is global
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              if(mounted) setState(() { _isLoadingUser = true; });
              await _fetchUserData();
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: [
                Showcase(
                  key: _balanceCardKey,
                  title: 'Your Finances',
                  description: 'Keep an eye on your account balance here. This is fetched from your user profile.',
                  titleTextStyle: showcaseTitleStyle,
                  descTextStyle: showcaseDescStyle,
                  showcaseBackgroundColor: colorScheme.primary,
                  overlayColor: Colors.black.withOpacity(0.7),
                  contentPadding: const EdgeInsets.all(12),
                  shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: _buildBalanceSection(context, _user),
                ),

                Showcase(
                  key: _actionButtonsRowKey,
                  title: 'Quick Actions',
                  description: 'Use these buttons to quickly list new spaces, view your properties, manage finances, and see tenants.',
                  titleTextStyle: showcaseTitleStyle,
                  descTextStyle: showcaseDescStyle,
                  showcaseBackgroundColor: colorScheme.primary,
                  overlayColor: Colors.black.withOpacity(0.7),
                  contentPadding: const EdgeInsets.all(12),
                  // No specific shapeBorder for a Row, default rectangle is fine.
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: actions.map((action) {
                        return _buildActionButton(
                          context: context,
                          icon: action['icon'] as IconData,
                          title: action['title'] as String,
                          onPressed: action['onPressed'] as VoidCallback,
                          iconContainerColor: action['color'] as Color,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                _buildSectionTitle(context, 'Test Tenant Payment Metrics'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        child: const Text('View Good Payer Metrics (Test)'),
                        onPressed: () => Get.to(() => LandlordViewOfTenantDetailsScreen(tenantId: TenantAnalyticsProvider.goodPayerTestId)), // Added const
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        child: const Text('View Bad Payer Metrics (Test)'),
                        onPressed: () => Get.to(() => LandlordViewOfTenantDetailsScreen(tenantId: TenantAnalyticsProvider.badPayerTestId)), // Added const
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        child: const Text('View Mixed Payer Metrics (Test)'),
                        onPressed: () => Get.to(() => LandlordViewOfTenantDetailsScreen(tenantId: TenantAnalyticsProvider.mixedPayerTestId)), // Added const
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
                      ),
                       const SizedBox(height: 8),
                      ElevatedButton(
                        child: const Text('View Default Test Tenant Metrics'),
                        onPressed: () => Get.to(() => LandlordViewOfTenantDetailsScreen(tenantId: TenantAnalyticsProvider.defaultTestTenantId)), // Added const
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
                      ),
                    ],
                  ),
                ),

                Showcase(
                  key: _recentTenantsSectionKey,
                  title: 'Manage Tenants',
                  description: 'See a list of your recent tenants. Tap on them for more details or actions.',
                  titleTextStyle: showcaseTitleStyle,
                  descTextStyle: showcaseDescStyle,
                  showcaseBackgroundColor: colorScheme.primary,
                  overlayColor: Colors.black.withOpacity(0.7),
                  contentPadding: const EdgeInsets.all(12),
                  shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, 'Recent Tenants'),
                      const RecentTenantsWidget(), // This is now an adaptive router
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }
}
