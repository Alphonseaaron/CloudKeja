import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp if using Firestore later

class MaintenanceRequestModel {
  final String id;
  final DateTime dateSubmitted;
  final String propertyAddress;
  final String description;
  final String status; // e.g., "Submitted", "InProgress", "Completed", "Cancelled"
  final List<String>? photos; // Optional list of photo URLs

  MaintenanceRequestModel({
    required this.id,
    required this.dateSubmitted,
    required this.propertyAddress,
    required this.description,
    required this.status,
    this.photos,
  });

  // Factory constructor for creating a new MaintenanceRequestModel instance from a Firestore snapshot.
  // This will be useful when fetching real data later.
  factory MaintenanceRequestModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return MaintenanceRequestModel(
      id: snapshot.id,
      dateSubmitted: (data['dateSubmitted'] as Timestamp).toDate(),
      propertyAddress: data['propertyAddress'] as String,
      description: data['description'] as String,
      status: data['status'] as String,
      photos: data['photos'] != null ? List<String>.from(data['photos']) : null,
    );
  }

  // Method to convert a MaintenanceRequestModel instance to a map for Firestore.
  // Useful if creating/updating requests.
  Map<String, dynamic> toJson() {
    return {
      'dateSubmitted': Timestamp.fromDate(dateSubmitted),
      'propertyAddress': propertyAddress,
      'description': description,
      'status': status,
      'photos': photos,
      // 'id' is usually the document ID and not stored as a field within the document itself.
    };
  }


  // Static method to create an empty or dummy model for placeholders/skeletonizer
  static MaintenanceRequestModel empty() {
    return MaintenanceRequestModel(
      id: 'skel-${DateTime.now().millisecondsSinceEpoch}',
      dateSubmitted: DateTime.now(),
      propertyAddress: 'Loading property address...',
      description: 'Loading description of the maintenance issue that was reported by the user...',
      status: 'Loading', // A neutral status for skeleton
      photos: [],
    );
  }

  // Example of creating a list of dummy data
  static List<MaintenanceRequestModel> dummyData = [
    MaintenanceRequestModel(
      id: '1',
      dateSubmitted: DateTime.now().subtract(const Duration(days: 10)),
      propertyAddress: '123 Cloud St, Apt 5B, Keja City',
      description: 'Leaking kitchen faucet, water dripping continuously under the sink.',
      status: 'Submitted',
      photos: ['https://via.placeholder.com/150/FF0000/FFFFFF?Text=Photo1', 'https://via.placeholder.com/150/00FF00/FFFFFF?Text=Photo2'],
    ),
    MaintenanceRequestModel(
      id: '2',
      dateSubmitted: DateTime.now().subtract(const Duration(days: 5)),
      propertyAddress: '456 Sky Ave, Unit 12, Keja Town',
      description: 'Air conditioning unit not cooling, making strange noises.',
      status: 'InProgress',
      photos: [],
    ),
    MaintenanceRequestModel(
      id: '3',
      dateSubmitted: DateTime.now().subtract(const Duration(days: 2)),
      propertyAddress: '789 Nimbus Rd, Apt 3C, Cloud District',
      description: 'Broken window pane in the living room due to recent storm.',
      status: 'Completed',
    ),
     MaintenanceRequestModel(
      id: '4',
      dateSubmitted: DateTime.now().subtract(const Duration(days: 1)),
      propertyAddress: '101 Cloud Ln, Apt 1A, Keja City',
      description: 'No hot water in the main bathroom. Boiler might be malfunctioning.',
      status: 'Cancelled',
    ),
  ];
}
