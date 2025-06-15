import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:cloudkeja/helpers/loading_effect.dart'; // Replaced
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/widgets/space_tile.dart'; // Adaptive SpacerTile router

class LandlordSpacesMaterial extends StatelessWidget {
  const LandlordSpacesMaterial({Key? key}) : super(key: key);

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
      body: FutureBuilder<List<SpaceModel>>(
        future: Provider.of<PostProvider>(context, listen: false)
            .fetchLandlordSpaces(FirebaseAuth.instance.currentUser!.uid),
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
