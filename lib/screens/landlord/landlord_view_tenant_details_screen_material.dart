import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/tenant_payment_metrics_model.dart';
import 'package:cloudkeja/providers/tenant_analytics_provider.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';

// Renamed helper widget
class _PaymentLogRowTileMaterial extends StatelessWidget {
  final AnalyzedPaymentRecordVo record;

  const _PaymentLogRowTileMaterial({Key? key, required this.record}) : super(key: key);

  Color _getStatusColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    // Using more theme-aware colors or specific shades for clarity
    switch (status.toLowerCase()) {
      case 'early': return Colors.green.shade600; // Keep distinct green for positive
      case 'on-time': return colorScheme.primary; // Primary for neutral good
      case 'late': return Colors.orange.shade700; // Keep distinct orange for warning
      case 'partial': return Colors.purple.shade500; // Keep distinct purple
      case 'unpaid': return colorScheme.error;
      default: return colorScheme.onSurface.withOpacity(0.7);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final statusColor = _getStatusColor(context, record.status);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colorScheme.outline.withOpacity(0.3), width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(record.paymentCycle, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                Chip(
                  label: Text(record.status, style: textTheme.labelSmall?.copyWith(color: ThemeData.estimateBrightnessForColor(statusColor) == Brightness.dark ? Colors.white : Colors.black87 )),
                  backgroundColor: statusColor,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  visualDensity: VisualDensity.compact,
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(child: Text('Due: ${DateFormat.yMd().format(record.dueDate)}', style: textTheme.bodySmall)),
                Expanded(child: Text('Paid: ${DateFormat.yMd().format(record.paymentDate)}', style: textTheme.bodySmall)),
              ],
            ),
            const SizedBox(height: 4),
             Row(
              children: [
                Expanded(child: Text('Amount Due: KES ${record.amountDue.toStringAsFixed(0)}', style: textTheme.bodySmall)),
                Expanded(child: Text('Amount Paid: KES ${record.amountPaid.toStringAsFixed(0)}', style: textTheme.bodySmall)),
              ],
            ),
            if (record.status.toLowerCase() == 'late')
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '${record.daysDifference.abs()} day(s) late',
                  style: textTheme.bodySmall?.copyWith(color: statusColor, fontWeight: FontWeight.w500),
                ),
              )
            else if (record.status.toLowerCase() == 'early')
             Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '${record.daysDifference} day(s) early',
                  style: textTheme.bodySmall?.copyWith(color: statusColor, fontWeight: FontWeight.w500),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Renamed main widget
class LandlordViewOfTenantDetailsScreenMaterial extends StatefulWidget {
  final String tenantId;
  final String? leaseId;

  const LandlordViewOfTenantDetailsScreenMaterial({
    Key? key,
    required this.tenantId,
    this.leaseId,
  }) : super(key: key);

  // static const String routeName = '/landlord-view-tenant-details'; // Keep in router if needed

  @override
  State<LandlordViewOfTenantDetailsScreenMaterial> createState() => _LandlordViewOfTenantDetailsScreenMaterialState();
}

class _LandlordViewOfTenantDetailsScreenMaterialState extends State<LandlordViewOfTenantDetailsScreenMaterial> {
  TenantPaymentMetrics? _metrics;
  UserModel? _tenantInfo;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTenantData();
  }

  Future<void> _fetchTenantData({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Assuming getOwnerDetails can fetch any user by ID, including tenants
      _tenantInfo = await authProvider.getOwnerDetails(widget.tenantId);

      final metrics = await Provider.of<TenantAnalyticsProvider>(context, listen: false)
          .calculateTenantPaymentMetrics(
              tenantId: widget.tenantId,
              leaseId: widget.leaseId,
              // forceRefresh: forceRefresh, // Pass if provider supports it
            );

      if (mounted) {
        setState(() {
          _metrics = metrics;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load tenant details: ${e.toString()}';
          _metrics = null; // Clear metrics on error
        });
      }
    }
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, {Color? valueColor}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)), // Consistent rounding
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: valueColor ?? colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor ?? colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getSummaryColor(BuildContext context, String summary) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Using more theme-aware colors or specific shades for clarity
    switch (summary.toLowerCase()) {
      case 'excellent': return Colors.green.shade600;
      case 'good': return colorScheme.primary; // Or Colors.blue.shade600
      case 'needs improvement': return Colors.orange.shade700;
      case 'poor': return colorScheme.error;
      default: return colorScheme.onSurface;
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    Widget content;

    if (_isLoading) {
      content = Skeletonizer( // Standard Material skeletonizer usage
        enabled: true,
         effect: ShimmerEffect( // Ensure ShimmerEffect is themed or uses defaults
            baseColor: colorScheme.surfaceVariant.withOpacity(0.4),
            highlightColor: colorScheme.surfaceVariant.withOpacity(0.8),
          ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Center(child: Container(height: 24, width: 200, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)))), // Placeholder for Overall Summary
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2, childAspectRatio: 1.8, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12, mainAxisSpacing: 12,
              children: List.generate(4, (_) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [const Icon(Icons.circle, size: 24), const SizedBox(height:8), Container(height:20, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4))), const SizedBox(height:4), Container(height:10, width:80, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)))])))),
            ),
            const SizedBox(height: 16),
            // Placeholder for ExpansionTile
            Container(height: 50, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 8),
            Container(height: 100, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)))
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
    } else if (_metrics == null || _metrics!.totalPaymentsAnalyzed == 0) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assessment_outlined, size: 80, color: colorScheme.primary.withOpacity(0.3)),
              const SizedBox(height: 20),
              Text('No Payment Data Available', style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.8))),
              const SizedBox(height: 8),
              Text('Payment metrics for this tenant could not be calculated or there are no payments.', textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      );
    } else {
      final metrics = _metrics!;
      content = ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: Text(
              'Overall: ${metrics.overallSummary}',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getSummaryColor(context, metrics.overallSummary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
            childAspectRatio: 1.8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildStatCard(context, 'On-Time %', '${metrics.onTimePaymentPercentage.toStringAsFixed(1)}%', Icons.thumb_up_alt_outlined, valueColor: Colors.green.shade700),
              _buildStatCard(context, 'Late Payments', metrics.latePayments.toString(), Icons.running_with_errors_outlined, valueColor: metrics.latePayments > 0 ? Colors.orange.shade700 : colorScheme.onSurface),
              _buildStatCard(context, 'Avg. Days Late', metrics.averageDaysLate.toStringAsFixed(1), Icons.history_toggle_off_outlined),
              _buildStatCard(context, 'Early Payments', metrics.earlyPayments.toString(), Icons.verified_outlined, valueColor: Colors.blue.shade600), // Example different color
              _buildStatCard(context, 'On-Time Streak', '${metrics.currentConsecutiveOnTimeStreak} (Max: ${metrics.longestConsecutiveOnTimeStreak})', Icons.trending_up_rounded),
              _buildStatCard(context, 'Late Streak', '${metrics.currentConsecutiveLateStreak} (Max: ${metrics.longestConsecutiveLateStreak})', Icons.trending_down_rounded),
            ],
          ),
          const SizedBox(height: 16),
          Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              key: const PageStorageKey<String>('paymentLogExpansionTileMaterial'),
              title: Text('Detailed Payment Log', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              initiallyExpanded: false,
              childrenPadding: const EdgeInsets.only(top: 0, bottom: 8),
              tilePadding: EdgeInsets.zero, // Removed default padding
              children: metrics.analyzedRecords.isEmpty
                  ? [Padding(padding: const EdgeInsets.all(16.0), child: Text('No detailed records for this period.', style: textTheme.bodyMedium))]
                  : metrics.analyzedRecords.map((record) => _PaymentLogRowTileMaterial(record: record)).toList(),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(_tenantInfo?.name ?? 'Tenant Performance', style: theme.appBarTheme.titleTextStyle ?? textTheme.titleLarge), // Themed title
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchTenantData(forceRefresh: true),
        child: content,
      ),
    );
  }
}
