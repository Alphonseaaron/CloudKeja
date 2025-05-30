import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';
import 'package:cloudkeja/models/maintenance_request_model.dart';
import 'package:cloudkeja/widgets/tiles/maintenance_request_tile.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/providers/maintenance_provider.dart'; // Import the provider

class UserMaintenanceHistoryScreen extends StatefulWidget {
  const UserMaintenanceHistoryScreen({Key? key}) : super(key: key);
  static const String routeName = '/user-maintenance-history';

  @override
  State<UserMaintenanceHistoryScreen> createState() => _UserMaintenanceHistoryScreenState();
}

class _UserMaintenanceHistoryScreenState extends State<UserMaintenanceHistoryScreen> {
  bool _isLoading = true; // Start with loading true
  List<MaintenanceRequestModel> _maintenanceRequests = [];

  String _selectedStatusFilter = 'All';
  DateTimeRange? _selectedDateFilter;
  String _activeDateFilterLabel = 'Any Date'; // For UI display of date filter

  final List<String> _statusFilterOptions = ['All', 'Submitted', 'In Progress', 'Completed', 'Cancelled'];
  final Map<String, DateTimeRange?> _dateFilterOptions = {
    'Any Date': null,
    'Today': DateTimeRange(start: DateTime.now().subtract(const Duration(days:0)), end: DateTime.now()), // Start of day to end of day
    'This Week': DateTimeRange(start: DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)), end: DateTime.now()),
    'This Month': DateTimeRange(start: DateTime(DateTime.now().year, DateTime.now().month, 1), end: DateTime.now()),
  };


  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final maintenanceProvider = Provider.of<MaintenanceProvider>(context, listen: false);
      _maintenanceRequests = await maintenanceProvider.fetchUserMaintenanceRequests(
        statusFilter: _selectedStatusFilter,
        dateFilter: _selectedDateFilter,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching requests: ${e.toString()}', style: TextStyle(color: Theme.of(context).colorScheme.onError)), backgroundColor: Theme.of(context).colorScheme.error),
        );
        _maintenanceRequests = [];
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectCustomDateRange() async {
    final theme = Theme.of(context);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateFilter ?? DateTimeRange(start: DateTime.now().subtract(const Duration(days: 7)), end: DateTime.now()),
      builder: (context, child) {
        return Theme(data: theme, child: child!); // Apply app's theme
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateFilter = picked;
        _activeDateFilterLabel = '${DateFormat.yMd().format(picked.start)} - ${DateFormat.yMd().format(picked.end)}';
        _selectedStatusFilter = _selectedStatusFilter; // Keep current status filter
      });
      _fetchRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Maintenance Requests'),
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchRequests(forceRefresh: true),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter UI Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              color: colorScheme.surfaceContainerLowest, // Subtle background for filter bar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Filters
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Filter by Status:', style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    child: Row(
                      children: _statusFilterOptions.map((status) {
                        final bool isSelected = _selectedStatusFilter == status;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Text(status),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedStatusFilter = status);
                                _fetchRequests();
                              }
                            },
                            // Chip styling comes from ChipThemeData
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Date Filters
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
                    child: Text('Filter by Date:', style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    child: Row(
                      children: [
                        ..._dateFilterOptions.entries.map((entry) {
                          final bool isSelected = _activeDateFilterLabel == entry.key;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ChoiceChip(
                              label: Text(entry.key),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedDateFilter = entry.value;
                                    _activeDateFilterLabel = entry.key;
                                  });
                                  _fetchRequests();
                                }
                              },
                            ),
                          );
                        }).toList(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ActionChip( // Using ActionChip for custom range button
                            avatar: const Icon(Icons.calendar_month_outlined, size: 18),
                            label: Text(_activeDateFilterLabel == 'Custom' || !_dateFilterOptions.containsKey(_activeDateFilterLabel) ? 'Custom Range' : 'Custom'),
                            onPressed: _selectCustomDateRange,
                            // backgroundColor: _activeDateFilterLabel == 'Custom' ? colorScheme.secondaryContainer : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness:1, color: theme.dividerColor),

            // Maintenance Requests List
            Expanded(
              child: Skeletonizer(
                enabled: _isLoading,
                effect: ShimmerEffect(
                  baseColor: colorScheme.surfaceVariant.withOpacity(0.4),
                  highlightColor: colorScheme.surfaceVariant.withOpacity(0.8),
                ),
                child: (_maintenanceRequests.isEmpty && !_isLoading)
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.build_circle_outlined, size: 80, color: colorScheme.primary.withOpacity(0.3)),
                              const SizedBox(height: 20),
                              Text(
                                'No Maintenance Requests Found',
                                style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.8)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedStatusFilter == 'All' && _selectedDateFilter == null
                                ? 'Your submitted maintenance requests will appear here.'
                                : 'No requests match your current filters.',
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        itemCount: _isLoading ? 5 : _maintenanceRequests.length,
                        itemBuilder: (context, index) {
                          if (_isLoading) {
                            return MaintenanceRequestTile(maintenanceRequest: MaintenanceRequestModel.empty());
                          }
                          final request = _maintenanceRequests[index];
                          return MaintenanceRequestTile(maintenanceRequest: request);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
