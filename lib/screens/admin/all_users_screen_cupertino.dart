import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For NetworkImage, Icons (some placeholders)
import 'package:intl/intl.dart'; // For date formatting
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/admin_provider.dart';
import 'package:cloudkeja/providers/subscription_provider.dart'; // Added
import 'package:cloudkeja/screens/admin/user_actions_cupertino.dart'; // Import the new function


class AllUsersScreenCupertino extends StatefulWidget {
  const AllUsersScreenCupertino({Key? key}) : super(key: key);

  @override
  State<AllUsersScreenCupertino> createState() => _AllUsersScreenCupertinoState();
}

class _AllUsersScreenCupertinoState extends State<AllUsersScreenCupertino> {
  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _selectedRoleFilter = 'All';
  String _selectedVerificationFilter = 'All Statuses';

  final List<String> _roleFilterOptions = ['All', 'Tenant', 'Landlord', 'ServiceProvider', 'Admin'];
  final List<String> _spVerificationFilterOptions = ['All Statuses', 'Verified SPs', 'Pending SPs'];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _allUsers = await Provider.of<AdminProvider>(context, listen: false).getAllUsers(forceRefresh: forceRefresh);
      _applyFilters();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _filteredUsers = []; // Clear users on error
        });
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Failed to load users: $_errorMessage'),
            actions: [CupertinoDialogAction(isDefaultAction: true, child: const Text('OK'), onPressed: () => Navigator.pop(ctx))],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilters() {
    if (!mounted) return;
    setState(() {
      List<UserModel> tempUsers = List.from(_allUsers);
      if (_selectedRoleFilter != 'All') {
        if (_selectedRoleFilter == 'Tenant') {
            tempUsers = tempUsers.where((user) => user.role == null || user.role == 'Tenant' && user.isAdmin != true && user.isLandlord != true).toList();
        } else if (_selectedRoleFilter == 'Admin') {
            tempUsers = tempUsers.where((user) => user.isAdmin == true).toList();
        } else {
             tempUsers = tempUsers.where((user) => user.role == _selectedRoleFilter).toList();
        }
      }

      if (_selectedRoleFilter == 'ServiceProvider' || _selectedRoleFilter == 'All') {
        if (_selectedVerificationFilter == 'Verified SPs') {
          tempUsers = tempUsers.where((user) => user.role == 'ServiceProvider' && user.isVerified == true).toList();
        } else if (_selectedVerificationFilter == 'Pending SPs') {
          tempUsers = tempUsers.where((user) => user.role == 'ServiceProvider' && (user.isVerified == null || user.isVerified == false)).toList();
        }
      } else {
         // If role is not SP or All, ensure SP verification filter doesn't wrongly apply or is reset
         if(_selectedVerificationFilter != 'All Statuses' && _selectedRoleFilter != 'ServiceProvider') {
            // This case implies a non-SP role is selected, but an SP filter is active. This shouldn't happen if UI resets SP filter correctly.
            // For safety, ensure we don't over-filter if SP filter is somehow active for non-SP roles.
         }
      }
      _filteredUsers = tempUsers;
    });
  }

  void _showRoleFilterPicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Filter by Role'),
        actions: _roleFilterOptions.map((role) => CupertinoActionSheetAction(
          isDefaultAction: _selectedRoleFilter == role,
          onPressed: () {
            setState(() {
              _selectedRoleFilter = role;
              if (_selectedRoleFilter != 'ServiceProvider' && _selectedRoleFilter != 'All') {
                 _selectedVerificationFilter = 'All Statuses'; // Reset SP status filter
              }
              _applyFilters();
            });
            Navigator.pop(context);
          },
          child: Text(role),
        )).toList(),
        cancelButton: CupertinoActionSheetAction(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
      ),
    );
  }

  void _showSPVerificationFilterPicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Filter SP Verification Status'),
        actions: _spVerificationFilterOptions.map((status) => CupertinoActionSheetAction(
          isDefaultAction: _selectedVerificationFilter == status,
          onPressed: () {
            setState(() {
              _selectedVerificationFilter = status;
              _applyFilters();
            });
            Navigator.pop(context);
          },
          child: Text(status),
        )).toList(),
        cancelButton: CupertinoActionSheetAction(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
      ),
    );
  }
  
  void _showUserActions(BuildContext context, UserModel user, CupertinoThemeData theme) {
    showCupertinoUserActions(
      context,
      user,
      theme,
      onEditSubscription: () => _showCupertinoEditSubscriptionDialog(context, user, theme),
      onSetAdminLimit: () => _showCupertinoSetAdminLimitDialog(context, user, theme),
    );
  }

  Widget _buildUserListTile(UserModel user, CupertinoThemeData theme) {
    String roleDisplay = user.role ?? 'User';
    if (user.isAdmin == true) roleDisplay = 'Admin';
    else if (user.isLandlord == true) roleDisplay = 'Landlord';
    else if (user.role == 'ServiceProvider') roleDisplay = 'Service Provider';

    Widget? trailingWidget;
    if (user.role == 'ServiceProvider') {
      trailingWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: (user.isVerified == true ? CupertinoColors.systemGreen : CupertinoColors.systemOrange).withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          user.isVerified == true ? 'Verified' : 'Pending',
          style: theme.textTheme.caption1.copyWith(
            color: user.isVerified == true ? CupertinoColors.systemGreen : CupertinoColors.systemOrange,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    String formattedExpiryDate = 'N/A';
    if (user.subscriptionExpiryDate != null) {
      formattedExpiryDate = DateFormat('dd MMM yyyy').format(user.subscriptionExpiryDate!.toDate());
    }

    return CupertinoListTile.notched(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: CupertinoColors.systemGrey5.resolveFrom(context),
        backgroundImage: (user.profile != null && user.profile!.isNotEmpty) ? NetworkImage(user.profile!) : null,
        child: (user.profile == null || user.profile!.isEmpty) ? Icon(CupertinoIcons.person_fill, size: 22, color: CupertinoColors.systemGrey.resolveFrom(context)) : null,
      ),
      title: Row(children: [
        Flexible(child: Text(user.name ?? 'N/A User', style: theme.textTheme.textStyle)),
        if (user.isAdmin == true) ...[const SizedBox(width: 5), Icon(CupertinoIcons.shield_lefthalf_fill, color: theme.primaryColor, size: 16)],
      ]),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.email ?? 'No email', style: theme.textTheme.tabLabelTextStyle),
          const SizedBox(height: 2),
          Text(
            "Tier: ${user.subscriptionTier ?? 'N/A'} (Expires: $formattedExpiryDate)",
            style: theme.textTheme.caption2.copyWith(color: CupertinoColors.secondaryLabel.resolveFrom(context)),
          ),
          Text(
            "Props: ${user.propertyCount ?? 0}, Admins: ${user.adminUserCount ?? 0}",
            style: theme.textTheme.caption2.copyWith(color: CupertinoColors.secondaryLabel.resolveFrom(context)),
          ),
        ],
      ),
      additionalInfo: trailingWidget,
      trailing: const CupertinoListTileChevron(),
      onTap: () => _showUserActions(context, user, theme),
    );
  }
  
  Widget _buildFilterControls(CupertinoThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: theme.barBackgroundColor, // Subtle background
              child: Text(_selectedRoleFilter == 'All' ? 'Role: All' : _selectedRoleFilter, style: theme.textTheme.textStyle.copyWith(fontSize: 14)),
              onPressed: _showRoleFilterPicker,
            ),
          ),
          if (_selectedRoleFilter == 'ServiceProvider' || _selectedRoleFilter == 'All') ...[
            const SizedBox(width: 10),
            Expanded(
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                color: theme.barBackgroundColor,
                child: Text(_selectedVerificationFilter == 'All Statuses' ? 'SP Status: All': _selectedVerificationFilter, style: theme.textTheme.textStyle.copyWith(fontSize: 14)),
                onPressed: _showSPVerificationFilterPicker,
              ),
            ),
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('All Users')),
      child: SafeArea(
        child: Column(
          children: [
            _buildFilterControls(theme),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (_isLoading && _filteredUsers.isEmpty) {
                    return const Center(child: CupertinoActivityIndicator(radius: 15));
                  }
                  if (_errorMessage != null && _filteredUsers.isEmpty) {
                    // Display error message more clearly
                    return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: $_errorMessage', style: TextStyle(color: CupertinoColors.destructiveRed.resolveFrom(context)))));
                  }
                  if (_filteredUsers.isEmpty) {
                     // Display no users found message
                    return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('No users found matching your criteria.', style: theme.textTheme.textStyle.copyWith(color: CupertinoColors.secondaryLabel.resolveFrom(context)))));
                  }
                  // Use ListView.separated for clarity if dividers are intended between all items.
                  // The current SliverChildBuilderDelegate with index.isOdd is okay but less direct.
                  return ListView.separated(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      return _buildUserListTile(_filteredUsers[index], theme);
                    },
                    separatorBuilder: (context, index) => Divider(indent: 16, endIndent: 0, height: 0.5, color: CupertinoColors.separator.resolveFrom(context)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCupertinoEditSubscriptionDialog(BuildContext context, UserModel user, CupertinoThemeData theme) {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final plans = subscriptionProvider.getSubscriptionPlans();

    String? selectedTierId = user.subscriptionTier ?? plans.first['id'] as String?;
    DateTime? selectedExpiryDate = user.subscriptionExpiryDate?.toDate();

    FixedExtentScrollController tierScrollController = FixedExtentScrollController(
      initialItem: plans.indexWhere((p) => p['id'] == selectedTierId),
    );

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext modalContext) => Container(
        height: 350, // Adjusted height
        color: theme.scaffoldBackgroundColor,
        child: Column(
          children: [
            CupertinoNavigationBar(
              leading: CupertinoButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(modalContext).pop(),
              ),
              middle: Text('Edit Subscription', style: theme.textTheme.navTitleTextStyle),
              trailing: CupertinoButton(
                child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () async {
                  if (selectedTierId == null) return;
                  final expiryTimestamp = selectedExpiryDate != null ? Timestamp.fromDate(selectedExpiryDate!) : null;
                  try {
                    await adminProvider.updateUserSubscriptionTier(user.userId!, selectedTierId!, expiryTimestamp);
                    Navigator.of(modalContext).pop(); // Pop the modal
                     _showCupertinoFeedbackDialog(context, "Success", "Subscription updated for ${user.name}.");
                    _fetchUsers(forceRefresh: true);
                  } catch (e) {
                    Navigator.of(modalContext).pop();
                    _showCupertinoFeedbackDialog(context, "Error", "Failed to update subscription: $e");
                  }
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CupertinoTextField(
                      readOnly: true,
                      placeholder: 'Select Tier',
                      controller: TextEditingController(text: plans.firstWhere((p) => p['id'] == selectedTierId)['name'] as String?),
                      prefix: const Padding(padding: EdgeInsets.all(8.0), child: Text("Tier:")),
                      onTap: () {
                        showCupertinoModalPopup(
                          context: modalContext, // Use modal's context
                          builder: (_) => Container(
                            height: 250,
                            color: theme.scaffoldBackgroundColor,
                            child: CupertinoPicker(
                              scrollController: tierScrollController,
                              itemExtent: 40,
                              onSelectedItemChanged: (int index) {
                                setState(() { // This setState is for the dialog if it were stateful, need to manage differently or use StatefulBuilder
                                  selectedTierId = plans[index]['id'] as String?;
                                  // Rebuild the outer modal to reflect selection if text field needs update.
                                  // This is tricky with nested modals. Consider a StatefulBuilder for the dialog content.
                                });
                              },
                              children: plans.map((p) => Center(child: Text(p['name'] as String))).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                     GestureDetector(
                      onTap: () {
                        showCupertinoModalPopup(
                          context: modalContext,
                          builder: (_) => Container(
                            height: 250,
                            color: theme.scaffoldBackgroundColor,
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.date,
                              initialDateTime: selectedExpiryDate ?? DateTime.now(),
                              onDateTimeChanged: (DateTime newDate) {
                                setState(() { // Similar to above, managing state in nested modals is complex this way
                                  selectedExpiryDate = newDate;
                                });
                              },
                            ),
                          ),
                        );
                      },
                      child: CupertinoTextField(
                        readOnly: true,
                        placeholder: 'Set Expiry Date',
                        controller: TextEditingController(text: selectedExpiryDate == null ? 'Not Set' : DateFormat('dd MMM yyyy').format(selectedExpiryDate!)),
                        prefix: const Padding(padding: EdgeInsets.all(8.0), child: Text("Expires:")),
                        suffix: selectedExpiryDate != null ? CupertinoButton(padding: EdgeInsets.zero, child: const Icon(CupertinoIcons.clear_circled_solid), onPressed: (){ setState(() {selectedExpiryDate = null;});}) : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCupertinoSetAdminLimitDialog(BuildContext context, UserModel user, CupertinoThemeData theme) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final TextEditingController countController = TextEditingController(text: (user.adminUserCount ?? 1).toString());

    showCupertinoDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: Text('Set Admin Limit for ${user.name}', style: theme.textTheme.navTitleTextStyle),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: CupertinoTextField(
              controller: countController,
              placeholder: 'Enter number (e.g., 1, 5)',
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: BoxDecoration(
                border: Border.all(color: CupertinoColors.inactiveGray, width: 0.5),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Save Limit'),
              onPressed: () async {
                final value = countController.text;
                if (value.isEmpty) { _showCupertinoFeedbackDialog(dialogContext, "Validation Error", "Count cannot be empty."); return; }
                final count = int.tryParse(value);
                if (count == null) { _showCupertinoFeedbackDialog(dialogContext, "Validation Error", "Invalid number."); return; }
                if (count < 1) { _showCupertinoFeedbackDialog(dialogContext, "Validation Error", "Count must be at least 1."); return; }

                try {
                  await adminProvider.updateLandlordAdminUserCount(user.userId!, count);
                  Navigator.of(dialogContext).pop(); // Pop the alert
                  _showCupertinoFeedbackDialog(context, "Success", "Admin user limit updated for ${user.name}.");
                  _fetchUsers(forceRefresh: true);
                } catch (e) {
                  Navigator.of(dialogContext).pop();
                  _showCupertinoFeedbackDialog(context, "Error", "Failed to update admin limit: $e");
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Helper for feedback, can be moved to a utility file
  void _showCupertinoFeedbackDialog(BuildContext context, String title, String content) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [CupertinoDialogAction(isDefaultAction: true, child: const Text('OK'), onPressed: () => Navigator.pop(ctx))],
      ),
    );
  }
}
