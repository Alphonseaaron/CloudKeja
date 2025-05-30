import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/config/app_config.dart'; // Import for kServiceProviderTypes
import 'package:cloudkeja/widgets/forms/multi_select_chip_field.dart'; // Import MultiSelectChipField
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:cloudkeja/services/walkthrough_service.dart';

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

  // GlobalKeys for ShowcaseView
  final _svcTypesKey = GlobalKey();
  final _locationFieldsKey = GlobalKey();
  final _certificationsKey = GlobalKey();
  final _saveProfileButtonKey = GlobalKey();

  List<GlobalKey> _showcaseKeys = [];

  // Existing Controllers
  late TextEditingController _phoneController;
  late TextEditingController _servicesOfferedController; // Detailed text description
  late TextEditingController _serviceAreasController;    // Detailed text description
  late TextEditingController _mondayAvailabilityController;
  late TextEditingController _tuesdayAvailabilityController;
  late TextEditingController _wednesdayAvailabilityController;
  late TextEditingController _thursdayAvailabilityController;
  late TextEditingController _fridayAvailabilityController;
  late TextEditingController _saturdayAvailabilityController;
  late TextEditingController _sundayAvailabilityController;

  // New State Variables for SP Types & Location
  List<String> _selectedServiceTypes = [];
  late TextEditingController _spCountryController;
  late TextEditingController _spCountyController;
  late TextEditingController _spSubCountyController;


  @override
  void initState() {
    super.initState();
    _initializeControllers();

    _showcaseKeys = [
      _svcTypesKey,
      _locationFieldsKey,
      _certificationsKey,
      _saveProfileButtonKey,
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Conditional trigger could be added here if needed,
      // e.g., check if _currentUser.serviceProviderTypes.isEmpty etc.
      WalkthroughService.startShowcaseIfNeeded(
        context: context,
        walkthroughKey: 'spCompleteProfile_v1',
        showcaseGlobalKeys: _showcaseKeys,
      );
    });

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

    // New Controllers
    _spCountryController = TextEditingController();
    _spCountyController = TextEditingController();
    _spSubCountyController = TextEditingController();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.getCurrentUser(forceRefresh: true); // Force refresh to get latest data

    if (mounted) {
      setState(() {
        _currentUser = authProvider.user;
        if (_currentUser != null) {
          _phoneController.text = _currentUser!.phone ?? '';
          // Detailed text descriptions
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

          // Initialize new fields
          _selectedServiceTypes = List<String>.from(_currentUser!.serviceProviderTypes ?? []);
          _spCountryController.text = _currentUser!.spCountry ?? 'Kenya'; // Default to Kenya if null
          _spCountyController.text = _currentUser!.spCounty ?? '';
          _spSubCountyController.text = _currentUser!.spSubCounty ?? '';
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
    // New controllers
    _spCountryController.dispose();
    _spCountyController.dispose();
    _spSubCountyController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Additional validation for SP specific fields
    if (_currentUser?.role == 'ServiceProvider') {
      if (_selectedServiceTypes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select at least one service specialization.', style: TextStyle(color: Theme.of(context).colorScheme.onError)), backgroundColor: Theme.of(context).colorScheme.error),
        );
        return;
      }
      if (_spCountryController.text.trim().isEmpty || _spCountyController.text.trim().isEmpty) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Country and County are required for your service location.', style: TextStyle(color: Theme.of(context).colorScheme.onError)), backgroundColor: Theme.of(context).colorScheme.error),
        );
        return;
      }
    }

    if (mounted) setState(() => _isSaving = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Error: User data not found.', style: TextStyle(color: Theme.of(context).colorScheme.onError)), backgroundColor: Theme.of(context).colorScheme.error),
      );
      if (mounted) setState(() => _isSaving = false);
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

    UserModel updatedUser = _currentUser!.copyWith(
      phone: _phoneController.text.trim(),
      servicesOffered: servicesOffered, // Detailed text
      serviceAreas: serviceAreas,       // Detailed text
      availabilitySchedule: availabilitySchedule,
      // New fields
      serviceProviderTypes: _selectedServiceTypes,
      spCountry: _spCountryController.text.trim(),
      spCounty: _spCountyController.text.trim(),
      spSubCounty: _spSubCountyController.text.trim(),
    );

    try {
      await authProvider.updateUserProfile(updatedUser); // updateUserProfile should handle all fields in UserModel
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      _loadUserData();
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
            flex: 2,
            child: Text('$label:', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
          ),
          Expanded(
            flex: 3,
            child: Text(value ?? 'Not available', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {IconData? icon, int maxLines = 1, String? hintText, bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: icon != null ? Icon(icon) : null,
        ),
        maxLines: maxLines,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty || value == 'Not Set')) {
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

    // Common showcase text style
    TextStyle? showcaseTitleStyle = textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary);
    TextStyle? showcaseDescStyle = textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary.withOpacity(0.9));

    return ShowCaseWidget(
      onFinish: () {
        WalkthroughService.markAsSeen('spCompleteProfile_v1');
      },
      builder: Builder(builder: (context) {
        return Scaffold(
          backgroundColor: colorScheme.background,
          appBar: AppBar(
            title: const Text('Manage Your Profile'),
          ),
          body: Skeletonizer(
            enabled: _isLoading,
            effect: ShimmerEffect(
              baseColor: colorScheme.surfaceVariant.withOpacity(0.4),
              highlightColor: colorScheme.surfaceVariant.withOpacity(0.8),
            ),
            child: RefreshIndicator(
              onRefresh: _loadUserData,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      _buildSectionTitle(context, 'Basic Information'),
                      _buildReadOnlyField(context, 'Email', _currentUser?.email, icon: Icons.email_outlined),
                      _buildReadOnlyField(context, 'Name', _currentUser?.name, icon: Icons.person_outline),
                      _buildReadOnlyField(
                        context,
                        'Verification Status',
                        _currentUser?.isVerified == true ? 'Verified' : 'Pending Verification',
                        icon: _currentUser?.isVerified == true ? Icons.verified_user_outlined : Icons.hourglass_empty_outlined,
                      ),

                      Showcase(
                        key: _certificationsKey,
                        title: 'Add Your Certifications',
                        description: 'Upload relevant certifications or licenses to build trust and get verified. Admins will review these.',
                        titleTextStyle: showcaseTitleStyle,
                        descTextStyle: showcaseDescStyle,
                        showcaseBackgroundColor: colorScheme.primary,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                            // TODO: Add button to manage/upload more certifications if needed (this would be a good place for a showcase if button exists)
                          ],
                        ),
                      ),

                      _buildSectionTitle(context, 'Contact & Service Details'),
                      _buildTextField(_phoneController, 'Phone Number', icon: Icons.phone_outlined, isRequired: true),

                      Showcase(
                        key: _svcTypesKey,
                        title: 'Define Your Services',
                        description: 'Select all service types you specialize in. This helps clients find you!',
                        titleTextStyle: showcaseTitleStyle,
                        descTextStyle: showcaseDescStyle,
                        showcaseBackgroundColor: colorScheme.primary,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(context, 'My Service Specializations'),
                            MultiSelectChipField(
                              allOptions: kServiceProviderTypes,
                              initialSelectedOptions: _selectedServiceTypes,
                              onSelectionChanged: (selected) => setState(() => _selectedServiceTypes = selected),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(_servicesOfferedController, 'Detailed Services Description', hintText: 'e.g., Kitchen sink repair, full house rewiring', icon: Icons.description_outlined, maxLines: 3, isRequired: true),
                      _buildTextField(_serviceAreasController, 'Primary Service Areas (comma-separated)', hintText: 'e.g., Downtown, West Suburbs, North End', icon: Icons.map_outlined, maxLines: 2, isRequired: true),

                      Showcase(
                        key: _locationFieldsKey,
                        title: 'Set Your Service Location',
                        description: 'Enter your primary service location details so clients in your area can discover you.',
                        titleTextStyle: showcaseTitleStyle,
                        descTextStyle: showcaseDescStyle,
                        showcaseBackgroundColor: colorScheme.primary,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(context, 'Primary Service Location'),
                            _buildTextField(_spCountryController, 'Country', icon: Icons.public_outlined, isRequired: true),
                            _buildTextField(_spCountyController, 'County / State', icon: Icons.location_city_outlined, isRequired: true),
                            _buildTextField(_spSubCountyController, 'Sub-County / City / Town (Optional)', icon: Icons.location_on_outlined),
                          ],
                        ),
                      ),

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
                        Showcase(
                          key: _saveProfileButtonKey,
                          title: 'Save Your Profile',
                          description: "Make sure to save your changes once you've updated your details.",
                          titleTextStyle: showcaseTitleStyle,
                          descTextStyle: showcaseDescStyle,
                          showcaseBackgroundColor: colorScheme.primary,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Save Profile'),
                            onPressed: _saveProfile,
                            style: theme.elevatedButtonTheme.style?.copyWith(
                              minimumSize: MaterialStateProperty.all(const Size(double.infinity, 48)),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
