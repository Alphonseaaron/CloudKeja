import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:get/route_manager.dart'; // For Get.to
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/tenant_analytics_provider.dart'; // For test tenant IDs
import 'package:cloudkeja/screens/landlord/add_space_router.dart'; // Router
import 'package:cloudkeja/screens/landlord/all_tenants_screen_router.dart'; // Router
import 'package:cloudkeja/screens/landlord/finances/finance_overview_screen.dart'; // Assuming adaptive or Material for now
import 'package:cloudkeja/screens/landlord/landlord_spaces.dart'; // Assuming adaptive or Material for now
import 'package:cloudkeja/screens/landlord/widgets/recent_tenants.dart'; // Adaptive Router
import 'package:cloudkeja/screens/landlord/landlord_view_tenant_details_screen.dart'; // Assuming adaptive or Material
import 'package:showcaseview/showcaseview.dart';
import 'package:cloudkeja/services/walkthrough_service.dart';

class LandlordDashboardCupertino extends StatefulWidget {
  const LandlordDashboardCupertino({Key? key}) : super(key: key);

  @override
  State<LandlordDashboardCupertino> createState() => _LandlordDashboardCupertinoState();
}

class _LandlordDashboardCupertinoState extends State<LandlordDashboardCupertino> {
  UserModel? _user;
  bool _isLoadingUser = true;

  final _balanceCardKey = GlobalKey();
  final _actionButtonsKey = GlobalKey();
  final _recentTenantsKey = GlobalKey();
  late List<GlobalKey> _showcaseKeys;

  @override
  void initState() {
    super.initState();
     _showcaseKeys = [
      _balanceCardKey,
      _actionButtonsKey,
      _recentTenantsKey,
    ];
    _fetchUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        WalkthroughService.startShowcaseIfNeeded(
          context: context,
          walkthroughKey: 'landlordDashboardCupertino_v1', // Unique key for Cupertino
          showcaseGlobalKeys: _showcaseKeys,
        );
      }
    });
  }

  Future<void> _fetchUserData() async {
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

  Widget _buildCupertinoBalanceSection(BuildContext context, UserModel? user) {
    final cupertinoTheme = CupertinoTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: cupertinoTheme.barBackgroundColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: [
            Text(
              'AVAILABLE BALANCE',
              style: cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
            ),
            const SizedBox(height: 8),
            _isLoadingUser || user == null
                ? const CupertinoActivityIndicator(radius: 12)
                : Text(
                    'KES ${user.balance?.toStringAsFixed(2) ?? "0.00"}',
                    style: cupertinoTheme.textTheme.navLargeTitleTextStyle.copyWith(
                      color: cupertinoTheme.primaryColor,
                      fontSize: 28, // Prominent balance
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCupertinoActionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onPressed,
  }) {
    final cupertinoTheme = CupertinoTheme.of(context);
    return GestureDetector( // Using GestureDetector for larger tap area if needed
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12), // Smaller padding for icon container
            decoration: BoxDecoration(
              color: cupertinoTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(icon, color: cupertinoTheme.primaryColor, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: cupertinoTheme.textTheme.caption1.copyWith(fontSize: 11), // Smaller text for actions
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final cupertinoTheme = CupertinoTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 16.0, top: 20.0, bottom: 8.0), // Adjusted padding
      child: Text(
        title,
        style: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(
          fontSize: 18, // Consistent section header size
          color: CupertinoColors.label.resolveFrom(context),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);

    // Showcase styles
    final TextStyle? showcaseTitleStyle = cupertinoTheme.textTheme.navTitleTextStyle.copyWith(
      color: CupertinoColors.white, fontWeight: FontWeight.bold,
    );
    final TextStyle? showcaseDescStyle = cupertinoTheme.textTheme.textStyle.copyWith(
      color: CupertinoColors.white.withOpacity(0.9),
    );
    final Color showcaseBgColor = cupertinoTheme.primaryColor.withOpacity(0.95);
    final Color showcaseOverlayColor = CupertinoColors.black.withOpacity(0.7);
    const EdgeInsets showcaseContentPadding = EdgeInsets.all(12);
    final BorderRadius showcaseTooltipBorderRadius = BorderRadius.circular(10.0);


    final List<Map<String, dynamic>> actions = [
      {'icon': CupertinoIcons.add_circled, 'title': 'List\nSpace', 'onPressed': () => Get.to(() => const AddSpaceRouter())},
      {'icon': CupertinoIcons.square_list_fill, 'title': 'View\nSpaces', 'onPressed': () => Get.to(() => const LandlordSpaces())},
      {'icon': CupertinoIcons.money_dollar_circle_fill, 'title': 'View\nFinances', 'onPressed': () => Get.to(() => const FinanceOverviewScreen())},
      {'icon': CupertinoIcons.person_3_fill, 'title': 'All\nTenants', 'onPressed': () => Get.to(() => const AllTenantsScreenRouter())},
    ];

    return ShowCaseWidget(
      onFinish: () {
        WalkthroughService.markAsSeen('landlordDashboardCupertino_v1');
      },
      builder: Builder(builder: (context) {
        return CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(
            middle: Text('Landlord Dashboard'),
          ),
          child: CustomScrollView( // Use CustomScrollView for refresh control and slivers
            slivers: [
              CupertinoSliverRefreshControl(onRefresh: () async {
                 if(mounted) setState(() { _isLoadingUser = true; });
                 await _fetchUserData();
              }),
              SliverList(
                delegate: SliverChildListDelegate([
                  Showcase(
                    key: _balanceCardKey,
                    title: 'Your Finances',
                    description: 'Keep an eye on your account balance here.',
                    titleTextStyle: showcaseTitleStyle,
                    descTextStyle: showcaseDescStyle,
                    showcaseBackgroundColor: showcaseBgColor,
                    overlayColor: showcaseOverlayColor,
                    contentPadding: showcaseContentPadding,
                    layerLink: LayerLink(), // Required for Showcase v2+
                    tooltipBorderRadius: showcaseTooltipBorderRadius,
                    child: _buildCupertinoBalanceSection(context, _user),
                  ),
                  Showcase(
                    key: _actionButtonsKey,
                    title: 'Quick Actions',
                    description: 'Manage your properties and finances with these actions.',
                    titleTextStyle: showcaseTitleStyle,
                    descTextStyle: showcaseDescStyle,
                    showcaseBackgroundColor: showcaseBgColor,
                    overlayColor: showcaseOverlayColor,
                    contentPadding: showcaseContentPadding,
                    layerLink: LayerLink(),
                    tooltipBorderRadius: showcaseTooltipBorderRadius,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: actions.map((action) {
                          return Expanded( // Ensure buttons take available space
                            child: _buildCupertinoActionButton(
                              context: context,
                              icon: action['icon'] as IconData,
                              title: action['title'] as String,
                              onPressed: action['onPressed'] as VoidCallback,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  _buildSectionHeader(context, 'Test Tenant Payment Metrics'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CupertinoButton(child: const Text('View Good Payer Metrics (Test)'), onPressed: () => Get.to(() => LandlordViewOfTenantDetailsScreen(tenantId: TenantAnalyticsProvider.goodPayerTestId))),
                        const SizedBox(height: 8),
                        CupertinoButton(child: const Text('View Bad Payer Metrics (Test)'), onPressed: () => Get.to(() => LandlordViewOfTenantDetailsScreen(tenantId: TenantAnalyticsProvider.badPayerTestId))),
                        const SizedBox(height: 8),
                        CupertinoButton(child: const Text('View Mixed Payer Metrics (Test)'), onPressed: () => Get.to(() => LandlordViewOfTenantDetailsScreen(tenantId: TenantAnalyticsProvider.mixedPayerTestId))),
                        const SizedBox(height: 8),
                        CupertinoButton(child: const Text('View Default Test Tenant Metrics'), onPressed: () => Get.to(() => LandlordViewOfTenantDetailsScreen(tenantId: TenantAnalyticsProvider.defaultTestTenantId))),
                      ],
                    ),
                  ),

                  Showcase(
                    key: _recentTenantsKey,
                    title: 'Manage Tenants',
                    description: 'See a list of your recent tenants here.',
                    titleTextStyle: showcaseTitleStyle,
                    descTextStyle: showcaseDescStyle,
                    showcaseBackgroundColor: showcaseBgColor,
                    overlayColor: showcaseOverlayColor,
                    contentPadding: showcaseContentPadding,
                    layerLink: LayerLink(),
                    tooltipBorderRadius: showcaseTooltipBorderRadius,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(context, 'Recent Tenants'),
                        const RecentTenantsWidget(), // Adaptive router will pick Cupertino version
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ]),
              ),
            ],
          ),
        );
      }),
    );
  }
}
