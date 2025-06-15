import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/chat_provider.dart'; // For ChatProvider, though not directly used, ChatRoom might need it
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/screens/chat/chat_room.dart'; // Assuming ChatRoom is adaptive or Material
import 'package:cloudkeja/screens/profile/user_profile_material.dart'; // Assuming UserProfileDetails is here or adaptive
import 'package:cloudkeja/widgets/recommended_house.dart'; // Assuming adaptive or Material
import 'package:skeletonizer/skeletonizer.dart';
import 'package:get/route_manager.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For profile image


class LandlordProfileMaterial extends StatefulWidget {
  const LandlordProfileMaterial({Key? key, required this.user}) : super(key: key);
  final UserModel user;

  @override
  State<LandlordProfileMaterial> createState() => _LandlordProfileMaterialState();
}

class _LandlordProfileMaterialState extends State<LandlordProfileMaterial> {
  late Future<List<SpaceModel>> _landlordSpacesFuture;
  bool _isLoadingSpaces = true; // Kept for clarity, though FutureBuilder handles connectionState

  @override
  void initState() {
    super.initState();
    _fetchLandlordSpaces();
  }

  void _fetchLandlordSpaces() {
    // Ensure context is available and widget is mounted for Provider.of
    if (mounted) {
      _landlordSpacesFuture = Provider.of<PostProvider>(context, listen: false)
          .fetchLandlordSpaces(widget.user.userId!);
      // No need to manually set _isLoadingSpaces to false here, FutureBuilder handles it
    } else {
      // Handle case where context might not be available (e.g., if called before build)
      // For initState, it's generally safe, but good practice for other scenarios.
      _landlordSpacesFuture = Future.value([]); // Return empty list or error
    }
  }


  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 12.0),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground),
      ),
    );
  }

  Widget _buildListingsSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Use a local or imported SpaceModel.empty()
    final mockSpaces = List.generate(2, (index) => _emptySpaceModelForSkeleton());

    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: colorScheme.surfaceVariant.withOpacity(0.4),
        highlightColor: colorScheme.surfaceVariant.withOpacity(0.8),
      ),
      child: RecommendedHouse(spaces: mockSpaces, title: '',), // Pass empty title or no title if not needed for skeleton
    );
  }

  // Local helper for skeleton to avoid conflicts if SpaceModel.empty() is not universally defined
  SpaceModel _emptySpaceModelForSkeleton() {
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


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: size.height * 0.28,
                pinned: true,
                floating: false,
                elevation: 1.0,
                backgroundColor: colorScheme.surface,
                foregroundColor: colorScheme.onSurface,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  centerTitle: false,
                  title: Text(
                    widget.user.name ?? 'Landlord Profile',
                    style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
                  ),
                  background: (widget.user.profile != null && widget.user.profile!.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: widget.user.profile!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: colorScheme.surfaceVariant),
                          errorWidget: (context, url, error) =>
                            Container(color: colorScheme.surfaceVariant, child: Icon(Icons.person_outline_rounded, size: 100, color: colorScheme.onSurfaceVariant)),
                        )
                      : Container(color: colorScheme.surfaceVariant, child: Icon(Icons.person_outline_rounded, size: 100, color: colorScheme.onSurfaceVariant)),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  // Assuming UserProfileDetailsMaterial is the Material version or an adaptive router
                  UserProfileDetailsMaterial(user: widget.user),

                  _buildSectionTitle(context, 'Listings by ${widget.user.name?.split(' ').first ?? 'this Landlord'}'),
                  FutureBuilder<List<SpaceModel>>(
                    future: _landlordSpacesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                          child: Center(child: Text('No spaces listed by this landlord.', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant))),
                        );
                      }
                      // Assuming RecommendedHouse is adaptive or Material
                      return RecommendedHouse(spaces: snapshot.data!, title: ''); // Pass empty title or adjust RecommendedHouse
                    },
                  ),
                  const SizedBox(height: 80),
                ]),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0).copyWith(
                bottom: MediaQuery.of(context).padding.bottom + 12.0,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
                // Optional: Add top border
                // border: Border(top: BorderSide(color: colorScheme.outline.withOpacity(0.2)))
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

                  String chatRoomId;
                  if (currentUser.userId!.compareTo(widget.user.userId!) > 0) {
                    chatRoomId = '${currentUser.userId}_${widget.user.userId}';
                  } else {
                    chatRoomId = '${widget.user.userId}_${currentUser.userId}';
                  }

                  // Ensure ChatRoom is adaptive or use Material version
                  Get.to(() => ChatRoom(), arguments: {
                    'user': widget.user,
                    'chatRoomId': chatRoomId,
                  });
                },
                style: ElevatedButton.styleFrom( // Ensure button style is applied
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
