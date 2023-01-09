import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/helpers/loading_effect.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/wishlist_provider.dart';
import 'package:cloudkeja/widgets/space_tile.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
      ),
      body: FutureBuilder<List<SpaceModel>>(
        future: Provider.of<WishlistProvider>(context, listen: false)
            .fetchWishlist(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingEffect.getSearchLoadingScreen(context);
          }

          return ListView(
              children:
                  snapshot.data!.map((e) => SpacerTile(space: e)).toList());
        },
      ),
    );
  }
}
