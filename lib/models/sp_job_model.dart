import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp if using Firestore later

class SPJobModel {
  final String id;
  final DateTime dateCompleted; // Could be dateScheduled or dateCompleted based on status
  final String clientName;
  final String? propertyAddress;
  final String serviceDescription;
  final String status; // e.g., "Scheduled", "InProgress", "Completed", "Cancelled", "PendingPayment"
  final double amountEarned;

  SPJobModel({
    required this.id,
    required this.dateCompleted,
    required this.clientName,
    this.propertyAddress,
    required this.serviceDescription,
    required this.status,
    required this.amountEarned,
  });

  // Factory constructor for creating from Firestore (for future use)
  factory SPJobModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return SPJobModel(
      id: snapshot.id,
      dateCompleted: (data['dateCompleted'] as Timestamp).toDate(),
      clientName: data['clientName'] as String,
      propertyAddress: data['propertyAddress'] as String?,
      serviceDescription: data['serviceDescription'] as String,
      status: data['status'] as String,
      amountEarned: (data['amountEarned'] as num).toDouble(),
    );
  }

  // ToJson method (for future use)
  Map<String, dynamic> toJson() {
    return {
      'dateCompleted': Timestamp.fromDate(dateCompleted),
      'clientName': clientName,
      'propertyAddress': propertyAddress,
      'serviceDescription': serviceDescription,
      'status': status,
      'amountEarned': amountEarned,
    };
  }

  static SPJobModel empty() {
    return SPJobModel(
      id: 'skel-${DateTime.now().millisecondsSinceEpoch}',
      dateCompleted: DateTime.now(),
      clientName: 'Loading Client Name...',
      propertyAddress: 'Loading Address...',
      serviceDescription: 'Loading service description of the job that was performed...',
      status: 'Loading',
      amountEarned: 0.0,
    );
  }

  static List<SPJobModel> get dummyData {
    return [
      SPJobModel(
        id: 'job001',
        dateCompleted: DateTime.now().subtract(const Duration(days: 2)),
        clientName: 'Alice Wonderland',
        propertyAddress: '101 Sky High Towers, Apt 15C',
        serviceDescription: 'Emergency plumbing: Fixed burst pipe under kitchen sink.',
        status: 'Completed',
        amountEarned: 150.00,
      ),
      SPJobModel(
        id: 'job002',
        dateCompleted: DateTime.now().add(const Duration(days: 3)), // Future date for scheduled
        clientName: 'Bob The Builder',
        propertyAddress: '202 Ground Floor Estates',
        serviceDescription: 'Scheduled electrical wiring inspection and minor repairs.',
        status: 'Scheduled',
        amountEarned: 250.00,
      ),
      SPJobModel(
        id: 'job003',
        dateCompleted: DateTime.now().subtract(const Duration(hours: 5)),
        clientName: 'Catherine Wheel',
        propertyAddress: '303 Rolling Hills Villas',
        serviceDescription: 'HVAC unit servicing and filter replacement.',
        status: 'InProgress',
        amountEarned: 180.00,
      ),
      SPJobModel(
        id: 'job004',
        dateCompleted: DateTime.now().subtract(const Duration(days: 7)),
        clientName: 'David Copperfield',
        propertyAddress: '404 Magic Manor',
        serviceDescription: 'Painting services for two bedrooms, client provided paint.',
        status: 'PendingPayment',
        amountEarned: 320.00,
      ),
      SPJobModel(
        id: 'job005',
        dateCompleted: DateTime.now().subtract(const Duration(days: 1)),
        clientName: 'Eva Green',
        propertyAddress: '505 Evergreen Terrace',
        serviceDescription: 'Cancelled appointment: Gate lock replacement.',
        status: 'Cancelled',
        amountEarned: 0.00,
      ),
    ];
  }
}
