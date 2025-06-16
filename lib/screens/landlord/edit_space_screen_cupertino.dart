import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For LatLng, File, Image.file (visual parts)
import 'package:provider/provider.dart';
import 'package:get/route_manager.dart'; // For Get.to for AddOnMap if not using direct Navigator.push
import 'package:cloud_firestore/cloud_firestore.dart'; // For GeoPoint, Timestamp
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Aliased
import 'package:google_maps_flutter/google_maps_flutter.dart'; // For LatLng
import 'package:media_picker_widget/media_picker_widget.dart';

import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/screens/landlord/widgets/add_on_map.dart'; // Router for AddOnMap
import 'package:cloudkeja/screens/landlord/widgets/cupertino_property_type_picker.dart';
import 'package:cloudkeja/screens/landlord/widgets/cupertino_amenities_picker.dart';

// Assuming these are defined similarly or imported from app_config
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


class EditSpaceScreenCupertino extends StatefulWidget {
  final SpaceModel space;
  const EditSpaceScreenCupertino({Key? key, required this.space}) : super(key: key);

  @override
  State<EditSpaceScreenCupertino> createState() => _EditSpaceScreenCupertinoState();
}

class _EditSpaceScreenCupertinoState extends State<EditSpaceScreenCupertino> {
  final _formKey = GlobalKey<FormState>();

  LatLng? _propertyLocation;
  List<File> _newImageFiles = [];
  List<String> _existingImageUrls = [];
  List<String> _imagesToDelete = [];
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _addressController;
  late TextEditingController _bedsController;
  late TextEditingController _bathsController;
  late TextEditingController _areaController;

  String? _selectedCategory;
  String? _selectedRentRate;
  List<String> _selectedAmenities = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.space.spaceName);
    _descriptionController = TextEditingController(text: widget.space.description);
    _priceController = TextEditingController(text: widget.space.price?.toStringAsFixed(0) ?? '');
    _addressController = TextEditingController(text: widget.space.address);

    _selectedCategory = widget.space.category;
    _selectedRentRate = _getRentRateStringFromInt(widget.space.rentTime);
    _selectedAmenities = List<String>.from(widget.space.amenities ?? []);

    if (widget.space.location != null) {
      _propertyLocation = LatLng(widget.space.location!.latitude, widget.space.location!.longitude);
    }
    _existingImageUrls = List<String>.from(widget.space.images ?? []);

    _bedsController = TextEditingController(text: widget.space.features?['beds']?.toString() ?? '');
    _bathsController = TextEditingController(text: widget.space.features?['baths']?.toString() ?? '');
    _areaController = TextEditingController(text: widget.space.features?['area']?.toString() ?? widget.space.size ?? '');
  }

  String? _getRentRateStringFromInt(int? rentTimeValue) {
    if (rentTimeValue == 1) return 'Daily';
    if (rentTimeValue == 7) return 'Weekly';
    if (rentTimeValue == 30) return 'Monthly';
    if (rentTimeValue == 365) return 'Yearly';
    return null;
  }

  int _getRateIntFromString(String? rateString) {
    if (rateString == 'Daily') return 1;
    if (rateString == 'Weekly') return 7;
    if (rateString == 'Monthly') return 30;
    if (rateString == 'Yearly') return 365;
    return 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _bedsController.dispose();
    _bathsController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String title, String content) {
    if (!mounted) return;
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [CupertinoDialogAction(isDefaultAction: true, child: const Text('OK'), onPressed: () => Navigator.pop(ctx))],
      ),
    );
  }

  void _pickImages() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Select Image Source'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(child: const Text('Camera'), onPressed: () { Navigator.pop(context); _openMediaPicker(PickerType.camera); }),
          CupertinoActionSheetAction(child: const Text('Gallery'), onPressed: () { Navigator.pop(context); _openMediaPicker(PickerType.gallery); }),
        ],
        cancelButton: CupertinoActionSheetAction(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
      )
    );
  }

  void _openMediaPicker(PickerType type) {
    List<Media> tempMediaList = [];
    final cupertinoTheme = CupertinoTheme.of(context);
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext modalContext) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        color: cupertinoTheme.scaffoldBackgroundColor,
        child: MediaPicker(
          mediaList: tempMediaList,
          onPick: (selectedList) {
            setState(() => _newImageFiles.addAll(selectedList.where((m) => m.file != null).map((m) => m.file!)));
            Navigator.pop(modalContext);
          },
          onCancel: () => Navigator.pop(modalContext),
          mediaCount: MediaCount.multiple,
          mediaType: MediaType.image,
          pickerType: type,
          decoration: PickerDecoration(
            cancelIcon: Icon(CupertinoIcons.clear_circled_solid, color: cupertinoTheme.primaryColor),
            albumTitleStyle: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(color: cupertinoTheme.textTheme.textStyle.color, fontWeight: FontWeight.bold),
            actionBarPosition: ActionBarPosition.top,
            completeText: 'Done',
            completeTextStyle: cupertinoTheme.textTheme.navActionTextStyle.copyWith(color: cupertinoTheme.primaryColor, fontWeight: FontWeight.bold),
            selectionColor: cupertinoTheme.primaryColor,
            selectedCountBackgroundColor: cupertinoTheme.primaryColor,
            selectedCountTextColor: cupertinoTheme.barBackgroundColor,
            backgroundColor: cupertinoTheme.scaffoldBackgroundColor,
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreviews() {
    final List<Widget> imageWidgets = [];
    // Existing images
    for (int i = 0; i < _existingImageUrls.length; i++) {
      imageWidgets.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0, top: 8.0),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Image.network(_existingImageUrls[i], width: 80, height: 80, fit: BoxFit.cover),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.clear_circled_solid, color: CupertinoColors.destructiveRed, size: 22),
                onPressed: () => setState(() {
                  _imagesToDelete.add(_existingImageUrls.removeAt(i));
                }),
              )
            ],
          ),
        )
      );
    }
    // New images
    for (int i = 0; i < _newImageFiles.length; i++) {
       imageWidgets.add(
         Padding(
           padding: const EdgeInsets.only(right: 8.0, top: 8.0),
           child: Stack(
            alignment: Alignment.topRight,
            children: [
              Image.file(_newImageFiles[i], width: 80, height: 80, fit: BoxFit.cover),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.clear_circled_solid, color: CupertinoColors.destructiveRed, size: 22),
                onPressed: () => setState(() => _newImageFiles.removeAt(i)),
              )
            ],
                   ),
         )
       );
    }
    return SizedBox(height: 90, child: ListView(scrollDirection: Axis.horizontal, children: imageWidgets));
  }

  Future<void> _deleteSpace() async {
     bool confirmed = await showCupertinoDialog<bool>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Delete Space'),
          content: const Text('Are you sure you want to delete this space? This action cannot be undone.'),
          actions: [
            CupertinoDialogAction(child: const Text('Cancel'), onPressed: () => Navigator.of(ctx).pop(false)),
            CupertinoDialogAction(isDestructiveAction: true, child: const Text('Delete'), onPressed: () => Navigator.of(ctx).pop(true)),
          ],
        ),
      ) ?? false;

      if (confirmed && mounted) {
        setState(() => _isLoading = true);
        try {
          await Provider.of<PostProvider>(context, listen: false).deleteSpace(widget.space.id!);
          // Pop twice: once for edit screen, once for the screen before it (e.g., dashboard)
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        } catch (e) {
           if(mounted) _showErrorDialog('Delete Failed', e.toString());
        } finally {
           if(mounted) setState(() => _isLoading = false);
        }
      }
  }


  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_propertyLocation == null) { _showErrorDialog('Location Missing', 'Please set the property location.'); return; }
    if (_existingImageUrls.isEmpty && _newImageFiles.isEmpty) { _showErrorDialog('Images Missing', 'Please upload at least one image.'); return; }
    if (_selectedCategory == null) { _showErrorDialog('Category Missing', 'Please select a category.'); return; }
    if (_selectedRentRate == null) { _showErrorDialog('Rent Rate Missing', 'Please select a rent rate.'); return; }

    setState(() => _isLoading = true);

    try {
      final updatedSpace = SpaceModel(
        id: widget.space.id,
        spaceName: _nameController.text,
        description: _descriptionController.text,
        price: double.tryParse(_priceController.text),
        address: _addressController.text,
        location: GeoPoint(_propertyLocation!.latitude, _propertyLocation!.longitude),
        newImageFiles: _newImageFiles,
        existingImageUrls: _existingImageUrls,
        imagesToDelete: _imagesToDelete,
        ownerId: fb_auth.FirebaseAuth.instance.currentUser!.uid,
        category: _selectedCategory,
        size: _areaController.text,
        features: {
          'beds': _bedsController.text,
          'baths': _bathsController.text,
          'area': _areaController.text,
        },
        rentTime: _getRateIntFromString(_selectedRentRate),
        amenities: _selectedAmenities,
        likes: widget.space.likes,
        isVerified: widget.space.isVerified,
        isAvailable: widget.space.isAvailable,
        createdAt: widget.space.createdAt, // Preserve original creation time
        updatedAt: Timestamp.now(),
      );

      await Provider.of<PostProvider>(context, listen: false).editSpace(updatedSpace);
      if (mounted) Navigator.of(context).pop(true); // Pop and indicate success
    } catch (e) {
      if (mounted) _showErrorDialog('Save Failed', e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Edit Space'),
        leading: CupertinoButton(padding: EdgeInsets.zero, child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop(false)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isLoading ? null : _submitForm,
          child: _isLoading ? const CupertinoActivityIndicator() : Text('Save', style: TextStyle(color: cupertinoTheme.primaryColor, fontWeight: FontWeight.bold)),
        ),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 30),
          children: <Widget>[
            CupertinoFormSection.insetGrouped(
              header: const Text('Space Information'),
              children: <Widget>[
                CupertinoTextFormFieldRow(controller: _nameController, placeholder: 'e.g., Cozy Apartment', prefix: const Text('Name'), validator: (v) => v!.isEmpty ? 'Name is required' : null),
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
                    final result = await Navigator.of(context).push<String>(CupertinoPageRoute(builder: (ctx) => CupertinoPropertyTypePickerScreen(propertyTypes: _kPropertyTypes, currentType: _selectedCategory)));
                    if (result != null) setState(() => _selectedCategory = result);
                  },
                ),
                CupertinoListTile.notched(
                  title: const Text('Rent Rate'),
                  additionalInfo: Text(_selectedRentRate ?? 'Select Rate'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => showCupertinoModalPopup<void>(
                    context: context,
                    builder: (BuildContext context) => SizedBox(
                      height: 250,
                      child: CupertinoPicker(
                        backgroundColor: cupertinoTheme.scaffoldBackgroundColor,
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int index) => setState(() => _selectedRentRate = _kRentRates[index]),
                        children: _kRentRates.map((rate) => Center(child: Text(rate))).toList(),
                        scrollController: FixedExtentScrollController(initialItem: _selectedRentRate != null ? _kRentRates.indexOf(_selectedRentRate!) : 0),
                      ),
                    )
                  ),
                ),
                CupertinoTextFormFieldRow(controller: _bedsController, placeholder: 'e.g., 3', prefix: const Text('Bedrooms'), keyboardType: TextInputType.number),
                CupertinoTextFormFieldRow(controller: _bathsController, placeholder: 'e.g., 2', prefix: const Text('Bathrooms'), keyboardType: TextInputType.number),
                CupertinoTextFormFieldRow(controller: _areaController, placeholder: 'e.g., 120 sqm', prefix: const Text('Area (sqm/sqft)')),
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: const Text('Amenities'),
              children: <Widget>[
                CupertinoListTile.notched(
                  title: const Text('Select Amenities'),
                  additionalInfo: Text(_selectedAmenities.isEmpty ? 'None' : (_selectedAmenities.length > 2 ? "${_selectedAmenities.length} selected" :_selectedAmenities.join(', ')), style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis)),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () async {
                    final result = await Navigator.of(context).push<List<String>>(CupertinoPageRoute(builder: (ctx) => CupertinoAmenitiesPickerScreen(allAmenities: _kPropertyAmenities, initialSelectedAmenities: _selectedAmenities)));
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
                    final LatLng? result = await Navigator.of(context).push<LatLng>(
                      CupertinoPageRoute(builder: (ctx) => AddOnMap(
                        onChanged: (val) {}, // Handled by pop result
                        initialLocation: _propertyLocation,
                        isEditing: _propertyLocation != null,
                      )),
                    );
                    if (result != null) setState(() => _propertyLocation = result);
                  },
                ),
                CupertinoListTile.notched(
                  title: const Text('Manage Photos'),
                  additionalInfo: Text('${_existingImageUrls.length + _newImageFiles.length} image(s)'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: _pickImages,
                ),
                if (_existingImageUrls.isNotEmpty || _newImageFiles.isNotEmpty) _buildImagePreviews(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: CupertinoButton(
                color: CupertinoColors.destructiveRed,
                onPressed: _isLoading ? null : _deleteSpace,
                child: const Text('Delete Space'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
