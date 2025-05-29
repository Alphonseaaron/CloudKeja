import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
// import 'package:cloudkeja/helpers/constants.dart'; // kPrimaryColor replaced by theme
import 'package:cloudkeja/models/message_model.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/screens/chat/add_message.dart'; // Will be themed separately if needed
import 'package:cloudkeja/screens/chat/widgets/chat_bubble.dart'; // Will be themed separately if needed
// import 'package:url_launcher/url_launcher.dart'; // Not used in this snippet

class ChatRoom extends StatelessWidget {
  static const routeName = '/chat-room';
  final ScrollController _scrollController = ScrollController();

  ChatRoom({Key? key}) : super(key: key);

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final chatRoomData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final UserModel user = chatRoomData['user']; // User being chatted with
    final chatRoomId = chatRoomData['chatRoomId'] as String;

    // Determine if the chat partner should have a verified badge
    bool isChatPartnerVerified = user.isAdmin == true || 
                                 (user.role == 'ServiceProvider' && user.isVerified == true);

    return Scaffold(
      backgroundColor: colorScheme.background, 
      appBar: AppBar(
        leading: IconButton( 
          icon: const Icon(Icons.arrow_back), 
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        leadingWidth: 30, 
        title: Row(
          children: [
            CircleAvatar(
              radius: 20, 
              backgroundColor: colorScheme.surfaceVariant,
              backgroundImage: (user.profile != null && user.profile!.isNotEmpty)
                  ? CachedNetworkImageProvider(user.profile!)
                  : null,
              child: (user.profile == null || user.profile!.isEmpty)
                  ? Icon(Icons.person_outline_rounded, size: 22, color: colorScheme.onSurfaceVariant)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Flexible( 
                        child: Text(
                          user.name ?? 'Chat User',
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface, 
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isChatPartnerVerified) ...[ // Updated condition for verified icon
                        const SizedBox(width: 4),
                        Icon(Icons.verified_rounded, color: colorScheme.primary, size: 16),
                      ]
                    ],
                  ),
                  if (user.phone != null && user.phone!.isNotEmpty) 
                    Text(
                      user.phone!,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7), 
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
        actions: [
          IconButton(
            splashRadius: 20,
            icon: const Icon(Icons.call_outlined), 
            tooltip: 'Call ${user.phone ?? ""}',
            onPressed: () async {
              if (user.phone != null && user.phone!.isNotEmpty) {
                bool? res = await FlutterPhoneDirectCaller.callNumber(user.phone!);
                if (res == false && context.mounted) { 
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Could not make phone call to ${user.phone}.', style: TextStyle(color: colorScheme.onError)),
                    backgroundColor: colorScheme.error,
                  ));
                }
              } else if (context.mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Phone number not available.', style: TextStyle(color: colorScheme.onError)),
                    backgroundColor: colorScheme.error,
                  ));
              }
            },
          ),
          _MoreVertMenu(user: user), 
          const SizedBox(width: 4), 
        ],
      ),
      body: Column( 
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy('sentAt', descending: false) 
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator()); 
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No messages yet.\nStart the conversation!',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
                      ),
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
                       return ChatBubble(message: message); 
                    } catch (e) {
                      return ListTile(title: Text('Error loading message: $e', style: TextStyle(color: colorScheme.error)));
                    }
                  },
                );
              },
            ),
          ),
          AddMessage(chatRoomId: chatRoomId, recipientId: user.userId!), 
        ],
      ),
    );
  }
}

class _MoreVertMenu extends StatelessWidget {
  final UserModel user; 
  const _MoreVertMenu({Key? key, required this.user}) : super(key: key);

  static const List<String> _options = [
    'View Profile', 
    'Search Chat',  
    'Mute Notifications', 
    'Clear Chat', 
    'Block User'  
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_outlined), 
      tooltip: 'More options',
      onSelected: (String value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$value selected for ${user.name}')),
        );
      },
      itemBuilder: (BuildContext context) {
        return _options.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(choice, style: theme.textTheme.bodyMedium), 
          );
        }).toList();
      },
    );
  }
}
