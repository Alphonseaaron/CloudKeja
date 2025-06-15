import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For NetworkImage, Icons, SnackBar (replace with Cupertino)
import 'package:provider/provider.dart';
import 'package:get/route_manager.dart'; // For Get.to, Get.offAll
import 'package:cached_network_image/cached_network_image.dart';

import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/tenancy_provider.dart'; // For current tenancy
import 'package:cloudkeja/models/space_model.dart'; // For SpaceModel in tenancy
import 'package:cloudkeja/screens/auth/login_page.dart';
// import 'package:cloudkeja/screens/profile/edit_profile.dart'; // Replaced by router
import 'package:cloudkeja/screens/profile/edit_profile_screen_router.dart'; // Import router
import 'package:cloudkeja/screens/user/user_payment_history_screen.dart'; // Assuming adaptive or routed
import 'package:cloudkeja/screens/user/user_maintenance_history_screen.dart'; // Assuming adaptive or routed
import 'package:cloudkeja/screens/profile/tenant_details_screen.dart'; // Assuming adaptive or routed
// TODO: Replace mpesa_helper and MyDropDown with Cupertino alternatives if UserPaymentDialog is adapted for Cupertino
// import 'package:cloudkeja/helpers/mpesa_helper.dart'; // mpesa_helper is used by UserPaymentDialogCupertinoContent
// import 'package:cloudkeja/helpers/my_dropdown.dart'; // MyDropDown is used by UserPaymentDialogCupertinoContent and is adaptive
import 'package:cloudkeja/widgets/dialogs/user_payment_dialog_cupertino_content.dart'; // Added


class UserProfileScreenCupertino extends StatefulWidget {
  // Optional: Allow viewing other users' profiles, or default to current user
  final String? userId; 
  const UserProfileScreenCupertino({Key? key, this.userId}) : super(key: key);

  @override
  State<UserProfileScreenCupertino> createState() => _UserProfileScreenCupertinoState();
}

class _UserProfileScreenCupertinoState extends State<UserProfileScreenCupertino> {
  Future<UserModel?>? _userFuture;
  Future<List<SpaceModel>>? _tenancyFuture; // For current tenancy

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData({bool forceRefresh = false}) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (widget.userId != null && widget.userId != authProvider.user?.userId) {
      // TODO: Implement fetching other user's profile if needed by admin/other logic
      // For now, this screen primarily focuses on the current user's profile.
      // If viewing others, tenancy info and some actions might be irrelevant or different.
      setState(() {
        _userFuture = authProvider.getUserById(widget.userId!); // Example, if such a method exists
      });
    } else {
       setState(() {
        _userFuture = authProvider.getCurrentUser(forceRefresh: forceRefresh);
      });
    }
    // After user is loaded, then load tenancy if it's the current user
    _userFuture?.then((user) {
      if (user != null && (widget.userId == null || widget.userId == user.userId)) {
        setState(() {
          _tenancyFuture = Provider.of<TenancyProvider>(context, listen: false).getUserTenancy(user, forceRefresh: forceRefresh);
        });
      }
    });
  }

  Widget _buildListTile(BuildContext context, String title, IconData leadingIcon, VoidCallback onTap, {bool isDestructive = false}) {
    final cupertinoTheme = CupertinoTheme.of(context);
    return CupertinoListTile.notched(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0), // Typical iOS padding
      leading: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: isDestructive 
              ? CupertinoColors.systemRed.resolveFrom(context).withOpacity(0.15)
              : cupertinoTheme.primaryColor.withOpacity(0.15),
        ),
        child: Icon(
          leadingIcon, 
          color: isDestructive ? CupertinoColors.systemRed.resolveFrom(context) : cupertinoTheme.primaryColor, 
          size: 20
        ),
      ),
      title: Text(title, style: TextStyle(color: isDestructive ? CupertinoColors.systemRed.resolveFrom(context) : cupertinoTheme.textTheme.textStyle.color)),
      trailing: const CupertinoListTileChevron(),
      onTap: onTap,
    );
  }
  
  void _showLogoutConfirmation(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext dialogContext) => CupertinoActionSheet(
        title: const Text('Confirm Logout'),
        message: const Text('Are you sure you want to log out?'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            child: const Text('Logout'),
            onPressed: () async {
              Navigator.pop(dialogContext); // Dismiss action sheet
              await Provider.of<AuthProvider>(context, listen: false).signOut();
              Get.offAll(() => const LoginPage()); // Navigate to login
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(dialogContext),
        ),
      ),
    );
  }

  void _showCupertinoPaymentDialog(BuildContext context, SpaceModel space) {
    showCupertinoDialog<bool>( // Expect a boolean result
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Make Payment'),
          content: UserPaymentDialogCupertinoContent(space: space), // Use the new Cupertino content
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              child: const Text('Cancel'),
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // Pop with false indicating cancellation
              },
            )
            // "Confirm & Pay" is now inside UserPaymentDialogCupertinoContent
          ],
        );
      },
    ).then((paymentSuccessful) {
      // After the dialog is popped, handle the result
      if (paymentSuccessful == true) {
        showCupertinoDialog(
          context: context, // Use the original screen's context
          builder: (BuildContext alertContext) => CupertinoAlertDialog(
            title: const Text('Payment Successful'),
            content: const Text('Your payment has been processed.'),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(alertContext).pop();
                  _loadUserData(forceRefresh: true); // Refresh data after successful payment
                },
              )
            ],
          ),
        );
      } else if (paymentSuccessful == false && mounted) {
        // Optional: Handle explicit cancellation if needed, though often just closing is fine.
        // If UserPaymentDialogCupertinoContent pops with `false` for failure, handle here.
        // Currently, it shows its own error or pops with true for success.
        // This 'else if' might not be hit if UserPaymentDialogCupertinoContent handles all its errors internally
        // and only pops 'true' for success or is dismissed (null result).
        // For now, this handles explicit cancellation from the AlertDialog's own cancel button.
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);

    return FutureBuilder<UserModel?>(
      future: _userFuture,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isLoadingUser = snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData && snapshot.connectionState != ConnectionState.done;

        return CupertinoPageScaffold(
          child: CustomScrollView(
            slivers: <Widget>[
              CupertinoSliverNavigationBar(
                largeTitle: Text(isLoadingUser ? 'Profile' : user?.name ?? 'User Profile'),
                // TODO: Add Edit button if it's the current user's profile
                // trailing: (widget.userId == null || widget.userId == Provider.of<AuthProvider>(context, listen: false).user?.userId)
                // ? CupertinoButton(
                //     padding: EdgeInsets.zero,
                //     child: const Text('Edit'),
                //     onPressed: () => Get.to(() => EditProfileScreen()), // Assuming EditProfile is adaptive
                //   )
                // : null,
                backgroundColor: cupertinoTheme.barBackgroundColor.withOpacity(0.7),
                border: Border(bottom: BorderSide(color: CupertinoColors.separator.resolveFrom(context), width: 0.5)),
              ),
              CupertinoSliverRefreshControl(
                onRefresh: () async => _loadUserData(forceRefresh: true),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: CupertinoColors.systemGrey5.resolveFrom(context),
                      backgroundImage: (user?.profile != null && user!.profile!.isNotEmpty)
                          ? CachedNetworkImageProvider(user.profile!)
                          : null,
                      child: (isLoadingUser || user?.profile == null || user!.profile!.isEmpty)
                          ? const CupertinoActivityIndicator(radius: 15) // Show loader inside avatar if image is loading or user is loading
                          : null,
                    ),
                  ),
                ),
              ),
              if (isLoadingUser && user == null) // Show skeleton sections only if user is truly null and loading
                 SliverList(delegate: SliverChildListDelegate([
                    CupertinoListSection.insetGrouped(children: List.generate(3, (_) => _buildListTile(context, "Loading...", CupertinoIcons.time, (){}))),
                    CupertinoListSection.insetGrouped(children: List.generate(2, (_) => _buildListTile(context, "Loading...", CupertinoIcons.time, (){}))),
                 ]))
              else if (user != null) ...[
                CupertinoListSection.insetGrouped(
                  header: Text('Personal Information', style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context))),
                  children: <Widget>[
                    CupertinoListTile(title: const Text('Email'), additionalInfo: Text(user.email ?? 'N/A', style: cupertinoTheme.textTheme.tabLabelTextStyle)),
                    CupertinoListTile(title: const Text('Phone'), additionalInfo: Text(user.phone ?? 'N/A', style: cupertinoTheme.textTheme.tabLabelTextStyle)),
                    if (user.idnumber != null && user.idnumber!.isNotEmpty)
                      CupertinoListTile(title: const Text('ID Number'), additionalInfo: Text(user.idnumber!, style: cupertinoTheme.textTheme.tabLabelTextStyle)),
                  ],
                ),
                CupertinoListSection.insetGrouped(
                  header: Text('Activity', style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context))),
                  children: <Widget>[
                    if (widget.userId == null || widget.userId == user.userId) // Show only for own profile
                      _buildListTile(context, 'Edit Profile', CupertinoIcons.pencil_ellipsis_rectangle, () {
                        Get.to(() => EditProfileScreenRouter(user: user));
                      }),
                    _buildListTile(context, 'Payment History', CupertinoIcons.creditcard, () => Get.to(() => const UserPaymentHistoryScreen())),
                    _buildListTile(context, 'Maintenance History', CupertinoIcons.wrench, () => Get.to(() => const UserMaintenanceHistoryScreen())),
                  ],
                ),
                
                // Current Tenancy Section
                SliverToBoxAdapter(
                  child: FutureBuilder<List<SpaceModel>>(
                    future: _tenancyFuture,
                    builder: (context, tenancySnapshot) {
                      if (tenancySnapshot.connectionState == ConnectionState.waiting && !tenancySnapshot.hasData) {
                        return Padding(padding: const EdgeInsets.all(16), child: CupertinoListSection.insetGrouped(header: const Text("Current Tenancy"), children: [CupertinoListTile(title: const Text("Loading tenancy..."))]));
                      }
                      if (!tenancySnapshot.hasData || tenancySnapshot.data!.isEmpty) {
                        return const SizedBox.shrink(); // No active tenancy
                      }
                      final space = tenancySnapshot.data!.first;
                      return CupertinoListSection.insetGrouped(
                        header: Text('Current Tenancy', style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context))),
                        children: [
                          CupertinoListTile.notched(
                             padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundColor: CupertinoColors.systemGrey5.resolveFrom(context),
                              backgroundImage: (space.images != null && space.images!.isNotEmpty) ? CachedNetworkImageProvider(space.images!.first) : null,
                              child: (space.images == null || space.images!.isEmpty) ? const Icon(CupertinoIcons.house_fill, size: 20) : null,
                            ),
                            title: Text(space.spaceName ?? 'N/A Property', style: cupertinoTheme.textTheme.textStyle),
                            subtitle: Text(space.address ?? 'N/A Address', style: cupertinoTheme.textTheme.tabLabelTextStyle),
                            trailing: const CupertinoListTileChevron(),
                            onTap: () => Get.to(() => TenantDetailsScreen(space: space)), // Assuming TenantDetailsScreen is adaptive or routed
                          ),
                           CupertinoListTile(
                            title: Text('Rent Due', style: cupertinoTheme.textTheme.textStyle),
                            additionalInfo: Text('KES ${space.price?.toStringAsFixed(0) ?? '0'}', style: cupertinoTheme.textTheme.tabLabelTextStyle),
                          ),
                          Padding( // Add padding around the button to match typical list item padding
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: CupertinoButton.filled(
                                child: const Text('Make Payment'),
                                onPressed: () => _showCupertinoPaymentDialog(context, space),
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),

                CupertinoListSection.insetGrouped(
                  children: <Widget>[
                    _buildListTile(context, 'Logout', CupertinoIcons.square_arrow_left, () => _showLogoutConfirmation(context), isDestructive: true),
                  ],
                ),
              ] else if (snapshot.hasError) ... [
                SliverFillRemaining(child: Center(child: Text('Error: ${snapshot.error}')))
              ] else ...[
                SliverFillRemaining(child: Center(child: Text('User not found or not logged in.')))
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 20)), // Bottom padding
            ],
          ),
        );
      },
    );
  }
}
