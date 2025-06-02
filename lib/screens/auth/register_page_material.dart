import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/screens/auth/widgets/custom_checkbox.dart';
import 'package:cloudkeja/screens/auth/widgets/primary_button.dart';
import 'package:cloudkeja/screens/home/my_nav_material.dart'; // Updated import
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloudkeja/config/app_config.dart'; // Import for kServiceProviderTypes
import 'package:cloudkeja/widgets/forms/multi_select_chip_field.dart'; // Import MultiSelectChipField

class RegisterPageMaterial extends StatefulWidget { // Renamed class
  const RegisterPageMaterial({Key? key}) : super(key: key); // Renamed constructor

  @override
  _RegisterPageMaterialState createState() => _RegisterPageMaterialState(); // Renamed state class
}

class _RegisterPageMaterialState extends State<RegisterPageMaterial> { // Renamed state class
  bool _passwordVisible = false;
  bool _passwordConfirmationVisible = false;
  bool _termsAccepted = false;

  String? _name, _idnumber, _email, _password, _phone, _passwordConfirmation;
  String? _selectedRole;
  List<XFile>? _certificationFiles;
  // String? _servicesOfferedText; // Replaced by controller
  // String? _serviceAreasText;     // Replaced by controller

  // New state variables for SP types and location
  List<String> _selectedServiceTypes = [];
  late TextEditingController _spCountryController;
  late TextEditingController _spCountyController;
  late TextEditingController _spSubCountyController;
  late TextEditingController _spServicesOfferedController; // Added controller
  late TextEditingController _spServiceAreasController;   // Added controller

  bool _isLoading = false;
  String? _errorMessage; // Added for inline error messages
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _spCountryController = TextEditingController(text: 'Kenya'); // Default country
    _spCountyController = TextEditingController();
    _spSubCountyController = TextEditingController();
    _spServicesOfferedController = TextEditingController(); // Initialize
    _spServiceAreasController = TextEditingController();   // Initialize
  }

  @override
  void dispose() {
    _spCountryController.dispose();
    _spCountyController.dispose();
    _spSubCountyController.dispose();
    _spServicesOfferedController.dispose(); // Dispose
    _spServiceAreasController.dispose();   // Dispose
    // Dispose other controllers if any were manually created and not part of form fields that handle their own.
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() => _passwordVisible = !_passwordVisible);
  }

  void _togglePasswordConfirmationVisibility() {
    setState(() => _passwordConfirmationVisible = !_passwordConfirmationVisible);
  }

  Future<void> _pickCertifications() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage(imageQuality: 80);
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() => _certificationFiles = pickedFiles);
    }
  }

  Future<void> _handleRegister() async {
    // final scaffoldMessenger = ScaffoldMessenger.of(context); // No longer needed for all errors
    // final theme = Theme.of(context); // No longer needed for all errors
    setState(() { // Clear previous error messages
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() => _errorMessage = 'Please fix the errors in the form.'); // Generic message, specific errors are in TextFormField validators
      return;
    }
    if (!_termsAccepted) {
      setState(() => _errorMessage = 'Please accept the Terms & Conditions.');
      return;
    }

    // Specific validation for Service Provider role
    if (_selectedRole == 'ServiceProvider') {
      if (_selectedServiceTypes.isEmpty) {
        setState(() => _errorMessage = 'Please select at least one service type for Service Providers.');
        return;
      }
      if (_spCountryController.text.trim().isEmpty || _spCountyController.text.trim().isEmpty) {
         setState(() => _errorMessage = 'Country and County are required for Service Providers.');
        return;
      }
       if ((_certificationFiles == null || _certificationFiles!.isEmpty)) {
         setState(() => _errorMessage = 'Please upload at least one certification for Service Provider.');
         return;
      }
      // servicesOfferedText and serviceAreasText are already validated by TextFormField validators
    }

    setState(() => _isLoading = true);

    const String defaultProfilePic = 'https://firebasestorage.googleapis.com/v0/b/cloudkeja-d7e6b.appspot.com/o/userData%2FprofilePics%2Favatar.png?alt=media&token=d41075f9-6611-40f3-9c46-80730625530e';

    UserModel user = UserModel(
      name: _name, idnumber: _idnumber, email: _email, password: _password, phone: _phone,
      profile: defaultProfilePic, isLandlord: _selectedRole == 'Landlord', isAdmin: false,
      role: _selectedRole, rentedPlaces: [], wishlist: [], balance: 0.0, isVerified: false, // Default verification
      // New SP fields
      serviceProviderTypes: _selectedRole == 'ServiceProvider' ? _selectedServiceTypes : const [],
      spCountry: _selectedRole == 'ServiceProvider' ? _spCountryController.text.trim() : null,
      spCounty: _selectedRole == 'ServiceProvider' ? _spCountyController.text.trim() : null,
      spSubCounty: _selectedRole == 'ServiceProvider' ? _spSubCountyController.text.trim() : null,
    );

    if (_selectedRole == 'ServiceProvider') {
      List<String> certificationUrls = [];
      if (_certificationFiles != null && _certificationFiles!.isNotEmpty) {
        try {
          String tempUserIdForPath = DateTime.now().millisecondsSinceEpoch.toString();
          for (XFile file in _certificationFiles!) {
            String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
            firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
                .ref().child('users_certs/${_email ?? tempUserIdForPath}/$fileName');
            UploadTask uploadTask = ref.putData(await file.readAsBytes(), SettableMetadata(contentType: 'image/jpeg'));
            TaskSnapshot snapshot = await uploadTask;
            String downloadUrl = await snapshot.ref.getDownloadURL();
            certificationUrls.add(downloadUrl);
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _errorMessage = 'Error uploading certifications: ${e.toString().replaceFirst('Exception: ', '')}';
              _isLoading = false;
            });
          }
          return;
        }
      } // Else, certifications might not be mandatory if validation above is removed/changed

      user = user.copyWith( // Use copyWith to update the user model
        certifications: certificationUrls,
        servicesOffered: _spServicesOfferedController.text.split(',').map((e) => e.trim()).where((s) => s.isNotEmpty).toList() ?? [],
        serviceAreas: _spServiceAreasController.text.split(',').map((e) => e.trim()).where((s) => s.isNotEmpty).toList() ?? [],
        availabilitySchedule: {'monday': '9am-5pm', 'tuesday': '9am-5pm', 'wednesday': '9am-5pm', 'thursday': '9am-5pm', 'friday': '9am-5pm'}, // Default
      );
    }

    try {
      await Provider.of<AuthProvider>(context, listen: false).signUp(user);
      // Let StreamBuilder handle navigation on success
      // Get.offAll(() => const MyNavMaterial()); // Updated to MyNavMaterial
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString().replaceFirst('Exception: ', '').replaceFirst('HttpException: ', '');
        });
      }
    } finally {
       if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar( // Added AppBar
        title: const Text('Create Account'),
        elevation: 0,
        backgroundColor: colorScheme.background,
        foregroundColor: colorScheme.onBackground,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 24), // Adjusted top spacing after AppBar

                TextFormField(onChanged: (val) => _name = val, validator: (val) => (val == null || val.isEmpty) ? 'Please enter your full names' : null, decoration: const InputDecoration(hintText: 'Full Names', prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 16),
                TextFormField(onChanged: (val) => _idnumber = val, validator: (val) { if (val == null || val.isEmpty) return 'Please enter ID number'; if (val.length < 7 || val.length > 8) return 'Enter a valid ID'; return null; }, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'ID Number', prefixIcon: Icon(Icons.badge_outlined))),
                const SizedBox(height: 16),
                TextFormField(onChanged: (val) => _phone = val, validator: (val) { if (val == null || val.isEmpty) return 'Enter phone'; if (val.length < 10) return 'Enter valid phone'; return null; }, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined))),
                const SizedBox(height: 16),
                TextFormField(onChanged: (val) => _email = val, validator: (val) { if (val == null || val.isEmpty) return 'Enter email'; if (!val.contains('@') || !val.contains('.')) return 'Enter valid email'; return null; }, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'Email Address', prefixIcon: Icon(Icons.email_outlined))),
                const SizedBox(height: 16),
                TextFormField(onChanged: (val) => _password = val, obscureText: !_passwordVisible, validator: (val) { if (val == null || val.isEmpty) return 'Enter password'; if (val.length < 6) return 'Min 6 chars'; return null; }, decoration: InputDecoration(hintText: 'Password', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(icon: Icon(_passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: colorScheme.onSurface.withOpacity(0.6)), onPressed: _togglePasswordVisibility))),
                const SizedBox(height: 16),
                TextFormField(onChanged: (val) => _passwordConfirmation = val, obscureText: !_passwordConfirmationVisible, validator: (val) { if (val == null || val.isEmpty) return 'Confirm password'; if (val != _password) return 'Passwords do not match'; return null; }, decoration: InputDecoration(hintText: 'Confirm Password', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(icon: Icon(_passwordConfirmationVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: colorScheme.onSurface.withOpacity(0.6)), onPressed: _togglePasswordConfirmationVisibility))),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  onChanged: (value) => setState(() { _selectedRole = value; _certificationFiles = null; _servicesOfferedText = null; _serviceAreasText = null; _selectedServiceTypes.clear(); }),
                  items: ['Tenant', 'Landlord', 'ServiceProvider'].map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
                  decoration: const InputDecoration(hintText: 'Select Role', prefixIcon: Icon(Icons.person_pin_circle_outlined)),
                  validator: (value) => (value == null || value.isEmpty) ? 'Please select a role' : null,
                ),
                const SizedBox(height: 16),

                if (_selectedRole == 'ServiceProvider') ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text("Your Service Specializations", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  MultiSelectChipField(
                    allOptions: kServiceProviderTypes,
                    initialSelectedOptions: _selectedServiceTypes,
                    onSelectionChanged: (selected) => setState(() => _selectedServiceTypes = selected),
                    // title: "Select your service types", // Optional title within widget
                  ),
                  const SizedBox(height: 16),
                  TextFormField(controller: _spServicesOfferedController, validator: (val) => (_selectedRole == 'ServiceProvider' && (val == null || val.isEmpty)) ? 'Describe services offered' : null, decoration: const InputDecoration(hintText: 'Briefly describe services (e.g., Kitchen plumbing, AC maintenance)', prefixIcon: Icon(Icons.description_outlined)), maxLines: 2),
                  const SizedBox(height: 16),
                  TextFormField(controller: _spServiceAreasController, validator: (val) => (_selectedRole == 'ServiceProvider' && (val == null || val.isEmpty)) ? 'Enter service areas' : null, decoration: const InputDecoration(hintText: 'Main service areas (e.g., Downtown, West Suburbs)', prefixIcon: Icon(Icons.map_outlined)), maxLines: 2),
                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text("Primary Service Location", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  TextFormField(controller: _spCountryController, validator: (val) => (val == null || val.isEmpty) ? 'Country is required' : null, decoration: const InputDecoration(hintText: 'Country (e.g., Kenya)', prefixIcon: Icon(Icons.public_outlined))),
                  const SizedBox(height: 16),
                  TextFormField(controller: _spCountyController, validator: (val) => (val == null || val.isEmpty) ? 'County is required' : null, decoration: const InputDecoration(hintText: 'County (e.g., Nairobi)', prefixIcon: Icon(Icons.location_city_outlined))),
                  const SizedBox(height: 16),
                  TextFormField(controller: _spSubCountyController, decoration: const InputDecoration(hintText: 'Sub-County / City / Town (Optional)', prefixIcon: Icon(Icons.location_on_outlined))),
                  const SizedBox(height: 16),

                  Text("Upload Certifications/Portfolio (Optional but Recommended)", style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file_outlined),
                    label: Text(_certificationFiles == null || _certificationFiles!.isEmpty ? 'Select Files' : '${_certificationFiles!.length} file(s) selected'),
                    onPressed: _pickCertifications,
                  ),
                  if (_certificationFiles != null && _certificationFiles!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Wrap(spacing: 8.0, runSpacing: 6.0, children: _certificationFiles!.map((file) => Chip(label: Text(file.name, style: textTheme.bodySmall), onDeleted: () => setState(() { _certificationFiles!.remove(file); if (_certificationFiles!.isEmpty) _certificationFiles = null; }), deleteIcon: const Icon(Icons.cancel, size: 18))).toList()),
                    ),
                  const SizedBox(height: 24),
                ],

                Row(
                  children: [
                    CustomCheckbox(initialValue: _termsAccepted, onChanged: (value) => setState(() => _termsAccepted = value)),
                    const SizedBox(width: 8),
                    Expanded(child: RichText(text: TextSpan(text: 'By creating an account, you agree to our ', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onBackground.withOpacity(0.8)), children: [TextSpan(text: 'Terms & Conditions', style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w600))]))),
                  ],
                ),
                const SizedBox(height: 16), // Space before error message

                if (_errorMessage != null && _errorMessage!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
                    ),
                  ),

                CustomPrimaryButton(textValue: 'Register', isLoading: _isLoading, onTap: _handleRegister),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account? ", style: textTheme.bodyMedium?.copyWith(color: colorScheme.onBackground.withOpacity(0.8))),
                    GestureDetector(onTap: () => Get.back(), child: Text('Login', style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold))),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
