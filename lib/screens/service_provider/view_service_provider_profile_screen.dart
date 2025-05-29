import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:skeletonizer/skeletonizer.dart'; // For loading state
import 'package:cloudkeja/screens/chat/chat_room.dart'; // For navigation
import 'package:get/route_manager.dart'; // For navigation
import 'package:cached_network_image/cached_network_image.dart'; // For profile picture
import 'package:url_launcher/url_launcher.dart'; // For phone calls

class ViewServiceProviderProfileScreen extends StatefulWidget {
  final String serviceProviderId;

  const ViewServiceProviderProfileScreen({
    Key? key,
    required this.serviceProviderId,
  }) : super(key: key);

  static const String routeName = '/view-service-provider-profile';

  @override
  State<ViewServiceProviderProfileScreen> createState() => _ViewServiceProviderProfileScreenState();
}

class _ViewServiceProviderProfileScreenState extends State<ViewServiceProviderProfileScreen> {
  UserModel? _serviceProvider;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchServiceProviderDetails();
  }

  Future<void> _fetchServiceProviderDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final user = await Provider.of<AuthProvider>(context, listen: false)
          .getOwnerDetails(widget.serviceProviderId); // Fetches any user by ID
      
      if (mounted) {
        setState(() {
          _serviceProvider = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load service provider details: ${e.toString()}';
        });
      }
    }
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String? value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                const SizedBox(height: 2),
                Text(value ?? 'Not specified', style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipsSection(BuildContext context, String title, List<String>? items) {
    final theme = Theme.of(context);
    if (items == null || items.isEmpty) {
      return _buildDetailRow(context, Icons.work_outline_rounded, title, 'Not specified');
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                title == 'Services Offered' ? Icons.construction_outlined : Icons.map_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(title, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 6.0,
            children: items.map((item) => Chip(
              label: Text(item),
              // Chip styling from ChipThemeData
            )).toList(),
          ),
        ],
      ),
    );
  }
  
  void _initiateChat() async {
    final theme = Theme.of(context); // For SnackBar theming
    final colorScheme = theme.colorScheme;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Please log in to chat.', style: TextStyle(color: colorScheme.onError)), backgroundColor: colorScheme.error),
      );
      return;
    }

    if (_serviceProvider == null || _serviceProvider!.userId == null) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Service provider details are unavailable.', style: TextStyle(color: colorScheme.onError)), backgroundColor: colorScheme.error),
      );
      return;
    }

    if (currentUser.userId == _serviceProvider!.userId) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('You cannot chat with yourself.', style: TextStyle(color: colorScheme.onError)), backgroundColor: colorScheme.error),
      );
      return;
    }

    String chatRoomId;
    if (currentUser.userId!.compareTo(_serviceProvider!.userId!) > 0) {
      chatRoomId = '${currentUser.userId}_${_serviceProvider!.userId}';
    } else {
      chatRoomId = '${_serviceProvider!.userId}_${currentUser.userId}';
    }
    
    // Navigate to ChatRoom
    // Using Get.to for consistency if used elsewhere for navigation to ChatRoom
    Get.to(() => ChatRoom(), arguments: {
      'user': _serviceProvider!, // The Service Provider's UserModel
      'chatRoomId': chatRoomId,
    });
    // Alternatively, using Navigator:
    // Navigator.of(context).pushNamed(ChatRoom.routeName, arguments: {
    //   'user': _serviceProvider!,
    //   'chatRoomId': chatRoomId,
    // });
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(title: const Text('Loading Profile...')),
        // Basic Skeleton for the profile page
        body: Skeletonizer(
          enabled: true,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const CircleAvatar(radius: 50),
              const SizedBox(height: 16),
              Container(height: 24, width: 200, color: Colors.transparent), // Name
              const SizedBox(height: 8),
              Container(height: 16, width: 250, color: Colors.transparent), // Email
              const SizedBox(height: 8),
              Container(height: 16, width: 150, color: Colors.transparent), // Phone
              const SizedBox(height: 24),
              Container(height: 18, width: 100, color: Colors.transparent), // Section title
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: List.generate(3, (_) => const Chip(label: Text('          ')))), // Chips
              const SizedBox(height: 16),
              Container(height: 18, width: 100, color: Colors.transparent), // Section title
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: List.generate(2, (_) => const Chip(label: Text('          ')))), // Chips
              const SizedBox(height: 24),
              Container(height: 48, color: Colors.transparent), // Button
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(_errorMessage!, style: textTheme.bodyLarge?.copyWith(color: colorScheme.error), textAlign: TextAlign.center),
          ),
        ),
      );
    }

    if (_serviceProvider == null) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(title: const Text('Profile Not Found')),
        body: Center(
          child: Text('Service provider profile could not be loaded.', style: textTheme.bodyLarge),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(_serviceProvider!.name ?? 'Service Provider'),
        // AppBar uses AppBarTheme
      ),
      body: RefreshIndicator( // Added RefreshIndicator
        onRefresh: _fetchServiceProviderDetails,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: colorScheme.surfaceVariant,
                backgroundImage: (_serviceProvider!.profile != null && _serviceProvider!.profile!.isNotEmpty)
                    ? CachedNetworkImageProvider(_serviceProvider!.profile!)
                    : null,
                child: (_serviceProvider!.profile == null || _serviceProvider!.profile!.isEmpty)
                    ? Icon(Icons.person_outline_rounded, size: 50, color: colorScheme.onSurfaceVariant)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                _serviceProvider!.name ?? 'N/A',
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _serviceProvider!.isVerified == true ? 'Verified Provider' : 'Verification Pending',
                    style: textTheme.bodyMedium?.copyWith(
                      color: _serviceProvider!.isVerified == true 
                          ? Colors.green.shade700 
                          : colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                     _serviceProvider!.isVerified == true ? Icons.verified_user_rounded : Icons.hourglass_top_rounded,
                     size: 16,
                     color: _serviceProvider!.isVerified == true 
                          ? Colors.green.shade700 
                          : colorScheme.onSurface.withOpacity(0.7),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Divider(color: colorScheme.outline.withOpacity(0.5)),
            const SizedBox(height: 16),

            _buildDetailRow(context, Icons.email_outlined, 'Email', _serviceProvider!.email),
            _buildDetailRow(context, Icons.phone_outlined, 'Phone', _serviceProvider!.phone),
            
            const SizedBox(height: 16),
            _buildChipsSection(context, 'Services Offered', _serviceProvider!.servicesOffered),
            const SizedBox(height: 16),
            _buildChipsSection(context, 'Service Areas', _serviceProvider!.serviceAreas),
            
            // TODO: Display certifications if links are valid and clickable
            // TODO: Display availability if structured and meaningful

            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: Text('Chat with ${_serviceProvider!.name?.split(" ").first ?? "Provider"}'),
              onPressed: _initiateChat,
              // Style from ElevatedButtonThemeData
              style: theme.elevatedButtonTheme.style?.copyWith(
                minimumSize: MaterialStateProperty.all(const Size(double.infinity, 48)),
              ),
            ),
             const SizedBox(height: 12),
             if (_serviceProvider!.phone != null && _serviceProvider!.phone!.isNotEmpty)
              OutlinedButton.icon(
                icon: const Icon(Icons.call_outlined),
                label: Text('Call ${_serviceProvider!.name?.split(" ").first ?? "Provider"}'),
                onPressed: () async {
                  final Uri launchUri = Uri(scheme: 'tel', path: _serviceProvider!.phone!);
                  if (await canLaunchUrl(launchUri)) {
                    await launchUrl(launchUri);
                  } else {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text('Could not make phone call to ${_serviceProvider!.phone}.', style: TextStyle(color: colorScheme.onError)), backgroundColor: colorScheme.error),
                    );
                  }
                },
                style: theme.outlinedButtonTheme.style?.copyWith(
                   minimumSize: MaterialStateProperty.all(const Size(double.infinity, 48)),
                )
              ),
          ],
        ),
      ),
    );
  }
}
