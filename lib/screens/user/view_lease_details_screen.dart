import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/lease_model.dart';
import 'package:cloudkeja/providers/tenancy_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:get/route_manager.dart'; // For Get.to() if used for navigation from here

class ViewLeaseDetailsScreen extends StatefulWidget {
  const ViewLeaseDetailsScreen({Key? key}) : super(key: key);

  static const String routeName = '/view-lease-details';

  @override
  State<ViewLeaseDetailsScreen> createState() => _ViewLeaseDetailsScreenState();
}

class _ViewLeaseDetailsScreenState extends State<ViewLeaseDetailsScreen> {
  LeaseModel? _leaseModel;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isDownloading = false; // For download button loading state

  @override
  void initState() {
    super.initState();
    _fetchLeaseDetails();
  }

  Future<void> _fetchLeaseDetails({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final lease = await Provider.of<TenancyProvider>(context, listen: false)
          .fetchActiveLeaseForCurrentUser(forceRefresh: forceRefresh);
      if (mounted) {
        setState(() {
          _leaseModel = lease;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load lease details: ${e.toString()}';
          _leaseModel = null; // Ensure no old data is shown
        });
      }
    }
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String? value, {bool isLink = false, VoidCallback? onLinkTap}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6))),
                const SizedBox(height: 2),
                isLink && value != null
                  ? InkWell(
                      onTap: onLinkTap,
                      child: Text(
                        value,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.secondary, // Use secondary for links
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                  : Text(
                      value ?? 'Not specified',
                      style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _downloadLeaseDocument() async {
    if (_leaseModel?.leaseDocumentUrl == null || _leaseModel!.leaseDocumentUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No lease document URL available.', style: TextStyle(color: Theme.of(context).colorScheme.onError)), backgroundColor: Theme.of(context).colorScheme.error),
      );
      return;
    }

    setState(() => _isDownloading = true);
    try {
      final Uri url = Uri.parse(_leaseModel!.leaseDocumentUrl!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication); // Open in browser or PDF viewer
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening document: ${e.toString()}', style: TextStyle(color: Theme.of(context).colorScheme.onError)), backgroundColor: Theme.of(context).colorScheme.error),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    Widget content;

    if (_isLoading) {
      content = Skeletonizer(
        enabled: true,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionTitle(context, 'Property Information'),
            _buildDetailRow(context, Icons.location_city_outlined, 'Property Address', LeaseModel.empty().propertyAddress),
            _buildDetailRow(context, Icons.apartment_outlined, 'Unit Identifier', LeaseModel.empty().unitIdentifier),
            _buildSectionTitle(context, 'Landlord Information'),
            _buildDetailRow(context, Icons.person_outline_rounded, 'Landlord Name', LeaseModel.empty().landlordName),
            _buildDetailRow(context, Icons.contact_phone_outlined, 'Landlord Contact', LeaseModel.empty().landlordContact),
            _buildSectionTitle(context, 'Lease Term'),
            _buildDetailRow(context, Icons.date_range_outlined, 'Start Date', 'Loading...'),
            _buildDetailRow(context, Icons.event_busy_outlined, 'End Date', 'Loading...'),
            _buildSectionTitle(context, 'Financials'),
            _buildDetailRow(context, Icons.monetization_on_outlined, 'Rent Amount', 'KES 0.00'),
            _buildDetailRow(context, Icons.calendar_today_outlined, 'Rent Due Date', LeaseModel.empty().rentDueDate),
            _buildDetailRow(context, Icons.shield_outlined, 'Security Deposit', 'KES 0.00'),
            const SizedBox(height: 24),
            ElevatedButton.icon(icon: const Icon(Icons.download_for_offline_outlined), label: const Text('Download Lease Agreement'), onPressed: null),
          ],
        ),
      );
    } else if (_errorMessage != null) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_errorMessage!, style: textTheme.bodyLarge?.copyWith(color: colorScheme.error), textAlign: TextAlign.center),
        ),
      );
    } else if (_leaseModel == null) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.find_in_page_outlined, size: 80, color: colorScheme.primary.withOpacity(0.3)),
              const SizedBox(height: 20),
              Text(
                'No Active Lease Agreement',
                style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.8)),
              ),
              const SizedBox(height: 8),
              Text(
                'Your active lease details will appear here once available.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
              ),
            ],
          ),
        ),
      );
    } else {
      final lease = _leaseModel!;
      content = ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle(context, 'Property Information'),
          _buildDetailRow(context, Icons.location_city_outlined, 'Property Address', lease.propertyAddress),
          if (lease.unitIdentifier != null && lease.unitIdentifier!.isNotEmpty)
            _buildDetailRow(context, Icons.apartment_outlined, 'Unit Identifier', lease.unitIdentifier),

          _buildSectionTitle(context, 'Landlord Information'),
          _buildDetailRow(context, Icons.person_outline_rounded, 'Landlord Name', lease.landlordName),
          if (lease.landlordContact != null && lease.landlordContact!.isNotEmpty)
            _buildDetailRow(context, Icons.contact_phone_outlined, 'Landlord Contact', lease.landlordContact),

          _buildSectionTitle(context, 'Lease Term'),
          _buildDetailRow(context, Icons.date_range_outlined, 'Start Date', DateFormat.yMMMd().format(lease.leaseStartDate.toDate())),
          _buildDetailRow(context, Icons.event_busy_outlined, 'End Date', DateFormat.yMMMd().format(lease.leaseEndDate.toDate())),

          _buildSectionTitle(context, 'Financials'),
          _buildDetailRow(context, Icons.monetization_on_outlined, 'Rent Amount', '${lease.currency} ${lease.rentAmount.toStringAsFixed(2)}'),
          _buildDetailRow(context, Icons.calendar_today_outlined, 'Rent Due Date', lease.rentDueDate),
          if (lease.securityDepositAmount != null && lease.securityDepositAmount! > 0)
            _buildDetailRow(context, Icons.shield_outlined, 'Security Deposit', '${lease.currency} ${lease.securityDepositAmount!.toStringAsFixed(2)}'),

          const SizedBox(height: 32),
          if (lease.leaseDocumentUrl != null && lease.leaseDocumentUrl!.isNotEmpty)
            ElevatedButton.icon(
              icon: _isDownloading
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary))
                  : const Icon(Icons.download_for_offline_outlined),
              label: Text(_isDownloading ? 'Downloading...' : 'Download Lease Agreement'),
              onPressed: _isDownloading ? null : _downloadLeaseDocument,
              style: theme.elevatedButtonTheme.style?.copyWith(
                minimumSize: MaterialStateProperty.all(const Size(double.infinity, 48)),
              ),
            )
          else
             _buildDetailRow(context, Icons.description_outlined, 'Lease Document', 'Not available'),

        ],
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('My Lease Agreement'),
        // AppBar uses AppBarTheme from AppTheme
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchLeaseDetails(forceRefresh: true),
        child: content,
      ),
    );
  }
}
