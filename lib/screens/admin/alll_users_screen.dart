import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:cloudkeja/helpers/constants.dart'; // kPrimaryColor replaced by theme
import 'package:cloudkeja/helpers/loading_effect.dart'; // Themed loading effect
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/admin_provider.dart';
import 'package:cloudkeja/screens/admin/user_actions.dart'; // For actionSheet
import 'package:skeletonizer/skeletonizer.dart'; // For better loading visuals

class AllUsersScreen extends StatefulWidget {
  const AllUsersScreen({Key? key}) : super(key: key);

  @override
  State<AllUsersScreen> createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends State<AllUsersScreen> {
  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;

  String _selectedRoleFilter = 'All';
  String _selectedVerificationFilter = 'All Statuses'; // For SPs: "Verified", "Pending"

  final List<String> _roleFilterOptions = ['All', 'Tenant', 'Landlord', 'ServiceProvider', 'Admin'];
  final List<String> _spVerificationFilterOptions = ['All Statuses', 'Verified SPs', 'Pending SPs'];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Assuming AdminProvider's getAllUsers fetches all users without pre-filtering by role
      _allUsers = await Provider.of<AdminProvider>(context, listen: false).getAllUsers();
      _applyFilters(); // Apply initial/default filters
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching users: ${e.toString()}', style: TextStyle(color: Theme.of(context).colorScheme.onError)), backgroundColor: Theme.of(context).colorScheme.error),
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

      // Role Filter
      if (_selectedRoleFilter != 'All') {
        if (_selectedRoleFilter == 'Tenant') { // Assuming 'Tenant' is role == null or role == 'Tenant'
            tempUsers = tempUsers.where((user) => user.role == null || user.role == 'Tenant' && user.isAdmin != true && user.isLandlord != true).toList();
        } else if (_selectedRoleFilter == 'Admin') {
            tempUsers = tempUsers.where((user) => user.isAdmin == true).toList();
        } else {
             tempUsers = tempUsers.where((user) => user.role == _selectedRoleFilter).toList();
        }
      }

      // SP Verification Filter (only if "ServiceProvider" role is relevant or "All" roles)
      if (_selectedRoleFilter == 'ServiceProvider' || _selectedRoleFilter == 'All') {
        if (_selectedVerificationFilter == 'Verified SPs') {
          tempUsers = tempUsers.where((user) => user.role == 'ServiceProvider' && user.isVerified == true).toList();
        } else if (_selectedVerificationFilter == 'Pending SPs') {
          tempUsers = tempUsers.where((user) => user.role == 'ServiceProvider' && (user.isVerified == null || user.isVerified == false)).toList();
        }
        // If _selectedVerificationFilter is 'All Statuses', no additional filtering on verification needed for SPs here.
      }
      _filteredUsers = tempUsers;
    });
  }

  Widget _buildSkeletonTile(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5), // Placeholder color
      ),
      title: Container(
        height: 16,
        width: MediaQuery.of(context).size.width * 0.3, // Shorter width
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        margin: const EdgeInsets.only(bottom: 4), // Add some margin like real text
      ),
      subtitle: Container(
        height: 12,
        width: MediaQuery.of(context).size.width * 0.5, // Medium width
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
      ),
      trailing: Container( // Placeholder for the chip
        height: 24, // Approx height of a chip
        width: 50,  // Approx width of a chip
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8), // Chip-like radius
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // Match real tile
    );
  }

  Widget _buildFilterDropdowns(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedRoleFilter,
              decoration: InputDecoration(
                labelText: 'Filter by Role',
                //border: OutlineInputBorder(), // Uses global theme
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              items: _roleFilterOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: textTheme.bodyMedium),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRoleFilter = newValue!;
                  // Reset verification filter if role is not SP or All
                  if (_selectedRoleFilter != 'ServiceProvider' && _selectedRoleFilter != 'All') {
                    _selectedVerificationFilter = 'All Statuses';
                  }
                  _applyFilters();
                });
              },
            ),
          ),
          if (_selectedRoleFilter == 'ServiceProvider' || _selectedRoleFilter == 'All') ...[
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedVerificationFilter,
                decoration: InputDecoration(
                  labelText: 'SP Verification',
                  //border: OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  isDense: true,
                ),
                items: _spVerificationFilterOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: textTheme.bodyMedium),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedVerificationFilter = newValue!;
                    _applyFilters();
                  });
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('All Users Management'), // More descriptive title
        // AppBar uses AppBarTheme
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchUsers(forceRefresh: true),
        child: Column(
          children: [
            _buildFilterDropdowns(context),
            Divider(height: 1, color: theme.dividerColor),
            Expanded(
              child: Skeletonizer(
                enabled: _isLoading,
                effect: ShimmerEffect(
                  baseColor: colorScheme.surfaceVariant.withOpacity(0.4),
                  highlightColor: colorScheme.surfaceVariant.withOpacity(0.8),
                ),
                child: (_filteredUsers.isEmpty && !_isLoading)
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline_rounded, size: 80, color: colorScheme.primary.withOpacity(0.3)),
                            const SizedBox(height: 20),
                            Text('No Users Found', style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.8))),
                            const SizedBox(height: 8),
                            Text('Try adjusting your filters or check back later.', textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.6))),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      itemCount: _isLoading ? 8 : _filteredUsers.length, // Show 8 skeleton items
                      itemBuilder: (context, index) {
                        if (_isLoading) {
                          return _buildSkeletonTile(context);
                        }
                        final user = _filteredUsers[index];
                        Widget? trailingWidget;
                        if (user.role == 'ServiceProvider') {
                          trailingWidget = Chip(
                            label: Text(
                              user.isVerified == true ? 'Verified' : 'Pending',
                              style: textTheme.labelSmall?.copyWith(
                                color: user.isVerified == true ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer, // Example contrast colors
                              ),
                            ),
                            backgroundColor: user.isVerified == true
                                ? Colors.green.shade100.withOpacity(0.7) // Light green for verified
                                : Colors.orange.shade100.withOpacity(0.7), // Light orange for pending
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                            visualDensity: VisualDensity.compact,
                          );
                        }


                        return ListTile(
                          leading: CircleAvatar(
                            radius: 22,
                            backgroundColor: colorScheme.surfaceVariant,
                            backgroundImage: (user.profile != null && user.profile!.isNotEmpty)
                                ? NetworkImage(user.profile!)
                                : null,
                            child: (user.profile == null || user.profile!.isEmpty)
                                ? Icon(Icons.person_outline_rounded, size: 22, color: colorScheme.onSurfaceVariant)
                                : null,
                          ),
                          title: Row(
                            children: [
                              Flexible(child: Text(user.name ?? 'N/A User', style: textTheme.titleSmall, overflow: TextOverflow.ellipsis)),
                              if (user.isAdmin == true) ...[
                                const SizedBox(width: 5),
                                Icon(Icons.shield_outlined, color: colorScheme.secondary, size: 16), // Admin icon
                              ],
                            ],
                          ),
                          subtitle: Text(user.email ?? 'No email', style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.7))),
                          trailing: trailingWidget,
                          onTap: () {
                            // Pass theme data to actionSheet for consistent styling
                            actionSheet(context, user, theme);
                          },
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        );
                      },
                      separatorBuilder: (context, index) => Divider(indent: 16, endIndent: 16, height: 1, color: theme.dividerColor.withOpacity(0.5)),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
