import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Aliased
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/models/user_model.dart'; // Added
import 'package:cloudkeja/providers/auth_provider.dart'; // Added
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/providers/subscription_provider.dart'; // Added
import 'package:cloudkeja/screens/landlord/add_space_screen_router.dart'; // Added
import 'package:cloudkeja/screens/subscription/subscription_plans_screen.dart'; // Added
import 'package:cloudkeja/widgets/space_tile.dart'; // Adaptive SpacerTile router

class LandlordSpacesMaterial extends StatelessWidget {
  const LandlordSpacesMaterial({Key? key}) : super(key: key);

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Property Limit Reached'),
          content: const Text(
              'You have reached the maximum number of properties for your current subscription plan. Please upgrade to add more.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Upgrade Plan'),
              onPressed: () {
                Navigator.of(ctx).pop(); // Close the dialog
                Navigator.of(context).pushNamed(SubscriptionPlansScreen.routeName);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    // Assuming AppBarTheme handles titleTextStyle globally, or use:
    // final appBarTitleStyle = theme.appBarTheme.titleTextStyle ?? textTheme.titleLarge;

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Spaces', style: theme.appBarTheme.titleTextStyle ?? textTheme.titleLarge), // Themed title
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final UserModel? currentUser = authProvider.user;
          final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);

          if (currentUser == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("User not found. Please re-login.")),
            );
            return;
          }

          if (subscriptionProvider.canAddProperty(currentUser)) {
            Navigator.of(context).pushNamed(AddSpaceScreenRouter.routeName);
          } else {
            _showUpgradeDialog(context);
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Add New Property',
      ),
      body: FutureBuilder<List<SpaceModel>>(
        future: Provider.of<PostProvider>(context, listen: false)
            .fetchLandlordSpaces(fb_auth.FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Standard Material loader
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading your spaces: ${snapshot.error}',
                  style: textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'You have not listed any spaces yet.',
                style: textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            );
          }

          // Use ListView.builder for better performance with potentially long lists
          return ListView.builder(
            padding: const EdgeInsets.all(8.0), // Add some padding around the list
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final space = snapshot.data![index];
              return Padding( // Use Padding instead of Container with margin for spacing
                padding: const EdgeInsets.symmetric(vertical: 4.0), // Consistent vertical spacing
                child: SpacerTile( // This is the adaptive router, will render SpaceTileMaterial
                  space: space,
                  isOwner: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
