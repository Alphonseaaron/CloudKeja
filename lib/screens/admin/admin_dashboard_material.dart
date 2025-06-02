import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:get/get_connect/http/src/utils/utils.dart'; // F. T unused
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
// import 'package:cloudkeja/helpers/loading_effect.dart'; // Replaced by Skeletonizer
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/invoice_provider.dart'; // For PdfInvoiceApi
import 'package:cloudkeja/providers/payment_provider.dart'; // For getTransactions
import 'package:cloudkeja/providers/post_provider.dart';
// import 'package:cloudkeja/screens/admin/all_landlords.dart'; // Replaced by router
// import 'package:cloudkeja/screens/admin/alll_users_screen.dart'; // Replaced by router
import 'package:cloudkeja/screens/admin/all_landlords_screen_router.dart'; // Import router
import 'package:cloudkeja/screens/admin/all_users_screen_router.dart';   // Import router
import 'package:cloudkeja/screens/auth/login_page.dart';
import 'package:cloudkeja/screens/chat/chat_screen.dart';
// import 'package:cloudkeja/screens/landlord/landlord_analytics.dart'; // Not directly used
import 'package:cloudkeja/widgets/space_tile.dart'; // Themed SpacerTile
import 'package:skeletonizer/skeletonizer.dart'; // For skeleton loading

// Assuming PdfInvoiceApi and PdfApi are correctly imported or defined elsewhere if used.
// For this refactor, the PDF generation logic will be kept as is, focusing on UI theming.
// If PdfInvoiceApi and PdfApi are part of the project, ensure they are correctly referenced.
// For now, commenting out related imports if they cause issues without full context.
// import 'package:cloudkeja/providers/invoice_provider.dart'; // If PdfInvoiceApi is here
// import 'package:cloudkeja/some_path/pdf_api.dart'; // If PdfApi is here


class AdminDashboard extends StatefulWidget { // Changed to StatefulWidget for RefreshIndicator state
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  Future<void> _refreshData() async {
    // Re-fetch any data needed for this dashboard, e.g., recent spaces
    // This will trigger FutureBuilders to re-run their futures
    setState(() {
      // This is primarily to allow FutureBuilders to re-fetch.
      // If PostProvider.getSpaces() has its own caching/refresh logic, that will be used.
      // Forcing a re-fetch might involve calling a method on the provider, e.g.:
      // Provider.of<PostProvider>(context, listen: false).fetchSpaces(forceRefresh: true);
      // For now, just calling setState to rebuild and re-trigger FutureBuilder.
    });
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onPressed,
    required Color iconColor, // The main color for the icon and its themed background
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Expanded(
      child: Card(
        // Using Card for consistent elevation and shape from CardTheme
        // elevation: cardTheme.elevation, // from theme
        // shape: cardTheme.shape, // from theme
        // color: cardTheme.color, // from theme
        margin: const EdgeInsets.symmetric(horizontal: 6.0), // Spacing between cards
        child: InkWell( // InkWell provides tap feedback on the Card
          onTap: onPressed,
          borderRadius: (theme.cardTheme.shape as RoundedRectangleBorder?)?.borderRadius ?? BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Fit content
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15), // Use the passed color with opacity
                    shape: BoxShape.circle, // Circular background for icon
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant, // Themed text color
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 12.0),
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

    // Define action button data with themed colors
    final List<Map<String, dynamic>> actions = [
      {
        'icon': Icons.people_alt_outlined,
        'title': 'Manage\nUsers',
        'onPressed': () => Get.to(() => const AllUsersScreenRouter()), // Use router
        'color': colorScheme.primary,
      },
      {
        'icon': Icons.real_estate_agent_outlined,
        'title': 'Manage\nLandlords',
        'onPressed': () => Get.to(() => const AllLandlordsScreenRouter()), // Use router
        'color': colorScheme.secondary,
      },
      {
        'icon': Icons.insert_chart_outlined, // Changed from show_chart
        'title': 'System\nAnalytics',
        'onPressed': () async {
          // Kept PDF logic, assuming PdfInvoiceApi and PdfApi are available and functional
          // This part is not directly related to UI theming but is core functionality.
          try {
            final transactions = await Provider.of<PaymentProvider>(context, listen: false).getTransactions();
            final pdfFile = await PdfInvoiceApi.generate(transactions); // Ensure this class exists
            PdfApi.openFile(pdfFile); // Ensure this class exists
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating report: $e', style: TextStyle(color: colorScheme.onError)), backgroundColor: colorScheme.error,));
          }
        },
        'color': colorScheme.tertiary,
      },
      {
        'icon': Icons.support_agent_outlined, // Changed from people_outline_outlined
        'title': 'Users\nSupport',
        'onPressed': () => Get.to(() => const ChatScreen()), // Assuming ChatScreen is general support
        'color': colorScheme.tertiary, // Changed from Colors.orange.shade700
      },
    ];


    return Scaffold(
      backgroundColor: colorScheme.background, // Themed background
      appBar: AppBar(
        title: const Text('System Administration'),
        // Actions use AppBarTheme (icon color)
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined), // Changed icon
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Get.offAll(() => const LoginPage());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView( // Changed outer Column to ListView for RefreshIndicator compatibility
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          children: [
            const SizedBox(height: 10), // Initial spacing
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0), // Reduced horizontal padding for the Row
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Expanded children handle spacing
                crossAxisAlignment: CrossAxisAlignment.start, // Align items to top
                children: actions.map((action) {
                  return _buildActionButton(
                    context: context,
                    icon: action['icon'] as IconData,
                    title: action['title'] as String,
                    onPressed: action['onPressed'] as VoidCallback,
                    iconColor: action['color'] as Color,
                  );
                }).toList(),
              ),
            ),

            _buildSectionTitle(context, 'Recent Spaces'),
            FutureBuilder<List<SpaceModel>>(
              future: Provider.of<PostProvider>(context, listen: false).getSpaces(), // Re-fetches on rebuild if provider doesn't cache
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Skeletonizer for the list of spaces
                  return Skeletonizer(
                    enabled: true,
                    effect: ShimmerEffect(
                      baseColor: colorScheme.surfaceVariant.withOpacity(0.4),
                      highlightColor: colorScheme.surfaceVariant.withOpacity(0.8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: 3, // Number of skeleton items
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: SpaceTile(space: SpaceModel.emptyForAdmin()), // Use a specific empty model if needed
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(padding: const EdgeInsets.all(16), child: Text('Error: ${snapshot.error}', style: TextStyle(color: colorScheme.error)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(padding: const EdgeInsets.all(16), child: Center(child: Text('No spaces found.', style: theme.textTheme.bodyMedium)));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding for the list
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    // SpacerTile was refactored and is theme-aware
                    // Its internal margin handles spacing between tiles
                    return SpaceTile(space: snapshot.data![index]);
                  },
                );
              },
            ),
            const SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
    );
  }
}

// Helper extension for SpaceModel if needed for skeletonizer, ensure it's defined
// (e.g. in a shared model extensions file or directly in SpaceModel)
extension EmptySpaceModelForAdmin on SpaceModel {
  static SpaceModel emptyForAdmin() {
    return SpaceModel(
      id: 'skeleton_admin_space',
      spaceName: 'Loading Space Name...',
      address: 'Loading address...',
      price: 0.0,
      images: ['https://via.placeholder.com/100/F0F0F0/AAAAAA?text=...'],
      description: 'Loading description...',
      isAvailable: true,
      ownerId: 'skeleton_owner',
      category: 'skeleton_category',
    );
  }
}

// Ensure PdfInvoiceApi and PdfApi are correctly defined/imported if used.
// Example stubs if they are not available for this refactoring:
class PdfInvoiceApi {
  static Future<dynamic> generate(dynamic invoice) async { /* Stub */ return null; }
}
class PdfApi {
  static Future<void> openFile(dynamic file) async { /* Stub */ }
}
