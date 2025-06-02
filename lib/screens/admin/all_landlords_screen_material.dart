import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/admin_provider.dart';
import 'package:cloudkeja/screens/admin/user_actions.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AllLandlordsScreen extends StatefulWidget {
  const AllLandlordsScreen({Key? key}) : super(key: key);

  @override
  State<AllLandlordsScreen> createState() => _AllLandlordsScreenState();
}

class _AllLandlordsScreenState extends State<AllLandlordsScreen> {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load landlords: $_errorMessage', style: TextStyle(color: Theme.of(context).colorScheme.onError)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildLandlordTile(BuildContext context, UserModel landlord, ThemeData theme, ColorScheme colorScheme, TextTheme textTheme) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorScheme.surfaceVariant,
        backgroundImage: (landlord.profile != null && landlord.profile!.isNotEmpty)
            ? NetworkImage(landlord.profile!)
            : null,
        child: (landlord.profile == null || landlord.profile!.isEmpty)
            ? Icon(Icons.person_outline_rounded, color: colorScheme.onSurfaceVariant)
            : null,
      ),
      title: Row(
        children: [
          Flexible(child: Text(landlord.name ?? 'N/A', style: textTheme.titleMedium, overflow: TextOverflow.ellipsis)),
          if (landlord.isAdmin == true) ...[
            const SizedBox(width: 5),
            Icon(Icons.shield_outlined, color: colorScheme.secondary, size: 18),
          ],
        ],
      ),
      subtitle: Text(landlord.email ?? 'No email', style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.7))),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.outline.withOpacity(0.7)),
      onTap: () {
        actionSheet(context, landlord, theme); // Pass theme object
      },
    );
  }

  Widget _buildSkeletonTile(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
      ),
      title: Container(
        height: 16,
        width: MediaQuery.of(context).size.width * 0.4,
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
      ),
      subtitle: Container(
        height: 12,
        width: MediaQuery.of(context).size.width * 0.6,
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        margin: const EdgeInsets.only(top: 4),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.outline.withOpacity(0.3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    Widget content;

    if (_isLoading && _landlords.isEmpty) {
      content = Skeletonizer(
        enabled: true,
        child: ListView.separated(
          itemCount: 10, // Number of skeleton items
          itemBuilder: (context, index) => _buildSkeletonTile(context),
          separatorBuilder: (context, index) => Divider(indent: 16, endIndent: 16, height: 1, color: theme.dividerColor.withOpacity(0.1)),
        ),
      );
    } else if (_errorMessage != null) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: colorScheme.error, size: 60),
              const SizedBox(height: 16),
              Text('Something Went Wrong', style: textTheme.titleLarge?.copyWith(color: colorScheme.error)),
              const SizedBox(height: 8),
              Text(_errorMessage!, textAlign: TextAlign.center, style: textTheme.bodyMedium),
            ],
          ),
        ),
      );
    } else if (_landlords.isEmpty) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.real_estate_agent_outlined, size: 80, color: colorScheme.primary.withOpacity(0.6)),
              const SizedBox(height: 20),
              Text("No Landlords Found", style: textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                "There are currently no users designated as landlords.",
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    } else {
      content = ListView.separated(
        itemCount: _landlords.length,
        itemBuilder: (context, index) {
          final landlord = _landlords[index];
          return _buildLandlordTile(context, landlord, theme, colorScheme, textTheme);
        },
        separatorBuilder: (context, index) => Divider(
          indent: 16,
          endIndent: 16,
          height: 1,
          color: theme.dividerColor.withOpacity(0.5)
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('All Landlords'),
        // AppBar theming will be inherited from AppTheme
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLandlords,
        child: content,
      ),
    );
  }
}
