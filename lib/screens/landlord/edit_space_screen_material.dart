import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:media_picker_widget/media_picker_widget.dart';
import 'package:provider/provider.dart';
// import 'package:cloudkeja/helpers/constants.dart'; // kPrimaryColor replaced by theme
import 'package:cloudkeja/helpers/my_dropdown.dart'; // Adaptive dropdown
import 'package:cloudkeja/helpers/my_loader.dart';   // Adaptive loader
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/screens/landlord/widgets/add_on_map.dart'; // Router for AddOnMap

class EditSpaceScreenMaterial extends StatefulWidget {
  const EditSpaceScreenMaterial({Key? key, required this.space}) : super(key: key);
  final SpaceModel space;

  @override
  _EditSpaceScreenMaterialState createState() => _EditSpaceScreenMaterialState();
}

class _EditSpaceScreenMaterialState extends State<EditSpaceScreenMaterial> {
  LatLng? propertyLocation;
  // File? coverImage; // coverImage seems unused in the original logic, focusing on imageFiles
  List<File> newImageFiles = []; // For newly added images
  List<String> existingImageUrls = []; // For existing network images
  List<String> imagesToDelete = []; // URLs of existing images marked for deletion

  bool isLoading = false;
  final formKey = GlobalKey<FormState>();

  // Form field controllers, initialized in initState
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _priceController;
  late TextEditingController _bedsController;
  late TextEditingController _bathsController;
  late TextEditingController _areaController;
  // late TextEditingController _floorsController; // Not in original form

  String? category;
  String? rentRate; // String representation e.g. "Monthly"
  // int? rentTime; // Integer representation for calculation, derived from rentRate

  List<String> options = [
    'Apartment', 'Airbnb', 'Conference Room', 'Event Grounds', 'House',
    'Hostel', 'Hotel', 'Office', 'Stall', 'Store shelf', 'Warehouse', 'Utility',
  ];
  List<String> rates = ['Daily', 'Weekly', 'Monthly', 'Yearly'];

  @override
  void initState() {
    super.initState();
    // Initialize controllers and state variables with widget.space data
    _nameController = TextEditingController(text: widget.space.spaceName);
    _descriptionController = TextEditingController(text: widget.space.description);
    _addressController = TextEditingController(text: widget.space.address);
    _priceController = TextEditingController(text: widget.space.price?.toStringAsFixed(0) ?? '');

    category = widget.space.category;
    // Convert rentTime (int) back to string for dropdown
    rentRate = _getRentRateString(widget.space.rentTime);

    if (widget.space.location != null) {
      propertyLocation = LatLng(widget.space.location!.latitude, widget.space.location!.longitude);
    }
    if (widget.space.images != null) {
      existingImageUrls = List<String>.from(widget.space.images!);
    }

    // Initialize features - handle potential null map and null values
    _bedsController = TextEditingController(text: widget.space.features?['beds'] ?? '');
    _bathsController = TextEditingController(text: widget.space.features?['baths'] ?? '');
    _areaController = TextEditingController(text: widget.space.features?['area'] ?? widget.space.size ?? '');
    // _floorsController = TextEditingController(text: widget.space.features?['floors'] ?? '');
  }

  String? _getRentRateString(int? rentTimeValue) {
    if (rentTimeValue == 1) return 'Daily';
    if (rentTimeValue == 7) return 'Weekly';
    if (rentTimeValue == 30) return 'Monthly';
    if (rentTimeValue == 365) return 'Yearly';
    return null;
  }

  int _getRateInt(String? rateString) {
    if (rateString == 'Daily') return 1;
    if (rateString == 'Weekly') return 7;
    if (rateString == 'Monthly') return 30;
    if (rateString == 'Yearly') return 365;
    return 0; // Default or error
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _bedsController.dispose();
    _bathsController.dispose();
    _areaController.dispose();
    // _floorsController.dispose();
    super.dispose();
  }

  InputDecoration _themedInputDecoration(BuildContext context, String labelText, IconData prefixIcon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return InputDecoration(
      labelText: labelText,
      labelStyle: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      border: const OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(4))),
      enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(4))),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: colorScheme.primary), borderRadius: const BorderRadius.all(Radius.circular(4))),
      filled: true,
      fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
      prefixIcon: Icon(prefixIcon, size: 22, color: colorScheme.onSurfaceVariant),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10), // Adjusted padding
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
        appBar: AppBar(
          title: Text("Edit ${widget.space.spaceName ?? 'Listing'}"),
        ),
        body: ListView(
          padding: const EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 20),
          children: <Widget>[
            Text("Space Information", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    child: TextFormField(
                      controller: _nameController,
                      validator: (val) => val!.isEmpty ? "Please enter a name" : null,
                      style: textTheme.bodyLarge,
                      decoration: _themedInputDecoration(context, "Space Name", Icons.title),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    child: TextFormField(
                      controller: _descriptionController,
                      validator: (val) => val!.isEmpty ? "Please enter the space description" : null,
                      style: textTheme.bodyLarge,
                      decoration: _themedInputDecoration(context, "Description", Icons.description_outlined),
                      maxLines: 3,
                    ),
                  ),
                  MyDropDown(
                    selectedOption: (val) => setState(() => category = val),
                    hintText: "Space Category",
                    options: options,
                    currentValue: category,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    child: TextFormField(
                      controller: _priceController,
                      validator: (val) => val!.isEmpty ? "Please enter the price" : null,
                      style: textTheme.bodyLarge,
                      decoration: _themedInputDecoration(context, "Price (KES)", Icons.sell_outlined),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 24),
              child: Text("More Details", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ),
            MyDropDown(
              selectedOption: (val) => setState(() => rentRate = val),
              hintText: "Rent rate",
              options: rates,
              currentValue: rentRate,
            ),
            Container(
              margin: const EdgeInsets.only(top: 12), // Adjusted top margin
              child: TextFormField(
                controller: _addressController,
                validator: (val) => val!.isEmpty ? "Please enter the space address" : null,
                style: textTheme.bodyLarge,
                decoration: _themedInputDecoration(context, "Space Address", Icons.location_on_outlined),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            InkWell(
              onTap: () {
                Get.to(() => AddOnMap( // Using the router
                  onChanged: (val) => setState(() => propertyLocation = val),
                  initialLocation: propertyLocation,
                  isEditing: propertyLocation != null,
                ));
              },
              child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outline.withOpacity(0.7)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                          backgroundColor: colorScheme.primary.withOpacity(0.1),
                          child: Icon(Icons.location_on_outlined, color: colorScheme.primary)),
                      const SizedBox(width: 10),
                      Text('Location on Map', style: textTheme.bodyLarge),
                      const Spacer(),
                      Icon(
                        Icons.check_circle,
                        color: propertyLocation == null ? colorScheme.onSurface.withOpacity(0.4) : colorScheme.primary,
                      )
                    ],
                  )),
            ),
             Container(
              margin: const EdgeInsets.only(top: 24, bottom: 8),
              child: Text("Photos", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ),
            // Display existing images with delete option
            if (existingImageUrls.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                itemCount: existingImageUrls.length,
                itemBuilder: (context, index) {
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.network(existingImageUrls[index], fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                      IconButton(
                        icon: Icon(Icons.cancel, color: colorScheme.error),
                        onPressed: () => setState(() {
                          imagesToDelete.add(existingImageUrls.removeAt(index));
                        }),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    ],
                  );
                },
              ),
            const SizedBox(height: 10),
            // Display newly added images with delete option
            if (newImageFiles.isNotEmpty)
              GridView.builder(
                 shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                itemCount: newImageFiles.length,
                itemBuilder: (context, index) {
                   return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.file(newImageFiles[index], fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                      IconButton(
                        icon: Icon(Icons.cancel, color: colorScheme.error),
                        onPressed: () => setState(() => newImageFiles.removeAt(index)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    ],
                  );
                }
              ),
            const SizedBox(height: 10),
            // Button to add more images
            OutlinedButton.icon(
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text("Add More Photos"),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
                side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
              ),
              onPressed: () => openImagePicker(context),
            ),

            // Features section
            Container(
              margin: const EdgeInsets.only(top: 24),
              child: Text("Features (Optional)", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ),
            Row(children: [
              Expanded(child: TextFormField(controller: _bedsController, decoration: _themedInputDecoration(context, "Beds", Icons.king_bed_outlined), keyboardType: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(child: TextFormField(controller: _bathsController, decoration: _themedInputDecoration(context, "Baths", Icons.bathtub_outlined), keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 12),
            TextFormField(controller: _areaController, decoration: _themedInputDecoration(context, "Area (e.g., 100 sqm)", Icons.square_foot_outlined)),


            Container(
              margin: const EdgeInsets.only(top: 24),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete_forever_outlined),
                label: const Text("Delete Space"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.errorContainer,
                  foregroundColor: colorScheme.onErrorContainer,
                  minimumSize: const Size(double.infinity, 44),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogCtx) {
                      return AlertDialog(
                        title: const Text("Delete Space"),
                        content: const Text("Are you sure you want to delete this space? This action cannot be undone."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogCtx).pop(),
                            child: const Text("Cancel"),
                          ),
                          TextButton( // Changed to TextButton for consistency
                            onPressed: () async {
                              Navigator.of(dialogCtx).pop(); // Close dialog first
                              setState(() => isLoading = true);
                              try {
                                await Provider.of<PostProvider>(context, listen: false).deleteSpace(widget.space.id!);
                                Navigator.of(context).pop(); // Pop EditSpaceScreen
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${widget.space.spaceName ?? 'Space'} deleted.")));
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error deleting space: $e")));
                              } finally {
                                 if(mounted) setState(() => isLoading = false);
                              }
                            },
                            child: Text("Delete", style: TextStyle(color: colorScheme.error)),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 20),
              child: ElevatedButton(
                onPressed: isLoading ? null : () async {
                  if (formKey.currentState!.validate()) {
                    setState(() => isLoading = true);

                    final updatedSpace = SpaceModel(
                      id: widget.space.id,
                      spaceName: _nameController.text,
                      description: _descriptionController.text,
                      price: double.tryParse(_priceController.text),
                      address: _addressController.text,
                      location: propertyLocation != null
                          ? GeoPoint(propertyLocation!.latitude, propertyLocation!.longitude)
                          : widget.space.location,
                      newImageFiles: newImageFiles, // Pass new image files
                      existingImageUrls: existingImageUrls, // Pass current list of URLs
                      imagesToDelete: imagesToDelete, // Pass URLs to delete
                      ownerId: FirebaseAuth.instance.currentUser!.uid, // Should be same as original
                      category: category,
                      size: _areaController.text,
                      features: {
                        'beds': _bedsController.text,
                        'baths': _bathsController.text,
                        'area': _areaController.text,
                      },
                      rentTime: _getRateInt(rentRate),
                      // Preserve other fields not being edited
                      likes: widget.space.likes,
                      isVerified: widget.space.isVerified,
                      isAvailable: widget.space.isAvailable,
                      createdAt: widget.space.createdAt,
                      updatedAt: Timestamp.now(), // Update timestamp
                    );

                    try {
                      await Provider.of<PostProvider>(context, listen: false).editSpace(updatedSpace);
                      Navigator.of(context).pop(true); // Pop and indicate success
                    } catch (e) {
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving changes: $e")));
                    } finally {
                       if(mounted) setState(() => isLoading = false);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  minimumSize: const Size(double.infinity, 48),
                  textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)
                ),
                child: isLoading
                    ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: colorScheme.onPrimary))
                    : const Text("Save Changes"),
              ),
            ),
          ],
        ));
  }

  Future<void> openImagePicker(BuildContext context) async {
    // Re-using the adaptive image picker logic from AddSpaceScreenMaterial
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    List<Media> currentMediaList = []; // Temporary list for this picker session

    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        context: context,
        builder: (modalCtx) { // Changed context name to avoid conflict
          return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(modalCtx).pop(),
              child: DraggableScrollableSheet(
                initialChildSize: 0.6,
                maxChildSize: 0.95,
                minChildSize: 0.6,
                builder: (sheetCtx, controller) => AnimatedContainer( // Changed context name
                    duration: const Duration(milliseconds: 500),
                    color: colorScheme.surface, // Themed background
                    child: MediaPicker(
                      scrollController: controller,
                      mediaList: currentMediaList, // Use temporary list
                      onPick: (selectedList) {
                        setState(() {
                          newImageFiles.addAll(selectedList.where((m) => m.file != null).map((m) => m.file!));
                        });
                        Navigator.pop(modalCtx); // Use modalCtx
                      },
                      onCancel: () => Navigator.pop(modalCtx), // Use modalCtx
                      mediaCount: MediaCount.multiple, // Allow multiple images
                      mediaType: MediaType.image,
                      decoration: PickerDecoration(
                        cancelIcon: Icon(Icons.close, color: colorScheme.onSurface),
                        albumTitleStyle: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
                        actionBarPosition: ActionBarPosition.top,
                        blurStrength: 0, // No blur if using solid background
                        completeTextStyle: textTheme.labelLarge?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
                        completeText: 'Done',
                        selectionColor: colorScheme.primary,
                        selectedCountBackgroundColor: colorScheme.primary,
                        selectedCountTextColor: colorScheme.onPrimary,
                        backgroundColor: colorScheme.surface,
                      ),
                    )),
              ));
        });
  }
}
