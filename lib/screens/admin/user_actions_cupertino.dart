import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/chat_provider.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/admin_provider.dart';
import 'package:cloudkeja/screens/chat/chat_room.dart'; // Assuming ChatRoom is adaptive or will be
import 'package:url_launcher/url_launcher.dart';
import 'package:get/route_manager.dart'; // For Get.to

// Helper to show Cupertino dialogs
void _showCupertinoFeedbackDialog(BuildContext context, String title, String content, {bool isSuccess = true, VoidCallback? onOk}) {
  showCupertinoDialog(
    context: context,
    builder: (dialogCtx) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        CupertinoDialogAction(
          child: const Text('OK'),
          isDefaultAction: true,
          onPressed: () {
            Navigator.of(dialogCtx).pop();
            onOk?.call(); // Call additional callback if provided
          },
        )
      ],
    ),
  );
}

// Helper to show confirmation dialog
Future<bool> _showCupertinoConfirmationDialog(BuildContext context, String title, String message) async {
  final result = await showCupertinoDialog<bool>(
    context: context,
    builder: (dialogCtx) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        CupertinoDialogAction(
          child: const Text('Cancel'),
          isDestructiveAction: false,
          onPressed: () => Navigator.of(dialogCtx).pop(false),
        ),
        CupertinoDialogAction(
          child: const Text('Confirm'),
          isDestructiveAction: true, // Or false depending on action
          onPressed: () => Navigator.of(dialogCtx).pop(true),
        ),
      ],
    ),
  );
  return result ?? false; // Return false if dialog is dismissed
}


void showCupertinoUserActions(
  BuildContext context,
  UserModel user,
  CupertinoThemeData cupertinoTheme, {
  required VoidCallback onEditSubscription,
  required VoidCallback onSetAdminLimit,
}) {
  final String? currentAdminUid = FirebaseAuth.instance.currentUser?.uid;
  final adminProvider = Provider.of<AdminProvider>(context, listen: false);

  List<CupertinoActionSheetAction> actions = [];

  // Chat with User
  actions.add(CupertinoActionSheetAction(
    leading: Icon(CupertinoIcons.chat_bubble_2_fill, color: cupertinoTheme.primaryColor),
    child: Text("Chat with User", style: TextStyle(color: cupertinoTheme.primaryColor)),
    onPressed: () async {
      Navigator.pop(context); // Close action sheet
      if (currentAdminUid == null) {
        _showCupertinoFeedbackDialog(context, "Error", "Admin not logged in."); return;
      }
      if (currentAdminUid == user.userId) {
         _showCupertinoFeedbackDialog(context, "Info", "Cannot chat with yourself."); return;
      }
      String chatRoomId = (currentAdminUid.compareTo(user.userId!) > 0)
          ? '${currentAdminUid}_${user.userId}'
          : '${user.userId}_${currentAdminUid}';

      // Assuming ChatRoom.routeName setup works with Get.to or standard navigation
      // If ChatRoom is not adaptive, this might show Material page on iOS
      Get.toNamed(ChatRoom.routeName, arguments: {'user': user, 'chatRoomId': chatRoomId});
    },
  ));

  // Call User
  actions.add(CupertinoActionSheetAction(
    leading: Icon(CupertinoIcons.phone_fill, color: cupertinoTheme.primaryColor),
    child: Text("Call User", style: TextStyle(color: cupertinoTheme.primaryColor)),
    onPressed: () async {
      Navigator.pop(context);
      if (user.phone != null && user.phone!.isNotEmpty) {
        await FlutterPhoneDirectCaller.callNumber(user.phone!);
      } else {
        _showCupertinoFeedbackDialog(context, "Info", "User phone number not available.");
      }
    },
  ));

  // Delete User Account
  actions.add(CupertinoActionSheetAction(
    leading: const Icon(CupertinoIcons.trash_fill, color: CupertinoColors.systemRed),
    child: const Text("Delete User Account", style: TextStyle(color: CupertinoColors.systemRed)),
    isDestructiveAction: true,
    onPressed: () async {
      Navigator.pop(context); // Close action sheet
      bool confirmed = await _showCupertinoConfirmationDialog(context, "Delete User?", "Are you sure you want to delete ${user.name ?? 'this user'}'s account? This action cannot be undone.");
      if (confirmed) {
        try {
          await adminProvider.deleteUserAccount(user.userId!);
          _showCupertinoFeedbackDialog(context, "Success", "${user.name ?? 'User'}'s account document deleted.");
        } catch (e) {
          _showCupertinoFeedbackDialog(context, "Error", "Failed to delete user: ${e.toString()}");
        }
      }
    },
  ));

  // Separator (visual only, not a real action) - ActionSheet doesn't have built-in separators easily
  // Could add a disabled action or just rely on grouping by text.

  // Admin Status Toggle
  actions.add(CupertinoActionSheetAction(
    leading: Icon(user.isAdmin == true ? CupertinoIcons.shield_fill : CupertinoIcons.shield_lefthalf_fill, color: cupertinoTheme.primaryColor),
    child: Text(user.isAdmin == true ? 'Revoke Admin Status' : "Make User Admin", style: TextStyle(color: cupertinoTheme.primaryColor)),
    onPressed: () async {
      Navigator.pop(context);
      try {
        await adminProvider.setUserAdminStatus(user.userId!, !(user.isAdmin ?? false));
        _showCupertinoFeedbackDialog(context, "Success", "Admin status updated for ${user.name ?? 'User'}.");
      } catch (e) {
         _showCupertinoFeedbackDialog(context, "Error", "Failed to update admin status: ${e.toString()}");
      }
    },
  ));

  // Landlord Status Toggle
  actions.add(CupertinoActionSheetAction(
    leading: Icon(user.isLandlord == true ? CupertinoIcons.house_fill : CupertinoIcons.house, color: cupertinoTheme.primaryColor),
    child: Text(user.isLandlord == true ? 'Revoke Landlord Status' : "Make User Landlord", style: TextStyle(color: cupertinoTheme.primaryColor)),
    onPressed: () async {
      Navigator.pop(context);
       try {
        await adminProvider.setUserLandlordStatus(user.userId!, !(user.isLandlord ?? false));
        _showCupertinoFeedbackDialog(context, "Success", "Landlord status updated for ${user.name ?? 'User'}.");
      } catch (e) {
         _showCupertinoFeedbackDialog(context, "Error", "Failed to update landlord status: ${e.toString()}");
      }
    },
  ));

  // --- Subscription Management ---
  actions.add(CupertinoActionSheetAction(
    leading: Icon(CupertinoIcons.money_dollar_circle, color: cupertinoTheme.primaryColor), // Or CupertinoIcons.pencil_ellipsis_rectangle
    child: Text("Edit Subscription", style: TextStyle(color: cupertinoTheme.primaryColor)),
    onPressed: () {
      Navigator.pop(context); // Close action sheet
      onEditSubscription();
    },
  ));

  if (user.isLandlord == true) {
    actions.add(CupertinoActionSheetAction(
      leading: Icon(CupertinoIcons.person_crop_circle_badge_plus, color: cupertinoTheme.primaryColor),
      child: Text("Set Admin User Limit", style: TextStyle(color: cupertinoTheme.primaryColor)),
      onPressed: () {
        Navigator.pop(context); // Close action sheet
        onSetAdminLimit();
      },
    ));
  }
  // --- End Subscription Management ---


  // Service Provider Specific Actions
  if (user.role == 'ServiceProvider') {
    // Visually indicate SP status (not an action)
     actions.add(CupertinoActionSheetAction( // Use as a non-tappable header if needed, or style differently
      child: Text(
        "Status: ${user.isVerified == true ? 'Verified SP' : 'Pending SP Verification'}",
        style: TextStyle(color: user.isVerified == true ? CupertinoColors.activeGreen : CupertinoColors.activeOrange),
      ),
      onPressed: () { Navigator.pop(context); /* No action, just info */}, // No action
    ));


    // View Certifications/Portfolio
    if (user.certifications != null && user.certifications!.isNotEmpty) {
      actions.add(CupertinoActionSheetAction(
        leading: Icon(CupertinoIcons.doc_text_fill, color: cupertinoTheme.primaryColor),
        child: Text('View Certifications/Portfolio', style: TextStyle(color: cupertinoTheme.primaryColor)),
        onPressed: () {
          Navigator.pop(context); // Close action sheet
          List<Widget> urlTiles = user.certifications!.map((url) {
            String fileName = url.split('/').last.split('?').first.split('%2F').last;
            try { fileName = Uri.decodeComponent(fileName); } catch(_){}
            return CupertinoListTile(
              leading: const Icon(CupertinoIcons.link),
              title: Text(fileName, style: cupertinoTheme.textTheme.textStyle.copyWith(fontSize: 14)),
              subtitle: Text(url, style: cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () async {
                final Uri uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  // Show feedback within this dialog or pop and show on previous screen
                  _showCupertinoFeedbackDialog(context, "Error", "Could not open URL: $url");
                }
              },
            );
          }).toList();

          showCupertinoDialog(
            context: context, // Use the main context for this new dialog
            builder: (dialogCtx) => CupertinoAlertDialog(
              title: const Text('Uploaded Files'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: urlTiles.isEmpty ? [const Text('No files found.')] : urlTiles,
                ),
              ),
              actions: [CupertinoDialogAction(child: const Text('Close'), onPressed: () => Navigator.of(dialogCtx).pop())],
            ),
          );
        },
      ));
    } else {
       actions.add(CupertinoActionSheetAction(
        leading: Icon(CupertinoIcons.doc_text, color: CupertinoColors.inactiveGray),
        child: Text('View Certifications/Portfolio', style: TextStyle(color: CupertinoColors.inactiveGray)),
        onPressed: () {
          Navigator.pop(context);
           _showCupertinoFeedbackDialog(context, "Info", "No certifications uploaded by this service provider.");
        },
      ));
    }

    // Verify/Unverify Service Provider
    if (user.isVerified != true) {
      actions.add(CupertinoActionSheetAction(
        leading: Icon(CupertinoIcons.checkmark_seal_fill, color: CupertinoColors.activeGreen),
        child: Text('Verify This Service Provider', style: TextStyle(color: CupertinoColors.activeGreen)),
        onPressed: () async {
          Navigator.pop(context);
          try {
            await adminProvider.setServiceProviderVerificationStatus(user.userId!, true);
            _showCupertinoFeedbackDialog(context, "Success", "${user.name ?? 'Provider'} has been VERIFIED.");
          } catch (e) {
            _showCupertinoFeedbackDialog(context, "Error", "Failed to verify: ${e.toString()}");
          }
        },
      ));
    } else {
      actions.add(CupertinoActionSheetAction(
        leading: const Icon(CupertinoIcons.xmark_seal_fill, color: CupertinoColors.systemRed),
        child: const Text('Unverify This Service Provider', style: TextStyle(color: CupertinoColors.systemRed)),
        isDestructiveAction: true,
        onPressed: () async {
          Navigator.pop(context);
          bool confirmed = await _showCupertinoConfirmationDialog(context, "Unverify Provider?", "Are you sure you want to unverify ${user.name ?? 'this provider'}?");
          if (confirmed) {
            try {
              await adminProvider.setServiceProviderVerificationStatus(user.userId!, false);
              _showCupertinoFeedbackDialog(context, "Success", "${user.name ?? 'Provider'} has been UNVERIFIED.");
            } catch (e) {
              _showCupertinoFeedbackDialog(context, "Error", "Failed to unverify: ${e.toString()}");
            }
          }
        },
      ));
    }
  }

  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext modalCtx) => CupertinoActionSheet(
      title: Text("Actions for ${user.name ?? 'User'}", style: cupertinoTheme.textTheme.navTitleTextStyle),
      // message: Text("Select an action."), // Optional message
      actions: actions,
      cancelButton: CupertinoActionSheetAction(
        child: const Text('Cancel'),
        isDefaultAction: true,
        onPressed: () {
          Navigator.pop(modalCtx);
        },
      ),
    ),
  );
}
