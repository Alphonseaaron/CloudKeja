import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/helpers/loading_effect.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/widgets/space_tile.dart';

class LandlordSpaces extends StatelessWidget {
  const LandlordSpaces({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Spaces')),
      body: FutureBuilder<List<SpaceModel>>(
        future: Provider.of<PostProvider>(context, listen: false)
            .fetchLandlordSpaces(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingEffect.getSearchLoadingScreen(context);
          }

          return ListView(
              children: snapshot.data!
                  .map((e) => Container(
                      margin: const EdgeInsets.all(10),
                      child: SpacerTile(
                        space: e,
                        isOwner: true,
                      )))
                  .toList());
        },
      ),
    );
  }
}
