import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For File, Image.file, potentially MediaPicker and AddOnMap if not fully adapted
import 'package:provider/provider.dart';
import 'package:get/route_manager.dart'; // For Get.to
import 'package:cloud_firestore/cloud_firestore.dart'; // For GeoPoint
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Aliased
import 'package:google_maps_flutter/google_maps_flutter.dart'; // For LatLng from AddOnMap
import 'package:media_picker_widget/media_picker_widget.dart'; // Material-based picker

import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/models/user_model.dart'; // Added
import 'package:cloudkeja/providers/auth_provider.dart'; // Added
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/providers/subscription_provider.dart'; // Added
import 'package:cloudkeja/screens/subscription/subscription_plans_screen.dart'; // Added
import 'package:cloudkeja/screens/landlord/widgets/add_on_map.dart'; // Material-based map screen
import 'package:cloudkeja/screens/landlord/widgets/cupertino_property_type_picker.dart';
import 'package:cloudkeja/screens/landlord/widgets/cupertino_amenities_picker.dart';
// TODO: Define kPropertyTypes, kPropertyAmenities, kRentRates if not globally available from app_config.dart
// For now, using placeholder lists.
// TODO: Consider moving property type options to a centralized config (e.g., app_config.dart)
const List<String> _kPropertyTypes = [
  'For Rent', // Added
  'For Sale', // Added
  'Apartment',
  'House',
  'Condo',
  'Townhouse',
  'Office',
  'Shop',
  'Warehouse',
  'Other'
];
const List<String> _kPropertyAmenities = ['WiFi', 'Parking', 'Balcony', 'Security', 'Pool', 'Gym', 'Furnished', 'Pet Friendly'];
const List<String> _kRentRates = ['Daily', 'Weekly', 'Monthly', 'Yearly'];


class AddSpaceScreenCupertino extends StatefulWidget {
  const AddSpaceScreenCupertino({Key? key}) : super(key: key);

  @override
  State<AddSpaceScreenCupertino> createState() => _AddSpaceScreenCupertinoState();
}

class _AddSpaceScreenCupertinoState extends State<AddSpaceScreenCupertino> {
  final _formKey = GlobalKey<FormState>(); // Using FormState for validation with CupertinoTextFormFieldRow

  LatLng? _propertyLocation;
  List<File> _imageFiles = []; // For multiple images
  bool _isLoading = false;

  // Form field controllers and state variables
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  final _bedsController = TextEditingController();
  final _bathsController = TextEditingController();
  final _areaController = TextEditingController();
  // final _floorsController = TextEditingController(); // Not in original Material form directly

  String? _selectedCategory; // e.g., Apartment, House
  String? _selectedRentRate; // e.g., Monthly, Daily
  List<String> _selectedAmenities = [];


  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _bedsController.dispose();
    _bathsController.dispose();
    _areaController.dispose();
    // _floorsController.dispose();
    super.dispose();
  }
  
  int _getRateFromSelection(String? rateSelection) {
    if (rateSelection == 'Daily') return 1;
    if (rateSelection == 'Weekly') return 7;
    if (rateSelection == 'Monthly') return 30;
    if (rateSelection == 'Yearly') return 365;
    return 0; // Default or error
  }

  Future<void> _submitForm() async {
    // --- Subscription Check ---
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final UserModel? currentUser = authProvider.user; // Assuming this holds the current user
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);

    if (currentUser == null) {
      _showErrorDialog('Error', 'User not found. Please re-login.');
      return;
    }

    if (!subscriptionProvider.canAddProperty(currentUser)) {
      _showCupertinoUpgradeDialog(context);
      return; // Prevent form submission
    }
    // --- End Subscription Check ---

    if (!_formKey.currentState!.validate()) {
      // Validation messages will be shown by CupertinoTextFormFieldRow
      return;
    }
    if (_propertyLocation == null) {
      _showErrorDialog('Location Missing', 'Please set the property location on the map.');
      return;
    }
    if (_imageFiles.isEmpty) {
      _showErrorDialog('Images Missing', 'Please upload at least one image for the property.');
      return;
    }
    if (_selectedCategory == null) {
      _showErrorDialog('Category Missing', 'Please select a property category.');
      return;
    }
    if (_selectedRentRate == null) {
      _showErrorDialog('Rent Rate Missing', 'Please select a rent rate.');
      return;
    }


    setState(() => _isLoading = true);

    try {
      final space = SpaceModel(
        spaceName: _nameController.text,
        description: _descriptionController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        address: _addressController.text,
        location: GeoPoint(_propertyLocation!.latitude, _propertyLocation!.longitude),
        imageFiles: _imageFiles, // Pass File list
        ownerId: fb_auth.FirebaseAuth.instance.currentUser!.uid,
        category: _selectedCategory,
        likes: 0,
        size: _areaController.text, // Assuming area is a string like "1200 sqft"
        features: { // Ensure these keys match your SpaceModel and backend expectations
          'beds': _bedsController.text,
          'baths': _bathsController.text,
          // 'floors': _floorsController.text,
          'area': _areaController.text, // Often duplicated or could be just here
        },
        amenities: _selectedAmenities,
        rentTime: _getRateFromSelection(_selectedRentRate), // Convert string to int
      );

      await Provider.of<PostProvider>(context, listen: false).addSpace(space);
      if (mounted) {
        Navigator.of(context).pop(); // Pop after successful submission
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Submission Failed', e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String title, String content) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [CupertinoDialogAction(isDefaultAction: true, child: const Text('OK'), onPressed: () => Navigator.pop(ctx))],
      ),
    );
  }

  void _showCupertinoUpgradeDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext ctx) {
        return CupertinoAlertDialog(
          title: const Text('Property Limit Reached'),
          content: const Text(
              'You have reached the maximum number of properties for your current subscription plan. Please upgrade to add more.'),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Upgrade Plan'),
              onPressed: () {
                Navigator.of(ctx).pop(); // Close the dialog
                // Use pushNamed for consistency if routes are set up, otherwise direct push
                Navigator.of(context).push(CupertinoPageRoute(
                    builder: (_) => const SubscriptionPlansScreen()));
              },
            ),
          ],
        );
      },
    );
  }
  
  void _pickImages() {
    // MediaPicker is Material styled, this is a known compromise.
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('Select Image Source'),
          actions: <CupertinoActionSheetAction>[
            CupertinoActionSheetAction(
              child: const Text('Camera'),
              onPressed: () { Navigator.pop(context); _openMediaPicker(PickerType.camera); },
            ),
            CupertinoActionSheetAction(
              child: const Text('Gallery'),
              onPressed: () { Navigator.pop(context); _openMediaPicker(PickerType.gallery); },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
        );
      }
    );
  }

  void _openMediaPicker(PickerType type) {
    List<Media> tempMediaList = []; // For MediaPicker
    final cupertinoTheme = CupertinoTheme.of(context); // Get theme for PickerDecoration

    showCupertinoModalPopup( // Using CupertinoModalPopup to host MediaPicker
      context: context,
      builder: (BuildContext modalContext) => Container( // Wrap MediaPicker in a themed Container
        height: MediaQuery.of(context).size.height * 0.7, // Example height
        color: cupertinoTheme.scaffoldBackgroundColor, // Background for the sheet
        child: MediaPicker(
          mediaList: tempMediaList,
          onPick: (selectedList) {
            setState(() {
              _imageFiles.addAll(selectedList.where((m) => m.file != null).map((m) => m.file!));
            });
            Navigator.pop(modalContext); // Use modalContext to pop the picker's modal
          },
          onCancel: () => Navigator.pop(modalContext), // Use modalContext
          mediaCount: MediaCount.multiple, // Allow multiple images
          mediaType: MediaType.image,
          pickerType: type, // Pass camera or gallery
          decoration: PickerDecoration( // Cupertino themed decoration
            cancelIcon: Icon(CupertinoIcons.clear_circled_solid, color: cupertinoTheme.primaryColor),
            albumTitleStyle: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(
              color: cupertinoTheme.textTheme.textStyle.color, // Use default text color from theme
              fontWeight: FontWeight.bold
            ),
            actionBarPosition: ActionBarPosition.top,
            blurStrength: 0, // No blur for solid background
            completeText: 'Done',
            completeTextStyle: cupertinoTheme.textTheme.navActionTextStyle.copyWith(
                color: cupertinoTheme.primaryColor, fontWeight: FontWeight.bold),
            selectionColor: cupertinoTheme.primaryColor,
            selectedCountBackgroundColor: cupertinoTheme.primaryColor,
            selectedCountTextColor: cupertinoTheme.barBackgroundColor, // Text color on primary for count
            backgroundColor: cupertinoTheme.scaffoldBackgroundColor, // Picker's own background area
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_imageFiles.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _imageFiles.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0, top: 8.0),
            child: Stack(
              children: [
                Image.file(File(_imageFiles[index].path), width: 80, height: 80, fit: BoxFit.cover),
                Positioned(
                  top: -5, right: -5,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(CupertinoIcons.clear_circled_solid, color: CupertinoColors.destructiveRed, size: 20),
                    onPressed: () => setState(() => _imageFiles.removeAt(index)),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Add New Space'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isLoading ? null : _submitForm,
          child: _isLoading 
              ? const CupertinoActivityIndicator() 
              : Text('Save', style: TextStyle(color: cupertinoTheme.primaryColor, fontWeight: FontWeight.bold)),
        ),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 30), // Padding for bottom content
          children: <Widget>[
            CupertinoFormSection.insetGrouped(
              header: const Text('Space Information'),
              children: <Widget>[
                CupertinoTextFormFieldRow(controller: _nameController, placeholder: 'e.g., Cozy Downtown Apartment', prefix: const Text('Name'), validator: (v) => v!.isEmpty ? 'Name is required' : null),
                CupertinoTextFormFieldRow(controller: _descriptionController, placeholder: 'Describe your space', prefix: const Text('Description'), maxLines: 3, validator: (v) => v!.isEmpty ? 'Description is required' : null),
                CupertinoTextFormFieldRow(controller: _priceController, placeholder: 'e.g., 25000', prefix: const Text('Price (KES)'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Price is required' : null),
                CupertinoTextFormFieldRow(controller: _addressController, placeholder: 'e.g., 123 Main St, City', prefix: const Text('Address'), validator: (v) => v!.isEmpty ? 'Address is required' : null),
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: const Text('Property Details'),
              children: <Widget>[
                CupertinoListTile.notched(
                  title: const Text('Category'),
                  additionalInfo: Text(_selectedCategory ?? 'Select Type'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () async {
                    final result = await Navigator.of(context).push<String>(
                      CupertinoPageRoute(builder: (ctx) => CupertinoPropertyTypePickerScreen(propertyTypes: _kPropertyTypes, currentType: _selectedCategory)),
                    );
                    if (result != null) setState(() => _selectedCategory = result);
                  },
                ),
                CupertinoListTile.notched(
                  title: const Text('Rent Rate'),
                  additionalInfo: Text(_selectedRentRate ?? 'Select Rate'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () async {
                     // Simple picker for rent rate
                    showCupertinoModalPopup<void>(
                        context: context,
                        builder: (BuildContext context) => SizedBox(
                              height: 250,
                              child: CupertinoPicker(
                                itemExtent: 32.0,
                                onSelectedItemChanged: (int index) => setState(() => _selectedRentRate = _kRentRates[index]),
                                children: _kRentRates.map((rate) => Center(child: Text(rate))).toList(),
                                scrollController: FixedExtentScrollController(initialItem: _selectedRentRate != null ? _kRentRates.indexOf(_selectedRentRate!) : 0),
                              ),
                            ));
                  },
                ),
                CupertinoTextFormFieldRow(controller: _bedsController, placeholder: 'e.g., 3', prefix: const Text('Bedrooms'), keyboardType: TextInputType.number),
                CupertinoTextFormFieldRow(controller: _bathsController, placeholder: 'e.g., 2', prefix: const Text('Bathrooms'), keyboardType: TextInputType.number),
                CupertinoTextFormFieldRow(controller: _areaController, placeholder: 'e.g., 120 sqm', prefix: const Text('Area (sqm/sqft)'), keyboardType: TextInputType.text),
              ],
            ),
             CupertinoFormSection.insetGrouped(
              header: const Text('Amenities'),
              children: <Widget>[
                CupertinoListTile.notched(
                  title: const Text('Select Amenities'),
                  additionalInfo: Text(_selectedAmenities.isEmpty ? 'None' : _selectedAmenities.join(', '), style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis)),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () async {
                    final result = await Navigator.of(context).push<List<String>>(
                      CupertinoPageRoute(builder: (ctx) => CupertinoAmenitiesPickerScreen(allAmenities: _kPropertyAmenities, initialSelectedAmenities: _selectedAmenities)),
                    );
                    if (result != null) setState(() => _selectedAmenities = result);
                  },
                ),
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: const Text('Location & Photos'),
              children: <Widget>[
                CupertinoListTile.notched(
                  title: const Text('Set on Map'),
                  additionalInfo: Text(_propertyLocation == null ? 'Not Set' : 'Location Set ✓'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () async {
                    // final LatLng? result = await Navigator.of(context).push<LatLng>(
                    //   MaterialPageRoute(builder: (ctx) => AddOnMap(onChanged: (val){}, initialLocation: _propertyLocation, isEditing: _propertyLocation != null)), // AddOnMap is Material
                    // );
                    // The above MaterialPageRoute is replaced by CupertinoPageRoute
                    final selectedLocation = await Navigator.of(context).push<LatLng>(
                      CupertinoPageRoute(builder: (ctx) => AddOnMap(
                        onChanged: (val) {
                          // This callback in AddOnMap is used if it pops itself after selection.
                          // However, AddOnMap (both versions) now pops itself after calling onChanged.
                          // The value from pop is what we use.
                        },
                        initialLocation: _propertyLocation,
                        isEditing: _propertyLocation != null,
                      )),
                    );
                    if (selectedLocation != null) {
                      setState(() => _propertyLocation = selectedLocation);
                    }
                  },
                ),
                CupertinoListTile.notched(
                  title: const Text('Upload Photos'),
                  additionalInfo: Text('${_imageFiles.length} image(s) selected'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: _pickImages,
                ),
                if (_imageFiles.isNotEmpty) _buildImagePreview(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
