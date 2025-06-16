import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/subscription_provider.dart';
import 'package:cloudkeja/screens/subscription/subscription_plans_screen.dart';

class UserSubscriptionStatusScreen extends StatelessWidget {
  static const String routeName = '/user-subscription-status';

  const UserSubscriptionStatusScreen({Key? key}) : super(key: key);

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'N/A (or Lifetime)'; // Or specific logic for indefinite plans
    }
    return DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    // Attempt to get UserModel from AuthProvider
    // This assumes AuthProvider holds the currently logged-in user's details
    // and that it's updated if the user's subscription changes elsewhere.
    final authProvider = Provider.of<AuthProvider>(context);
    final UserModel? currentUser = authProvider.user; // Assuming authProvider.user is the UserModel

    final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);

    Widget buildContent(UserModel user) {
      final planDetails = subscriptionProvider.getPlanById(user.subscriptionTier ?? 'starter');
      final String tierName = planDetails?['name'] as String? ?? user.subscriptionTier ?? 'Unknown Plan';
      final String propertyLimit = planDetails?['propertyLimit'] == -1 ? 'Unlimited' : '${planDetails?['propertyLimit']}';
      final String adminLimit = planDetails?['adminUserLimit'] == -1 ? 'Unlimited' : '${planDetails?['adminUserLimit']}';

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              elevation: 2.0,
              child: ListTile(
                title: const Text('Current Tier'),
                subtitle: Text(tierName, style: Theme.of(context).textTheme.titleLarge),
                leading: const Icon(Icons.star, color: Colors.amber),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2.0,
              child: ListTile(
                title: const Text('Subscription Expiry'),
                subtitle: Text(_formatTimestamp(user.subscriptionExpiryDate), style: Theme.of(context).textTheme.titleMedium),
                leading: const Icon(Icons.event_available, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2.0,
              child: ListTile(
                title: const Text('Property Usage'),
                subtitle: Text('${user.propertyCount ?? 0} / $propertyLimit properties', style: Theme.of(context).textTheme.titleMedium),
                leading: const Icon(Icons.home_work, color: Colors.green),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2.0,
              child: ListTile(
                title: const Text('Admin Users'),
                subtitle: Text('${user.adminUserCount ?? 0} / $adminLimit users', style: Theme.of(context).textTheme.titleMedium),
                leading: const Icon(Icons.people, color: Colors.orange),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.manage_accounts),
                label: const Text('Manage Subscription'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(SubscriptionPlansScreen.routeName);
                },
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Subscription'),
      ),
      body: currentUser == null
          ? Center(
              // Show a loading indicator or a message if user data isn't available yet.
              // This could also be a place to prompt login if user is null due to not being logged in.
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Loading user data...'),
                  const SizedBox(height:10),
                  // If AuthProvider.user is null because it's still loading, FutureBuilder on getCurrentUser might be better.
                  // If it's null because no one is logged in, then this screen shouldn't be accessible or should show a login prompt.
                  ElevatedButton(onPressed: () async {
                    // Example: try to refresh user data if it was a loading issue
                    try {
                      await authProvider.getCurrentUser();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to load user data: $e')),
                      );
                    }
                  }, child: const Text("Refresh User Data"))
                ],
              ),
            )
          : buildContent(currentUser),
    );
  }
}
