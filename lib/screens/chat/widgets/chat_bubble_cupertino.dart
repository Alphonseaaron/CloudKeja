import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For Get.to, CachedNetworkImageProvider
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For image bubbles
import 'package:get/route_manager.dart'; // For Get.to for FullscreenImage

import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/models/message_model.dart';
import 'package:cloudkeja/helpers/full_screen_image.dart'; // Assuming this is a shared/generic widget

class ChatBubbleCupertino extends StatelessWidget {
  final MessageModel message;

  const ChatBubbleCupertino({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    final String? currentUserId = Provider.of<AuthProvider>(context, listen: false).user?.userId;
    final bool isMe = currentUserId == message.senderId;
    final Brightness brightness = CupertinoTheme.brightnessOf(context);
    final bool isDarkMode = brightness == Brightness.dark;

    final Color myBubbleColor = isDarkMode 
        ? CupertinoColors.activeBlue.darkColor 
        : CupertinoColors.activeBlue.color;
    final Color otherBubbleColor = isDarkMode 
        ? CupertinoColors.systemGrey3.darkColor 
        : CupertinoColors.systemGrey5.color;
        
    final Color myTextColor = CupertinoColors.white; // Text on activeBlue is usually white
    final Color otherTextColor = isDarkMode ? CupertinoColors.white : CupertinoColors.black;

    final Color timestampColor = isDarkMode 
        ? CupertinoColors.systemGrey.color
        : CupertinoColors.systemGrey.darkColor;


    final Alignment bubbleAlignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final Radius tailRadius = const Radius.circular(4);
    final Radius mainRadius = const Radius.circular(18);

    final BorderRadius bubbleBorderRadius = isMe
        ? BorderRadius.only(
            topLeft: mainRadius,
            bottomLeft: mainRadius,
            topRight: mainRadius,
            bottomRight: tailRadius, // iOS "tail" is often less pronounced or integrated
          )
        : BorderRadius.only(
            topLeft: tailRadius,
            topRight: mainRadius,
            bottomLeft: mainRadius,
            bottomRight: mainRadius,
          );

    Widget messageContent;

    if (message.mediaUrl != null && message.mediaUrl!.isNotEmpty) {
      // Media message (image)
      messageContent = GestureDetector(
        onTap: () {
          Get.to(() => FullscreenImage(image: message.mediaUrl!));
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.65,
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16), // Slightly larger radius for image consistency
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CachedNetworkImage(
                  imageUrl: message.mediaUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const CupertinoActivityIndicator(),
                  errorWidget: (context, url, error) => const Icon(CupertinoIcons.photo_fill, size: 50),
                ),
                if (message.sentAt != null)
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      DateFormat('HH:mm').format(message.sentAt!.toDate()),
                      style: cupertinoTheme.textTheme.caption1.copyWith(
                        color: CupertinoColors.white,
                        shadows: [
                          Shadow(color: CupertinoColors.black.withOpacity(0.7), blurRadius: 2, offset: const Offset(0,1))
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
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? myBubbleColor : otherBubbleColor,
          borderRadius: bubbleBorderRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.message != null && message.message!.isNotEmpty)
              Text(
                message.message!,
                style: cupertinoTheme.textTheme.textStyle.copyWith(color: isMe ? myTextColor : otherTextColor),
              ),
            if (message.sentAt != null) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  DateFormat('HH:mm').format(message.sentAt!.toDate()),
                  style: cupertinoTheme.textTheme.caption2.copyWith(color: isMe ? myTextColor.withOpacity(0.8) : timestampColor),
                ),
              ),
            ]
          ],
        ),
      );
    }

    return Align(
      alignment: bubbleAlignment,
      child: Padding( // Add padding around each bubble for spacing between them
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: messageContent,
      )
    );
  }
}
