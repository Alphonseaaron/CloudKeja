import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/providers/subscription_provider.dart';

class SubscriptionPlansScreen extends StatelessWidget {
  static const String routeName = '/subscription-plans';

  const SubscriptionPlansScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the SubscriptionProvider
    // For this screen, we can assume SubscriptionProvider is already provided higher up the widget tree.
    // If not, this widget itself would need to create/provide it or receive it.
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
    final plans = subscriptionProvider.getSubscriptionPlans();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: plans.length,
        itemBuilder: (ctx, index) {
          final plan = plans[index];
          final features = plan['features'] as List<String>? ?? [];

          return Card(
            elevation: 4.0,
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    plan['name'] as String? ?? 'Unnamed Plan',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Price: KES ${plan['price']}', // Assuming KES currency
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    'Features:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4.0),
                  ...features.map((feature) => Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 2.0, bottom: 2.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 16.0, color: Colors.green),
                            const SizedBox(width: 8.0),
                            Expanded(child: Text(feature)),
                          ],
                        ),
                      )).toList(),
                  const SizedBox(height: 12.0),
                  Text(
                    'Property Limit: ${plan['propertyLimit'] == -1 ? "Unlimited" : plan['propertyLimit']}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Admin User Limit: ${plan['adminUserLimit'] == -1 ? "Unlimited" : plan['adminUserLimit']}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20.0),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                        textStyle: Theme.of(context).textTheme.labelLarge,
                      ),
                      onPressed: () {
                        // Action for choosing the plan
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Selected: ${plan['name']}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        print('Plan selected: ${plan['id']} - ${plan['name']}');
                        // TODO: Navigate to payment screen or initiate upgrade process
                      },
                      child: const Text('Choose Plan'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
