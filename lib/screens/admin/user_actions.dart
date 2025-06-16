// import 'package:cloud_firestore/cloud_firestore.dart'; // Not directly used for user data, UserModel has it
import 'package:firebase_auth/firebase_auth.dart'; // For current user ID for chat
import 'package:flutter/cupertino.dart'; // Replaced with Material Icons
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/chat_provider.dart'; // For initiating chat
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/admin_provider.dart';
import 'package:cloudkeja/providers/subscription_provider.dart'; // Added
import 'package:cloudkeja/screens/admin/all_users_screen_material.dart'; // Potentially for dialogs, or move dialogs
import 'package:cloudkeja/screens/chat/chat_room.dart';
import 'package:url_launcher/url_launcher.dart'; // For launching URLs
import 'package:get/route_manager.dart'; // For Get.to() if needed for profile navigation
// Note: Dialogs will be called via methods passed to this sheet, or by assuming they exist on the calling screen's context.
// For simplicity, we'll assume the calling screen (AllUsersScreen) handles showing the dialogs.
// We'll add callbacks for the new actions.

// Updated signature to accept ThemeData and new callbacks
void actionSheet(
  BuildContext context,
  UserModel user,
  ThemeData theme, {
  required VoidCallback onEditSubscription, // Callback for editing subscription
  required VoidCallback onSetAdminLimit,    // Callback for setting admin limit
}) {
  final String? currentAdminUid = FirebaseAuth.instance.currentUser?.uid; // For chat initiation
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;
  final adminProvider = Provider.of<AdminProvider>(context, listen: false);

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent, // Sheet content will define its own background
    shape: theme.bottomSheetTheme.shape, // Use themed shape
    isScrollControlled: true, // Allow for taller content
    builder: (BuildContext buildContext) {
      return Container(
        decoration: BoxDecoration(
          color: theme.bottomSheetTheme.backgroundColor ?? colorScheme.surface, // Themed background
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), // Consistent radius
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Drag Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Section Title
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Actions for ${user.name ?? 'User'}",
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Divider(color: theme.dividerColor),

              // General Actions
              ListTile(
                dense: true,
                leading: Icon(Icons.chat_bubble_outline_rounded, size: 22, color: colorScheme.primary),
                title: Text("Chat with User", style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface)),
                onTap: () async {
                  Navigator.pop(buildContext); // Close sheet first
                  if (currentAdminUid == null) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Admin not logged in."))); return;
                  }
                  if (currentAdminUid == user.userId) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cannot chat with yourself."))); return;
                  }
                  // Simplified chat room ID logic (consistent with ChatRoom initiation)
                  String chatRoomId;
                  if (currentAdminUid.compareTo(user.userId!) > 0) {
                    chatRoomId = '${currentAdminUid}_${user.userId}';
                  } else {
                    chatRoomId = '${user.userId}_${currentAdminUid}';
                  }
                  // UserModel for the user being chatted with is already available in 'user'
                  Navigator.of(context).pushNamed(ChatRoom.routeName, arguments: {
                    'user': user,
                    'chatRoomId': chatRoomId,
                  });
                },
              ),
              ListTile(
                dense: true,
                leading: Icon(Icons.call_outlined, size: 22, color: colorScheme.primary),
                title: Text("Call User", style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface)),
                onTap: () async {
                  Navigator.pop(buildContext);
                  if (user.phone != null && user.phone!.isNotEmpty) {
                    await FlutterPhoneDirectCaller.callNumber(user.phone!);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User phone number not available.")));
                  }
                },
              ),
              ListTile(
                dense: true,
                leading: Icon(Icons.delete_outline_rounded, size: 22, color: colorScheme.error),
                title: Text("Delete User Account", style: textTheme.bodyLarge?.copyWith(color: colorScheme.error)),
                onTap: () async {
                  Navigator.pop(buildContext);
                  // Optional: Show confirmation dialog before deleting
                  await adminProvider.deleteUserAccount(user.userId!);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${user.name ?? 'User'} account document deleted.")));
                },
              ),
              Divider(color: theme.dividerColor),

              // Admin & Landlord Status Actions
              ListTile(
                dense: true,
                leading: Icon(user.isAdmin == true ? Icons.shield_rounded : Icons.shield_outlined, size: 22, color: colorScheme.secondary),
                title: Text(user.isAdmin == true ? 'Revoke Admin Status' : "Make User Admin", style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface)),
                onTap: () async {
                  Navigator.pop(buildContext);
                  await adminProvider.setUserAdminStatus(user.userId!, !(user.isAdmin ?? false));
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Admin status updated for ${user.name ?? 'User'}.")));
                },
              ),
              ListTile(
                dense: true,
                leading: Icon(user.isLandlord == true ? Icons.real_estate_agent_rounded : Icons.real_estate_agent_outlined, size: 22, color: colorScheme.secondary),
                title: Text(user.isLandlord == true ? 'Revoke Landlord Status' : "Make User Landlord", style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface)),
                onTap: () async {
                  Navigator.pop(buildContext);
                  await adminProvider.setUserLandlordStatus(user.userId!, !(user.isLandlord ?? false));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Landlord status updated for ${user.name ?? 'User'}.")));
                  // Consider calling a refresh callback if the main list needs it
                },
              ),
              Divider(color: theme.dividerColor),

              // Subscription and Limit Management
              ListTile(
                dense: true,
                leading: Icon(Icons.subscriptions_outlined, size: 22, color: colorScheme.primary),
                title: Text("Edit Subscription", style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface)),
                onTap: () {
                  Navigator.pop(buildContext); // Close sheet
                  onEditSubscription(); // Call the callback
                },
              ),
              if (user.isLandlord == true)
                ListTile(
                  dense: true,
                  leading: Icon(Icons.admin_panel_settings_outlined, size: 22, color: colorScheme.primary),
                  title: Text("Set Admin User Limit", style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface)),
                  onTap: () {
                    Navigator.pop(buildContext); // Close sheet
                    onSetAdminLimit(); // Call the callback
                  },
                ),

              // Service Provider Specific Actions
              if (user.role == 'ServiceProvider') ...[
                Divider(color: theme.dividerColor),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Service Provider Actions",
                    style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                ListTile(
                  dense: true,
                  leading: Icon(
                    user.isVerified == true ? Icons.verified_user_rounded : Icons.hourglass_empty_rounded,
                    size: 22,
                    color: user.isVerified == true ? Colors.green.shade700 : Colors.orange.shade700,
                  ),
                  title: Text("Status: ${user.isVerified == true ? 'Verified' : 'Pending Verification'}", style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface)),
                ),
                if (user.certifications != null && user.certifications!.isNotEmpty)
                  ListTile(
                    dense: true,
                    leading: Icon(Icons.description_outlined, size: 22, color: colorScheme.onSurfaceVariant),
                    title: Text('View Certifications/Portfolio', style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface)),
                    onTap: () {
                      Navigator.pop(buildContext); // Close bottom sheet
                      showDialog(
                        context: context,
                        builder: (dialogCtx) => AlertDialog(
                          title: Text('Uploaded Certifications', style: textTheme.titleLarge),
                          content: SingleChildScrollView(
                            child: (user.certifications == null || user.certifications!.isEmpty)
                                ? const Text('No certifications found.')
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: user.certifications!.map((url) {
                                      String fileName = url.split('/').last.split('?').first.split('%2F').last;
                                      try { fileName = Uri.decodeComponent(fileName); } catch(_){}

                                      return ListTile(
                                        leading: Icon(Icons.link_rounded, color: colorScheme.primary),
                                        title: Text(fileName, style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary)),
                                        subtitle: Text(url, style: textTheme.caption, maxLines: 1, overflow: TextOverflow.ellipsis,),
                                        onTap: () async {
                                          final Uri uri = Uri.parse(url);
                                          if (await canLaunchUrl(uri)) {
                                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                                          } else {
                                            ScaffoldMessenger.of(dialogCtx).showSnackBar(SnackBar(content: Text('Could not open URL: $url')));
                                          }
                                        },
                                      );
                                    }).toList(),
                                  ),
                          ),
                          actions: [ TextButton(child: const Text('Close'), onPressed: () => Navigator.of(dialogCtx).pop()) ],
                        ),
                      );
                    },
                  )
                else
                  ListTile(
                    dense: true,
                    leading: Icon(Icons.description_outlined, size: 22, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                    title: Text('View Certifications/Portfolio', style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.5))),
                    subtitle: Text('(No files uploaded)', style: textTheme.caption),
                    onTap: () {
                       Navigator.pop(buildContext);
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No certifications uploaded by this service provider.")));
                    }
                  ),

                if (user.isVerified != true)
                  ListTile(
                    dense: true,
                    leading: Icon(Icons.check_circle_outline_rounded, size: 22, color: Colors.green.shade700),
                    title: Text('Verify This Service Provider', style: textTheme.bodyLarge?.copyWith(color: Colors.green.shade700)),
                    onTap: () async {
                      Navigator.pop(buildContext);
                      await adminProvider.setServiceProviderVerificationStatus(user.userId!, true);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${user.name ?? 'Provider'} has been VERIFIED.")));
                      // Consider refresh callback
                    },
                  )
                else // user.isVerified == true
                  ListTile(
                    dense: true,
                    leading: Icon(Icons.cancel_outlined, size: 22, color: colorScheme.error),
                    title: Text('Unverify This Service Provider', style: textTheme.bodyLarge?.copyWith(color: colorScheme.error)),
                    onTap: () async {
                      Navigator.pop(buildContext);
                      await adminProvider.setServiceProviderVerificationStatus(user.userId!, false);
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${user.name ?? 'Provider'} has been UNVERIFIED.")));
                       // Consider refresh callback
                    },
                  ),
              ],
              const SizedBox(height: 10), // Bottom padding
            ],
          ),
        ),
      );
    },
  );
}
