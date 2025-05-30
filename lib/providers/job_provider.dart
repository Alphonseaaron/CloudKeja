import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloudkeja/models/sp_job_model.dart'; // Ensure this path is correct

class JobProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<SPJobModel>> fetchSPJobHistory({
    String? serviceProviderId, // Allow passing SP ID for admin/other views
    String? statusFilter,
    DateTimeRange? dateFilter,
    bool forceRefresh = false,
  }) async {
    final targetId = serviceProviderId ?? _auth.currentUser?.uid;

    if (targetId == null) {
      debugPrint('JobProvider: User not logged in or serviceProviderId not provided.');
      return [];
    }

    try {
      debugPrint('JobProvider: Fetching job history for SP $targetId with status: $statusFilter, dateRange: $dateFilter');

      Query query = _firestore
          .collection('service_jobs')
          .where('serviceProviderId', isEqualTo: targetId);
          // Default ordering, can be overridden by specific needs or removed if filters are complex
          // .orderBy('dateCompleted', descending: true);

      if (statusFilter != null && statusFilter.toLowerCase() != 'all') {
        query = query.where('status', isEqualTo: statusFilter);
      }

      if (dateFilter != null) {
        // Assuming dateCompleted is the primary field for date filtering job history.
        // If jobs also have a 'dateScheduled' or 'jobDate', adjust field name as needed.
        query = query
            .where('dateCompleted', isGreaterThanOrEqualTo: Timestamp.fromDate(dateFilter.start))
            .where('dateCompleted', isLessThanOrEqualTo: Timestamp.fromDate(DateTime(dateFilter.end.year, dateFilter.end.month, dateFilter.end.day, 23, 59, 59)));
      }

      // Add a default sort if no specific date filter is applied, or if status filter needs it
      // For example, always sort by a creation or scheduling date if 'dateCompleted' is not always present
      // query = query.orderBy('createdAt', descending: true); // Example fallback sort

      final snapshot = await query.get();
      debugPrint('JobProvider: Fetched ${snapshot.docs.length} job records for SP $targetId.');

      if (snapshot.docs.isEmpty) {
        debugPrint('JobProvider: No matching job documents found for SP $targetId.');
      }

      final jobs = snapshot.docs.map((doc) {
        try {
          return SPJobModel.fromSnapshot(doc);
        } catch (e) {
          debugPrint('Error parsing job document ${doc.id}: $e');
          return null;
        }
      }).whereType<SPJobModel>().toList();

      // Sort client-side if Firestore multiple orderBy on different fields isn't feasible for all cases
      // For example, if primary sort is by status, then by date:
      jobs.sort((a, b) {
        int dateCompare = (b.dateCompleted).compareTo(a.dateCompleted); // Most recent first
        if (dateCompare != 0) return dateCompare;
        return a.status.compareTo(b.status); // Then by status
      });

      return jobs;

    } catch (e) {
      debugPrint('Error fetching SP job history for $targetId: $e');
      throw Exception('Could not fetch job history: $e');
    }
  }

  // New method to get job count by a single status
  Future<int> getJobCountByStatus(String serviceProviderId, String status) async {
    if (serviceProviderId.isEmpty || status.isEmpty) return 0;
    try {
      debugPrint('JobProvider: Getting job count for SP $serviceProviderId, status: $status');
      final snapshot = await _firestore
          .collection('service_jobs')
          .where('serviceProviderId', isEqualTo: serviceProviderId)
          .where('status', isEqualTo: status)
          .count() // Use count() aggregation query
          .get();
      debugPrint('JobProvider: Count for SP $serviceProviderId, status $status is ${snapshot.count}');
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting job count by status for $serviceProviderId: $e');
      return 0; // Return 0 on error
    }
  }

  // New method to get job count by a list of statuses
  Future<int> getJobCountByStatusList(String serviceProviderId, List<String> statuses) async {
     if (serviceProviderId.isEmpty || statuses.isEmpty) return 0;
    // Firestore's 'whereIn' can take up to 30 values in Dart/Flutter (was 10).
    // If more are needed, multiple queries would be required.
    if (statuses.length > 30) {
      debugPrint('JobProvider: Status list exceeds Firestore "whereIn" limit of 30.');
      // Optionally handle this by splitting into multiple queries or returning an error/0.
      // For now, returning 0 as a safeguard.
      return 0;
    }
    try {
      debugPrint('JobProvider: Getting job count for SP $serviceProviderId, statuses: $statuses');
      final snapshot = await _firestore
          .collection('service_jobs')
          .where('serviceProviderId', isEqualTo: serviceProviderId)
          .where('status', whereIn: statuses)
          .count() // Use count() aggregation query
          .get();
      debugPrint('JobProvider: Count for SP $serviceProviderId, statuses $statuses is ${snapshot.count}');
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting job count by status list for $serviceProviderId: $e');
      return 0; // Return 0 on error
    }
  }
}
