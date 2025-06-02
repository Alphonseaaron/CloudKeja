import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For NetworkImage, CachedNetworkImageProvider
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/models/chat_provider.dart'; // For ChatTileModel
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/screens/chat/chat_room.dart'; // For navigation

class ChatTileCupertino extends StatelessWidget {
  final ChatTileModel chatModel;

  const ChatTileCupertino({Key? key, required this.chatModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    final String? currentUserId = Provider.of<AuthProvider>(context, listen: false).user?.userId;

    if (chatModel.user == null) {
      return CupertinoListTile.notched(
        title: Text('Unknown User', style: cupertinoTheme.textTheme.textStyle),
        subtitle: Text('Error: User data missing', style: cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(color: CupertinoColors.systemRed.resolveFrom(context))),
      );
    }

    final UserModel userToChatWith = chatModel.user!;
    final bool hasUnread = chatModel.unreadCount > 0;

    return CupertinoListTile.notched(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0), // Standard padding
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: CupertinoColors.systemGrey5.resolveFrom(context),
            backgroundImage: (userToChatWith.profile != null && userToChatWith.profile!.isNotEmpty)
                ? CachedNetworkImageProvider(userToChatWith.profile!)
                : null,
            child: (userToChatWith.profile == null || userToChatWith.profile!.isEmpty)
                ? Icon(CupertinoIcons.person_fill, size: 28, color: CupertinoColors.systemGrey.resolveFrom(context))
                : null,
          ),
          if (hasUnread)
            Positioned(
              right: -2, // Adjust for visibility
              top: -2,  // Adjust for visibility
              child: Container(
                padding: const EdgeInsets.all(5), // Small padding for the badge
                decoration: BoxDecoration(
                  color: cupertinoTheme.primaryColor, // Use primary color for unread badge
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18), // Ensure circle shape
                child: Text(
                  chatModel.unreadCount.toString(),
                  style: cupertinoTheme.textTheme.caption1.copyWith(color: CupertinoColors.white, fontWeight: FontWeight.bold, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              userToChatWith.name ?? 'Chat User',
              style: cupertinoTheme.textTheme.textStyle.copyWith(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (userToChatWith.isAdmin == true) ...[
            const SizedBox(width: 4),
            Icon(CupertinoIcons.shield_lefthalf_fill, color: cupertinoTheme.primaryColor, size: 16),
          ],
        ],
      ),
      subtitle: Text(
        '${chatModel.latestMessageSenderId == currentUserId ? "You: " : ""}${chatModel.latestMessage ?? "No messages yet"}',
        style: cupertinoTheme.textTheme.tabLabelTextStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      additionalInfo: (chatModel.time != null) 
        ? Text(
            DateFormat('HH:mm').format(chatModel.time!.toDate()),
            style: cupertinoTheme.textTheme.tabLabelTextStyle,
          ) 
        : null,
      trailing: const CupertinoListTileChevron(),
      onTap: () {
        Navigator.of(context, rootNavigator: true).pushNamed(ChatRoom.routeName, arguments: { // Use rootNavigator for full screen modal presentation
          'user': userToChatWith,
          'chatRoomId': chatModel.chatRoomId!,
        });
      },
    );
  }
}
