import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For Skeletonizer, ShimmerEffect - consider alternatives if available
import 'package:provider/provider.dart';
import 'package:get/route_manager.dart'; // For Get.to

import 'package:cloudkeja/models/chat_provider.dart'; // For ChatTileModel and provider
import 'package:cloudkeja/screens/chat/widgets/chat_tile_cupertino.dart'; // Use Cupertino ChatTile
import 'package:cloudkeja/screens/chat/chat_screen_search.dart'; // Assuming this screen can be used or will be adapted
import 'package:skeletonizer/skeletonizer.dart';


class ChatScreenCupertino extends StatelessWidget {
  const ChatScreenCupertino({Key? key}) : super(key: key);
  // static const routeName = '/chat-cupertino'; // If direct navigation needed

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Chats'),
        // TODO: Consider adding a search icon or new chat icon if desired for Cupertino
        // trailing: CupertinoButton(
        //   padding: EdgeInsets.zero,
        //   child: Icon(CupertinoIcons.search),
        //   onPressed: () => Get.to(() => const ChatScreenSearch()),
        // ),
      ),
      child: ChatScreenWidgetCupertino(),
    );
  }
}

class ChatScreenWidgetCupertino extends StatefulWidget {
  const ChatScreenWidgetCupertino({Key? key}) : super(key: key);

  @override
  State<ChatScreenWidgetCupertino> createState() => _ChatScreenWidgetCupertinoState();
}

class _ChatScreenWidgetCupertinoState extends State<ChatScreenWidgetCupertino> {
  Future<List<ChatTileModel>>? _chatsFuture;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
    if (_uid != null) {
      _loadChats();
    }
  }

  void _loadChats({bool forceRefresh = false}) {
    if (_uid != null) {
      setState(() {
        _chatsFuture = Provider.of<ChatProvider>(context, listen: false).getChats(_uid!, forceRefresh: forceRefresh);
      });
    }
  }
  
  // Note: Skeletonizer is Material-based. For pure Cupertino, custom skeleton items would be better.
  // Using it here for expediency, assuming it can be styled neutrally enough.
  Widget _buildChatTileSkeleton(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    return CupertinoListTile.notched(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      leading: CircleAvatar(radius: 28, backgroundColor: CupertinoColors.systemGrey5.resolveFrom(context)),
      title: Container(height: 16, width: 120, color: CupertinoColors.systemGrey5.resolveFrom(context)),
      subtitle: Container(height: 12, width: 180, color: CupertinoColors.systemGrey5.resolveFrom(context)),
      additionalInfo: Container(height: 10, width: 40, color: CupertinoColors.systemGrey5.resolveFrom(context)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final String? uid = FirebaseAuth.instance.currentUser?.uid; // Now using _uid state
    final cupertinoTheme = CupertinoTheme.of(context);

    if (_uid == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.exclamationmark_octagon, color: CupertinoColors.systemRed.resolveFrom(context), size: 48),
            const SizedBox(height: 16),
            Text('Please log in to view your chats.', style: cupertinoTheme.textTheme.textStyle),
          ],
        ),
      );
    }

    return FutureBuilder<List<ChatTileModel>>(
      future: _chatsFuture, // Use state variable for future
      builder: (context, snapshot) {
        bool isLoading = snapshot.connectionState == ConnectionState.waiting; // Simpler loading check for FutureBuilder

        if (isLoading && (snapshot.data == null || snapshot.data!.isEmpty)) { // Show skeleton if loading and no data yet
          final cupertinoTheme = CupertinoTheme.of(context); // Needed for colors
          final shimmerBaseColor = CupertinoColors.systemGrey5.resolveFrom(context);
          final shimmerHighlightColor = CupertinoColors.systemGrey4.resolveFrom(context);

          return Skeletonizer( 
            enabled: true,
            effect: ShimmerEffect(
              baseColor: shimmerBaseColor,
              highlightColor: shimmerHighlightColor,
              period: const Duration(milliseconds: 1500), // Standard shimmer period
            ),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: 5, // Number of skeleton items
              itemBuilder: (context, index) => _buildChatTileSkeleton(context),
              separatorBuilder: (context, index) => Divider(indent: 72, endIndent: 16, height: 0.5, color: CupertinoColors.separator.resolveFrom(context)),
            ),
          );
        }

        if (snapshot.hasError) {
           return Center(
             child: Padding(
               padding: const EdgeInsets.all(16.0),
               child: Text('Error loading chats: ${snapshot.error}', style: cupertinoTheme.textTheme.textStyle.copyWith(color: CupertinoColors.systemRed.resolveFrom(context))),
             ),
           );
        }

        final contacts = snapshot.data;

        if (contacts == null || contacts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.chat_bubble_2, size: 80, color: CupertinoColors.systemGrey2.resolveFrom(context)),
                  const SizedBox(height: 24),
                  Text('No Chats Available Yet', textAlign: TextAlign.center, style: cupertinoTheme.textTheme.navTitleTextStyle),
                  const SizedBox(height: 12),
                  Text(
                    'Start a conversation. Your messages will appear here.',
                    textAlign: TextAlign.center,
                    style: cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          );
        }

        // Using CustomScrollView for potential CupertinoSliverRefreshControl
        return CustomScrollView(
          slivers: <Widget>[
            CupertinoSliverRefreshControl(
              onRefresh: () async {
                _loadChats(forceRefresh: true);
              },
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  if (index.isOdd) { // Separator
                    return Divider(indent: 72, endIndent: 16, height: 0.5, color: CupertinoColors.separator.resolveFrom(context));
                  }
                  final itemIndex = index ~/ 2;
                  if (itemIndex >= contacts.length) return null;
                  
                  return ChatTileCupertino(chatModel: contacts[itemIndex]);
                },
                childCount: contacts.length * 2 -1, // Account for separators
              ),
            ),
          ],
        );
      },
    );
  }
}
