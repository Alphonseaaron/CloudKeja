import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/screens/home/view_all_screen_router.dart'; // Use router
import 'package:cloudkeja/widgets/_best_offer_item_card_material.dart'; // Import Material item card

class BestOfferMaterialWidget extends StatelessWidget {
  final List<SpaceModel> spaces;

  const BestOfferMaterialWidget({Key? key, required this.spaces}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme; // For "See All" link

    if (spaces.isEmpty) {
      // Optionally, return a message or an empty container if there are no spaces
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
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onBackground, // Explicitly use theme color
                ),
              ),
              InkWell(
                onTap: () {
                  // Assuming ViewAllScreen is adaptive or use ViewAllScreenRouter if it exists
                  Get.to(() => const ViewAllScreenRouter(title: 'Best Offers'));
                },
                child: Text(
                  'See All',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
              return BestOfferItemCardMaterial(space: space); // Use Material item card
            },
          ),
        ],
      ),
    );
  }
}
