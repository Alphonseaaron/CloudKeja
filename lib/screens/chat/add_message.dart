import 'package:flutter/material.dart';
import 'package:media_picker_widget/media_picker_widget.dart'; // For MediaPicker
import 'package:provider/provider.dart';
// import 'package:cloudkeja/helpers/constants.dart'; // kPrimaryColor replaced by theme
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/models/chat_provider.dart'; // For ChatProvider
import 'package:cloudkeja/models/message_model.dart';
import 'package:cloudkeja/models/user_model.dart'; // For UserModel if needed by ChatProvider

class AddMessage extends StatefulWidget {
  final String recipientId; // Renamed from userId for clarity
  final String chatRoomId;  // Added chatRoomId parameter

  const AddMessage({Key? key, required this.recipientId, required this.chatRoomId}) : super(key: key);

  @override
  _AddMessageState createState() => _AddMessageState();
}

class _AddMessageState extends State<AddMessage> {
  final TextEditingController _messageController = TextEditingController();
  List<Media> _mediaList = []; // For selected media

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final currentUserId = Provider.of<AuthProvider>(context, listen: false).user?.userId;
    if (currentUserId == null) return; // Should not happen if user is in chat room

    final messageText = _messageController.text.trim();
    if (messageText.isEmpty && _mediaList.isEmpty) {
      return; // Don't send empty messages
    }

    // If media is selected, it's handled by onPick in openImagePicker
    // This method is primarily for text messages or if media sending logic is centralized.
    if (messageText.isNotEmpty) {
      Provider.of<ChatProvider>(context, listen: false).sendMessage(
        chatRoomId: widget.chatRoomId, // Use passed chatRoomId
        senderId: currentUserId,
        recipientId: widget.recipientId,
        message: MessageModel(
          message: messageText,
          senderId: currentUserId,
          receiverId: widget.recipientId, // Ensure receiverId is correctly set
          mediaFiles: [], // Text message has no media files here
          mediaType: '',  // No media type for text
          // sentAt and isRead will be handled by the provider or backend
        ),
      );
      _messageController.clear();
      setState(() {}); // To update UI if needed (e.g., disable button after send)
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    // final currentUserId = Provider.of<AuthProvider>(context, listen: false).user?.userId; // Not needed directly in build

    return Container(
      padding: EdgeInsets.only(
        left: 12.0, 
        right: 8.0, 
        top: 8.0, 
        bottom: MediaQuery.of(context).padding.bottom + 8.0 // Respect bottom safe area
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer, // M3 color for input bars
        // border: Border(top: BorderSide(color: colorScheme.outline.withOpacity(0.5), width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end, // Align items to bottom for multi-line TextField
        children: [
          // Camera/Media Picker Icon Button
          IconButton(
            icon: Icon(Icons.camera_alt_outlined, color: colorScheme.onSurfaceVariant),
            tooltip: 'Attach Media',
            onPressed: () => _openImagePicker(context),
          ),
          // TextField
          Expanded(
            child: Padding( // Padding to control TextField height implicitly with contentPadding
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: TextField(
                controller: _messageController,
                maxLines: null, // Allows multiple lines
                minLines: 1,     // Starts as single line
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface), // Themed text color
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  // contentPadding, border, fillColor, filled are from InputDecorationTheme
                  // Ensure InputDecorationTheme has appropriate values for a chat input
                  // e.g., filled: true, fillColor: colorScheme.surface, border: OutlineInputBorder(...)
                  // For a more compact look often seen in chat apps:
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0), // Rounded border
                    borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface, // Or a slightly different variant
                ),
              ),
            ),
          ),
          // Send Icon Button
          IconButton.filled( // M3 filled IconButton
            icon: const Icon(Icons.send_rounded),
            tooltip: 'Send Message',
            onPressed: _sendMessage,
            // backgroundColor will be colorScheme.primary
            // foregroundColor (icon color) will be colorScheme.onPrimary
            // Can adjust padding/size if needed:
            // style: IconButton.styleFrom(padding: const EdgeInsets.all(12)),
          ),
        ],
      ),
    );
  }

  // Media Picker Bottom Sheet
  void _openImagePicker(BuildContext context) {
    final theme = Theme.of(context); // For theming picker decoration
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final currentUserId = Provider.of<AuthProvider>(context, listen: false).user?.userId;

    if (currentUserId == null) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true, // Allows sheet to take full height if needed
      backgroundColor: Colors.transparent, // Transparent for custom shape
      shape: RoundedRectangleBorder( // Themed shape for the sheet
        borderRadius: theme.bottomSheetTheme.shape is RoundedRectangleBorder
            ? ((theme.bottomSheetTheme.shape as RoundedRectangleBorder).borderRadius as BorderRadiusGeometry)
            : const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return GestureDetector( // To dismiss by tapping outside DraggableScrollableSheet
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6, // Initial height of the sheet
            maxChildSize: 0.95,    // Max height
            minChildSize: 0.4,     // Min height
            builder: (BuildContext bContext, ScrollController scrollController) {
              return Container( // Actual content container for media picker
                decoration: BoxDecoration(
                  color: colorScheme.surface, // Themed background for picker content
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: MediaPicker(
                  scrollController: scrollController,
                  mediaList: _mediaList, // Pass current list
                  onPick: (selectedList) async {
                    // Handle picked media
                    Navigator.of(context).pop(); // Close the picker first
                    if (selectedList.isNotEmpty) {
                      setState(() => _mediaList = selectedList); // Update local list
                      // Process and send media messages
                      for (var mediaFile in _mediaList) {
                         if (mediaFile.file != null) {
                           double mediaSize = mediaFile.file!.readAsBytesSync().lengthInBytes / (1024 * 1024);
                           if (mediaSize > 5.0) { // Example: 5MB limit
                             ScaffoldMessenger.of(bContext).showSnackBar(
                               SnackBar(content: Text('File ${mediaFile.file!.path.split('/').last} exceeds 5MB limit.', style: TextStyle(color: colorScheme.onError)), backgroundColor: colorScheme.error),
                             );
                             continue; // Skip this file
                           }

                           await Provider.of<ChatProvider>(context, listen: false).sendMessage(
                            chatRoomId: widget.chatRoomId,
                            senderId: currentUserId,
                            recipientId: widget.recipientId,
                            message: MessageModel(
                              message: '', // No text message, only media
                              senderId: currentUserId,
                              receiverId: widget.recipientId,
                              mediaFiles: [mediaFile.file!], // Send one file at a time
                              mediaType: mediaFile.mediaType == MediaType.image ? 'image' : 'video',
                            ),
                          );
                         }
                      }
                      setState(() => _mediaList.clear()); // Clear list after sending
                    }
                  },
                  onCancel: () => Navigator.of(context).pop(),
                  mediaCount: MediaCount.multiple, // Or .single
                  mediaType: MediaType.image,       // Or .video, .all
                  decoration: PickerDecoration( // Themed decoration for MediaPicker
                    cancelIcon: Icon(Icons.close, color: colorScheme.onSurface),
                    albumTitleStyle: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
                    actionBarPosition: ActionBarPosition.top, // Standard position
                    blurStrength: 0, // No blur, use solid background
                    completeText: 'Done', // Text for completion button
                    completeTextStyle: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
                    selectionColor: colorScheme.primary, // Color for selection indicators
                    selectedCountBackgroundColor: colorScheme.primary,
                    selectedCountTextColor: colorScheme.onPrimary,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
