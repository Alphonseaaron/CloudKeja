import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/user_model.dart'; // For UserModel
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/screens/landlord/add_space.dart';
import 'package:cloudkeja/screens/landlord/all_tenants_screen.dart';
import 'package:cloudkeja/screens/landlord/finances/finance_overview_screen.dart';
// import 'package:cloudkeja/screens/landlord/landlord_analytics.dart'; // Not used directly, FinanceOverviewScreen is
import 'package:cloudkeja/screens/landlord/landlord_spaces.dart';
import 'package:cloudkeja/screens/landlord/widgets/recent_tenants.dart'; // Already refactored
import 'package:skeletonizer/skeletonizer.dart'; // For skeleton loading

class LandlordDashboard extends StatefulWidget {
  const LandlordDashboard({Key? key}) : super(key: key);

  @override
  State<LandlordDashboard> createState() => _LandlordDashboardState();
}

class _LandlordDashboardState extends State<LandlordDashboard> {
  UserModel? _user;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    // Assuming getCurrentUser might involve an async call if user data is not readily available
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
      elevation: 2.0, // Subtle elevation
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
            Skeletonizer.zone( // Skeletonize only the balance text if user is loading
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
    required Color iconContainerColor, // Base color for the icon container
    required Color iconColor,          // Color for the icon itself
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Expanded( // Use Expanded to make buttons share space
      child: InkWell( // Using InkWell for custom tap effect container
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.0), // For ripple effect
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16), // Increased padding for larger tap target
                decoration: BoxDecoration(
                  color: iconContainerColor.withOpacity(0.15), // Lighter, themed background
                  borderRadius: BorderRadius.circular(12.0), // Consistent border radius
                ),
                child: Icon(icon, color: iconContainerColor, size: 28), // Themed icon color
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(height: 1.2), // Improved line height for two-line text
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
    // final textTheme = theme.textTheme; // Defined locally where needed

    // Action button definitions
    final List<Map<String, dynamic>> actions = [
      {
        'icon': Icons.add_business_outlined,
        'title': 'List\nSpace',
        'onPressed': () => Get.to(() => const AddSpaceScreen()),
        'color': colorScheme.primary, // Example: Use primary color
      },
      {
        'icon': Icons.holiday_village_outlined,
        'title': 'View\nSpaces',
        'onPressed': () => Get.to(() => const LandlordSpaces()),
        'color': colorScheme.secondary, // Example: Use secondary color
      },
      {
        'icon': Icons.analytics_outlined, // Changed from show_chart
        'title': 'View\nFinances', // Changed title for clarity
        'onPressed': () => Get.to(() => const FinanceOverviewScreen()),
        'color': colorScheme.tertiary, // Example: Use tertiary color
      },
      {
        'icon': Icons.people_alt_outlined, // Changed from people_outline_outlined
        'title': 'View\nTenants', // Changed title
        'onPressed': () => Get.to(() => const AllTenantsScreen()),
        'color': Colors.deepOrange.shade400, // Custom color if specific meaning
      },
    ];

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Landlord Dashboard'),
        // AppBar uses AppBarTheme from AppTheme
      ),
      body: RefreshIndicator( // Added RefreshIndicator
        onRefresh: () async {
          setState(() { _isLoadingUser = true; });
          await _fetchUserData(); 
          // Also trigger refresh for RecentTenantsWidget if it has its own refresh logic
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8.0), // Overall padding for ListView
          children: [
            _buildBalanceSection(context, _user), // Pass user to handle skeleton internally
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0), // Padding around the Row
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround, // Distribute space
                crossAxisAlignment: CrossAxisAlignment.start, // Align items to top
                children: actions.map((action) {
                  return _buildActionButton(
                    context: context,
                    icon: action['icon'] as IconData,
                    title: action['title'] as String,
                    onPressed: action['onPressed'] as VoidCallback,
                    iconContainerColor: action['color'] as Color,
                    iconColor: action['color'] as Color, // Icon color same as container base
                  );
                }).toList(),
              ),
            ),
            
            _buildSectionTitle(context, 'Recent Tenants'),
            const RecentTenantsWidget(), // Already refactored, handles its own skeleton
            
            const SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
    );
  }
}
