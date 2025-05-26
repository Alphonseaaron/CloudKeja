// import 'dart:io';
class UserModel {
  String? userId;
  final String? name;
  final String? idnumber;
  final String? email;
  final String? password;
  final String? profile;
  List<dynamic>? rentedPlaces = [];
  List<dynamic>? wishlist = [];
  final String? phone;
  final bool? isLandlord;
  final String? bankBusinessNumber;
  final String? bankNumber;
  final bool? isAdmin;
  final double? balance;
  final String? role;
  final List<String>? certifications;
  final List<String>? servicesOffered;
  final List<String>? serviceAreas;
  final Map<String, dynamic>? availabilitySchedule;
  final bool? isVerified;

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
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'idnumber':idnumber,
        'email': email,
        'password': password,
        'profile': profile,
        'phone': phone,
        'isLandlord': isLandlord,
        'bankBusinessNumber': bankBusinessNumber,
        'bankNumber' : bankNumber,
        'isAdmin': isAdmin,
        'rentedPlaces': rentedPlaces,
        'wishlist': wishlist,
        'balance': 0,
        'role': role,
        'certifications': certifications,
        'servicesOffered': servicesOffered,
        'serviceAreas': serviceAreas,
        'availabilitySchedule': availabilitySchedule,
        'isVerified': isVerified ?? false,
      };

  factory UserModel.fromJson(dynamic json) {
    return UserModel(
      userId: json['userId'],
      name: json['name'],
      idnumber: json['idnumber'],
      email: json['email'],
      password: json['password'],
      profile: json['profile'],
      phone: json['phone'],
      isLandlord: json['isLandlord'],
      bankBusinessNumber: json['bankBusinessNumber'],
      bankNumber : json['bankNumber'],
      isAdmin: json['isAdmin'],
      rentedPlaces: json['rentedPlaces'],
      wishlist: json['wishlist'],
      balance: double.parse(json['balance'].toString()),
      role: json['role'],
      certifications: json['certifications'] != null ? List<String>.from(json['certifications']) : null,
      servicesOffered: json['servicesOffered'] != null ? List<String>.from(json['servicesOffered']) : null,
      serviceAreas: json['serviceAreas'] != null ? List<String>.from(json['serviceAreas']) : null,
      availabilitySchedule: json['availabilitySchedule'] != null ? Map<String, dynamic>.from(json['availabilitySchedule']) : null,
      isVerified: json['isVerified'] ?? false,
    );
  }
}
