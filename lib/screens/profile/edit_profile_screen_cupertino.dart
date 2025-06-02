import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For CachedNetworkImageProvider, CircleAvatar, SnackBar (replace SnackBar)
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Aliased to avoid conflict with Provider's User
import 'package:media_picker_widget/media_picker_widget.dart';


import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';

class EditProfileScreenCupertino extends StatefulWidget {
  final UserModel user; // User model passed to the screen

  const EditProfileScreenCupertino({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfileScreenCupertino> createState() => _EditProfileScreenCupertinoState();
}

class _EditProfileScreenCupertinoState extends State<EditProfileScreenCupertino> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  
  List<Media> _mediaList = [];
  File? _newProfileImageFile;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>(); // Can be used with CupertinoTextFormFieldRow's validator

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email); // Assuming email might be editable, or just display
    _phoneController = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    String? newProfileUrl = widget.user.profile;

    try {
      if (_newProfileImageFile != null) {
        final imageRef = FirebaseStorage.instance
            .ref('userData/profile/${widget.user.userId ?? fb_auth.FirebaseAuth.instance.currentUser!.uid}');
        final uploadTask = imageRef.putFile(_newProfileImageFile!);
        final snapshot = await uploadTask.whenComplete(() {});
        newProfileUrl = await snapshot.ref.getDownloadURL();
      }

      final updatedUser = UserModel(
        userId: widget.user.userId ?? fb_auth.FirebaseAuth.instance.currentUser!.uid,
        name: _nameController.text,
        email: _emailController.text, // If email is editable
        phone: _phoneController.text,
        profile: newProfileUrl,
        // Copy other fields that are not edited on this screen
        role: widget.user.role,
        isAdmin: widget.user.isAdmin,
        isLandlord: widget.user.isLandlord,
        isVerified: widget.user.isVerified,
        idNumber: widget.user.idNumber,
        // etc.
      );
      
      await Provider.of<AuthProvider>(context, listen: false).updateProfile(updatedUser, newProfileImageFile: _newProfileImageFile);

      if (mounted) {
        _showFeedbackDialog('Success', 'Profile updated successfully.', isError: false, popOnOk: true);
      }
    } catch (e) {
      if (mounted) {
        _showFeedbackDialog('Error', 'Failed to update profile: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  void _showFeedbackDialog(String title, String content, {bool isError = false, bool popOnOk = false}) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(ctx); // Dismiss dialog
              if (popOnOk && !isError) { // If success and popOnOk is true, pop the edit screen
                 Navigator.of(context).pop();
              }
            },
          )
        ],
      ),
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Change Profile Photo'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: const Text('Take Photo'),
            onPressed: () {
              Navigator.pop(context);
              _openImagePicker(context, PickerType.camera);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Choose from Library'),
            onPressed: () {
              Navigator.pop(context);
              _openImagePicker(context, PickerType.gallery);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
  
  void _openImagePicker(BuildContext context, PickerType pickerType) {
    // MediaPicker is Material styled, this is a known compromise for this step
    // Ideally, a Cupertino-native image picker or an adaptive plugin would be used.
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoTheme( // Try to theme the media picker if it respects it
          data: CupertinoTheme.of(context),
          child: MediaPicker(
            mediaList: _mediaList,
            onPick: (selectedList) {
              setState(() {
                _mediaList = selectedList;
                if (_mediaList.isNotEmpty && _mediaList.first.file != null) {
                  _newProfileImageFile = _mediaList.first.file;
                }
              });
              Navigator.pop(context); // Pop MediaPicker
            },
            onCancel: () => Navigator.pop(context),
            mediaCount: MediaCount.single,
            mediaType: MediaType.image,
            decoration: PickerDecoration( // These decorations are Material-based
              completeText: 'Select',
              actionBarPosition: ActionBarPosition.top,
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Edit Profile'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isLoading ? null : _saveProfile,
          child: _isLoading 
              ? const CupertinoActivityIndicator() 
              : Text('Save', style: TextStyle(color: cupertinoTheme.primaryColor, fontWeight: FontWeight.bold)),
        ),
      ),
      child: Form( // Using Form for validation
        key: _formKey,
        child: ListView( // Using ListView for scrollability with many fields
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          children: <Widget>[
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: CupertinoColors.systemGrey5.resolveFrom(context),
                    backgroundImage: _newProfileImageFile != null
                        ? FileImage(_newProfileImageFile!) as ImageProvider
                        : (widget.user.profile != null && widget.user.profile!.isNotEmpty)
                            ? CachedNetworkImageProvider(widget.user.profile!)
                            : null,
                    child: (_newProfileImageFile == null && (widget.user.profile == null || widget.user.profile!.isEmpty))
                        ? Icon(CupertinoIcons.person_fill, size: 50, color: CupertinoColors.systemGrey.resolveFrom(context))
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _showImageSourceActionSheet(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey4.resolveFrom(context),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(CupertinoIcons.pencil_circle_fill, size: 22, color: cupertinoTheme.primaryColor),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            CupertinoFormSection.insetGrouped(
              header: Text('User Information', style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context))),
              children: <Widget>[
                CupertinoTextFormFieldRow(
                  prefix: const Text('Name'),
                  controller: _nameController,
                  placeholder: 'Enter full name',
                  validator: (value) => value == null || value.isEmpty ? 'Name cannot be empty' : null,
                ),
                CupertinoTextFormFieldRow(
                  prefix: const Text('Email'),
                  controller: _emailController,
                  placeholder: 'Enter email address',
                  keyboardType: TextInputType.emailAddress,
                   // Assuming email might not be editable or has specific validation
                  readOnly: true, // Example: Making email read-only
                  style: TextStyle(color: CupertinoColors.inactiveGray.resolveFrom(context)),
                ),
                CupertinoTextFormFieldRow(
                  prefix: const Text('Phone'),
                  controller: _phoneController,
                  placeholder: 'Enter phone number',
                  keyboardType: TextInputType.phone,
                  validator: (value) => value == null || value.isEmpty ? 'Phone cannot be empty' : null,
                ),
                // Add other fields as needed, e.g., ID, DOB, Postal using similar rows
              ],
            ),
          ],
        ),
      ),
    );
  }
}
