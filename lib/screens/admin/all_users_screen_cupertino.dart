import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For NetworkImage, Icons (some placeholders)
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/admin_provider.dart';
// TODO: Import actual user action methods or UserProfileScreen if available for Cupertino

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
  
  void _showUserActions(BuildContext context, UserModel user) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext dialogContext) => CupertinoActionSheet(
        title: Text(user.name ?? 'User Actions'),
        message: Text(user.email ?? 'Select an action'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(child: const Text('View Profile'), onPressed: () { Navigator.pop(dialogContext); /* TODO */ }),
          CupertinoActionSheetAction(child: const Text('Toggle Admin Status'), onPressed: () { Navigator.pop(dialogContext); /* TODO */ }),
          CupertinoActionSheetAction(child: const Text('Toggle Landlord Status'), onPressed: () { Navigator.pop(dialogContext); /* TODO */ }),
          if (user.role == 'ServiceProvider')
            CupertinoActionSheetAction(child: Text(user.isVerified == true ? 'Unverify SP' : 'Verify SP'), onPressed: () { Navigator.pop(dialogContext); /* TODO */ }),
          CupertinoActionSheetAction(isDestructiveAction: true, child: const Text('Delete User'), onPressed: () { Navigator.pop(dialogContext); /* TODO */ }),
        ],
        cancelButton: CupertinoActionSheetAction(child: const Text('Cancel'), onPressed: () => Navigator.pop(dialogContext)),
      ),
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
            fontWeight: FontWeight.w600
          ),
        ),
      );
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
      subtitle: Text(user.email ?? 'No email', style: theme.textTheme.tabLabelTextStyle),
      additionalInfo: trailingWidget, // Using additionalInfo for the chip-like text
      trailing: const CupertinoListTileChevron(),
      onTap: () => _showUserActions(context, user),
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
                    return Center( /* Error display */ ); // Simplified for brevity
                  }
                  if (_filteredUsers.isEmpty) {
                    return Center( /* Empty state display */ ); // Simplified for brevity
                  }
                  return CustomScrollView(
                    slivers: <Widget>[
                      CupertinoSliverRefreshControl(onRefresh: _fetchUsers),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index.isOdd) return Divider(indent: 16, endIndent: 0, height: 0.5, color: CupertinoColors.separator.resolveFrom(context));
                            final itemIndex = index ~/ 2;
                            if (itemIndex >= _filteredUsers.length) return null;
                            return _buildUserListTile(_filteredUsers[itemIndex], theme);
                          },
                          childCount: _filteredUsers.length * 2 -1,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
