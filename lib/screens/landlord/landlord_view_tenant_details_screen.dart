import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/tenant_payment_metrics_model.dart';
import 'package:cloudkeja/providers/tenant_analytics_provider.dart';
import 'package:cloudkeja/providers/auth_provider.dart'; // To fetch tenant name
import 'package:cloudkeja/models/user_model.dart'; // For UserModel
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';
// import 'package:get/route_manager.dart'; // Not used in this screen directly

// --- _PaymentLogRowTile Widget ---
class _PaymentLogRowTile extends StatelessWidget {
  final AnalyzedPaymentRecordVo record;

  const _PaymentLogRowTile({Key? key, required this.record}) : super(key: key);

  Color _getStatusColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status.toLowerCase()) {
      case 'early': return Colors.green.shade700;
      case 'on-time': return Colors.blue.shade600; // Using blue for on-time for visual distinction
      case 'late': return Colors.orange.shade800;
      case 'partial': return Colors.purple.shade400;
      case 'unpaid': return colorScheme.error; // Should not happen if only analyzing paid
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
                  label: Text(record.status, style: textTheme.labelSmall?.copyWith(color: Colors.white)),
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


class LandlordViewOfTenantDetailsScreen extends StatefulWidget {
  final String tenantId;
  final String? leaseId;

  const LandlordViewOfTenantDetailsScreen({
    Key? key,
    required this.tenantId,
    this.leaseId,
  }) : super(key: key);

  static const String routeName = '/landlord-view-tenant-details';

  @override
  State<LandlordViewOfTenantDetailsScreen> createState() => _LandlordViewOfTenantDetailsScreenState();
}

class _LandlordViewOfTenantDetailsScreenState extends State<LandlordViewOfTenantDetailsScreen> {
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
      _tenantInfo = await authProvider.getOwnerDetails(widget.tenantId); // Fetches user by ID

      final metrics = await Provider.of<TenantAnalyticsProvider>(context, listen: false)
          .calculateTenantPaymentMetrics(
              tenantId: widget.tenantId,
              leaseId: widget.leaseId,
              // forceRefresh: forceRefresh, // If provider supports it
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
          _metrics = null;
        });
      }
    }
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, {Color? valueColor}) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: valueColor ?? theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor ?? theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getSummaryColor(String summary) {
    switch (summary.toLowerCase()) {
      case 'excellent': return Colors.green.shade700;
      case 'good': return Colors.blue.shade600;
      case 'needs improvement': return Colors.orange.shade800;
      case 'poor': return Theme.of(context).colorScheme.error;
      default: return Theme.of(context).colorScheme.onSurface;
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
            Center(child: Container(height: 24, width: 200, color: Colors.transparent)), // Overall Summary
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2, childAspectRatio: 1.8, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12, mainAxisSpacing: 12,
              children: List.generate(4, (_) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [const Icon(Icons.circle, size: 24), const SizedBox(height:8), Container(height:20, color:Colors.transparent), const SizedBox(height:4), Container(height:10, width:80, color:Colors.transparent)])))),
            ),
            const SizedBox(height: 16),
            ExpansionTile(title: Text('Detailed Payment Log', style: textTheme.titleMedium), children: [ListView.builder(itemCount:3, shrinkWrap:true, physics: const NeverScrollableScrollPhysics(), itemBuilder: (ctx, i) => _PaymentLogRowTile(record: AnalyzedPaymentRecordVo(originalPaymentId: 'skel', paymentCycle: 'Loading...', dueDate: DateTime.now(), paymentDate: DateTime.now(), amountDue: 0, amountPaid: 0, status: 'Loading', daysDifference: 0)))])
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
              Text('Payment metrics for this tenant could not be calculated or there are no payments.', textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.6))),
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
                color: _getSummaryColor(metrics.overallSummary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2, // Responsive columns
            childAspectRatio: 1.8, // Adjust for content
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildStatCard(context, 'On-Time %', '${metrics.onTimePaymentPercentage.toStringAsFixed(1)}%', Icons.thumb_up_alt_outlined, valueColor: Colors.green.shade700),
              _buildStatCard(context, 'Late Payments', metrics.latePayments.toString(), Icons.running_with_errors_outlined, valueColor: metrics.latePayments > 0 ? Colors.orange.shade800 : colorScheme.onSurface),
              _buildStatCard(context, 'Avg. Days Late', metrics.averageDaysLate.toStringAsFixed(1), Icons.history_toggle_off_outlined),
              _buildStatCard(context, 'Early Payments', metrics.earlyPayments.toString(), Icons.verified_outlined),
              _buildStatCard(context, 'On-Time Streak', '${metrics.currentConsecutiveOnTimeStreak} (Max: ${metrics.longestConsecutiveOnTimeStreak})', Icons.trending_up_rounded),
              _buildStatCard(context, 'Late Streak', '${metrics.currentConsecutiveLateStreak} (Max: ${metrics.longestConsecutiveLateStreak})', Icons.trending_down_rounded),
            ],
          ),
          const SizedBox(height: 16),
          Theme( // Ensure ExpansionTile uses themed expand/collapse icon color
            data: theme.copyWith(dividerColor: Colors.transparent), // Remove default divider from ExpansionTile
            child: ExpansionTile(
              key: PageStorageKey<String>('paymentLogExpansionTile'), // Maintain expansion state
              title: Text('Detailed Payment Log', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              initiallyExpanded: false,
              childrenPadding: const EdgeInsets.only(top: 0, bottom: 8),
              tilePadding: const EdgeInsets.symmetric(horizontal: 0), // Adjust if Card used inside
              children: metrics.analyzedRecords.isEmpty
                  ? [Padding(padding: const EdgeInsets.all(16.0), child: Text('No detailed records for this period.', style: textTheme.bodyMedium))]
                  : metrics.analyzedRecords.map((record) => _PaymentLogRowTile(record: record)).toList(),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(_tenantInfo?.name ?? 'Tenant Performance'),
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchTenantData(forceRefresh: true),
        child: content,
      ),
    );
  }
}
