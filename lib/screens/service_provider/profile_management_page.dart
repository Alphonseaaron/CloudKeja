import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';

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
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) {
      // This assumes getCurrentUser fetches and sets the user in AuthProvider
      // Or that the user is already available from a previous login/fetch
      await authProvider.getCurrentUser(); 
    }

    if (mounted) {
      setState(() {
        _currentUser = authProvider.user;
        if (_currentUser != null) {
          _phoneController.text = _currentUser!.phone ?? '';
          _servicesOfferedController.text = (_currentUser!.servicesOffered ?? []).join(', ');
          _serviceAreasController.text = (_currentUser!.serviceAreas ?? []).join(', ');
          
          _mondayAvailabilityController.text = _currentUser!.availabilitySchedule?['monday'] ?? '';
          _tuesdayAvailabilityController.text = _currentUser!.availabilitySchedule?['tuesday'] ?? '';
          _wednesdayAvailabilityController.text = _currentUser!.availabilitySchedule?['wednesday'] ?? '';
          _thursdayAvailabilityController.text = _currentUser!.availabilitySchedule?['thursday'] ?? '';
          _fridayAvailabilityController.text = _currentUser!.availabilitySchedule?['friday'] ?? '';
          _saturdayAvailabilityController.text = _currentUser!.availabilitySchedule?['saturday'] ?? '';
          _sundayAvailabilityController.text = _currentUser!.availabilitySchedule?['sunday'] ?? '';
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
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isSaving = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User data not found.')),
      );
      setState(() {
        _isSaving = false;
      });
      return;
    }

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

    // Create a new UserModel instance with updated fields
    // We must include all fields from the original _currentUser,
    // especially those not editable on this page.
    UserModel updatedUser = UserModel(
      userId: _currentUser!.userId,
      name: _currentUser!.name, // Assuming name is not editable here or handled elsewhere
      idnumber: _currentUser!.idnumber,
      email: _currentUser!.email, // Email is typically not editable
      password: _currentUser!.password, // Password management is a separate flow
      profile: _currentUser!.profile,
      phone: _phoneController.text.trim(),
      isLandlord: _currentUser!.isLandlord,
      bankBusinessNumber: _currentUser!.bankBusinessNumber,
      bankNumber: _currentUser!.bankNumber,
      isAdmin: _currentUser!.isAdmin,
      rentedPlaces: _currentUser!.rentedPlaces,
      wishlist: _currentUser!.wishlist,
      balance: _currentUser!.balance,
      role: _currentUser!.role,
      certifications: _currentUser!.certifications, // Certifications might be updated in a separate flow
      servicesOffered: servicesOffered,
      serviceAreas: serviceAreas,
      availabilitySchedule: availabilitySchedule,
      isVerified: _currentUser!.isVerified, // Verification status is read-only for the user
    );

    try {
      await authProvider.updateUserProfile(updatedUser);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      // Optionally, reload data if needed, or trust provider to update state
      _loadUserData(); 
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: ${error.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, {IconData? icon}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        icon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      ),
      validator: (value) {
        // Basic validation, can be expanded
        // if (value == null || value.isEmpty) {
        //   return 'Please enter $label';
        // }
        return null;
      },
    );
  }

  Widget _buildReadOnlyField(String label, String? value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (icon != null) ...[Icon(icon, color: Theme.of(context).primaryColor), const SizedBox(width: 12)],
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? 'Not available')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Manage Your Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Manage Your Profile')),
        body: const Center(child: Text('Could not load user data. Please try again later.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Your Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildReadOnlyField('Email', _currentUser!.email, icon: Icons.email),
              _buildReadOnlyField('Name', _currentUser!.name, icon: Icons.person),
              _buildReadOnlyField(
                'Verification Status', 
                _currentUser!.isVerified == true ? 'Verified' : 'Pending Verification',
                icon: _currentUser!.isVerified == true ? Icons.verified_user : Icons.hourglass_empty
              ),
              const SizedBox(height: 16),

              Text('Certifications:', style: Theme.of(context).textTheme.titleMedium),
              if (_currentUser!.certifications == null || _currentUser!.certifications!.isEmpty)
                const Text('No certifications uploaded.')
              else
                ..._currentUser!.certifications!.map((cert) => ListTile(
                      leading: const Icon(Icons.article),
                      title: Text(cert.split('/').last.split('?').first.split('%2F').last), // Basic name extraction
                      subtitle: Text(cert, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      onTap: () { /* Optionally open URL or show image */ },
                    )),
              // TODO: Add button to upload more certifications later
              const SizedBox(height: 20),
              
              _buildTextField(_phoneController, 'Phone Number', icon: Icons.phone),
              const SizedBox(height: 16),
              _buildTextField(_servicesOfferedController, 'Services Offered (comma-separated)', icon: Icons.build),
              const SizedBox(height: 16),
              _buildTextField(_serviceAreasController, 'Service Areas (comma-separated)', icon: Icons.map),
              const SizedBox(height: 20),

              Text('Availability Schedule:', style: Theme.of(context).textTheme.titleMedium),
              _buildTextField(_mondayAvailabilityController, 'Monday Availability', icon: Icons.calendar_today),
              const SizedBox(height: 8),
              _buildTextField(_tuesdayAvailabilityController, 'Tuesday Availability', icon: Icons.calendar_today),
              const SizedBox(height: 8),
              _buildTextField(_wednesdayAvailabilityController, 'Wednesday Availability', icon: Icons.calendar_today),
              const SizedBox(height: 8),
              _buildTextField(_thursdayAvailabilityController, 'Thursday Availability', icon: Icons.calendar_today),
              const SizedBox(height: 8),
              _buildTextField(_fridayAvailabilityController, 'Friday Availability', icon: Icons.calendar_today),
              const SizedBox(height: 8),
              _buildTextField(_saturdayAvailabilityController, 'Saturday Availability', icon: Icons.calendar_today),
              const SizedBox(height: 8),
              _buildTextField(_sundayAvailabilityController, 'Sunday Availability', icon: Icons.calendar_today),
              const SizedBox(height: 24),

              if (_isSaving)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text('Save Profile'),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
