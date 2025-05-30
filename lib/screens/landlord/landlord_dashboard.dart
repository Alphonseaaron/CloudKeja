import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/user_model.dart'; // For UserModel
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/tenant_analytics_provider.dart'; // For test tenant IDs
import 'package:cloudkeja/screens/landlord/add_space.dart';
import 'package:cloudkeja/screens/landlord/all_tenants_screen.dart';
import 'package:cloudkeja/screens/landlord/finances/finance_overview_screen.dart';
import 'package:cloudkeja/screens/landlord/landlord_spaces.dart';
import 'package:cloudkeja/screens/landlord/widgets/recent_tenants.dart';
import 'package:cloudkeja/screens/landlord/landlord_view_tenant_details_screen.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:cloudkeja/services/walkthrough_service.dart';

class LandlordDashboard extends StatefulWidget {
  const LandlordDashboard({Key? key}) : super(key: key);

  @override
  State<LandlordDashboard> createState() => _LandlordDashboardState();
}

class _LandlordDashboardState extends State<LandlordDashboard> {
  UserModel? _user;
  bool _isLoadingUser = true;

  // GlobalKeys for ShowcaseView
  final _balanceCardKey = GlobalKey();
  final _actionButtonsRowKey = GlobalKey();
  final _recentTenantsSectionKey = GlobalKey();

  List<GlobalKey> _showcaseKeys = [];

  @override
  void initState() {
    super.initState();
    _showcaseKeys = [
      _balanceCardKey,
      _actionButtonsRowKey,
      _recentTenantsSectionKey,
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      WalkthroughService.startShowcaseIfNeeded(
        context: context,
        walkthroughKey: 'landlordDashboardOverview_v1',
        showcaseGlobalKeys: _showcaseKeys,
      );
    });
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = await Provider.of<AuthProvider>(context, listen: false).getCurrentUser();
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
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'AVAILABLE BALANCE',
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
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
    required Color iconContainerColor,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

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
                  color: iconContainerColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(icon, color: iconContainerColor, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Common showcase text style
    TextStyle? showcaseTitleStyle = textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary);
    TextStyle? showcaseDescStyle = textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary.withOpacity(0.9));

    final List<Map<String, dynamic>> actions = [
      {
        'icon': Icons.add_business_outlined,
        'title': 'List\nSpace',
        'onPressed': () => Get.to(() => const AddSpaceScreen()),
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
        'title': 'All\nTenants', // Changed title to reflect actual navigation
        'onPressed': () {
          Get.to(() => const AllTenantsScreen());
        },
        'color': Colors.deepOrange.shade400,
      },
    ];

    return ShowCaseWidget(
      onFinish: () {
        WalkthroughService.markAsSeen('landlordDashboardOverview_v1');
      },
      builder: Builder(builder: (context) {
        return Scaffold(
          backgroundColor: colorScheme.background,
          appBar: AppBar(
            title: const Text('Landlord Dashboard'),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() { _isLoadingUser = true; });
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
                  child: _buildBalanceSection(context, _user),
                ),

                Showcase(
                  key: _actionButtonsRowKey,
                  title: 'Quick Actions',
                  description: 'Use these buttons to quickly list new spaces, view your properties, manage finances, and see tenants.',
                  titleTextStyle: showcaseTitleStyle,
                  descTextStyle: showcaseDescStyle,
                  showcaseBackgroundColor: colorScheme.primary,
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
                          iconColor: action['color'] as Color,
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // --- Test Navigation Buttons for Tenant Payment Metrics ---
                // This section is intentionally NOT part of the walkthrough
                _buildSectionTitle(context, 'Test Tenant Payment Metrics'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        child: const Text('View Good Payer Metrics (Test)'),
                        onPressed: () => Get.to(() => const LandlordViewOfTenantDetailsScreen(tenantId: TenantAnalyticsProvider.goodPayerTestId)),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        child: const Text('View Bad Payer Metrics (Test)'),
                        onPressed: () => Get.to(() => const LandlordViewOfTenantDetailsScreen(tenantId: TenantAnalyticsProvider.badPayerTestId)),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        child: const Text('View Mixed Payer Metrics (Test)'),
                        onPressed: () => Get.to(() => const LandlordViewOfTenantDetailsScreen(tenantId: TenantAnalyticsProvider.mixedPayerTestId)),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
                      ),
                       const SizedBox(height: 8),
                      ElevatedButton( // Button for the original testTenant1 (default good payer)
                        child: const Text('View Default Test Tenant Metrics'),
                        onPressed: () => Get.to(() => const LandlordViewOfTenantDetailsScreen(tenantId: TenantAnalyticsProvider.defaultTestTenantId)),
                        style: ElevatedButton.stylefrom(minimumSize: const Size(double.infinity, 40)),
                      ),
                    ],
                  ),
                ),
                // --- End Test Navigation Buttons ---

                Showcase(
                  key: _recentTenantsSectionKey,
                  title: 'Manage Tenants',
                  description: 'See a list of your recent tenants. Tap on them for more details or actions.',
                  titleTextStyle: showcaseTitleStyle,
                  descTextStyle: showcaseDescStyle,
                  showcaseBackgroundColor: colorScheme.primary,
                  child: Column( // Wrap title and widget for single showcase item
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, 'Recent Tenants'),
                      const RecentTenantsWidget(),
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
