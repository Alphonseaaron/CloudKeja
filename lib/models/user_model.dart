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
    );
  }
}
