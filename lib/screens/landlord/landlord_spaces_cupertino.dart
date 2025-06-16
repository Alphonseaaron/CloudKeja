import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Aliased
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/models/user_model.dart'; // Added
import 'package:cloudkeja/providers/auth_provider.dart'; // Added
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/providers/subscription_provider.dart'; // Added
import 'package:cloudkeja/screens/landlord/add_space_screen_router.dart'; // Added
import 'package:cloudkeja/screens/subscription/subscription_plans_screen.dart'; // Added
import 'package:cloudkeja/widgets/space_tile.dart'; // Adaptive SpacerTile router

class LandlordSpacesCupertino extends StatelessWidget {
  const LandlordSpacesCupertino({Key? key}) : super(key: key);

  void _showCupertinoUpgradeDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext ctx) {
        return CupertinoAlertDialog(
          title: const Text('Property Limit Reached'),
          content: const Text(
              'You have reached the maximum number of properties for your current subscription plan. Please upgrade to add more.'),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Upgrade Plan'),
              onPressed: () {
                Navigator.of(ctx).pop(); // Close the dialog
                Navigator.of(context).push(CupertinoPageRoute(
                    builder: (_) => const SubscriptionPlansScreen()));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Your Spaces'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: () async {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            final UserModel? currentUser = authProvider.user;
            final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);

            if (currentUser == null) {
              // Show some error or prompt login, though user should be logged in to see this screen
              showCupertinoDialog(
                  context: context,
                  builder: (ctx) => CupertinoAlertDialog(
                        title: const Text('Error'),
                        content: const Text('User not found. Please re-login.'),
                        actions: [
                          CupertinoDialogAction(isDefaultAction: true, child: const Text('OK'), onPressed: () => Navigator.pop(ctx))
                        ],
                      ));
              return;
            }

            if (subscriptionProvider.canAddProperty(currentUser)) {
              Navigator.of(context).pushNamed(AddSpaceScreenRouter.routeName);
            } else {
              _showCupertinoUpgradeDialog(context);
            }
          },
        ),
      ),
      child: FutureBuilder<List<SpaceModel>>(
        future: Provider.of<PostProvider>(context, listen: false)
            .fetchLandlordSpaces(fb_auth.FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator(radius: 15));
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${snapshot.error}',
                  style: cupertinoTheme.textTheme.textStyle.copyWith(color: CupertinoColors.destructiveRed.resolveFrom(context)),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'You have not listed any spaces yet.',
                style: cupertinoTheme.textTheme.textStyle.copyWith(color: CupertinoColors.secondaryLabel.resolveFrom(context)),
                textAlign: TextAlign.center,
              ),
            );
          }

          // Using CustomScrollView with SliverList for pull-to-refresh capability if added later
          // Or just ListView.builder if no refresh needed for this specific screen.
          // For consistency with other Cupertino screens, CustomScrollView + SliverList is good.
          return CustomScrollView(
            slivers: [
              // Optional: CupertinoSliverRefreshControl(onRefresh: ...),
              SliverPadding(
                padding: const EdgeInsets.all(16.0), // Padding around the list of tiles
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final space = snapshot.data![index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0), // Spacing between tiles
                        child: SpacerTile( // This is the adaptive router, will render SpaceTileCupertino
                          space: space,
                          isOwner: true,
                        ),
                      );
                    },
                    childCount: snapshot.data!.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
