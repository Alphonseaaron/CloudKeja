import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:skeletonizer/skeletonizer.dart'; // Import Skeletonizer
import 'package:url_launcher/url_launcher.dart'; // For opening certification URLs

class ServiceProviderProfilePage extends StatefulWidget {
  const ServiceProviderProfilePage({Key? key}) : super(key: key);
  static const String routeName = '/service-provider-profile';

  @override
  State<ServiceProviderProfilePage> createState() => _ServiceProviderProfilePageState();
}

class _ServiceProviderProfilePageState extends State<ServiceProviderProfilePage> {
  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isSaving = false;

  final _formKey = GlobalKey<FormState>();

  // TextEditingControllers remain the same
  late TextEditingController _phoneController;
  late TextEditingController _servicesOfferedController;
  late TextEditingController _serviceAreasController;
  late TextEditingController _mondayAvailabilityController;
  late TextEditingController _tuesdayAvailabilityController;
  late TextEditingController _wednesdayAvailabilityController;
  late TextEditingController _thursdayAvailabilityController;
  late TextEditingController _fridayAvailabilityController;
  late TextEditingController _saturdayAvailabilityController;
  late TextEditingController _sundayAvailabilityController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadUserData();
  }

  void _initializeControllers() {
    _phoneController = TextEditingController();
    _servicesOfferedController = TextEditingController();
    _serviceAreasController = TextEditingController();
    _mondayAvailabilityController = TextEditingController();
    _tuesdayAvailabilityController = TextEditingController();
    _wednesdayAvailabilityController = TextEditingController();
    _thursdayAvailabilityController = TextEditingController();
    _fridayAvailabilityController = TextEditingController();
    _saturdayAvailabilityController = TextEditingController();
    _sundayAvailabilityController = TextEditingController();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Ensure user data is fetched if not already available
    await authProvider.getCurrentUser(); 

    if (mounted) {
      setState(() {
        _currentUser = authProvider.user;
        if (_currentUser != null) {
          _phoneController.text = _currentUser!.phone ?? '';
          _servicesOfferedController.text = (_currentUser!.servicesOffered ?? []).join(', ');
          _serviceAreasController.text = (_currentUser!.serviceAreas ?? []).join(', ');
          
          final schedule = _currentUser!.availabilitySchedule ?? {};
          _mondayAvailabilityController.text = schedule['monday'] ?? 'Not Set';
          _tuesdayAvailabilityController.text = schedule['tuesday'] ?? 'Not Set';
          _wednesdayAvailabilityController.text = schedule['wednesday'] ?? 'Not Set';
          _thursdayAvailabilityController.text = schedule['thursday'] ?? 'Not Set';
          _fridayAvailabilityController.text = schedule['friday'] ?? 'Not Set';
          _saturdayAvailabilityController.text = schedule['saturday'] ?? 'Not Set';
          _sundayAvailabilityController.text = schedule['sunday'] ?? 'Not Set';
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _servicesOfferedController.dispose();
    _serviceAreasController.dispose();
    _mondayAvailabilityController.dispose();
    _tuesdayAvailabilityController.dispose();
    _wednesdayAvailabilityController.dispose();
    _thursdayAvailabilityController.dispose();
    _fridayAvailabilityController.dispose();
    _saturdayAvailabilityController.dispose();
    _sundayAvailabilityController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (mounted) setState(() => _isSaving = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Error: User data not found.', style: TextStyle(color: Theme.of(context).colorScheme.onError)), backgroundColor: Theme.of(context).colorScheme.error),
      );
      if (mounted) setState(() => _isSaving = false);
      return;
    }

    // Prepare data (same as before)
    List<String> servicesOffered = _servicesOfferedController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    List<String> serviceAreas = _serviceAreasController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    Map<String, dynamic> availabilitySchedule = {
      'monday': _mondayAvailabilityController.text.trim(),
      'tuesday': _tuesdayAvailabilityController.text.trim(),
      'wednesday': _wednesdayAvailabilityController.text.trim(),
      'thursday': _thursdayAvailabilityController.text.trim(),
      'friday': _fridayAvailabilityController.text.trim(),
      'saturday': _saturdayAvailabilityController.text.trim(),
      'sunday': _sundayAvailabilityController.text.trim(),
    };

    UserModel updatedUser = _currentUser!.copyWith( // Assuming UserModel has copyWith
      phone: _phoneController.text.trim(),
      servicesOffered: servicesOffered,
      serviceAreas: serviceAreas,
      availabilitySchedule: availabilitySchedule,
    );

    try {
      await authProvider.updateUserProfile(updatedUser);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      _loadUserData(); // Refresh data
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: ${error.toString()}', style: TextStyle(color: Theme.of(context).colorScheme.onError)), backgroundColor: Theme.of(context).colorScheme.error),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildReadOnlyField(BuildContext context, String label, String? value, {IconData? icon}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[Icon(icon, color: theme.colorScheme.primary, size: 20), const SizedBox(width: 12)],
          Expanded(
            flex: 2, // Give more space to label
            child: Text('$label:', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
          ),
          Expanded(
            flex: 3, // More space to value
            child: Text(value ?? 'Not available', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTextField(TextEditingController controller, String label, {IconData? icon, int maxLines = 1}) {
    // InputDecoration will be largely handled by the global theme
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label, // Uses floating label behavior from theme
          prefixIcon: icon != null ? Icon(icon) : null, // Icon inside the field
          // Border, contentPadding, fillColor, etc., will come from InputDecorationTheme
        ),
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.isEmpty || value == 'Not Set') { // Consider "Not Set" as empty for validation
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Manage Your Profile'),
        // Uses AppBarTheme from AppTheme
      ),
      body: Skeletonizer(
        enabled: _isLoading,
        effect: ShimmerEffect(
          baseColor: colorScheme.surfaceVariant.withOpacity(0.4),
          highlightColor: colorScheme.surfaceVariant.withOpacity(0.8),
        ),
        child: RefreshIndicator( // Added RefreshIndicator
          onRefresh: _loadUserData,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  // Read-only section
                  _buildSectionTitle(context, 'Basic Information'),
                  _buildReadOnlyField(context, 'Email', _currentUser?.email, icon: Icons.email_outlined),
                  _buildReadOnlyField(context, 'Name', _currentUser?.name, icon: Icons.person_outline),
                  _buildReadOnlyField(
                    context,
                    'Verification Status', 
                    _currentUser?.isVerified == true ? 'Verified' : 'Pending Verification',
                    icon: _currentUser?.isVerified == true ? Icons.verified_user_outlined : Icons.hourglass_empty_outlined,
                  ),
                  
                  _buildSectionTitle(context, 'Certifications'),
                  if (_currentUser?.certifications == null || _currentUser!.certifications!.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('No certifications uploaded.', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7))),
                    )
                  else
                    ..._currentUser!.certifications!.map((certUrl) {
                      String fileName = 'View Certification Document';
                      try {
                        fileName = Uri.decodeFull(certUrl.split('/').last.split('?').first.split('%2F').last);
                      } catch (_) {}
                      
                      return ListTile(
                        leading: Icon(Icons.article_outlined, color: colorScheme.secondary),
                        title: Text(fileName, style: textTheme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text('Tap to view', style: textTheme.caption?.copyWith(color: colorScheme.onSurface.withOpacity(0.6))),
                        onTap: () async {
                           final Uri uri = Uri.parse(certUrl);
                           if (await canLaunchUrl(uri)) {
                             await launchUrl(uri, mode: LaunchMode.externalApplication);
                           } else {
                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open URL: $certUrl')));
                           }
                        },
                        contentPadding: EdgeInsets.zero,
                      );
                    }),
                  // Consider adding a button to upload/manage certifications here if desired
                  // E.g., TextButton.icon(icon: Icon(Icons.add_link), label: Text("Manage Certifications"), onPressed: (){})

                  _buildSectionTitle(context, 'Service Details'),
                  _buildTextField(_phoneController, 'Phone Number', icon: Icons.phone_outlined),
                  _buildTextField(_servicesOfferedController, 'Services Offered (comma-separated)', icon: Icons.construction_outlined, maxLines: 2),
                  _buildTextField(_serviceAreasController, 'Service Areas (comma-separated)', icon: Icons.map_outlined, maxLines: 2),
                  
                  _buildSectionTitle(context, 'Weekly Availability'),
                  _buildTextField(_mondayAvailabilityController, 'Monday', icon: Icons.calendar_view_day_outlined),
                  _buildTextField(_tuesdayAvailabilityController, 'Tuesday', icon: Icons.calendar_view_day_outlined),
                  _buildTextField(_wednesdayAvailabilityController, 'Wednesday', icon: Icons.calendar_view_day_outlined),
                  _buildTextField(_thursdayAvailabilityController, 'Thursday', icon: Icons.calendar_view_day_outlined),
                  _buildTextField(_fridayAvailabilityController, 'Friday', icon: Icons.calendar_view_day_outlined),
                  _buildTextField(_saturdayAvailabilityController, 'Saturday', icon: Icons.calendar_view_day_outlined),
                  _buildTextField(_sundayAvailabilityController, 'Sunday', icon: Icons.calendar_view_day_outlined),
                  
                  const SizedBox(height: 32),
                  if (_isSaving)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton.icon( // Changed to ElevatedButton.icon for better UX
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save Profile'),
                      onPressed: _saveProfile,
                      // Style from ElevatedButtonThemeData
                      style: theme.elevatedButtonTheme.style?.copyWith(
                        minimumSize: MaterialStateProperty.all(const Size(double.infinity, 48)), // Full width button
                      ),
                    ),
                  const SizedBox(height: 20), // Bottom padding
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper extension for UserModel if copyWith is not defined
// Ensure UserModel has a copyWith method or define one like this:
/*
extension UserModelCopyWith on UserModel {
  UserModel copyWith({
    String? userId,
    String? name,
    // ... other fields
    String? phone,
    List<String>? servicesOffered,
    List<String>? serviceAreas,
    Map<String, dynamic>? availabilitySchedule,
    // ... other fields
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      // ... other fields
      phone: phone ?? this.phone,
      servicesOffered: servicesOffered ?? this.servicesOffered,
      serviceAreas: serviceAreas ?? this.serviceAreas,
      availabilitySchedule: availabilitySchedule ?? this.availabilitySchedule,
      // ... other fields
      // Ensure all fields are covered
      idnumber: this.idnumber,
      email: this.email,
      password: this.password,
      profile: this.profile,
      isLandlord: this.isLandlord,
      bankBusinessNumber: this.bankBusinessNumber,
      bankNumber: this.bankNumber,
      isAdmin: this.isAdmin,
      rentedPlaces: this.rentedPlaces,
      wishlist: this.wishlist,
      balance: this.balance,
      role: this.role,
      certifications: this.certifications,
      isVerified: this.isVerified,
    );
  }
}
*/
