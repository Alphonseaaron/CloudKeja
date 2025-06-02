import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart' show SnackBar, Colors; // SnackBar replaced
import 'package:flutter/material.dart' show Colors; // Assuming Colors might still be used somewhere, otherwise remove.
import 'package:provider/provider.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/config/app_config.dart'; // For kServiceProviderTypes
import 'package:cloudkeja/screens/auth/cupertino_select_service_types_page_stub.dart';
import 'package:cloudkeja/screens/auth/login_page.dart'; // For navigation back to Login
import 'package:get/get.dart'; // For Get.back() or Get.to()

class CupertinoRegisterPage extends StatefulWidget {
  const CupertinoRegisterPage({super.key});

  @override
  State<CupertinoRegisterPage> createState() => _CupertinoRegisterPageState();
}

class _CupertinoRegisterPageState extends State<CupertinoRegisterPage> {
  final _formKey = GlobalKey<FormState>(); // Though CupertinoTextFields don't use Form directly for validation

  final _nameController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _spCountryController = TextEditingController(text: 'Kenya'); // Default to Kenya
  final _spCountyController = TextEditingController();
  final _spSubCountyController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String _selectedRole = 'Tenant'; // Default role
  List<String> _selectedServiceTypes = [];
  bool _agreedToTerms = false;
  bool _passwordVisible = false; // Added for password visibility
  bool _confirmPasswordVisible = false; // Added for confirm password visibility

  final Map<String, String> _roles = {
    'Tenant': 'Tenant',
    'Landlord': 'Landlord',
    'ServiceProvider': 'Service Provider',
  };

  void _showRolePicker() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        padding: const EdgeInsets.only(top: 6.0),
        color: CupertinoTheme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
        child: Column(
          children: [
            SizedBox( // Drag handle or cancel button area
              height: 40,
              child: CupertinoButton(
                child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                magnification: 1.22,
                squeeze: 1.2,
                useMagnifier: true,
                itemExtent: 32.0, // Height of each item
                scrollController: FixedExtentScrollController(
                  initialItem: _roles.keys.toList().indexOf(_selectedRole),
                ),
                onSelectedItemChanged: (int selectedItem) {
                  setState(() {
                    _selectedRole = _roles.values.elementAt(selectedItem);
                  });
                },
                children: _roles.values.map((String value) {
                  return Center(child: Text(value, style: CupertinoTheme.of(context).textTheme.textStyle));
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    if (!_agreedToTerms) {
      setState(() => _errorMessage = 'You must agree to the terms and conditions.');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }
    // Basic empty checks (CupertinoTextFields don't use Form validators in the same way)
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _phoneController.text.isEmpty || _passwordController.text.isEmpty) {
         setState(() => _errorMessage = 'Please fill all required fields.');
         return;
    }
     if (_selectedRole == 'ServiceProvider' && _selectedServiceTypes.isEmpty) {
      setState(() => _errorMessage = 'Service Providers must select at least one service type.');
      return;
    }


    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final userModel = UserModel(
      name: _nameController.text.trim(),
      idNumber: _idNumberController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      role: _selectedRole,
      isVerified: _selectedRole == 'ServiceProvider' ? false : null, // SPs start unverified
      serviceProviderTypes: _selectedRole == 'ServiceProvider' ? _selectedServiceTypes : null,
      spCountry: _selectedRole == 'ServiceProvider' ? _spCountryController.text.trim() : null,
      spCounty: _selectedRole == 'ServiceProvider' ? _spCountyController.text.trim() : null,
      spSubCounty: _selectedRole == 'ServiceProvider' ? _spSubCountyController.text.trim() : null,
      // Other fields like certifications, availabilitySchedule will be updated via profile management for SP
    );

    try {
      await Provider.of<AuthProvider>(context, listen: false).signUp(
        userModel,
        _passwordController.text,
        null, // No certification files at initial Cupertino registration
      );
      // Navigation is handled by StreamBuilder in MyAppCupertino
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    } finally {
      if (mounted && _isLoading) { // Ensure isLoading is reset if signup fails early
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idNumberController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _spCountryController.dispose();
    _spCountyController.dispose();
    _spSubCountyController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    bool obscureText = false,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    TextInputAction? textInputAction,
    FocusNode? focusNode,
    void Function(String)? onSubmitted,
    bool isPassword = false, // Added to identify password fields
    bool isConfirmPassword = false, // Added to identify confirm password field
  }) {
    // Determine current visibility state based on which password field it is
    bool currentVisibility = isPassword ? _passwordVisible : (isConfirmPassword ? _confirmPasswordVisible : false);

    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      obscureText: (isPassword || isConfirmPassword) ? !currentVisibility : obscureText,
      keyboardType: keyboardType,
      prefix: prefixIcon != null ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Icon(prefixIcon, size: 22, color: CupertinoColors.placeholderText),
      ) : null,
      suffix: (isPassword || isConfirmPassword) // Add suffix only for password fields
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(
                currentVisibility ? CupertinoIcons.eye_slash_fill : CupertinoIcons.eye_fill,
                size: 24,
                color: CupertinoColors.inactiveGray,
              ),
              onPressed: () {
                setState(() {
                  if (isPassword) {
                    _passwordVisible = !_passwordVisible;
                  } else if (isConfirmPassword) {
                    _confirmPasswordVisible = !_confirmPasswordVisible;
                  }
                });
              },
            )
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.inactiveGray.withOpacity(0.4), width: 0.5),
        borderRadius: BorderRadius.circular(8.0),
      ),
      textInputAction: textInputAction,
      focusNode: focusNode,
      onSubmitted: onSubmitted != null ? (value) => onSubmitted(value) : null,
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Create Account'),
        leading: CupertinoNavigationBarBackButton(
          previousPageTitle: 'Log In', // Or just rely on default back arrow
          onPressed: () => Get.back(), // Or Navigator.pop(context)
        ),
      ),
      child: SafeArea(
        child: Form( // Using Form for potential future direct validation if needed, though not typical for CupertinoTextFields
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // CupertinoFormSection.insetGrouped( // Optional: Grouping fields
              //   header: Text('Account Type'),
              //   children: [
                  CupertinoFormRow(
                    prefix: const Text('I am a:'),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _showRolePicker,
                      child: Text(_selectedRole, style: theme.textTheme.textStyle.copyWith(color: theme.primaryColor)),
                    ),
                  ),
              //   ],
              // ),
              // const SizedBox(height: 16),

              _buildTextField(controller: _nameController, placeholder: 'Full Name', prefixIcon: CupertinoIcons.person, textInputAction: TextInputAction.next),
              const SizedBox(height: 12),
              _buildTextField(controller: _idNumberController, placeholder: 'ID Number (Optional)', prefixIcon: CupertinoIcons.number, keyboardType: TextInputType.number, textInputAction: TextInputAction.next),
              const SizedBox(height: 12),
              _buildTextField(controller: _phoneController, placeholder: 'Phone Number', prefixIcon: CupertinoIcons.phone, keyboardType: TextInputType.phone, textInputAction: TextInputAction.next),
              const SizedBox(height: 12),
              _buildTextField(controller: _emailController, placeholder: 'Email Address', prefixIcon: CupertinoIcons.mail, keyboardType: TextInputType.emailAddress, autocorrect: false, textInputAction: TextInputAction.next),
              const SizedBox(height: 12),
              _buildTextField(controller: _passwordController, placeholder: 'Password', prefixIcon: CupertinoIcons.lock_fill, textInputAction: TextInputAction.next, isPassword: true),
              const SizedBox(height: 12),
              _buildTextField(controller: _confirmPasswordController, placeholder: 'Confirm Password', prefixIcon: CupertinoIcons.lock_fill, textInputAction: TextInputAction.done, onSubmitted: (_) => _handleRegister(), isConfirmPassword: true),

              if (_selectedRole == 'ServiceProvider') ...[
                const SizedBox(height: 20),
                Text('Service Provider Details', style: theme.textTheme.navTitleTextStyle.copyWith(fontWeight: FontWeight.bold)), // Section title
                const SizedBox(height: 8),
                CupertinoListTile( // Using CupertinoListTile for tappable row
                  title: Text('Service Types (${_selectedServiceTypes.length} selected)', style: theme.textTheme.textStyle),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () async {
                    // Navigate to selection page and await result
                    final List<String>? result = await Navigator.of(context).push(
                      CupertinoPageRoute(builder: (context) => const CupertinoSelectServiceTypesPageStub()), // In real app, pass current selection
                    );
                    if (result != null) {
                      // setState(() => _selectedServiceTypes = result); // This would be for a real selection page
                    }
                    // For stub, we just navigate. If you want to test selection, modify the stub.
                    // For now, we show a CupertinoAlertDialog to indicate it's a stub.
                    if (mounted) { // Check mounted before showing dialog
                      showCupertinoDialog<void>(
                        context: context,
                        builder: (BuildContext context) => CupertinoAlertDialog(
                          title: const Text('Information'),
                          content: const Text('Service Type selection is a stub for now and will be implemented later.'),
                          actions: <CupertinoDialogAction>[
                            CupertinoDialogAction(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(controller: _spCountryController, placeholder: 'Country of Service', prefixIcon: CupertinoIcons.map_pin_ellipse, textInputAction: TextInputAction.next),
                const SizedBox(height: 12),
                _buildTextField(controller: _spCountyController, placeholder: 'County/State of Service', prefixIcon: CupertinoIcons.map_pin_ellipse, textInputAction: TextInputAction.next),
                const SizedBox(height: 12),
                _buildTextField(controller: _spSubCountyController, placeholder: 'Sub-County/City (Optional)', prefixIcon: CupertinoIcons.map_pin, textInputAction: TextInputAction.done, onSubmitted: (_) => _handleRegister()),
              ],

              const SizedBox(height: 20),
              CupertinoFormRow(
                prefix: const Text('Agree to Terms & Conditions'),
                child: CupertinoSwitch(
                  value: _agreedToTerms,
                  onChanged: (bool value) => setState(() => _agreedToTerms = value),
                  activeColor: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),

              if (_isLoading)
                const Center(child: CupertinoActivityIndicator(radius: 15))
              else
                CupertinoButton.filled(
                  onPressed: _handleRegister,
                  child: const Text('Create Account'),
                ),

              if (_errorMessage != null && _errorMessage!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Center(
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.caption1TextStyle.copyWith(color: CupertinoColors.destructiveRed, fontSize: 14), // Consistent error style
                    ),
                  ),
                ),

              const SizedBox(height: 16),
              CupertinoButton(
                onPressed: () {
                  Get.off(() => const LoginPage()); // Navigate back to Login router
                },
                child: const Text('Already have an account? Log In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
