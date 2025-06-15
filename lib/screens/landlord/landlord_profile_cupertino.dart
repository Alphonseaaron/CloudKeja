import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp in ChatRoom, GeoPoint
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // For current user ID
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/route_manager.dart'; // For Get.to for ChatRoom

import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/screens/chat/chat_room.dart'; // Assuming ChatRoom is adaptive or will be
import 'package:cloudkeja/widgets/space_tile.dart'; // Adaptive SpaceTile router

class LandlordProfileCupertino extends StatefulWidget {
  final UserModel user;
  const LandlordProfileCupertino({Key? key, required this.user}) : super(key: key);

  @override
  State<LandlordProfileCupertino> createState() => _LandlordProfileCupertinoState();
}

class _LandlordProfileCupertinoState extends State<LandlordProfileCupertino> {
  late Future<List<SpaceModel>> _landlordSpacesFuture;

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
    } else {
      _landlordSpacesFuture = Future.value([]);
    }
     // Trigger rebuild if future changes
    if(mounted) setState(() {});
  }


  Widget _buildCupertinoProfileHeader(BuildContext context, UserModel user) {
    final cupertinoTheme = CupertinoTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: CupertinoColors.systemGrey5.resolveFrom(context),
            backgroundImage: (user.profile != null && user.profile!.isNotEmpty)
                ? CachedNetworkImageProvider(user.profile!)
                : null,
            child: (user.profile == null || user.profile!.isEmpty)
                ? Icon(CupertinoIcons.person_fill, size: 50, color: CupertinoColors.systemGrey.resolveFrom(context))
                : null,
          ),
          const SizedBox(height: 12),
          if (user.email != null && user.email!.isNotEmpty)
            Text(
              user.email!,
              style: cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(fontSize: 14),
            ),
          const SizedBox(height: 4),
          if (user.phone != null && user.phone!.isNotEmpty)
            Text(
              user.phone!,
              style: cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(fontSize: 14),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final cupertinoTheme = CupertinoTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 16.0, top: 20.0, bottom: 8.0),
      child: Text(
        title,
        style: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(
          fontSize: 18,
          color: CupertinoColors.label.resolveFrom(context),
        ),
      ),
    );
  }

  void _showCupertinoFeedbackDialog(BuildContext context, String title, String content) {
    showCupertinoDialog(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            isDefaultAction: true,
            onPressed: () => Navigator.of(dialogCtx).pop(),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          CustomScrollView(
            slivers: <Widget>[
              CupertinoSliverNavigationBar(
                largeTitle: Text(widget.user.name ?? 'Landlord Profile'),
                // previousPageTitle: "Back", // Optional: customize back button text
                backgroundColor: cupertinoTheme.barBackgroundColor.withOpacity(0.7),
                border: Border(bottom: BorderSide(color: CupertinoColors.separator.resolveFrom(context), width: 0.5)),
              ),
              CupertinoSliverRefreshControl(onRefresh: () async { _fetchLandlordSpaces(); } ),
              SliverToBoxAdapter(
                child: _buildCupertinoProfileHeader(context, widget.user),
              ),
              SliverToBoxAdapter(
                child: _buildSectionHeader(context, 'Listings by ${widget.user.name?.split(' ').first ?? 'this Landlord'}'),
              ),
              FutureBuilder<List<SpaceModel>>(
                future: _landlordSpacesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(child: Center(child: CupertinoActivityIndicator(radius: 15)));
                  }
                  if (snapshot.hasError) {
                    return SliverFillRemaining(child: Center(child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Error: ${snapshot.error}', style: TextStyle(color: CupertinoColors.destructiveRed.resolveFrom(context))))));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                        child: Center(child: Text('No spaces listed by this landlord.', style: cupertinoTheme.textTheme.tabLabelTextStyle)),
                      ),
                    );
                  }
                  final spaces = snapshot.data!;
                  return SliverPadding( // Add padding around the list of SpaceTiles
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          // Using the adaptive SpaceTile router
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0), // Spacing between tiles
                            child: SpaceTile(space: spaces[index], isOwner: false), // isOwner typically false when viewing other's profile
                          );
                        },
                        childCount: spaces.length,
                      ),
                    ),
                  );
                },
              ),
              SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).padding.bottom + 80)), // Space for button
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16, // Respect safe area
            child: SizedBox( // Ensure button takes full width
              width: double.infinity,
              child: CupertinoButton.filled(
                child: const Text('Talk to Landlord'),
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final currentUser = authProvider.user;

                  if (currentUser == null) {
                    _showCupertinoFeedbackDialog(context, 'Login Required', 'Please log in to chat.');
                    return;
                  }
                  if (currentUser.userId == widget.user.userId) {
                    _showCupertinoFeedbackDialog(context, 'Chat Error', 'You cannot chat with yourself.');
                    return;
                  }

                  String chatRoomId = (currentUser.userId!.compareTo(widget.user.userId!) > 0)
                      ? '${currentUser.userId}_${widget.user.userId}'
                      : '${widget.user.userId}_${currentUser.userId}';

                  Get.to(() => ChatRoom(), arguments: {
                    'user': widget.user,
                    'chatRoomId': chatRoomId,
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
