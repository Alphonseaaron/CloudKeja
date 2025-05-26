import 'package:flutter/material.dart';

class ServiceProviderDashboardPage extends StatefulWidget {
  const ServiceProviderDashboardPage({Key? key}) : super(key: key);

  static const String routeName = '/service-provider-dashboard';

  @override
  State<ServiceProviderDashboardPage> createState() => _ServiceProviderDashboardPageState();
}

class _ServiceProviderDashboardPageState extends State<ServiceProviderDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Provider Dashboard'),
        // Potentially add actions or leading widget if needed later
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Assigned Maintenance Tasks',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24), // Increased spacing
              Icon(
                Icons.construction, // Relevant icon
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'A list of maintenance tasks assigned to you by landlords or property managers will appear here.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'You will be able to view task details, communicate with the assigner, and update the status of each task (e.g., "Accepted", "In Progress", "Completed", "Requires Parts").',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Placeholder for future action button or summary
              // Example:
              // ElevatedButton(
              //   onPressed: () {
              //     // Potentially refresh tasks or navigate to a specific task
              //   },
              //   child: const Text('Refresh Tasks'),
              // ),
              Text(
                'Future enhancements will include filtering, sorting, and notification capabilities for new assignments.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
