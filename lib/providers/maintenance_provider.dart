import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloudkeja/models/maintenance_request_model.dart';

class MaintenanceProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cache for user's maintenance requests to avoid unnecessary fetches
  // List<MaintenanceRequestModel>? _userMaintenanceRequests;
  // DateTime? _lastFetchTime;
  // String? _lastFetchedUserId;
  // String? _lastStatusFilter;
  // DateTimeRange? _lastDateFilter;

  // Simple caching can be complex with filters. For now, direct fetch or provider-level caching.
  // More advanced caching would involve checking if filters changed significantly.

  Future<List<MaintenanceRequestModel>> fetchUserMaintenanceRequests({
    String? specificUserId, // Optional: for admins or specific use cases
    String? statusFilter,   // e.g., "All", "Submitted", "InProgress", "Completed", "Cancelled"
    DateTimeRange? dateFilter,
    bool forceRefresh = false, // To bypass cache if implemented
  }) async {
    final targetUserId = specificUserId ?? _auth.currentUser?.uid;

    if (targetUserId == null) {
      // Not logged in, or no specific user ID provided when required
      debugPrint('MaintenanceProvider: User not logged in or targetUserId is null.');
      return []; 
    }

    // Caching logic could be added here if needed:
    // if (!forceRefresh && 
    //     _userMaintenanceRequests != null && 
    //     _lastFetchTime != null && 
    //     DateTime.now().difference(_lastFetchTime!) < const Duration(minutes: 5) && // Example: 5-minute cache
    //     _lastFetchedUserId == targetUserId &&
    //     _lastStatusFilter == statusFilter &&
    //     _lastDateFilter == dateFilter) {
    //   debugPrint('MaintenanceProvider: Returning cached maintenance requests.');
    //   return _userMaintenanceRequests!;
    // }

    try {
      debugPrint('MaintenanceProvider: Fetching maintenance requests for user $targetUserId with status: $statusFilter, dateRange: $dateFilter');
      Query query = _firestore
          .collection('maintenance_requests')
          .where('userId', isEqualTo: targetUserId)
          .orderBy('dateSubmitted', descending: true); // Order by most recent

      if (statusFilter != null && statusFilter.toLowerCase() != 'all') {
        query = query.where('status', isEqualTo: statusFilter);
      }

      if (dateFilter != null) {
        query = query
            .where('dateSubmitted', isGreaterThanOrEqualTo: Timestamp.fromDate(dateFilter.start))
            // For end date, use a time at the end of the day if filtering by whole days
            .where('dateSubmitted', isLessThanOrEqualTo: Timestamp.fromDate(DateTime(dateFilter.end.year, dateFilter.end.month, dateFilter.end.day, 23, 59, 59)));
      }

      final snapshot = await query.get();
      debugPrint('MaintenanceProvider: Fetched ${snapshot.docs.length} requests.');

      final requests = snapshot.docs
          .map((doc) => MaintenanceRequestModel.fromSnapshot(doc))
          .toList();
      
      // Update cache if implementing caching
      // _userMaintenanceRequests = requests;
      // _lastFetchTime = DateTime.now();
      // _lastFetchedUserId = targetUserId;
      // _lastStatusFilter = statusFilter;
      // _lastDateFilter = dateFilter;

      // notifyListeners(); // Only if this provider holds the state for UI directly
      return requests;

    } catch (e) {
      debugPrint('Error fetching user maintenance requests: $e');
      // Propagate the error or return an empty list
      throw Exception('Could not fetch maintenance requests: $e');
    }
  }

  // TODO: Add methods for submitting, updating, or deleting maintenance requests if needed by the app.
  // Example:
  // Future<void> submitMaintenanceRequest(MaintenanceRequestModel requestData) async {
  //   try {
  //     await _firestore.collection('maintenance_requests').add(requestData.toJson());
  //     notifyListeners(); // If other parts of the app need to react to new requests
  //   } catch (e) {
  //     debugPrint('Error submitting maintenance request: $e');
  //     throw Exception('Could not submit request: $e');
  //   }
  // }
}
