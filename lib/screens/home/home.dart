import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/helpers/loading_effect.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/post_provider.dart';

import 'package:cloudkeja/widgets/recommended_house.dart';
import 'package:cloudkeja/widgets/custom_app_bar.dart';
import 'package:cloudkeja/widgets/search_input.dart';
import 'package:cloudkeja/widgets/welcome_text.dart';
import 'package:cloudkeja/widgets/categories.dart';
import 'package:cloudkeja/widgets/best_offer.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: const CustomAppBar(),
      body: FutureBuilder<List<SpaceModel>>(
          future: Provider.of<PostProvider>(context, listen: false).getSpaces(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingEffect.getSearchLoadingScreen(context);
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const WelcomeText(),
                  const SearchInput(),
                  const Categories(),
                  RecommendedHouse(
                    spaces: snapshot.data!,
                  ),
                  BestOffer(
                    spaces: snapshot.data!,
                  ),
                ],
              ),
            );
          }),
    );
  }
}
