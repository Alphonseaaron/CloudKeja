// ignore_for_file: recursive_getters, unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloudkeja/models/user_model.dart';

final usersRef = FirebaseFirestore.instance.collection('users');

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  UserModel? get user => _user;

  Future<void> logIn(String email, String password) async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    await getCurrentUser();

    notifyListeners();
  }

  Future<void> signUp(UserModel userModel) async {
    final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: userModel.email!.trim(), password: userModel.password!.trim());

    // userModel.userId = result.user!.uid; // userId is already set in the constructor or copyWith
    final id = result.user!.uid;

    // Create a new UserModel with the additional fields set
    UserModel newUser = userModel.copyWith(
      userId: id, // Ensure userId is correctly set from auth result
      subscriptionTier: "Starter Plan",
      propertyCount: 0,
      adminUserCount: 1, // Landlord themselves
      subscriptionExpiryDate: null, // Explicitly null, can be Timestamp.now() or other logic if needed
    );

    await usersRef.doc(id).set(newUser.toJson());

    getCurrentUser(); // This will fetch the newly created user data
  }

  Future<UserModel> getCurrentUser() async {
    final value = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    _user = UserModel.fromJson(value);

    notifyListeners();
    return _user!;
  }

  Future<UserModel> getOwnerDetails(String uid) async {
    final value =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    notifyListeners();
    return UserModel.fromJson(value);
  }

  Future<void> updateProfile(UserModel user) async {
    await usersRef.doc(user.userId).update(user.toJson());
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      // Handle specific errors or rethrow a generic one
      // For example, you could throw e.message or a custom error string
      throw Exception('Error sending password reset email: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }
}
