import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:cloudkeja/models/user_model.dart'; // Assuming user_model.dart is in lib/models/

class SubscriptionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Subscription Plans ---

  List<Map<String, dynamic>> getSubscriptionPlans() {
    // Hardcoded subscription plans
    return [
      {
        'id': 'starter',
        'name': 'Tier 1 - Starter Plan',
        'price': 0, // Or actual price like 5000
        'propertyLimit': 5,
        'adminUserLimit': 1,
        'features': [
          'Manage up to 5 properties',
          '1 Admin User',
          'Basic analytics',
          'Email support',
        ],
      },
      {
        'id': 'growth',
        'name': 'Tier 2 - Growth Plan',
        'price': 10000,
        'propertyLimit': 20,
        'adminUserLimit': 5,
        'features': [
          'Manage up to 20 properties',
          'Up to 5 Admin Users',
          'Advanced analytics',
          'Priority email support',
          'Tenant communication tools',
        ],
      },
      {
        'id': 'enterprise',
        'name': 'Tier 3 - Enterprise Plan',
        'price': 25000,
        'propertyLimit': 100, // Using -1 for unlimited as per issue description for some cases
        'adminUserLimit': 20, // Using -1 for unlimited
        'features': [
          'Manage unlimited properties',
          'Unlimited Admin Users',
          'Dedicated account manager',
          'Customizable reports',
          'API access',
          '24/7 phone support',
        ],
      },
    ];
  }

  Map<String, dynamic>? getPlanById(String tierId) {
    final plans = getSubscriptionPlans();
    try {
      return plans.firstWhere((plan) => plan['id'] == tierId);
    } catch (e) {
      // If no plan is found, return null or throw an error
      print('Error: Plan with ID "$tierId" not found. $e');
      return null;
    }
  }

  // --- Update Subscription ---

  Future<void> updateUserSubscription(String userId, String newTierId, Timestamp? expiryDate) async {
    try {
      // Optionally, fetch plan details if needed for other logic
      // final planDetails = getPlanById(newTierId);
      // if (planDetails == null) {
      //   throw Exception("Invalid tier ID provided.");
      // }

      await _firestore.collection('users').doc(userId).update({
        'subscriptionTier': newTierId,
        'subscriptionExpiryDate': expiryDate,
        // Reset counts if business logic requires, or handle this elsewhere
        // 'propertyCount': 0, // Example: Reset count on new subscription
      });
      // No direct state in this provider changes, but if you were caching user's sub, you'd notify.
      // notifyListeners();
    } catch (e) {
      print('Error updating user subscription: $e');
      // Rethrow or handle as per application's error handling strategy
      rethrow;
    }
  }

  // --- Check Active Subscription ---

  bool hasActiveSubscription(UserModel user) {
    if (user.subscriptionExpiryDate == null) {
      // Assuming null means a lifetime or non-expiring plan (e.g. "Starter Plan" might be indefinite)
      // Or, for some plans, null might mean "not subscribed" if an expiry is always expected.
      // For this example, let's consider "Starter Plan" (often free) as always active if no expiry.
      // Or, if `subscriptionTier` itself indicates a non-expiring default tier.
      // A common approach for paid tiers: null expiry means it's not active or an error.
      // However, based on the requirements, "Starter Plan" is a default.
      // Let's assume if expiryDate is null, it's active (e.g. for a free tier or lifetime).
      // This logic might need refinement based on specific business rules for each tier.
      return true; // Or based on tier, e.g. user.subscriptionTier == 'starter'
    }
    return user.subscriptionExpiryDate!.toDate().isAfter(DateTime.now());
  }

  // --- Check Limits ---

  bool canAddProperty(UserModel user) {
    if (user.subscriptionTier == null) {
      // If somehow subscriptionTier is null, deny adding.
      // This case should ideally be prevented by defaulting in UserModel.
      return false;
    }
    final planDetails = getPlanById(user.subscriptionTier!);
    if (planDetails == null) {
      // Invalid or unknown plan, deny.
      return false;
    }

    final propertyLimit = planDetails['propertyLimit'] as int?;
    if (propertyLimit == null) {
      // If limit is not defined for the plan (should not happen with current setup), deny.
      return false;
    }
    if (propertyLimit == -1) {
      return true; // -1 signifies unlimited properties
    }
    return (user.propertyCount ?? 0) < propertyLimit;
  }

  bool canAddAdminUser(UserModel user) {
    if (user.subscriptionTier == null) {
      return false;
    }
    final planDetails = getPlanById(user.subscriptionTier!);
    if (planDetails == null) {
      return false;
    }

    final adminUserLimit = planDetails['adminUserLimit'] as int?;
    if (adminUserLimit == null) {
      return false;
    }
    if (adminUserLimit == -1) {
      return true; // -1 signifies unlimited admin users
    }
    return (user.adminUserCount ?? 0) < adminUserLimit;
  }
}
