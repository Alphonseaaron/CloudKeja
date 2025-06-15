import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/widgets/space_tile.dart'; // Adaptive SpacerTile router

class LandlordSpacesCupertino extends StatelessWidget {
  const LandlordSpacesCupertino({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Your Spaces'),
      ),
      child: FutureBuilder<List<SpaceModel>>(
        future: Provider.of<PostProvider>(context, listen: false)
            .fetchLandlordSpaces(FirebaseAuth.instance.currentUser!.uid),
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
