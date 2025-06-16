import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:get/route_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:media_picker_widget/media_picker_widget.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/helpers/constants.dart';
import 'package:cloudkeja/helpers/my_dropdown.dart';
import 'package:cloudkeja/helpers/my_loader.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/models/user_model.dart'; // Added
import 'package:cloudkeja/providers/auth_provider.dart'; // Added
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/providers/subscription_provider.dart'; // Added
import 'package:cloudkeja/screens/subscription/subscription_plans_screen.dart'; // Added
import 'package:cloudkeja/screens/landlord/widgets/add_on_map.dart';

class AddSpaceScreenMaterial extends StatefulWidget { // Renamed class
  const AddSpaceScreenMaterial({Key? key}) : super(key: key); // Renamed constructor

  @override
  _AddSpaceScreenMaterialState createState() => _AddSpaceScreenMaterialState(); // Renamed state class
}

class _AddSpaceScreenMaterialState extends State<AddSpaceScreenMaterial> { // Renamed state class
  LatLng? propertyLocation;
  File? coverImage;
  List<File> imageFiles = [];
  List<Media> mediaList = [];
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();
  String? ownerId;
  String? type;
  String? name;
  String? description;
  String? address;
  String? price;
  String? beds;
  String? baths;
  String? area;
  String? floors;
  String? category;
  String? rentTime;
  String? rentRate;

  // TODO: Consider moving category options to a centralized config (e.g., app_config.dart)
  List<String> options = [
    'For Rent', // Added
    'For Sale', // Added
    'Apartment',
    'Airbnb',
    'Conference Room',
    'Event Grounds',
    'House',
    'Hostel',
    'Hotel',
    'Office',
    'Stall',
    'Store shelf',
    'Warehouse',
    'Utility',
  ];

  List<String> rates = [
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly',
  ];

  int getRate() {
    if (rentRate == 'Daily') {
      return 1;
    } else if (rentRate == 'Weekly') {
      return 7;
    } else if (rentRate == 'Monthly') {
      return 30;
    } else if (rentRate == 'Yearly') {
      return 365;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get theme instance
    final colorScheme = theme.colorScheme; // Get colorScheme for easier access

    return Scaffold(
        appBar: AppBar(
          title: const Text("Add a Listing"),
          // AppBar theme is applied globally, specific overrides can be done here if needed
        ),
        body: ListView(
          padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
          children: <Widget>[
            const Text("Space Information",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                    color: Colors.black)),
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    child: TextFormField(
                      onChanged: (val) {
                        setState(() {
                          name = val;
                        });
                      },
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Please enter a name";
                        }
                        return null;
                      },
                      style: const TextStyle(
                          letterSpacing: 0, fontWeight: FontWeight.w500),
                      decoration: const InputDecoration(
                        hintText: "Space Name",
                        hintStyle: TextStyle(
                            fontSize: 14,
                            letterSpacing: 0,
                            fontWeight: FontWeight.w500),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(4),
                            ),
                            borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(4),
                            ),
                            borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(4),
                            ),
                            borderSide: BorderSide.none),
                        filled: true,
                        fillColor: colorScheme.surfaceVariant.withOpacity(0.5), // Theme color
                        prefixIcon: Icon(
                          Icons.person,
                          size: 22,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.all(0),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    child: TextFormField(
                      onChanged: (val) {
                        setState(() {
                          description = val;
                        });
                      },
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Please enter the space description";
                        }
                        return null;
                      },
                      style: const TextStyle(
                          letterSpacing: 0, fontWeight: FontWeight.w500),
                      decoration: const InputDecoration(
                        hintText: "Description",
                        hintStyle: TextStyle(
                            fontSize: 14,
                            letterSpacing: 0,
                            fontWeight: FontWeight.w500),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(4),
                            ),
                            borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(4),
                            ),
                            borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(4),
                            ),
                            borderSide: BorderSide.none),
                        filled: true,
                        fillColor: colorScheme.surfaceVariant.withOpacity(0.5), // Theme color
                        prefixIcon: Icon(
                          Icons.more_vert,
                          size: 22,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.all(0),
                      ),
                    ),
                  ),
                  MyDropDown(
                    selectedOption: (val) {
                      setState(() {
                        category = val;
                      });
                    },
                    hintText: "Space Category",
                    options: options,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    child: TextFormField(
                      onChanged: (val) {
                        setState(() {
                          price = val;
                        });
                      },
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Please enter the price";
                        }
                        return null;
                      },
                      style: const TextStyle(
                          letterSpacing: 0, fontWeight: FontWeight.w500),
                      decoration: const InputDecoration(
                        hintText: "Price",
                        hintStyle: TextStyle(
                            fontSize: 14,
                            letterSpacing: 0,
                            fontWeight: FontWeight.w500),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(4),
                            ),
                            borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(4),
                            ),
                            borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(4),
                            ),
                            borderSide: BorderSide.none),
                        filled: true,
                        fillColor: colorScheme.surfaceVariant.withOpacity(0.5), // Theme color
                        prefixIcon: Icon(
                          Icons.sell_outlined,
                          size: 22,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.all(0),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 24),
              child: const Text("More",
                  style:
                  TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0)),
            ),

            MyDropDown(
              selectedOption: (val) {
                setState(() {
                  rentRate = val;
                });
              },
              hintText: "Rent rate",
              options: rates,
            ),
            Container(
              margin: const EdgeInsets.only(top: 0),
              child: TextFormField(
                onChanged: (val) {
                  setState(() {
                    address = val;
                  });
                },
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Please enter the space address";
                  }
                  return null;
                },
                style: const TextStyle(
                    letterSpacing: 0, fontWeight: FontWeight.w500),
                decoration: const InputDecoration(
                  hintText: "Space Address",
                  hintStyle: TextStyle(
                      fontSize: 14,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w500),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      ),
                      borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      ),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      ),
                      borderSide: BorderSide.none),
                  filled: true,
                        fillColor: colorScheme.surfaceVariant.withOpacity(0.5), // Theme color
                  prefixIcon: Icon(Icons.location_on_outlined),
                  isDense: true,
                  contentPadding: EdgeInsets.all(0),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            InkWell(
              onTap: () {
                Get.to(() => AddOnMap(
                  onChanged: (val) {
                    setState(() {
                      propertyLocation = val;
                    });
                  },
                  initialLocation: propertyLocation, // Pass current location if editing
                  isEditing: propertyLocation != null,  // Set isEditing based on location presence
                ));
              },
              child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.symmetric(vertical: 8.0), // Add some padding for better tap target
                  decoration: BoxDecoration( // Optional: Add a border or background to make it look more tappable
                    border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Padding( // Padding for the icon within the tappable area
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: CircleAvatar(
                            backgroundColor: colorScheme.primary.withOpacity(0.1), // Theme color
                            child: Icon(
                              Icons.location_on_outlined,
                              color: colorScheme.primary, // Theme color
                            )),
                      ),
                      const Text('Location on Map'),
                      const Spacer(),
                      Padding( // Padding for the check icon
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Icon(
                          Icons.check_circle,
                          color: propertyLocation == null
                              ? colorScheme.onSurface.withOpacity(0.4) // Theme color for unchecked
                              : colorScheme.primary, // Theme color for checked
                        ),
                      )
                    ],
                  )),
            ),
            Container(
              margin: const EdgeInsets.only(top: 24, bottom: 0),
              child: const Text("Photos",
                  style:
                  TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0)),
            ),
            InkWell(
              onTap: () {
                openImagePicker(context, true);
              },
              child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                          backgroundColor: Colors.grey[400],
                          child: const Icon(Icons.camera_alt_outlined)),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text('Cover Image'),
                      const Spacer(),
                      Icon(
                        Icons.check_circle,
                        color: coverImage == null
                            ? Colors.grey[400]
                            : Colors.green,
                      )
                    ],
                  )),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      openImagePicker(context, false);
                    },
                    child: Container(
                        padding: const EdgeInsets.all(20),
                        color: colorScheme.primary.withOpacity(0.1), // Theme color
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: colorScheme.primary, // Theme color
                        )),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  ...List.generate(
                      imageFiles.length,
                          (index) => Stack(
                        clipBehavior: Clip.none,
                        children: [
                          SizedBox(
                            height: 80,
                            width: 80,
                            child: Image.file(
                              imageFiles[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                              top: -5,
                              right: -5,
                              child: GestureDetector(
                                onTap: () {
                                  imageFiles.remove(imageFiles[index]);
                                  setState(() {});
                                },
                                child: const Icon(Icons.cancel,
                                    color: Colors.pinkAccent),
                              ))
                        ],
                      ))
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 24),
              child: Center(
                child: Container(
                  height: 45,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[400]!,
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: imageFiles.isEmpty || propertyLocation == null
                        ? null
                        : () async {
                      // --- Subscription Check ---
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      final UserModel? currentUser = authProvider.user;
                      final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);

                      if (currentUser == null) {
                        // Should not happen if user is properly authenticated to reach this screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("User not found. Please re-login.")),
                        );
                        return;
                      }

                      if (!subscriptionProvider.canAddProperty(currentUser)) {
                        _showUpgradeDialog(context);
                        return; // Prevent form submission
                      }
                      // --- End Subscription Check ---

                      if (!formKey.currentState!.validate()) {
                        return; // Form validation failed
                      }
                      formKey.currentState!.save();


                      setState(() {
                        isLoading = true;
                      });
                      final space = SpaceModel(
                        spaceName: name,
                        description: description,
                        price: double.parse(price!),
                        address: address,
                        location: GeoPoint(propertyLocation!.latitude,
                            propertyLocation!.longitude),
                        imageFiles: imageFiles,
                        ownerId: FirebaseAuth.instance.currentUser!.uid,
                        category: category,
                        likes: 0,
                        size: area,
                        features: {
                          'beds': beds,
                          'baths': baths,
                          'floors': floors,
                          'area': area,
                        },
                        rentTime: getRate(),
                      );

                      await Provider.of<PostProvider>(context,
                          listen: false)
                          .addSpace(space);

                      setState(() {
                        isLoading = false;
                      });
                      Navigator.of(context).pop();
                    },
                    child: isLoading
                        ? const MyLoader()
                        : const Text("Add Property",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary)), // Theme color
                    style: ElevatedButton.styleFrom( // Use ElevatedButton.styleFrom for newer Flutter versions
                        backgroundColor: colorScheme.primary, // Theme color
                        foregroundColor: colorScheme.onPrimary, // Theme color for text/icon
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Adjust padding
                        textStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold) // Ensure textTheme is available
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ));
  }

  Future<void> openImagePicker(
      BuildContext context,
      bool isCover,
      ) async {
    // openCamera(onCapture: (image){
    //   setState(()=> mediaList = [image]);
    // });
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        context: context,
        builder: (context) {
          return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: DraggableScrollableSheet(
                initialChildSize: 0.6,
                maxChildSize: 0.95,
                minChildSize: 0.6,
                builder: (ctx, controller) => AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    color: Colors.white,
                    child: MediaPicker(
                      scrollController: controller,
                      mediaList: mediaList,
                      onPick: (selectedList) {
                        setState(() => mediaList = selectedList);

                        if (isCover) {
                          coverImage = mediaList.first.file;
                          mediaList.clear();
                        }

                        if (!isCover) {
                          for (var element in mediaList) {
                            imageFiles.add(element.file!);
                          }
                          mediaList.clear();
                        }

                        mediaList.clear();

                        Navigator.pop(context);
                      },
                      onCancel: () => Navigator.pop(context),
                      mediaCount:
                      isCover ? MediaCount.single : MediaCount.multiple,
                      mediaType: MediaType.image,
                      decoration: PickerDecoration(
                        cancelIcon: Icon(Icons.close, color: colorScheme.onSurface), // Theme color
                        albumTitleStyle: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold), // Theme style
                        actionBarPosition: ActionBarPosition.top,
                        blurStrength: 2, // Keep or adjust as desired
                        // completeButtonStyle: ButtonStyle(), // Can be themed if needed
                        completeTextStyle: textTheme.labelLarge?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold), // Theme style
                        completeText: 'Done', // Changed to "Done" for consistency
                        selectionColor: colorScheme.primary,
                        selectedCountBackgroundColor: colorScheme.primary,
                        selectedCountTextColor: colorScheme.onPrimary,
                        backgroundColor: colorScheme.surface, // Theme color for picker background
                      ),
                    )),
              ));
        });
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Property Limit Reached'),
          content: const Text(
              'You have reached the maximum number of properties for your current subscription plan. Please upgrade to add more.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Upgrade Plan'),
              onPressed: () {
                Navigator.of(ctx).pop(); // Close the dialog
                Navigator.of(context).pushNamed(SubscriptionPlansScreen.routeName);
              },
            ),
          ],
        );
      },
    );
  }
}

