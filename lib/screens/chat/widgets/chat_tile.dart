import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp, if used for time display
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting timestamp
import 'package:provider/provider.dart';
// import 'package:cloudkeja/helpers/constants.dart'; // kPrimaryColor replaced by theme
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/models/chat_provider.dart'; // For ChatTileModel
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/screens/chat/chat_room.dart';

class ChatTile extends StatelessWidget {
  // final String roomId; // roomId is part of chatModel
  final ChatTileModel chatModel;

  const ChatTile({Key? key, required this.chatModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final String? currentUserId = Provider.of<AuthProvider>(context, listen: false).user?.userId;

    if (chatModel.user == null) {
      // Handle cases where user data might be missing in the chatModel
      return ListTile(
        title: Text('Unknown User', style: textTheme.titleSmall),
        subtitle: Text('Error: User data missing', style: textTheme.bodySmall?.copyWith(color: colorScheme.error)),
      );
    }

    final userToChatWith = chatModel.user!;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Standard padding
      leading: CircleAvatar(
        radius: 28, // Slightly larger avatar
        backgroundColor: colorScheme.surfaceVariant, // Themed placeholder background
        backgroundImage: (userToChatWith.profile != null && userToChatWith.profile!.isNotEmpty)
            ? CachedNetworkImageProvider(userToChatWith.profile!)
            : null,
        child: (userToChatWith.profile == null || userToChatWith.profile!.isEmpty)
            ? Icon(Icons.person_outline_rounded, size: 28, color: colorScheme.onSurfaceVariant) // Themed placeholder icon
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              userToChatWith.name ?? 'Chat User', // Handle null name
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600), // Slightly bolder title
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (userToChatWith.isAdmin == true) ...[ // Check for isAdmin status
            const SizedBox(width: 4),
            Icon(Icons.verified_rounded, color: colorScheme.primary, size: 16),
          ],
        ],
      ),
      subtitle: Text(
        '${chatModel.latestMessageSenderId == currentUserId ? "You: " : ""}${chatModel.latestMessage ?? "No messages yet"}',
        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: (chatModel.time != null) ? Text(
        DateFormat('HH:mm').format(chatModel.time!.toDate()), // Format timestamp
        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
      ) : null, // No trailing widget if time is null
      onTap: () async {
        // Navigation logic remains similar
        // The chatRoomId is already part of chatModel
        Navigator.of(context).pushNamed(ChatRoom.routeName, arguments: {
          'user': userToChatWith, // Pass the UserModel of the person we are chatting with
          'chatRoomId': chatModel.chatRoomId!,
        });
      },
      // tileColor: tileColor, // For specific background if needed, default is transparent
      // selectedTileColor: selectedTileColor, // If selection state is managed
    );
  }
}
