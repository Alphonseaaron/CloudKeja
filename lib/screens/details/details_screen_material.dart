// import 'package:cloud_firestore/cloud_firestore.dart'; // Used for chat functionality only
// import 'package:firebase_auth/firebase_auth.dart'; // Used for chat functionality only
import 'package:flutter/cupertino.dart'; // For CupertinoIcons, consider replacing with Material
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Used by SpaceLocation
import 'package:provider/provider.dart';
// import 'package:cloudkeja/helpers/constants.dart'; // Old constants, replaced by theme
import 'package:cloudkeja/helpers/review_widget.dart'; // UserReview widget
import 'package:cloudkeja/models/chat_provider.dart'; // For chat
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/models/user_model.dart'; // For chat owner details
import 'package:cloudkeja/providers/auth_provider.dart'; // For current user ID in chat
import 'package:cloudkeja/screens/chat/chat_room.dart';
import 'package:cloudkeja/screens/details/space_location.dart';
import 'package:cloudkeja/screens/details/owner_tile.dart';
import 'package:cloudkeja/screens/details/space_reviews.dart';
import 'package:cloudkeja/screens/payment/payment_screen.dart';
import 'package:cloudkeja/widgets/about.dart';
import 'package:cloudkeja/widgets/content_intro.dart';
// import 'package:cloudkeja/widgets/details_app_bar.dart'; // Replaced by DetailsAppBarRouter
import 'package:cloudkeja/widgets/details_app_bar_router.dart'; // Import the router
import 'package:cloudkeja/widgets/house_info.dart';
import 'package:cloudkeja/widgets/unit_display_carousel.dart';

class DetailsScreenMaterial extends StatelessWidget { // Renamed class
  final SpaceModel space;
  const DetailsScreenMaterial({ // Renamed constructor
    Key? key,
    required this.space,
  }) : super(key: key);

  // Helper for section titles
  Widget _buildSectionTitle(BuildContext context, String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 12.0),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Helper for wrapping content sections
  Widget _buildSectionContent(Widget content) {
    return SliverToBoxAdapter(
      child: content, // ContentIntro, HouseInfo, etc. already have their own padding.
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Unit Counts Logic
    int totalUnits = space.units?.length ?? 0;
    int vacantUnits = space.units?.where((u) => u['status'] == 'vacant').length ?? 0; // Inlined status
    int availableUnits = space.units?.where((u) => u['status'] == 'vacant' || u['status'] == 'pending_move_out').length ?? 0; // Inlined status

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bool isOwner = authProvider.user?.userId == space.ownerId;

    return Scaffold(
      backgroundColor: colorScheme.background,
      // Using Stack to keep the bottom action bar persistent over scrollable content
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Use DetailsAppBarRouter now
              _buildSectionContent(DetailsAppBarRouter(space: space)),
              _buildSectionContent(const SizedBox(height: 16)), // Spacing after app bar
              _buildSectionContent(ContentIntro(space: space)),
              _buildSectionContent(const SizedBox(height: 16)),
              _buildSectionContent(const HouseInfo()), // Assumes HouseInfo has its own padding
              _buildSectionContent(OwnerTile(userId: space.ownerId)),
              _buildSectionContent(About(space: space)),

              // Unit Counts Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Unit Information', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (totalUnits > 0) ...[ // Only show if there's unit data
                        Text('Total Units: $totalUnits', style: textTheme.bodyLarge),
                        Text('Available Units (Vacant or Pending): $availableUnits', style: textTheme.bodyLarge),
                        Text('Strictly Vacant Units: $vacantUnits', style: textTheme.bodyLarge),
                        const SizedBox(height: 16),
                        UnitDisplayCarousel(
                          units: space.units ?? [],
                          isOwner: isOwner, // Pass the isOwner flag
                          spaceId: space.id!, // Pass the spaceId
                        ),
                      ] else ...[
                        Text('No unit information available for this property.', style: textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic)),
                      ],
                    ],
                  ),
                ),
              ),

              _buildSectionTitle(context, 'Reviews & Ratings'),
              _buildSectionContent(SpaceReviews(spaceId: space.id!)),
              SliverToBoxAdapter( // For the "Add Review" button
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.rate_review_outlined),
                    label: const Text('Write a Review'),
                    onPressed: () {
                      showDialog(
                        barrierDismissible: true, // Allow dismissing by tapping outside
                        context: context,
                        builder: (context) => AlertDialog( // Using AlertDialog for better M3 theming
                          contentPadding: EdgeInsets.zero, // UserReview has its own padding
                          // title: Text('Leave a Review', style: textTheme.titleLarge), // Title can be part of UserReview
                          content: UserReview(space.id!),
                          shape: theme.dialogTheme.shape, // Uses global DialogTheme shape
                        ),
                      );
                    },
                    // Style will come from OutlinedButtonThemeData
                  ),
                ),
              ),

              // SpaceLocation section (already includes its own title and padding)
              _buildSectionContent(SpaceLocation(
                location: (space.location != null)
                  ? LatLng(space.location!.latitude, space.location!.longitude)
                  : null, // Handle null location gracefully
                imageUrl: space.images?.first,
                spaceName: space.spaceName,
              )),

              const SliverToBoxAdapter(
                child: SizedBox(height: 100), // Space for the floating action bar at the bottom
              ),
            ],
          ),

          // Bottom Action Bar (Book Now & Chat)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)
                  .copyWith(bottom: MediaQuery.of(context).padding.bottom + 12.0), // Consider safe area
              decoration: BoxDecoration(
                color: colorScheme.surface, // Use surface color for background
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
                // border: Border(top: BorderSide(color: colorScheme.outline.withOpacity(0.5)))
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Check if user is owner - if so, disable booking
                        final currentUser = Provider.of<AuthProvider>(context, listen: false).user;
                        if (currentUser?.userId == space.ownerId) {
                           ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('You cannot book your own space.', style: TextStyle(color: colorScheme.onError)), backgroundColor: colorScheme.error),
                          );
                          return;
                        }
                        Get.to(() => PaymentScreen(space: space));
                      },
                      // Style will come from ElevatedButtonThemeData
                      // Ensure button height is adequate
                      style: theme.elevatedButtonTheme.style?.copyWith(
                        padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
                      ),
                      child: Text('Book Now', style: textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal( // M3 style icon button
                    onPressed: () async {
                      // Chat functionality (remains largely the same logic)
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      if (authProvider.user == null) {
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please log in to chat.', style: TextStyle(color: colorScheme.onError)), backgroundColor: colorScheme.error));
                         return;
                      }
                      if (authProvider.user?.userId == space.ownerId) {
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You cannot chat about your own space.', style: TextStyle(color: colorScheme.onError)), backgroundColor: colorScheme.error));
                         return;
                      }

                      // Simplified chat room ID logic (can be more robust)
                      String chatRoomId;
                      if (authProvider.user!.userId!.compareTo(space.ownerId!) > 0) {
                        chatRoomId = '${authProvider.user!.userId}_${space.ownerId}';
                      } else {
                        chatRoomId = '${space.ownerId}_${authProvider.user!.userId}';
                      }

                      // Fetch owner details for chat screen
                      UserModel? ownerDetails = await authProvider.getOwnerDetails(space.ownerId!);
                      if (ownerDetails != null) {
                         Navigator.of(context).pushNamed(ChatRoom.routeName, arguments: {
                           'user': ownerDetails, // The user to chat with (owner)
                           'chatRoomId': chatRoomId,
                         });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not load owner details for chat.', style: TextStyle(color: colorScheme.onError)), backgroundColor: colorScheme.error));
                      }
                    },
                    icon: Icon(Icons.chat_bubble_outline_rounded, color: colorScheme.onPrimaryContainer), // Changed to Material icon
                    // style: IconButton.styleFrom(
                    //   backgroundColor: colorScheme.primaryContainer, // M3 filledTonal uses this
                    //   foregroundColor: colorScheme.onPrimaryContainer,
                    //   padding: const EdgeInsets.all(16),
                    // ),
                     tooltip: 'Chat with Owner',
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
