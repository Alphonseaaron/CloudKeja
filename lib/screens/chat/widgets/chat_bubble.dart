import 'package:flutter/material.dart';
import 'package:get/route_manager.dart'; // For Get.to()
import 'package:intl/intl.dart'; // For DateFormat
import 'package:provider/provider.dart'; // For AuthProvider
import 'package:cloudkeja/helpers/cached_image.dart'; // Assuming this is a helper for CachedNetworkImage
import 'package:cloudkeja/helpers/full_screen_image.dart'; // For viewing full image
import 'package:cloudkeja/providers/auth_provider.dart';
// import 'dart:ui' as ui; // No longer needed for custom painter
import 'package:cloudkeja/models/message_model.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  const ChatBubble({Key? key, required this.message}) : super(key: key); // Corrected constructor

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final size = MediaQuery.of(context).size;
    final currentUserId = Provider.of<AuthProvider>(context, listen: false).user?.userId;
    final bool isMe = currentUserId == message.senderId;

    // Define bubble properties based on sender
    final Alignment bubbleAlignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final Color bubbleColor = isMe ? colorScheme.primary : colorScheme.surfaceVariant;
    final Color textColor = isMe ? colorScheme.onPrimary : colorScheme.onSurfaceVariant;
    final Color timestampColor = isMe 
        ? colorScheme.onPrimary.withOpacity(0.8) 
        : colorScheme.onSurfaceVariant.withOpacity(0.7);

    final BorderRadius bubbleBorderRadius = isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(4), // "Tail" effect
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(4), // "Tail" effect
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          );

    Widget messageContent;

    if (message.mediaUrl != null && message.mediaUrl!.isNotEmpty) {
      // Media message (image)
      messageContent = GestureDetector(
        onTap: () {
          Get.to(() => FullscreenImage(image: message.mediaUrl!));
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Consistent margin
          constraints: BoxConstraints(
            maxWidth: size.width * 0.65, // Max width for media
            maxHeight: size.height * 0.4, // Max height for media
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12), // Consistent border radius for images
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                cachedImage(message.mediaUrl!, fit: BoxFit.cover), // Assuming cachedImage handles placeholder/error
                if (message.sentAt != null)
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      DateFormat('HH:mm').format(message.sentAt!.toDate()),
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white, // Timestamp on image usually white
                        shadows: [
                          Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 2, offset: const Offset(0,1))
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Text message
      messageContent = Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0), // Adjusted padding
        constraints: BoxConstraints(maxWidth: size.width * 0.75), // Max width for text bubbles
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: bubbleBorderRadius,
        ),
        child: Column( // Use Column to arrange text and timestamp
          crossAxisAlignment: CrossAxisAlignment.start, // Text aligns left in bubble
          mainAxisSize: MainAxisSize.min, // Bubble wraps content
          children: [
            if (message.message != null && message.message!.isNotEmpty)
              Text(
                message.message!,
                style: textTheme.bodyMedium?.copyWith(color: textColor, height: 1.4), // Improved line height
              ),
            if (message.sentAt != null) ...[
              const SizedBox(height: 4), // Space between message and timestamp
              Align( // Align timestamp to the right within the bubble
                alignment: Alignment.centerRight,
                child: Text(
                  DateFormat('HH:mm').format(message.sentAt!.toDate()),
                  style: textTheme.bodySmall?.copyWith(color: timestampColor),
                ),
              ),
            ]
          ],
        ),
      );
    }

    return Align( // Use Align to position the bubble left or right
      alignment: bubbleAlignment,
      child: messageContent,
    );
  }
}

// BubbleBackground, BubblePainter, and myColors list are no longer needed and have been removed.
