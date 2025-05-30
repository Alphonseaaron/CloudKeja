import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart'; // Import Skeletonizer
import 'package:get/route_manager.dart'; // Import Get
import 'package:cloudkeja/screens/chat/chat_screen.dart'; // Import ChatScreen
// import 'package:fl_chart/fl_chart.dart'; // Example, if charts were to be added
import 'package:showcaseview/showcaseview.dart';
import 'package:cloudkeja/services/walkthrough_service.dart';

// Mock data models (replace with actual models when available)
class ServiceTask {
  final String id;
  final String title;
  final String address;
  final String status; // e.g., "New", "In Progress", "Completed"
  final DateTime dueDate;

  ServiceTask({required this.id, required this.title, required this.address, required this.status, required this.dueDate});

  static ServiceTask empty() { // For skeletonizer
    return ServiceTask(
      id: 'skel-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Loading Task Title...',
      address: 'Loading address...',
      status: 'Status',
      dueDate: DateTime.now(),
    );
  }
}

class ServiceProviderStats {
  final int newTasks;
  final int inProgressTasks;
  final int completedToday;
  // final int unreadMessages; // Example if we had this data

  ServiceProviderStats({
    required this.newTasks,
    required this.inProgressTasks,
    required this.completedToday,
    // this.unreadMessages = 0, // Default if not fetched
  });

  static ServiceProviderStats empty() { // For skeletonizer
    return ServiceProviderStats(newTasks: 0, inProgressTasks: 0, completedToday: 0 /*, unreadMessages: 0 */);
  }
}


class ServiceProviderDashboardPage extends StatefulWidget {
  const ServiceProviderDashboardPage({Key? key}) : super(key: key);
  static const String routeName = '/service-provider-dashboard';

  @override
  State<ServiceProviderDashboardPage> createState() => _ServiceProviderDashboardPageState();
}

class _ServiceProviderDashboardPageState extends State<ServiceProviderDashboardPage> {
  bool _isLoading = true;
  ServiceProviderStats _stats = ServiceProviderStats.empty();
  List<ServiceTask> _assignedTasks = List.generate(3, (index) => ServiceTask.empty()); // For skeleton

  // GlobalKeys for ShowcaseView
  final _statsGridKey = GlobalKey();
  final _quickActionsKey = GlobalKey();
  final _assignedTasksListKey = GlobalKey();

  List<GlobalKey> _showcaseKeys = [];

  @override
  void initState() {
    super.initState();
    _showcaseKeys = [
      _statsGridKey,
      _quickActionsKey,
      _assignedTasksListKey,
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      WalkthroughService.startShowcaseIfNeeded(
        context: context,
        walkthroughKey: 'spDashboardOverview_v1',
        showcaseGlobalKeys: _showcaseKeys,
      );
    });
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _stats = ServiceProviderStats(newTasks: 3, inProgressTasks: 5, completedToday: 2 /*, unreadMessages: 2 */); // Example unread messages
        _assignedTasks = [
          ServiceTask(id: '1', title: 'Fix Leaky Faucet', address: '123 Main St, Apt 4B', status: 'New', dueDate: DateTime.now().add(const Duration(days: 2))),
          ServiceTask(id: '2', title: 'Repair HVAC Unit', address: '456 Oak Ave', status: 'In Progress', dueDate: DateTime.now().add(const Duration(days: 1))),
          ServiceTask(id: '3', title: 'Paint Living Room', address: '789 Pine Ln', status: 'New', dueDate: DateTime.now().add(const Duration(days: 3))),
          ServiceTask(id: '4', title: 'Electrical Wiring Check', address: '101 Maple Dr', status: 'Completed', dueDate: DateTime.now().subtract(const Duration(days: 1))),
        ];
        _isLoading = false;
      });
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
    VoidCallback? onTap, // Added onTap callback
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      // Card properties from theme
      child: InkWell( // Make the card tappable
        onTap: onTap,
        borderRadius: (theme.cardTheme.shape as RoundedRectangleBorder?)?.borderRadius ?? BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: iconColor),
              const SizedBox(height: 8),
              Text(
                value, // This can be a count or placeholder like "--"
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: iconColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskListItem(BuildContext context, ServiceTask task) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    IconData statusIcon;
    Color statusColor;

    switch (task.status) {
      case 'New':
        statusIcon = Icons.new_releases_outlined;
        statusColor = colorScheme.secondary;
        break;
      case 'In Progress':
        statusIcon = Icons.construction_outlined;
        statusColor = colorScheme.primary;
        break;
      case 'Completed':
        statusIcon = Icons.check_circle_outline;
        statusColor = Colors.green.shade600;
        break;
      default:
        statusIcon = Icons.help_outline;
        statusColor = colorScheme.onSurface.withOpacity(0.5);
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: statusColor.withOpacity(0.15),
        child: Icon(statusIcon, color: statusColor, size: 24),
      ),
      title: Text(task.title, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${task.address}\nDue: ${MaterialLocalizations.of(context).formatShortDate(task.dueDate)}',
        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.outline),
      onTap: () {
        // TODO: Navigate to task details page
        // Get.to(() => ServiceTaskDetailsPage(taskId: task.id));
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Common showcase text style
    TextStyle? showcaseTitleStyle = textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary);
    TextStyle? showcaseDescStyle = textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary.withOpacity(0.9));

    return ShowCaseWidget(
      onFinish: () {
        WalkthroughService.markAsSeen('spDashboardOverview_v1');
      },
      builder: Builder(builder: (context) {
        return Scaffold(
          backgroundColor: colorScheme.background,
          appBar: AppBar(
            title: const Text('Service Provider Dashboard'),
          ),
          body: Skeletonizer(
            enabled: _isLoading,
            effect: ShimmerEffect(
              baseColor: colorScheme.surfaceVariant.withOpacity(0.4),
              highlightColor: colorScheme.surfaceVariant.withOpacity(0.8),
            ),
            child: RefreshIndicator(
              onRefresh: _fetchDashboardData,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                children: [
                  // Stats Section
                  Showcase(
                    key: _statsGridKey,
                    title: 'Your Dashboard Stats',
                    description: 'Get a quick overview of your tasks, earnings, and messages here.',
                    titleTextStyle: showcaseTitleStyle,
                    descTextStyle: showcaseDescStyle,
                    showcaseBackgroundColor: colorScheme.primary,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GridView.count(
                        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.15,
                        children: [
                          _buildStatCard(context, icon: Icons.assignment_late_outlined, value: _stats.newTasks.toString(), label: 'New Tasks', iconColor: colorScheme.secondary),
                          _buildStatCard(context, icon: Icons.construction_rounded, value: _stats.inProgressTasks.toString(), label: 'In Progress', iconColor: colorScheme.primary),
                          _buildStatCard(context, icon: Icons.task_alt_outlined, value: _stats.completedToday.toString(), label: 'Completed Today', iconColor: Colors.green.shade600),
                          _buildStatCard(
                            context,
                            icon: Icons.chat_bubble_outline_rounded,
                            value: "View",
                            label: 'My Chats',
                            iconColor: colorScheme.tertiary,
                            onTap: () {
                              Get.to(() => const ChatScreen());
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  _buildSectionTitle(context, 'Quick Actions'),
                  Showcase(
                    key: _quickActionsKey,
                    title: 'Manage Your Services',
                    description: 'Quickly access your schedule or update your availability.',
                    titleTextStyle: showcaseTitleStyle,
                    descTextStyle: showcaseDescStyle,
                    showcaseBackgroundColor: colorScheme.primary,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Wrap(
                        spacing: 12.0,
                        runSpacing: 8.0,
                        children: [
                          ElevatedButton.icon(icon: Icon(Icons.calendar_month_outlined, size: 18), label: const Text('My Schedule'), onPressed: () { /* TODO */ }),
                          OutlinedButton.icon(icon: Icon(Icons.edit_calendar_outlined, size: 18), label: const Text('Update Availability'), onPressed: () { Get.toNamed(ServiceProviderProfilePage.routeName); }),
                        ],
                      ),
                    ),
                  ),

                  _buildSectionTitle(context, 'Assigned Tasks'),
                  Showcase(
                    key: _assignedTasksListKey,
                    title: 'Current Tasks',
                    description: 'This list shows your currently assigned tasks. Tap on them for details.',
                    titleTextStyle: showcaseTitleStyle,
                    descTextStyle: showcaseDescStyle,
                    showcaseBackgroundColor: colorScheme.primary,
                    // Note: If the list is empty or loading, this showcase might point to an empty space.
                    // For a more robust showcase, one might wrap a parent container that always exists.
                    // However, for this overview, showcasing the list area is generally acceptable.
                    child: (_isLoading && _assignedTasks.every((t) => t.id.startsWith('skel-')))
                        ? ListView.builder( // Show skeleton in showcase if loading
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 3,
                            itemBuilder: (context, index) => _buildTaskListItem(context, ServiceTask.empty()),
                          )
                        : (!_isLoading && _assignedTasks.isEmpty)
                            ? Padding( // Show empty message in showcase
                                padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
                                child: Center(child: Text('No tasks assigned at the moment.', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)))),
                              )
                            : ListView.separated( // Show actual list in showcase
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _assignedTasks.length,
                                itemBuilder: (context, index) => _buildTaskListItem(context, _assignedTasks[index]),
                                separatorBuilder: (context, index) => Divider(indent: 16, endIndent: 16, height: 1, color: colorScheme.outline.withOpacity(0.2)),
                              ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
