import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For FlutterPhoneDirectCaller, Icons (placeholder), ScaffoldMessenger (replace)
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

import 'package:cloudkeja/models/message_model.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/screens/chat/widgets/chat_bubble_cupertino.dart'; // Use Cupertino ChatBubble
// TODO: Create AddMessageCupertino or make AddMessage adaptive
import 'package:cloudkeja/screens/chat/add_message.dart'; // Using Material AddMessage for now

class ChatRoomScreenCupertino extends StatefulWidget { 
  // static const String routeName = '/chat-room-cupertino'; // Route name now handled by router
  
  final UserModel user; // User being chatted with
  final String chatRoomId;

  const ChatRoomScreenCupertino({
    Key? key,
    required this.user,
    required this.chatRoomId,
  }) : super(key: key);

  @override
  State<ChatRoomScreenCupertino> createState() => _ChatRoomScreenCupertinoState();
}

class _ChatRoomScreenCupertinoState extends State<ChatRoomScreenCupertino> {
  final ScrollController _scrollController = ScrollController();

  // Access widget fields with widget.user and widget.chatRoomId

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // Delay slightly to allow ListView to build
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
           _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }
  
  void _showMoreActions(BuildContext context, UserModel user) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext dialogContext) => CupertinoActionSheet(
        title: Text(user.name ?? 'Options'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(child: const Text('View Profile'), onPressed: () { Navigator.pop(dialogContext); /* TODO */ }),
          CupertinoActionSheetAction(child: const Text('Search Chat'), onPressed: () { Navigator.pop(dialogContext); /* TODO */ }),
          CupertinoActionSheetAction(child: const Text('Mute Notifications'), onPressed: () { Navigator.pop(dialogContext); /* TODO */ }),
          CupertinoActionSheetAction(child: const Text('Clear Chat'), isDestructiveAction: true, onPressed: () { Navigator.pop(dialogContext); /* TODO */ }),
          CupertinoActionSheetAction(child: const Text('Block User'), isDestructiveAction: true, onPressed: () { Navigator.pop(dialogContext); /* TODO */ }),
        ],
        cancelButton: CupertinoActionSheetAction(child: const Text('Cancel'), onPressed: () => Navigator.pop(dialogContext)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    // Arguments are now passed via constructor (widget.user, widget.chatRoomId)
    // final chatRoomData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    // final UserModel user = chatRoomData['user']; 
    // final chatRoomId = chatRoomData['chatRoomId'] as String;

    bool isChatPartnerVerified = widget.user.isAdmin == true || (widget.user.role == 'ServiceProvider' && widget.user.isVerified == true);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        middle: Row( // Custom title view
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 18, // Smaller for nav bar
              backgroundColor: CupertinoColors.systemGrey5.resolveFrom(context),
              backgroundImage: (widget.user.profile != null && widget.user.profile!.isNotEmpty)
                  ? CachedNetworkImageProvider(widget.user.profile!)
                  : null,
              child: (widget.user.profile == null || widget.user.profile!.isEmpty)
                  ? Icon(CupertinoIcons.person_fill, size: 18, color: CupertinoColors.systemGrey.resolveFrom(context))
                  : null,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(child: Text(widget.user.name ?? 'Chat User', overflow: TextOverflow.ellipsis, style: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(fontSize: 16))),
                    if(isChatPartnerVerified) ...[const SizedBox(width: 4), Icon(CupertinoIcons.checkmark_seal_fill, color: cupertinoTheme.primaryColor, size: 14)]
                  ]),
                  if (widget.user.phone != null && widget.user.phone!.isNotEmpty)
                    Text(widget.user.phone!, style: cupertinoTheme.textTheme.caption1.copyWith(fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.phone, size: 26),
              onPressed: () async {
                if (widget.user.phone != null && widget.user.phone!.isNotEmpty) {
                  bool? res = await FlutterPhoneDirectCaller.callNumber(widget.user.phone!);
                  if (res == false && mounted) {
                    showCupertinoDialog(context: context, builder: (ctx) => CupertinoAlertDialog(title: const Text('Call Failed'), content: Text('Could not make phone call to ${widget.user.phone}.'), actions: [CupertinoDialogAction(isDefaultAction: true, child: const Text('OK'), onPressed: ()=>Navigator.pop(ctx))]));
                  }
                } else if (mounted) {
                  showCupertinoDialog(context: context, builder: (ctx) => CupertinoAlertDialog(title: const Text('No Phone Number'), content: const Text('Phone number not available.'), actions: [CupertinoDialogAction(isDefaultAction: true, child: const Text('OK'), onPressed: ()=>Navigator.pop(ctx))]));
                }
              },
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.ellipsis_vertical, size: 26),
              onPressed: () => _showMoreActions(context, widget.user),
            ),
          ],
        ),
      ),
      child: SafeArea( // SafeArea for the body content
        bottom: true, // Ensure AddMessage is above home indicator if KeyboardAvoidingView isn't perfect
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                  .doc(widget.chatRoomId) // Use widget.chatRoomId
                    .collection('messages')
                    .orderBy('sentAt', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CupertinoActivityIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('No messages yet.\nStart the conversation!', textAlign: TextAlign.center, style: cupertinoTheme.textTheme.tabLabelTextStyle),
                      ),
                    );
                  }
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final messageDoc = snapshot.data!.docs[index];
                      try {
                        final message = MessageModel.fromSnapshot(messageDoc);
                        return ChatBubbleCupertino(message: message);
                      } catch (e) {
                        return CupertinoListTile(title: Text('Error: $e', style: TextStyle(color: CupertinoColors.destructiveRed.resolveFrom(context))));
                      }
                    },
                  );
                },
              ),
            ),
            // TODO: Create AddMessageCupertino or make AddMessage adaptive. Using Material one for now.
            // This will likely look out of place.
            AddMessage(chatRoomId: widget.chatRoomId, recipientId: widget.user.userId!),
          ],
        ),
      ),
    );
  }
}
