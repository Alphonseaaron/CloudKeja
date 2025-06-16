import 'dart:io'; // Keep for File type if imageFiles is used for uploads
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart'; // Not directly used in model if location is GeoPoint

class SpaceModel {
  String? id;
  final String? spaceName;
  final String? address;
  final String? category; // e.g., "For Rent", "For Sale" - consider if this is same as propertyType or different
  final String? description;
  final double? price;
  final String? ownerId;
  final String? size; // e.g., "1200 sqft" - consider if area field is better as double
  final Map<String, dynamic>? features; // Can store misc features
  final int? rentTime; // e.g., 1 for per month, 7 per week - consider an enum or constants
  final int? likes;
  final GeoPoint? location; // For map coordinates
  List<dynamic>? images; // List of image URLs
  List<File>? imageFiles; // For uploading new images, transient

  // New fields for filtering
  final String? propertyType;    // e.g., "Apartment", "House", "Studio"
  final int? numBedrooms;       // e.g., 1, 2, 3, 0 for Studio
  final int? numBathrooms;      // e.g., 1, 2
  final List<String>? amenities; // e.g., ["Parking", "Pets Allowed"]
  final bool isAvailable;      // To filter out unavailable spaces, defaults to true
  final List<Map<String, dynamic>>? units;

  // For testing - can be removed from final model
  final bool? needsAttention;


  SpaceModel({
    this.id,
    this.spaceName,
    this.address,
    this.category,
    this.description,
    this.price,
    this.ownerId,
    this.size,
    this.features,
    this.rentTime,
    this.likes,
    this.location,
    this.images,
    this.imageFiles, // Only for client-side use during uploads
    // New fields in constructor
    this.propertyType,
    this.numBedrooms,
    this.numBathrooms,
    List<String>? amenities, // Initialize to empty list if null
    this.isAvailable = true, // Default to true for new spaces
    this.units,
    this.needsAttention, // For testing
  }) : amenities = amenities ?? const [],
       units = units ?? const [];

  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // ID is usually the document ID, not stored in fields
      'spaceName': spaceName,
      'address': address,
      'category': category,
      'description': description,
      'price': price,
      'ownerId': ownerId,
      'size': size,
      'features': features,
      'rentTime': rentTime,
      'likes': likes ?? 0, // Default likes to 0
      'location': location,
      'images': images,
      // New fields
      'propertyType': propertyType,
      'numBedrooms': numBedrooms,
      'numBathrooms': numBathrooms,
      'amenities': amenities,
      'isAvailable': isAvailable,
      'units': units?.map((u) => u).toList(),
      // 'searchKeywords': _generateSearchKeywords(), // Example for search field
    };
  }

  // Helper to generate search keywords (example, adapt as needed)
  // List<String> _generateSearchKeywords() {
  //   List<String> keywords = [];
  //   if (spaceName != null) keywords.addAll(spaceName!.toLowerCase().split(' '));
  //   if (address != null) keywords.addAll(address!.toLowerCase().split(' '));
  //   if (propertyType != null) keywords.add(propertyType!.toLowerCase());
  //   if (category != null) keywords.add(category!.toLowerCase());
  //   // Add more relevant fields to keywords
  //   return keywords.toSet().toList(); // Remove duplicates
  // }


  factory SpaceModel.fromJson(dynamic json) {
    // Handle both Map<String, dynamic> (from Firestore direct fetch) and DocumentSnapshot
    Map<String, dynamic> data;
    String? docId;

    if (json is DocumentSnapshot) {
      data = json.data() as Map<String, dynamic>;
      docId = json.id;
    } else if (json is Map<String, dynamic>) {
      data = json;
      docId = data['id'] as String?; // If ID is stored as a field (less common for root doc ID)
    } else {
      throw ArgumentError('Invalid JSON type for SpaceModel.fromJson');
    }

    return SpaceModel(
      id: docId, // Use document ID from snapshot
      spaceName: data['spaceName'] as String?,
      address: data['address'] as String?,
      category: data['category'] as String?,
      description: data['description'] as String?,
      price: (data['price'] as num?)?.toDouble(),
      ownerId: data['ownerId'] as String?,
      size: data['size'] as String?,
      features: data['features'] as Map<String, dynamic>?,
      rentTime: data['rentTime'] as int?,
      likes: data['likes'] as int? ?? 0,
      location: data['location'] as GeoPoint?,
      images: data['images'] != null ? List<dynamic>.from(data['images']) : [],
      // New fields
      propertyType: data['propertyType'] as String?,
      numBedrooms: data['numBedrooms'] as int?,
      numBathrooms: data['numBathrooms'] as int?,
      amenities: data['amenities'] != null ? List<String>.from(data['amenities']) : const [],
      isAvailable: data['isAvailable'] as bool? ?? true, // Default to true if missing
      units: data['units'] != null ? List<Map<String, dynamic>>.from(data['units']) : const [],
      needsAttention: data['needsAttention'] as bool?, // For testing
    );
  }

  SpaceModel copyWith({
    String? id,
    String? spaceName,
    String? address,
    String? category,
    String? description,
    double? price,
    String? ownerId,
    String? size,
    Map<String, dynamic>? features,
    int? rentTime,
    int? likes,
    GeoPoint? location,
    List<dynamic>? images,
    List<File>? imageFiles, // Not typically part of copyWith for Firestore data model state
    String? propertyType,
    int? numBedrooms,
    int? numBathrooms,
    List<String>? amenities,
    bool? isAvailable,
    List<Map<String, dynamic>>? units,
    bool? needsAttention,
  }) {
    return SpaceModel(
      id: id ?? this.id,
      spaceName: spaceName ?? this.spaceName,
      address: address ?? this.address,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      ownerId: ownerId ?? this.ownerId,
      size: size ?? this.size,
      features: features ?? this.features,
      rentTime: rentTime ?? this.rentTime,
      likes: likes ?? this.likes,
      location: location ?? this.location,
      images: images ?? this.images,
      imageFiles: imageFiles ?? this.imageFiles, // Keep if used for UI state before upload
      propertyType: propertyType ?? this.propertyType,
      numBedrooms: numBedrooms ?? this.numBedrooms,
      numBathrooms: numBathrooms ?? this.numBathrooms,
      amenities: amenities ?? this.amenities,
      isAvailable: isAvailable ?? this.isAvailable,
      units: units ?? this.units,
      needsAttention: needsAttention ?? this.needsAttention,
    );
  }

  // Static method for creating an empty model, useful for Skeletonizer or initial states
  static SpaceModel empty() {
    return SpaceModel(
      id: 'skeleton_id_${DateTime.now().millisecondsSinceEpoch}',
      spaceName: 'Loading Property Name...', // Placeholder text
      address: 'Loading address...',
      category: 'Category',
      description: 'Loading description of property features and details...',
      price: 0.0,
      ownerId: 'skeleton_owner',
      size: '--- sqft',
      features: {},
      rentTime: 1, // Default to per month
      likes: 0,
      location: const GeoPoint(0, 0), // Default location
      images: ['https://via.placeholder.com/300/F0F0F0/AAAAAA?text=Loading...'], // Placeholder image
      propertyType: 'Property Type',
      numBedrooms: 0,
      numBathrooms: 0,
      amenities: List.generate(3, (index) => 'Amenity ${index+1}        '), // Placeholder amenities
      isAvailable: true,
      units: const [],
      needsAttention: false,
    );
  }
}
