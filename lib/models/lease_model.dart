import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For @required

class LeaseModel {
  final String leaseId; // Document ID from Firestore
  final String propertyAddress;
  final String? unitIdentifier;
  final String landlordName;
  final String? landlordContact; // Phone or email
  final Timestamp leaseStartDate;
  final Timestamp leaseEndDate;
  final double rentAmount;
  final String rentDueDate; // e.g., "1st of every month", "Upon Occupancy"
  final double? securityDepositAmount;
  final String? leaseDocumentUrl; // URL to PDF
  final String tenantId; // ID of the tenant (current user)
  final String? propertyId; // Optional: ID of the property
  final String? landlordId; // Optional: ID of the landlord

  LeaseModel({
    required this.leaseId,
    required this.propertyAddress,
    this.unitIdentifier,
    required this.landlordName,
    this.landlordContact,
    required this.leaseStartDate,
    required this.leaseEndDate,
    required this.rentAmount,
    required this.rentDueDate,
    this.securityDepositAmount,
    this.leaseDocumentUrl,
    required this.tenantId,
    this.propertyId,
    this.landlordId,
  });

  factory LeaseModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return LeaseModel(
      leaseId: snapshot.id,
      propertyAddress: data['propertyAddress'] as String,
      unitIdentifier: data['unitIdentifier'] as String?,
      landlordName: data['landlordName'] as String,
      landlordContact: data['landlordContact'] as String?,
      leaseStartDate: data['leaseStartDate'] as Timestamp,
      leaseEndDate: data['leaseEndDate'] as Timestamp,
      rentAmount: (data['rentAmount'] as num).toDouble(),
      rentDueDate: data['rentDueDate'] as String,
      securityDepositAmount: (data['securityDepositAmount'] as num?)?.toDouble(),
      leaseDocumentUrl: data['leaseDocumentUrl'] as String?,
      tenantId: data['tenantId'] as String,
      propertyId: data['propertyId'] as String?,
      landlordId: data['landlordId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'propertyAddress': propertyAddress,
      'unitIdentifier': unitIdentifier,
      'landlordName': landlordName,
      'landlordContact': landlordContact,
      'leaseStartDate': leaseStartDate,
      'leaseEndDate': leaseEndDate,
      'rentAmount': rentAmount,
      'rentDueDate': rentDueDate,
      'securityDepositAmount': securityDepositAmount,
      'leaseDocumentUrl': leaseDocumentUrl,
      'tenantId': tenantId,
      'propertyId': propertyId,
      'landlordId': landlordId,
      // leaseId is typically the document ID, not stored as a field
    };
  }

  static LeaseModel empty() {
    return LeaseModel(
      leaseId: 'skeleton_id',
      propertyAddress: 'Loading Property Address...',
      unitIdentifier: 'Unit ---',
      landlordName: 'Loading Landlord Name...',
      landlordContact: 'Loading contact...',
      leaseStartDate: Timestamp.now(),
      leaseEndDate: Timestamp.now(),
      rentAmount: 0.0,
      rentDueDate: '---',
      securityDepositAmount: 0.0,
      leaseDocumentUrl: null,
      tenantId: 'skeleton_tenant',
      propertyId: 'skeleton_property',
      landlordId: 'skeleton_landlord',
    );
  }

  static LeaseModel dummy() {
    return LeaseModel(
      leaseId: 'dummyLease001',
      propertyAddress: '123 Cloud Keja Towers, Apt 10B, Sky City',
      unitIdentifier: 'Unit 10B',
      landlordName: 'Mr. John Landlord',
      landlordContact: '0712345678 / john.landlord@email.com',
      leaseStartDate: Timestamp.fromDate(DateTime(2023, 1, 1)),
      leaseEndDate: Timestamp.fromDate(DateTime(2023, 12, 31)),
      rentAmount: 35000.00,
      rentDueDate: '1st of every month',
      securityDepositAmount: 70000.00,
      leaseDocumentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf', // Placeholder PDF URL
      tenantId: 'current_user_dummy_id', // This should be replaced by actual user ID during testing
      propertyId: 'prop123',
      landlordId: 'landlord001',
    );
  }
}
