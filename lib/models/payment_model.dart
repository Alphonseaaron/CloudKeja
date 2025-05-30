import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id; // Document ID from Firestore
  final Timestamp date; // Use Timestamp for Firestore compatibility
  final String description;
  final double amount;
  final String currency; // e.g., "KES", "USD"
  final String status; // e.g., "Successful", "Pending", "Failed"
  final String userId; // ID of the user associated with the payment
  final String? propertyId; // Optional: ID of the property related to the payment
  final String? paymentMethod; // e.g., "Mpesa", "Card", "Bank Transfer"
  final String? transactionId; // e.g., Mpesa transaction code

  PaymentModel({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    this.currency = 'KES', // Default currency
    required this.status,
    required this.userId,
    this.propertyId,
    this.paymentMethod,
    this.transactionId,
  });

  // Factory constructor to create a PaymentModel from a Firestore document
  factory PaymentModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return PaymentModel(
      id: snapshot.id,
      date: data['date'] as Timestamp,
      description: data['description'] as String,
      amount: (data['amount'] as num).toDouble(), // Firestore stores numbers, cast to double
      currency: data['currency'] as String? ?? 'KES',
      status: data['status'] as String,
      userId: data['userId'] as String,
      propertyId: data['propertyId'] as String?,
      paymentMethod: data['paymentMethod'] as String?,
      transactionId: data['transactionId'] as String?,
    );
  }

  // Method to convert a PaymentModel instance to a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'description': description,
      'amount': amount,
      'currency': currency,
      'status': status,
      'userId': userId,
      'propertyId': propertyId,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      // 'id' is typically not stored as a field in the document itself
    };
  }

  // Static method for creating an empty model for skeletonizer
  static PaymentModel empty() {
    return PaymentModel(
      id: 'skel-${DateTime.now().millisecondsSinceEpoch}', // Unique skeleton ID
      date: Timestamp.now(),
      description: 'Loading payment description...',
      amount: 0.00,
      status: 'Loading',
      userId: 'skeleton_user',
      currency: 'KES',
      paymentMethod: '---',
      transactionId: '---',
      propertyId: 'skeleton_property'
    );
  }
}
