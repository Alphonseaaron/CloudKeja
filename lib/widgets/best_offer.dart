import 'package:flutter/widgets.dart'; // For StatelessWidget, BuildContext, Key
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/space_model.dart'; // For SpaceModel type
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/widgets/best_offer_material.dart';
import 'package:cloudkeja/widgets/best_offer_cupertino.dart';

// Renamed original BestOffer to BestOfferRouter to act as the router
class BestOfferRouter extends StatelessWidget {
  final List<SpaceModel> spaces;

  const BestOfferRouter({
    Key? key,
    required this.spaces,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      return BestOfferCupertinoWidget(
        key: key, // Pass key
        spaces: spaces,
      );
    } else {
      return BestOfferMaterialWidget(
        key: key, // Pass key
        spaces: spaces,
      );
    }
  }
}

// _BestOfferItemCard and _BestOfferItemCardState classes were removed from this file
// in a previous step. This file now only contains the router.
// The placeholder in the ListView.builder from the previous step is implicitly gone
// as this whole build method is replaced by the router logic.
