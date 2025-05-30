import 'dart:io';
// import 'dart:math'; // Not used

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:cloudkeja/models/message_model.dart';
import 'package:cloudkeja/models/user_model.dart';

class ChatTileModel {
  final UserModel? user;
  String? latestMessage;
  Timestamp? time;
  final String? latestMessageSenderId;
  final String? chatRoomId;

  ChatTileModel({
    this.user,
    this.latestMessage,
    this.time,
    this.chatRoomId,
    this.latestMessageSenderId,
  });
}

class ChatProvider with ChangeNotifier {
  List<ChatTileModel> _contactedUsers = [];

  List<ChatTileModel> get contactedUsers => [..._contactedUsers];

  /////////////////SEND MESSAGE////////////////////////
  Future<void> sendMessage(
      // Parameters are: the ID of the person receiving the message,
      // the ID of the person sending the message, and the message object itself.
      String toUserId,
      String fromUserId,
      MessageModel messageDetails) async { // Renamed message to messageDetails for clarity

    // 1. Standardized Chat Room ID Calculation
    String chatRoomId;
    String docInitiatorId; // User ID that is alphabetically smaller
    String docReceiverId;  // User ID that is alphabetically larger

    if (fromUserId.compareTo(toUserId) > 0) {
      chatRoomId = '${toUserId}_${fromUserId}';
      docInitiatorId = toUserId;
      docReceiverId = fromUserId;
    } else {
      chatRoomId = '${fromUserId}_${toUserId}';
      docInitiatorId = fromUserId;
      docReceiverId = toUserId;
    }

    // 2. Single chatDocRef
    final chatDocRef = FirebaseFirestore.instance.collection('chats').doc(chatRoomId);
    String mediaUrl = ''; // To store URL if media is present

    // Prepare message data (common for both new and existing chat rooms)
    final messageData = {
      'message': messageDetails.message ?? '',
      'sender': fromUserId, // The actual sender
      'to': toUserId,         // The actual recipient
      'media': mediaUrl,      // Will be updated if media is uploaded
      'mediaType': messageDetails.mediaType ?? '',
      'isRead': false,
      'sentAt': Timestamp.now(), // Use a single timestamp for consistency
    };

    // Handle media upload first if present
    if (messageDetails.mediaFiles != null && messageDetails.mediaFiles!.isNotEmpty) {
      // Assuming only one media file for simplicity as per original logic's loop structure
      // In a real multi-file scenario, this would be a list of URLs or separate messages.
      File firstMediaFile = messageDetails.mediaFiles!.first;
      try {
        final fileData = await FirebaseStorage.instance
            .ref('chatFiles/$fromUserId/${DateTime.now().toIso8601String()}_${firstMediaFile.path.split('/').last}')
            .putFile(firstMediaFile);
        mediaUrl = await fileData.ref.getDownloadURL();
        messageData['media'] = mediaUrl; // Update messageData with the URL
        // If message text is empty and media is present, set message to 'photo' or 'media'
        if ((messageDetails.message == null || messageDetails.message!.isEmpty)) {
          messageData['message'] = messageDetails.mediaType == 'image' ? 'Photo' : 'Media';
        }
      } catch (e) {
        // Handle storage upload error
        debugPrint('Error uploading media to Firebase Storage: $e');
        // Optionally, don't send the message or send without media
        return; // Or throw e;
      }
    }

    // Update latestMessage text based on content
    String latestMessageText = messageData['message'] as String;
    if (latestMessageText.isEmpty && mediaUrl.isNotEmpty) {
        latestMessageText = messageDetails.mediaType == 'image' ? 'Photo' : 'Media';
    }


    // 3. Simplified Logic Flow
    final chatDocSnapshot = await chatDocRef.get();
    final now = Timestamp.now();

    if (chatDocSnapshot.exists) {
      // Chat room exists, update it
      await chatDocRef.update({
        'latestMessage': latestMessageText,
        'sentAt': now,
        'sentBy': fromUserId, // The actual sender of this message
      });
    } else {
      // Chat room doesn't exist, create it
      await chatDocRef.set({
        'initiator': docInitiatorId, // Alphabetically smaller ID
        'receiver': docReceiverId,   // Alphabetically larger ID
        'participants': [fromUserId, toUserId], // Store actual participants for easier querying if needed
        'startedAt': now,
        'latestMessage': latestMessageText,
        'sentAt': now,
        'sentBy': fromUserId, // The actual sender of this first message
      });
    }

    // Add message to subcollection
    // Use a new document ID for each message
    await chatDocRef.collection('messages').doc().set(messageData);

    // No need to call notifyListeners() here if this provider primarily handles sending,
    // and another part of the app (e.g., a stream listener) handles displaying messages.
    // If this provider also holds chat messages for UI, then notifyListeners() might be needed.
  }


  //////////////////////////////////////////////////////
  /// GET CHATS (getChats method)
  /// This method needs to be consistent with the new chatRoomId logic.
  /// It should query based on the user's ID being present in either
  /// 'initiator' or 'receiver' field if we stick to those,
  /// OR more robustly, query where 'participants' array contains uid.
  Future<List<ChatTileModel>> getChats(String uid) async {
    List<ChatTileModel> users = [];
    Set<String> processedChatRoomIds = {}; // To avoid duplicates if querying by initiator and receiver separately

    // Query where the current user is the 'initiator' (alphabetically smaller ID in the pair)
    final initiatorChatsSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('initiator', isEqualTo: uid)
        .orderBy('sentAt', descending: true) // Order by last message time
        .get();

    // Query where the current user is the 'receiver' (alphabetically larger ID in the pair)
    final receiverChatsSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('receiver', isEqualTo: uid)
        .orderBy('sentAt', descending: true)
        .get();

    // Process chats where user is initiator
    for (var element in initiatorChatsSnapshot.docs) {
      if (processedChatRoomIds.contains(element.id)) continue; // Skip if already processed

      final otherUserId = element['receiver'] as String?; // The other participant
      if (otherUserId == null) continue;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(otherUserId).get();
      if (userDoc.exists) {
        users.add(ChatTileModel(
          chatRoomId: element.id,
          latestMessageSenderId: element['sentBy'] as String?,
          user: UserModel.fromJson(userDoc.data()), // Assuming UserModel.fromJson can handle Map<String, dynamic>?
          latestMessage: element['latestMessage'] as String?,
          time: element['sentAt'] as Timestamp?,
        ));
        processedChatRoomIds.add(element.id);
      }
    }

    // Process chats where user is receiver
    for (var element in receiverChatsSnapshot.docs) {
      if (processedChatRoomIds.contains(element.id)) continue; // Skip if already processed

      final otherUserId = element['initiator'] as String?; // The other participant
      if (otherUserId == null) continue;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(otherUserId).get();
      if (userDoc.exists) {
         users.add(ChatTileModel(
          chatRoomId: element.id,
          latestMessageSenderId: element['sentBy'] as String?,
          user: UserModel.fromJson(userDoc.data()),
          latestMessage: element['latestMessage'] as String?,
          time: element['sentAt'] as Timestamp?,
        ));
        processedChatRoomIds.add(element.id);
      }
    }

    // Sort all collected chats by time
    users.sort((a, b) {
      if (a.time == null && b.time == null) return 0;
      if (a.time == null) return 1; // Null times go to the end
      if (b.time == null) return -1;
      return b.time!.compareTo(a.time!);
    });

    _contactedUsers = users; // Update local cache
    notifyListeners(); // Notify UI to update
    return _contactedUsers;
  }


  Future<List<ChatTileModel>> searchUser(String searchTerm) async {
    List<UserModel> users = [];
    if (searchTerm.trim().isEmpty) {
      return [];
    }

    final results = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: searchTerm.trim())
        .where('name', isLessThanOrEqualTo: '${searchTerm.trim()}\uf8ff') // Standard way to do prefix search
        .limit(10) // Limit results for performance
        .get();

    // Additional query for phone number if needed, or combine if possible with OR (requires composite index)
    // final phoneResults = await FirebaseFirestore.instance.collection('users')
    //     .where('phone', isGreaterThanOrEqualTo: searchTerm.trim())
    //     .where('phone', isLessThanOrEqualTo: '${searchTerm.trim()}\uf8ff')
    //     .limit(10)
    //     .get();
    // users.addAll(phoneResults.docs.map((e) => UserModel.fromJson(e.data())).toList());


    // Using a Set to avoid duplicate users if name and phone search yield same user
    Set<String> foundUserIds = {};

    for (var e in results.docs) {
      if (!foundUserIds.contains(e.id)) {
         users.add(UserModel.fromJson(e.data()));
         foundUserIds.add(e.id);
      }
    }

    // For simplicity, not merging phone results here to avoid complexity with duplicate handling without proper IDs from search.
    // The above name search is generally sufficient for user lookup.

    // Map UserModel to ChatTileModel for consistency, chatRoomId might be empty initially
    _contactedUsers = users.map((e) => ChatTileModel(user: e, chatRoomId: '')).toList();
    notifyListeners();
    return _contactedUsers;
  }
}
