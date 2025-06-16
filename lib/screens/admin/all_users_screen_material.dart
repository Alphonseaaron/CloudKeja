import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:provider/provider.dart';
import 'package:cloudkeja/helpers/loading_effect.dart'; // Themed loading effect
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/admin_provider.dart';
import 'package:cloudkeja/providers/subscription_provider.dart'; // Added
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
                                color: user.isVerified == true ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
                              ),
                            ),
                            backgroundColor: user.isVerified == true
                                ? Colors.green.shade100.withOpacity(0.7)
                                : Colors.orange.shade100.withOpacity(0.7),
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                            visualDensity: VisualDensity.compact,
                          );
                        }

                        String formattedExpiryDate = 'N/A';
                        if (user.subscriptionExpiryDate != null) {
                          formattedExpiryDate = DateFormat('dd MMM yyyy').format(user.subscriptionExpiryDate!.toDate());
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
                                Icon(Icons.shield_outlined, color: colorScheme.secondary, size: 16),
                              ],
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.email ?? 'No email', style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.7))),
                              const SizedBox(height: 2),
                              Text(
                                "Tier: ${user.subscriptionTier ?? 'N/A'} (Expires: $formattedExpiryDate)",
                                style: textTheme.bodySmall?.copyWith(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.6)),
                              ),
                              Text(
                                "Props: ${user.propertyCount ?? 0}, Admins: ${user.adminUserCount ?? 0}",
                                style: textTheme.bodySmall?.copyWith(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.6)),
                              ),
                            ],
                          ),
                          trailing: trailingWidget,
                          onTap: () {
                            actionSheet(
                              context,
                              user,
                              theme,
                              onEditSubscription: () => _showEditSubscriptionDialog(context, user, theme),
                              onSetAdminLimit: () => _showSetAdminLimitDialog(context, user, theme),
                            );
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

  void _showEditSubscriptionDialog(BuildContext context, UserModel user, ThemeData theme) {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final plans = subscriptionProvider.getSubscriptionPlans();
    String? selectedTierId = user.subscriptionTier ?? plans.first['id'];
    DateTime? selectedExpiryDate = user.subscriptionExpiryDate?.toDate();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(builder: (stfContext, stfSetState) {
          return AlertDialog(
            title: Text('Edit Subscription for ${user.name}', style: theme.textTheme.titleLarge),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DropdownButtonFormField<String>(
                    value: selectedTierId,
                    decoration: InputDecoration(labelText: 'Subscription Tier', border: OutlineInputBorder()),
                    items: plans.map((plan) {
                      return DropdownMenuItem<String>(
                        value: plan['id'] as String,
                        child: Text(plan['name'] as String),
                      );
                    }).toList(),
                    onChanged: (value) {
                      stfSetState(() {
                        selectedTierId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    title: Text(selectedExpiryDate == null
                        ? 'Set Expiry Date'
                        : 'Expires: ${DateFormat('dd MMM yyyy').format(selectedExpiryDate!)}'),
                    trailing: Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: stfContext, // Use StatefulBuilder context for date picker
                        initialDate: selectedExpiryDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != selectedExpiryDate) {
                        stfSetState(() {
                          selectedExpiryDate = picked;
                        });
                      }
                    },
                  ),
                  if (selectedExpiryDate != null)
                    TextButton(
                      child: Text('Clear Expiry Date', style: TextStyle(color: theme.colorScheme.error)),
                      onPressed: () {
                        stfSetState(() {
                          selectedExpiryDate = null;
                        });
                      },
                    ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              ElevatedButton(
                child: const Text('Save Changes'),
                onPressed: () async {
                  if (selectedTierId == null) return; // Should not happen
                  final expiryTimestamp = selectedExpiryDate != null ? Timestamp.fromDate(selectedExpiryDate!) : null;
                  try {
                    await adminProvider.updateUserSubscriptionTier(user.userId!, selectedTierId!, expiryTimestamp);
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Subscription updated for ${user.name}.'), backgroundColor: Colors.green),
                    );
                    _fetchUsers(forceRefresh: true);
                  } catch (e) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update subscription: $e'), backgroundColor: theme.colorScheme.error),
                    );
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  void _showSetAdminLimitDialog(BuildContext context, UserModel user, ThemeData theme) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final TextEditingController countController = TextEditingController(text: (user.adminUserCount ?? 1).toString());
    final GlobalKey<FormState> dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Set Admin Limit for ${user.name}', style: theme.textTheme.titleLarge),
          content: Form(
            key: dialogFormKey,
            child: TextFormField(
              controller: countController,
              decoration: InputDecoration(
                labelText: 'Admin User Count',
                hintText: 'Enter number (e.g., 1, 5)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Count cannot be empty.';
                final count = int.tryParse(value);
                if (count == null) return 'Invalid number.';
                if (count < 1) return 'Count must be at least 1.';
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text('Save Limit'),
              onPressed: () async {
                if (dialogFormKey.currentState!.validate()) {
                  final newCount = int.parse(countController.text);
                  try {
                    await adminProvider.updateLandlordAdminUserCount(user.userId!, newCount);
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Admin user limit updated for ${user.name}.'), backgroundColor: Colors.green),
                    );
                    _fetchUsers(forceRefresh: true);
                  } catch (e) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update admin limit: $e'), backgroundColor: theme.colorScheme.error),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
