import 'package:cloud_firestore/cloud_firestore.dart'; // For chat functionality
import 'package:firebase_auth/firebase_auth.dart'; // For current user ID in chat
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:cloudkeja/helpers/constants.dart'; // kPrimaryColor replaced by theme
// import 'package:cloudkeja/helpers/loading_effect.dart'; // Replaced by Skeletonizer
import 'package:cloudkeja/models/chat_provider.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart'; // For current user ID in chat
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/screens/chat/chat_room.dart';
import 'package:cloudkeja/screens/profile/user_profile.dart'; // Contains UserProfileDetails
import 'package:cloudkeja/widgets/recommended_house.dart'; // Already refactored
import 'package:skeletonizer/skeletonizer.dart'; // For skeleton loading
import 'package:get/route_manager.dart'; // For navigation

class LandlordProfile extends StatefulWidget { // Changed to StatefulWidget for loading state
  const LandlordProfile({Key? key, required this.user}) : super(key: key);
  final UserModel user;

  @override
  State<LandlordProfile> createState() => _LandlordProfileState();
}

class _LandlordProfileState extends State<LandlordProfile> {
  late Future<List<SpaceModel>> _landlordSpacesFuture;
  bool _isLoadingSpaces = true;

  @override
  void initState() {
    super.initState();
    _landlordSpacesFuture = Provider.of<PostProvider>(context, listen: false)
        .fetchLandlordSpaces(widget.user.userId!);
    _landlordSpacesFuture.whenComplete(() {
      if (mounted) setState(() => _isLoadingSpaces = false);
    });
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Placeholder for listings skeleton
  Widget _buildListingsSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mockSpaces = List.generate(2, (index) => SpaceModel.empty()); // Use the extension

    return Skeletonizer(
      enabled: true, // Always enabled when this widget is shown
      effect: ShimmerEffect(
        baseColor: colorScheme.surfaceVariant.withOpacity(0.4),
        highlightColor: colorScheme.surfaceVariant.withOpacity(0.8),
      ),
      child: RecommendedHouse(spaces: mockSpaces), // Use the existing RecommendedHouse for structure
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colorScheme.background,
      // Using CustomScrollView for a more flexible layout, including a proper app bar
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: size.height * 0.28, // Adjust as needed
                pinned: true, // App bar stays visible
                floating: false, // Does not float
                elevation: 1.0, // Subtle elevation for app bar
                backgroundColor: colorScheme.surface, // Themed AppBar background
                foregroundColor: colorScheme.onSurface, // For back button and title
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  centerTitle: false, // Align title to the left
                  title: Text(
                    widget.user.name ?? 'Landlord Profile',
                    style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface), // Themed title
                  ),
                  background: (widget.user.profile != null && widget.user.profile!.isNotEmpty)
                      ? Image.network(
                          widget.user.profile!,
                          fit: BoxFit.cover,
                          // Add error builder for network image
                          errorBuilder: (context, error, stackTrace) =>
                            Container(color: colorScheme.surfaceVariant, child: Icon(Icons.person, size: 100, color: colorScheme.onSurfaceVariant)),
                        )
                      : Container(color: colorScheme.surfaceVariant, child: Icon(Icons.person, size: 100, color: colorScheme.onSurfaceVariant)),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  // UserProfileDetails is already refactored and themed
                  UserProfileDetails(user: widget.user),

                  _buildSectionTitle(context, 'Listings by ${widget.user.name?.split(' ').first ?? 'this Landlord'}'),
                  FutureBuilder<List<SpaceModel>>(
                    future: _landlordSpacesFuture,
                    builder: (context, snapshot) {
                      if (_isLoadingSpaces) { // Use local loading state
                        return _buildListingsSkeleton(context);
                      }
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Error loading spaces: ${snapshot.error}', style: textTheme.bodyMedium?.copyWith(color: colorScheme.error)),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(child: Text('No spaces listed by this landlord.', style: textTheme.bodyMedium)),
                        );
                      }
                      // RecommendedHouse is already refactored and themed
                      return RecommendedHouse(spaces: snapshot.data!);
                    },
                  ),
                  const SizedBox(height: 80), // Space for the bottom button
                ]),
              ),
            ],
          ),

          // Positioned "Talk to Landlord" Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0).copyWith(
                bottom: MediaQuery.of(context).padding.bottom + 12.0, // Respect safe area
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface, // Themed background for button container
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Talk to Landlord'),
                onPressed: () async {
                   final authProvider = Provider.of<AuthProvider>(context, listen: false);
                   final currentUser = authProvider.user;

                   if (currentUser == null) {
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please log in to chat.', style: TextStyle(color: colorScheme.onError)), backgroundColor: colorScheme.error));
                     return;
                   }
                   if (currentUser.userId == widget.user.userId) {
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You cannot chat with yourself.', style: TextStyle(color: colorScheme.onError)), backgroundColor: colorScheme.error));
                     return;
                   }

                  // Simplified chat room ID logic
                  String chatRoomId;
                  if (currentUser.userId!.compareTo(widget.user.userId!) > 0) {
                    chatRoomId = '${currentUser.userId}_${widget.user.userId}';
                  } else {
                    chatRoomId = '${widget.user.userId}_${currentUser.userId}';
                  }

                  // The user model for the landlord is already available in widget.user
                  Get.to(() => ChatRoom(), arguments: { // Using Get.to for navigation
                    'user': widget.user,
                    'chatRoomId': chatRoomId,
                  });
                },
                // Style will come from ElevatedButtonThemeData
                style: theme.elevatedButtonTheme.style?.copyWith(
                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// Extension for SpaceModel to create an empty model for skeletonizer if not already present globally
// Ensure this or a similar helper is available.
// If SpaceModel.empty() is defined elsewhere (e.g. in home.dart's context), this might be redundant.
// For safety, defining it here if it's not globally accessible.
extension EmptySpaceModelForLandlordProfile on SpaceModel { // Renamed to avoid conflict
  static SpaceModel empty() { // If SpaceModel.empty() is not accessible here
    return SpaceModel(
      id: 'skeleton_landlord_space',
      spaceName: 'Loading Space...',
      address: 'Loading address...',
      price: 0.0,
      images: ['https://via.placeholder.com/230x300/F0F0F0/AAAAAA?text=Loading...'],
      description: 'Loading description...',
      isAvailable: true,
      ownerId: 'skeleton_owner',
      category: 'skeleton_category',
    );
  }
}
