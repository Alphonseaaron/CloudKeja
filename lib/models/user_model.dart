import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp, if any date fields were added (not in this task)

class UserModel {
  String? userId;
  final String? name;
  final String? idnumber;
  final String? email;
  final String? password; // Note: Storing passwords directly in a model like this is generally not secure for client-side models.
  final String? profile;
  List<dynamic>? rentedPlaces; // Consider changing to List<String> if they are IDs
  List<dynamic>? wishlist;     // Consider changing to List<String> if they are IDs
  final String? phone;
  final bool? isLandlord;
  final String? bankBusinessNumber;
  final String? bankNumber;
  final bool? isAdmin;
  final double? balance;
  final String? role;
  final List<String>? certifications;
  final List<String>? servicesOffered; // For SP: detailed text descriptions
  final List<String>? serviceAreas;    // For SP: detailed text descriptions of areas
  final Map<String, dynamic>? availabilitySchedule;
  bool? isVerified; // Changed to non-final to allow update from Admin

  // New fields for Service Provider categorization and location
  final List<String>? serviceProviderTypes; // Predefined categories
  final String? spCountry;
  final String? spCounty;
  final String? spSubCounty; // Or spCity, spTown, etc.

  // New fields for subscription and usage
  final String? subscriptionTier;
  final Timestamp? subscriptionExpiryDate;
  final int? propertyCount;
  final int? adminUserCount;

  UserModel({
    this.userId,
    this.name,
    this.idnumber,
    this.email,
    this.password,
    this.profile,
    this.phone,
    this.isLandlord,
    this.bankBusinessNumber,
    this.bankNumber,
    this.isAdmin,
    this.rentedPlaces,
    this.wishlist,
    this.balance,
    this.role,
    this.certifications,
    this.servicesOffered,
    this.serviceAreas,
    this.availabilitySchedule,
    this.isVerified = false,
    List<String>? serviceProviderTypes, // New constructor parameter
    this.spCountry,                     // New constructor parameter
    this.spCounty,                      // New constructor parameter
    this.spSubCounty,                   // New constructor parameter
    // New constructor parameters for subscription and usage
    String? subscriptionTier,
    this.subscriptionExpiryDate,
    int? propertyCount,
    int? adminUserCount,
  }) : serviceProviderTypes = serviceProviderTypes ?? const [],
       subscriptionTier = subscriptionTier ?? "Starter Plan", // Default value
       propertyCount = propertyCount ?? 0, // Default value
       adminUserCount = adminUserCount ?? 0; // Default value


  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'idnumber':idnumber,
        'email': email,
        // 'password': password, // Password should typically not be converted to JSON from client model
        'profile': profile,
        'phone': phone,
        'isLandlord': isLandlord,
        'bankBusinessNumber': bankBusinessNumber,
        'bankNumber' : bankNumber,
        'isAdmin': isAdmin,
        'rentedPlaces': rentedPlaces,
        'wishlist': wishlist,
        'balance': balance ?? 0.0, // Provide default for balance
        'role': role,
        'certifications': certifications,
        'servicesOffered': servicesOffered,
        'serviceAreas': serviceAreas,
        'availabilitySchedule': availabilitySchedule,
        'isVerified': isVerified ?? false,
        // New fields for JSON
        'serviceProviderTypes': serviceProviderTypes,
        'spCountry': spCountry,
        'spCounty': spCounty,
        'spSubCounty': spSubCounty,
        // New fields for JSON
        'subscriptionTier': subscriptionTier,
        'subscriptionExpiryDate': subscriptionExpiryDate,
        'propertyCount': propertyCount,
        'adminUserCount': adminUserCount,
      };

  factory UserModel.fromJson(dynamic json) {
    // Ensure json is Map<String, dynamic> for type safety
    Map<String, dynamic> data = {};
    if (json is Map<String, dynamic>) {
      data = json;
    } else if (json is QueryDocumentSnapshot) { // Compatibility with Firestore docs
        data = json.data() as Map<String, dynamic>;
        // If userId is not stored as a field but is the doc ID
        if (data['userId'] == null) data['userId'] = json.id;
    } else if (json is DocumentSnapshot) {
        data = json.data() as Map<String, dynamic>;
        if (data['userId'] == null) data['userId'] = json.id;
    }


    return UserModel(
      userId: data['userId'] as String?,
      name: data['name'] as String?,
      idnumber: data['idnumber'] as String?,
      email: data['email'] as String?,
      password: data['password'] as String?, // Be cautious with password handling
      profile: data['profile'] as String?,
      phone: data['phone'] as String?,
      isLandlord: data['isLandlord'] as bool?,
      bankBusinessNumber: data['bankBusinessNumber'] as String?,
      bankNumber: data['bankNumber'] as String?,
      isAdmin: data['isAdmin'] as bool?,
      // Handle lists more safely
      rentedPlaces: data['rentedPlaces'] != null ? List<dynamic>.from(data['rentedPlaces']) : [],
      wishlist: data['wishlist'] != null ? List<dynamic>.from(data['wishlist']) : [],
      balance: data['balance'] != null ? double.tryParse(data['balance'].toString()) ?? 0.0 : 0.0,
      role: data['role'] as String?,
      certifications: data['certifications'] != null ? List<String>.from(data['certifications']) : null,
      servicesOffered: data['servicesOffered'] != null ? List<String>.from(data['servicesOffered']) : null,
      serviceAreas: data['serviceAreas'] != null ? List<String>.from(data['serviceAreas']) : null,
      availabilitySchedule: data['availabilitySchedule'] != null ? Map<String, dynamic>.from(data['availabilitySchedule']) : null,
      isVerified: data['isVerified'] as bool? ?? false,
      // New fields from JSON
      serviceProviderTypes: data['serviceProviderTypes'] != null ? List<String>.from(data['serviceProviderTypes']) : const [],
      spCountry: data['spCountry'] as String?,
      spCounty: data['spCounty'] as String?,
      spSubCounty: data['spSubCounty'] as String?,
      // New fields from JSON
      subscriptionTier: data['subscriptionTier'] as String? ?? "Starter Plan", // Default value
      subscriptionExpiryDate: data['subscriptionExpiryDate'] as Timestamp?,
      propertyCount: data['propertyCount'] as int? ?? 0, // Default value
      adminUserCount: data['adminUserCount'] as int? ?? 0, // Default value
    );
  }

  // copyWith method for immutability and easy updates
  UserModel copyWith({
    String? userId,
    String? name,
    String? idnumber,
    String? email,
    String? password,
    String? profile,
    List<dynamic>? rentedPlaces,
    List<dynamic>? wishlist,
    String? phone,
    bool? isLandlord,
    String? bankBusinessNumber,
    String? bankNumber,
    bool? isAdmin,
    double? balance,
    String? role,
    List<String>? certifications,
    List<String>? servicesOffered,
    List<String>? serviceAreas,
    Map<String, dynamic>? availabilitySchedule,
    bool? isVerified,
    List<String>? serviceProviderTypes,
    String? spCountry,
    String? spCounty,
    String? spSubCounty,
    // New fields for copyWith
    String? subscriptionTier,
    Timestamp? subscriptionExpiryDate,
    int? propertyCount,
    int? adminUserCount,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      idnumber: idnumber ?? this.idnumber,
      email: email ?? this.email,
      password: password ?? this.password,
      profile: profile ?? this.profile,
      rentedPlaces: rentedPlaces ?? this.rentedPlaces,
      wishlist: wishlist ?? this.wishlist,
      phone: phone ?? this.phone,
      isLandlord: isLandlord ?? this.isLandlord,
      bankBusinessNumber: bankBusinessNumber ?? this.bankBusinessNumber,
      bankNumber: bankNumber ?? this.bankNumber,
      isAdmin: isAdmin ?? this.isAdmin,
      balance: balance ?? this.balance,
      role: role ?? this.role,
      certifications: certifications ?? this.certifications,
      servicesOffered: servicesOffered ?? this.servicesOffered,
      serviceAreas: serviceAreas ?? this.serviceAreas,
      availabilitySchedule: availabilitySchedule ?? this.availabilitySchedule,
      isVerified: isVerified ?? this.isVerified,
      serviceProviderTypes: serviceProviderTypes ?? this.serviceProviderTypes,
      spCountry: spCountry ?? this.spCountry,
      spCounty: spCounty ?? this.spCounty,
      spSubCounty: spSubCounty ?? this.spSubCounty,
      // New fields for copyWith
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionExpiryDate: subscriptionExpiryDate ?? this.subscriptionExpiryDate,
      propertyCount: propertyCount ?? this.propertyCount,
      adminUserCount: adminUserCount ?? this.adminUserCount,
    );
  }
}
