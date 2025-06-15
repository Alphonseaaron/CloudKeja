import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For NetworkImage, SnackBar (will replace SnackBar)
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/admin_provider.dart';
import 'package:cloudkeja/screens/admin/user_actions_cupertino.dart'; // Import the new function


class AllLandlordsScreenCupertino extends StatefulWidget {
  const AllLandlordsScreenCupertino({Key? key}) : super(key: key);

  @override
  State<AllLandlordsScreenCupertino> createState() => _AllLandlordsScreenCupertinoState();
}

class _AllLandlordsScreenCupertinoState extends State<AllLandlordsScreenCupertino> {
  List<UserModel> _landlords = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLandlords();
  }

  Future<void> _fetchLandlords() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fetchedLandlords = await Provider.of<AdminProvider>(context, listen: false).getAllLandlords();
      if (mounted) {
        setState(() {
          _landlords = fetchedLandlords;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString();
          _landlords = [];
          _isLoading = false;
        });
        // Show Cupertino alert for error
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Failed to load landlords: $_errorMessage'),
            actions: [CupertinoDialogAction(isDefaultAction: true, child: const Text('OK'), onPressed: () => Navigator.pop(ctx))],
          ),
        );
      }
    }
  }

  void _showLandlordActions(BuildContext context, UserModel landlord) {
    // Call the new Cupertino-specific action sheet function
    // Note: 'landlord' is a UserModel, which is what showCupertinoUserActions expects.
    showCupertinoUserActions(context, landlord, CupertinoTheme.of(context));
  }

  Widget _buildLandlordListTile(UserModel landlord) {
    final theme = CupertinoTheme.of(context);
    return CupertinoListTile.notched(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: CupertinoColors.systemGrey5.resolveFrom(context),
        backgroundImage: (landlord.profile != null && landlord.profile!.isNotEmpty)
            ? NetworkImage(landlord.profile!) // NetworkImage is fine
            : null,
        child: (landlord.profile == null || landlord.profile!.isEmpty)
            ? Icon(CupertinoIcons.person_fill, size: 22, color: CupertinoColors.systemGrey.resolveFrom(context))
            : null,
      ),
      title: Row(
        children: [
          Flexible(child: Text(landlord.name ?? 'N/A Landlord', style: theme.textTheme.textStyle)),
          if (landlord.isAdmin == true) ...[
            const SizedBox(width: 5),
            Icon(CupertinoIcons.shield_lefthalf_fill, color: theme.primaryColor, size: 16),
          ],
        ],
      ),
      subtitle: Text(landlord.email ?? 'No email', style: theme.textTheme.tabLabelTextStyle),
      trailing: const CupertinoListTileChevron(),
      onTap: () => _showLandlordActions(context, landlord),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('All Landlords'),
      ),
      child: SafeArea( // Ensure content is within safe area
        child: Builder( // Use Builder to get context for CupertinoSliverRefreshControl if needed for theme
          builder: (context) {
            if (_isLoading && _landlords.isEmpty) {
              return const Center(child: CupertinoActivityIndicator(radius: 15));
            }
            if (_errorMessage != null && _landlords.isEmpty) { // Show error prominently if list is empty
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.xmark_octagon, color: CupertinoColors.destructiveRed, size: 50),
                      const SizedBox(height: 16),
                      Text('Something Went Wrong', style: theme.textTheme.navTitleTextStyle.copyWith(color: CupertinoColors.destructiveRed)),
                      const SizedBox(height: 8),
                      Text(_errorMessage!, textAlign: TextAlign.center, style: theme.textTheme.textStyle),
                    ],
                  ),
                ),
              );
            }
            if (_landlords.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.house_fill, size: 60, color: CupertinoColors.systemGrey.resolveFrom(context)),
                      const SizedBox(height: 20),
                      Text("No Landlords Found", style: theme.textTheme.navTitleTextStyle),
                      const SizedBox(height: 8),
                      Text(
                        "There are currently no users designated as landlords.",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.tabLabelTextStyle,
                      ),
                    ],
                  ),
                ),
              );
            }

            return CustomScrollView(
              slivers: <Widget>[
                CupertinoSliverRefreshControl(
                  onRefresh: _fetchLandlords,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      if (index.isOdd) { // Separator
                        return Divider(indent: 16, endIndent: 0, height: 0.5, color: CupertinoColors.separator.resolveFrom(context));
                      }
                      final itemIndex = index ~/ 2;
                      if (itemIndex >= _landlords.length) return null;
                      
                      final landlord = _landlords[itemIndex];
                      return _buildLandlordListTile(landlord);
                    },
                    childCount: _landlords.length * 2 -1, // Account for separators
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}
