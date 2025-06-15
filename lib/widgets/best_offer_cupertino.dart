import 'package:flutter/cupertino.dart';
import 'package:get/route_manager.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/screens/home/view_all_screen_router.dart'; // Use router
import 'package:cloudkeja/widgets/_best_offer_item_card_cupertino.dart'; // Import Cupertino item card

class BestOfferCupertinoWidget extends StatelessWidget {
  final List<SpaceModel> spaces;

  const BestOfferCupertinoWidget({Key? key, required this.spaces}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);

    if (spaces.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Best Offer',
                style: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label.resolveFrom(context), // Standard label color
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero, // Remove default padding for link-like appearance
                child: Text(
                  'See All',
                  style: cupertinoTheme.textTheme.actionTextStyle.copyWith( // Standard action text style
                     color: cupertinoTheme.primaryColor,
                     fontWeight: FontWeight.w600, // Make it slightly bolder like a link
                  ),
                ),
                onPressed: () {
                  Get.to(() => const ViewAllScreenRouter(title: 'Best Offers'));
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: spaces.length > 5 ? 5 : spaces.length, // Show up to 5 items
            itemBuilder: (context, index) {
              final space = spaces[index];
              // Each item is BestOfferItemCardCupertino, which has its own padding and border logic
              return BestOfferItemCardCupertino(space: space);
            },
          ),
        ],
      ),
    );
  }
}
