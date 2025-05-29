import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart'; // Replaced CupertinoIcons.search
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
// import 'package:cloudkeja/helpers/constants.dart'; // kPrimaryColor replaced by theme
import 'package:cloudkeja/helpers/loading_effect.dart'; // Themed loading effect
import 'package:cloudkeja/providers/auth_provider.dart'; // Not directly used in this build, but good for context
import 'package:cloudkeja/models/chat_provider.dart'; // For ChatTileModel and provider
import 'package:cloudkeja/screens/chat/chat_screen_search.dart';
import 'package:cloudkeja/screens/chat/widgets/chat_tile.dart'; // Will be themed separately
import 'package:skeletonizer/skeletonizer.dart'; // For skeleton loading of chat list

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);
  static const routeName = '/chat';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // For easy access to theme properties

    return Scaffold(
      // backgroundColor will be from AppTheme.lightTheme.scaffoldBackgroundColor
      appBar: AppBar(
        // elevation will be from AppTheme.lightTheme.appBarTheme.elevation
        // backgroundColor will be from AppTheme.lightTheme.appBarTheme.backgroundColor
        // titleTextStyle will be from AppTheme.lightTheme.appBarTheme.titleTextStyle
        title: const Text('Chats'), // Changed title for consistency
        actions: [
          IconButton(
            // iconTheme will be from AppTheme.lightTheme.appBarTheme.iconTheme
            icon: const Icon(Icons.search_outlined), // Material Design icon
            tooltip: 'Search Chats',
            onPressed: () {
              Get.to(() => const ChatScreenSearch());
            },
          ),
        ],
      ),
      body: const ChatScreenWidget(),
    );
  }
}

class ChatScreenWidget extends StatelessWidget {
  static const routeName = '/chat-screen-widget'; // Not typically used for nested widgets

  const ChatScreenWidget({Key? key}) : super(key: key);
  
  Widget _buildChatTileSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile( // Using ListTile structure for skeleton
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      leading: const CircleAvatar(radius: 28), // Skeletonizer will color this
      title: Container(height: 16, width: 120, color: Colors.transparent), // Skeletonizer colors
      subtitle: Container(height: 12, width: 180, color: Colors.transparent),
      trailing: Container(height: 10, width: 40, color: Colors.transparent), // For timestamp
    );
  }


  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (uid == null) {
      // Handle case where user is not logged in, though typically caught by auth guards earlier
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: 48),
            const SizedBox(height: 16),
            Text('Please log in to view your chats.', style: textTheme.bodyLarge),
          ],
        ),
      );
    }

    return FutureBuilder<List<ChatTileModel>>(
      future: Provider.of<ChatProvider>(context, listen: false).getChats(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Using Skeletonizer for a list of chat tiles
          return Skeletonizer(
            enabled: true,
            effect: ShimmerEffect(
              baseColor: colorScheme.surfaceVariant.withOpacity(0.4),
              highlightColor: colorScheme.surfaceVariant.withOpacity(0.8),
            ),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: 5, // Number of skeleton items
              itemBuilder: (context, index) => _buildChatTileSkeleton(context),
              separatorBuilder: (context, index) => Divider(indent: 16, endIndent: 16, height: 1, color: colorScheme.outline.withOpacity(0.2)),
            ),
          );
          // return LoadingEffect.getSearchLoadingScreen(context); // Already themed, but Skeletonizer is more specific here
        }

        if (snapshot.hasError) {
           return Center(
             child: Padding(
               padding: const EdgeInsets.all(16.0),
               child: Text('Error loading chats: ${snapshot.error}', style: textTheme.bodyMedium?.copyWith(color: colorScheme.error)),
             ),
           );
        }

        final contacts = snapshot.data;

        if (contacts == null || contacts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0), // Increased padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded, // Themed icon
                    size: 80,
                    color: colorScheme.primary.withOpacity(0.3), // Softer color
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Chats Available Yet', // Updated main message
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge?.copyWith( // More prominent
                      color: colorScheme.onBackground.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Start a conversation with a landlord or service provider. Your messages will appear here.', // Updated sub-text
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.6),
                      height: 1.5, // Improved line height
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8.0), // Padding for the list
          itemCount: contacts.length,
          itemBuilder: (context, index) => ChatTile( // ChatTile will be themed next
            roomId: contacts[index].chatRoomId!,
            chatModel: contacts[index],
          ),
          separatorBuilder: (context, index) => Divider(
            indent: 72, // Indent past avatar and some padding
            endIndent: 16,
            height: 1,
            color: colorScheme.outline.withOpacity(0.2), // Themed divider
          ),
        );
      },
    );
  }
}
