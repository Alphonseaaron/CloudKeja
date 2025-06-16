import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For some Material Icons used as placeholders & ScaffoldMessenger (replace with Cupertino alternatives)
import 'package:provider/provider.dart';
import 'package:get/route_manager.dart'; // For Get.to if used for navigation
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Used by SpaceLocation

import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/widgets/details_app_bar_router.dart'; // Router for platform-specific app bar
// Cupertino specific versions of sub-widgets will be needed or these need to be adaptive
import 'package:cloudkeja/widgets/content_intro.dart'; // Assuming this can be styled neutrally or adapted
import 'package:cloudkeja/widgets/house_info.dart';    // Same assumption
import 'package:cloudkeja/screens/details/owner_tile.dart'; // Same assumption
import 'package:cloudkeja/widgets/about.dart';          // Same assumption
import 'package:cloudkeja/screens/details/space_reviews.dart'; // Same assumption
import 'package:cloudkeja/helpers/review_widget.dart';      // UserReview for dialog
import 'package:cloudkeja/screens/details/space_location.dart';
import 'package:cloudkeja/screens/payment/payment_screen.dart'; // Assuming this screen is adaptive or will be handled by its own router
import 'package:cloudkeja/screens/chat/chat_room.dart'; // Assuming this screen is adaptive or will be handled by its own router
import 'package:cloudkeja/widgets/unit_display_carousel.dart';


class DetailsScreenCupertino extends StatelessWidget {
  final SpaceModel space;

  const DetailsScreenCupertino({
    Key? key,
    required this.space,
  }) : super(key: key);

  // Helper for section titles - Cupertino style
  Widget _buildSectionTitle(BuildContext context, String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 8.0),
        child: Text(
          title,
          style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(fontSize: 20),
        ),
      ),
    );
  }
  
  // Helper for wrapping content sections
  Widget _buildSectionContent(Widget content) {
    return SliverToBoxAdapter(
      child: Padding(
        // Standard padding for content sections, can be adjusted
        padding: const EdgeInsets.symmetric(horizontal: 0), // Content widgets should handle their own internal padding
        child: content,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);

    // Unit Counts Logic
    int totalUnits = space.units?.length ?? 0;
    int vacantUnits = space.units?.where((u) => u['status'] == 'vacant').length ?? 0; // Inlined status
    int availableUnits = space.units?.where((u) => u['status'] == 'vacant' || u['status'] == 'pending_move_out').length ?? 0; // Inlined status

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bool isOwner = authProvider.user?.userId == space.ownerId;

    // TODO: Adapt ContentIntro, HouseInfo, OwnerTile, About, SpaceReviews, UserReview, SpaceLocation
    // to be more Cupertino-styled or create Cupertino variants if they are too Material-specific.
    // For now, they are used as-is.

    return CupertinoPageScaffold(
      // No navigationBar here, as DetailsAppBarRouter handles the top area including back button
      // backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(context), // Or specific color
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: DetailsAppBarRouter(space: space)), // Platform-aware app bar
              _buildSectionContent(const SizedBox(height: 16)),
              _buildSectionContent(ContentIntro(space: space)), // Needs review for Cupertino look
              _buildSectionContent(const SizedBox(height: 16)),
              _buildSectionContent(const HouseInfo()), // Needs review
              _buildSectionContent(OwnerTile(userId: space.ownerId)), // Needs review
              _buildSectionContent(About(space: space)), // Needs review

              // Unit Counts Section (Cupertino styled)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Standard padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unit Information',
                        style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      if (totalUnits > 0) ...[
                        Text('Total Units: $totalUnits', style: CupertinoTheme.of(context).textTheme.textStyle),
                        Text('Available Units (Vacant or Pending): $availableUnits', style: CupertinoTheme.of(context).textTheme.textStyle),
                        Text('Strictly Vacant Units: $vacantUnits', style: CupertinoTheme.of(context).textTheme.textStyle),
                        const SizedBox(height: 16),
                        UnitDisplayCarousel(
                          units: space.units ?? [],
                          isOwner: isOwner, // Pass the isOwner flag
                          spaceId: space.id!, // Pass the spaceId
                        ), // The carousel is Material-based for now
                      ] else ...[
                         Text('No unit information available for this property.', style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(fontStyle: FontStyle.italic)),
                      ],
                    ],
                  ),
                ),
              ),

              _buildSectionTitle(context, 'Reviews & Ratings'),
              _buildSectionContent(SpaceReviews(spaceId: space.id!)), // Needs review
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: CupertinoButton(
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.pen, size: 20), // Using Cupertino icon
                        SizedBox(width: 8),
                        Text('Write a Review'),
                      ],
                    ),
                    onPressed: () {
                      showCupertinoDialog( // Using CupertinoDialog
                        context: context,
                        builder: (context) => CupertinoAlertDialog( // Or CupertinoPopupSurface for more custom content
                          title: const Text('Leave a Review'),
                          content: UserReview(space.id!), // UserReview needs to be Cupertino-friendly
                          actions: [
                            CupertinoDialogAction(
                              child: const Text('Cancel'),
                              isDestructiveAction: true,
                              onPressed: () => Navigator.pop(context),
                            ),
                            // Assuming UserReview has its own submit logic that pops
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              _buildSectionContent(SpaceLocation( // Needs review for Cupertino map controls if any
                location: (space.location != null)
                  ? LatLng(space.location!.latitude, space.location!.longitude)
                  : null,
                imageUrl: space.images?.first,
                spaceName: space.spaceName,
              )),
              const SliverToBoxAdapter(
                child: SizedBox(height: 110), // Space for the floating action bar
              ),
            ],
          ),

          // Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0)
                  .copyWith(bottom: MediaQuery.of(context).padding.bottom + 12.0),
              decoration: BoxDecoration(
                color: cupertinoTheme.barBackgroundColor.withOpacity(0.95), // Translucent bar
                border: Border(top: BorderSide(color: CupertinoColors.separator.resolveFrom(context), width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoButton.filled(
                      padding: const EdgeInsets.symmetric(vertical: 14), // Make button taller
                      onPressed: () {
                        final currentUser = Provider.of<AuthProvider>(context, listen: false).user;
                        if (currentUser?.userId == space.ownerId) {
                           showCupertinoDialog(context: context, builder: (ctx) => CupertinoAlertDialog(title: const Text('Action Denied'), content: const Text('You cannot book your own space.'), actions: [CupertinoDialogAction(isDefaultAction: true, child: const Text('OK'), onPressed: ()=> Navigator.pop(ctx))]));
                          return;
                        }
                        Get.to(() => PaymentScreen(space: space)); // Assuming PaymentScreen is adaptive or routed
                      },
                      child: const Text('Book Now', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CupertinoButton(
                    padding: const EdgeInsets.all(12), // Ensure tappable area
                    onPressed: () async {
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      if (authProvider.user == null) {
                         showCupertinoDialog(context: context, builder: (ctx) => CupertinoAlertDialog(title: const Text('Login Required'), content: const Text('Please log in to chat.'), actions: [CupertinoDialogAction(isDefaultAction: true, child: const Text('OK'), onPressed: ()=> Navigator.pop(ctx))]));
                         return;
                      }
                      if (authProvider.user?.userId == space.ownerId) {
                        showCupertinoDialog(context: context, builder: (ctx) => CupertinoAlertDialog(title: const Text('Action Denied'), content: const Text('You cannot chat about your own space.'), actions: [CupertinoDialogAction(isDefaultAction: true, child: const Text('OK'), onPressed: ()=> Navigator.pop(ctx))]));
                         return;
                      }
                      String chatRoomId;
                      if (authProvider.user!.userId!.compareTo(space.ownerId!) > 0) {
                        chatRoomId = '${authProvider.user!.userId}_${space.ownerId}';
                      } else {
                        chatRoomId = '${space.ownerId}_${authProvider.user!.userId}';
                      }
                      UserModel? ownerDetails = await authProvider.getOwnerDetails(space.ownerId!);
                      if (ownerDetails != null) {
                         Navigator.of(context).pushNamed(ChatRoom.routeName, arguments: {'user': ownerDetails, 'chatRoomId': chatRoomId});
                      } else {
                         showCupertinoDialog(context: context, builder: (ctx) => CupertinoAlertDialog(title: const Text('Error'), content: const Text('Could not load owner details for chat.'), actions: [CupertinoDialogAction(isDefaultAction: true, child: const Text('OK'), onPressed: ()=> Navigator.pop(ctx))]));
                      }
                    },
                    child: Icon(CupertinoIcons.chat_bubble_2_fill, size: 28, color: cupertinoTheme.primaryColor),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
