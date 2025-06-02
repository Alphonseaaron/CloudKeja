import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:media_picker_widget/media_picker_widget.dart'; // For MediaPicker
import 'package:provider/provider.dart';
import 'package:cloudkeja/services/platform_service.dart'; // Added
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
    final platformService = Provider.of<PlatformService>(context, listen: false);
    final bool useCupertino = platformService.useCupertino;
    final currentUserId = Provider.of<AuthProvider>(context, listen: false).user?.userId;

    if (currentUserId == null) return;

    // Platform-specific theming for PickerDecoration
    late PickerDecoration pickerDecoration;
    if (useCupertino) {
      final cupertinoTheme = CupertinoTheme.of(context);
      pickerDecoration = PickerDecoration(
        cancelIcon: Icon(CupertinoIcons.clear_circled_solid, color: cupertinoTheme.primaryColor),
        albumTitleStyle: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(fontWeight: FontWeight.bold),
        actionBarPosition: ActionBarPosition.top,
        blurStrength: 0,
        completeText: 'Done',
        completeTextStyle: cupertinoTheme.textTheme.navActionTextStyle.copyWith(color: cupertinoTheme.primaryColor, fontWeight: FontWeight.w600),
        selectionColor: cupertinoTheme.primaryColor,
        selectedCountBackgroundColor: cupertinoTheme.primaryColor,
        selectedCountTextColor: cupertinoTheme.barBackgroundColor, // Typically white or light
        backgroundColor: cupertinoTheme.scaffoldBackgroundColor, // Background for the picker area
      );
    } else {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      final textTheme = theme.textTheme;
      pickerDecoration = PickerDecoration(
        cancelIcon: Icon(Icons.close, color: colorScheme.onSurface),
        albumTitleStyle: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
        actionBarPosition: ActionBarPosition.top,
        blurStrength: 0,
        completeText: 'Done',
        completeTextStyle: textTheme.labelLarge?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
        selectionColor: colorScheme.primary,
        selectedCountBackgroundColor: colorScheme.primary,
        selectedCountTextColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.surface,
      );
    }

    final mediaPickerWidget = MediaPicker(
      mediaList: _mediaList,
      onPick: (selectedList) async {
        Navigator.of(context).pop(); // Close picker first
        if (selectedList.isNotEmpty) {
          setState(() => _mediaList = selectedList);
          for (var mediaFile in _mediaList) {
            if (mediaFile.file != null) {
              double mediaSize = mediaFile.file!.readAsBytesSync().lengthInBytes / (1024 * 1024);
              if (mediaSize > 5.0) { // 5MB limit
                String fileName = mediaFile.file!.path.split('/').last;
                String message = 'File $fileName exceeds 5MB limit.';
                if (useCupertino) {
                  showCupertinoDialog(
                    context: context, // Using the builder's context for the dialog
                    builder: (dialogContext) => CupertinoAlertDialog(
                      title: const Text('File Too Large'),
                      content: Text(message),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('OK'),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                      ],
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onError)),
                        backgroundColor: Theme.of(context).colorScheme.error),
                  );
                }
                continue;
              }
              await Provider.of<ChatProvider>(context, listen: false).sendMessage(
                chatRoomId: widget.chatRoomId,
                senderId: currentUserId,
                recipientId: widget.recipientId,
                message: MessageModel(
                  message: '',
                  senderId: currentUserId,
                  receiverId: widget.recipientId,
                  mediaFiles: [mediaFile.file!],
                  mediaType: mediaFile.mediaType == MediaType.image ? 'image' : 'video',
                ),
              );
            }
          }
          setState(() => _mediaList.clear());
        }
      },
      onCancel: () => Navigator.of(context).pop(),
      mediaCount: MediaCount.multiple,
      mediaType: MediaType.image, // Default to image, can be changed
      decoration: pickerDecoration,
    );

    if (useCupertino) {
      showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext modalContext) {
          // Use modalContext for dialogs shown from within the modal
          return Container(
            height: MediaQuery.of(context).size.height * 0.7, // Example height
            decoration: BoxDecoration(
              color: CupertinoTheme.of(modalContext).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Column( // Added Column for potential title/drag handle
              children: [
                // Optional: Add a grabber or title bar for the Cupertino sheet
                Container(
                  height: 6,
                  width: 40,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: CupertinoColors.inactiveGray.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Expanded(
                  child: mediaPickerWidget,
                ),
              ],
            ),
          );
        },
      );
    } else {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: Theme.of(context).bottomSheetTheme.shape is RoundedRectangleBorder
              ? ((Theme.of(context).bottomSheetTheme.shape as RoundedRectangleBorder).borderRadius as BorderRadiusGeometry)
              : const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        builder: (BuildContext bottomSheetContext) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(bottomSheetContext).pop(),
            child: DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.95,
              minChildSize: 0.4,
              builder: (BuildContext draggableContext, ScrollController scrollController) {
                // Pass scrollController to MediaPicker if it needs to control scrolling within the DraggableScrollableSheet
                return Container(
                   decoration: BoxDecoration(
                    color: pickerDecoration.backgroundColor ?? Theme.of(draggableContext).colorScheme.surface,
                     borderRadius: const BorderRadius.only(
                       topLeft: Radius.circular(20),
                       topRight: Radius.circular(20),
                     ),
                   ),
                  child: MediaPicker(
                    scrollController: scrollController, // Pass the scroll controller here
                    mediaList: _mediaList,
                    onPick: mediaPickerWidget.onPick, // Reuse the onPick logic
                    onCancel: mediaPickerWidget.onCancel,
                    mediaCount: mediaPickerWidget.mediaCount,
                    mediaType: mediaPickerWidget.mediaType,
                    decoration: mediaPickerWidget.decoration,
                  ),
                );
              },
            ),
          );
        },
      );
    }
  }
}
