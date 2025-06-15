import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/tenant_payment_metrics_model.dart';
import 'package:cloudkeja/providers/tenant_analytics_provider.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:intl/intl.dart'; // For date formatting

// Renamed helper widget for Cupertino
class _PaymentLogRowTileCupertino extends StatelessWidget {
  final AnalyzedPaymentRecordVo record;

  const _PaymentLogRowTileCupertino({Key? key, required this.record}) : super(key: key);

  Color _getStatusColor(BuildContext context, String status) {
    // Using Cupertino standard colors
    switch (status.toLowerCase()) {
      case 'early': return CupertinoColors.systemGreen.resolveFrom(context);
      case 'on-time': return CupertinoColors.systemBlue.resolveFrom(context);
      case 'late': return CupertinoColors.systemOrange.resolveFrom(context);
      case 'partial': return CupertinoColors.systemPurple.resolveFrom(context);
      case 'unpaid': return CupertinoColors.systemRed.resolveFrom(context);
      default: return CupertinoColors.secondaryLabel.resolveFrom(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    final statusColor = _getStatusColor(context, record.status);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: CupertinoColors.separator.resolveFrom(context), width: 0.5))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(record.paymentCycle, style: cupertinoTheme.textTheme.textStyle.copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  record.status,
                  style: cupertinoTheme.textTheme.caption1.copyWith(color: statusColor, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text('Due: ${DateFormat.yMd().format(record.dueDate)}', style: cupertinoTheme.textTheme.tabLabelTextStyle)),
              Expanded(child: Text('Paid: ${DateFormat.yMd().format(record.paymentDate)}', style: cupertinoTheme.textTheme.tabLabelTextStyle)),
            ],
          ),
          const SizedBox(height: 4),
           Row(
            children: [
              Expanded(child: Text('Amount Due: KES ${record.amountDue.toStringAsFixed(0)}', style: cupertinoTheme.textTheme.tabLabelTextStyle)),
              Expanded(child: Text('Amount Paid: KES ${record.amountPaid.toStringAsFixed(0)}', style: cupertinoTheme.textTheme.tabLabelTextStyle)),
            ],
          ),
          if (record.status.toLowerCase() == 'late')
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '${record.daysDifference.abs()} day(s) late',
                style: cupertinoTheme.textTheme.caption1.copyWith(color: statusColor, fontWeight: FontWeight.w500),
              ),
            )
          else if (record.status.toLowerCase() == 'early')
           Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '${record.daysDifference} day(s) early',
                style: cupertinoTheme.textTheme.caption1.copyWith(color: statusColor, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }
}


class LandlordViewOfTenantDetailsScreenCupertino extends StatefulWidget {
  final String tenantId;
  final String? leaseId;

  const LandlordViewOfTenantDetailsScreenCupertino({
    Key? key,
    required this.tenantId,
    this.leaseId,
  }) : super(key: key);

  @override
  State<LandlordViewOfTenantDetailsScreenCupertino> createState() => _LandlordViewOfTenantDetailsScreenCupertinoState();
}

class _LandlordViewOfTenantDetailsScreenCupertinoState extends State<LandlordViewOfTenantDetailsScreenCupertino> {
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
      _tenantInfo = await authProvider.getOwnerDetails(widget.tenantId);

      final metrics = await Provider.of<TenantAnalyticsProvider>(context, listen: false)
          .calculateTenantPaymentMetrics(
              tenantId: widget.tenantId,
              leaseId: widget.leaseId,
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

  Widget _buildCupertinoStatItem(BuildContext context, String label, String value, IconData icon, {Color? valueColor}) {
    final cupertinoTheme = CupertinoTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: cupertinoTheme.barBackgroundColor.withOpacity(0.5), // Subtle background
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26, color: valueColor ?? cupertinoTheme.primaryColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(
              fontSize: 18, // Adjusted for prominence
              fontWeight: FontWeight.bold,
              color: valueColor ?? cupertinoTheme.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(fontSize: 11), // Smaller label
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getSummaryColorCupertino(BuildContext context, String summary) {
    // Using Cupertino standard colors
    switch (summary.toLowerCase()) {
      case 'excellent': return CupertinoColors.systemGreen.resolveFrom(context);
      case 'good': return CupertinoColors.systemBlue.resolveFrom(context);
      case 'needs improvement': return CupertinoColors.systemOrange.resolveFrom(context);
      case 'poor': return CupertinoColors.systemRed.resolveFrom(context);
      default: return CupertinoColors.label.resolveFrom(context);
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final cupertinoTheme = CupertinoTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 16.0, top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(
          fontSize: 18,
          color: CupertinoColors.label.resolveFrom(context),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_tenantInfo?.name ?? 'Tenant Performance'),
      ),
      child: CustomScrollView(
        slivers: [
          CupertinoSliverRefreshControl(onRefresh: () => _fetchTenantData(forceRefresh: true)),
          if (_isLoading)
            const SliverFillRemaining(child: Center(child: CupertinoActivityIndicator(radius: 15))),
          if (!_isLoading && _errorMessage != null)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(_errorMessage!, style: TextStyle(color: CupertinoColors.destructiveRed.resolveFrom(context)), textAlign: TextAlign.center),
                ),
              ),
            ),
          if (!_isLoading && _errorMessage == null && (_metrics == null || _metrics!.totalPaymentsAnalyzed == 0))
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.doc_chart, size: 70, color: CupertinoColors.systemGrey2.resolveFrom(context)),
                      const SizedBox(height: 20),
                      Text('No Payment Data Available', style: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('Metrics could not be calculated or no payments found.', textAlign: TextAlign.center, style: cupertinoTheme.textTheme.tabLabelTextStyle),
                    ],
                  ),
                ),
              ),
            ),
          if (!_isLoading && _errorMessage == null && _metrics != null && _metrics!.totalPaymentsAnalyzed > 0) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    'Overall: ${_metrics!.overallSummary}',
                    style: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getSummaryColorCupertino(context, _metrics!.overallSummary),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                  childAspectRatio: 1.5, // Adjusted for content
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildListDelegate([
                  _buildCupertinoStatItem(context, 'On-Time %', '${_metrics!.onTimePaymentPercentage.toStringAsFixed(1)}%', CupertinoIcons.hand_thumbsup_fill, valueColor: CupertinoColors.systemGreen.resolveFrom(context)),
                  _buildCupertinoStatItem(context, 'Late Payments', _metrics!.latePayments.toString(), CupertinoIcons.clock_fill, valueColor: _metrics!.latePayments > 0 ? CupertinoColors.systemOrange.resolveFrom(context) : CupertinoColors.label.resolveFrom(context)),
                  _buildCupertinoStatItem(context, 'Avg. Days Late', _metrics!.averageDaysLate.toStringAsFixed(1), CupertinoIcons.timer_fill),
                  _buildCupertinoStatItem(context, 'Early Payments', _metrics!.earlyPayments.toString(), CupertinoIcons.check_mark_circled_solid, valueColor: CupertinoColors.systemBlue.resolveFrom(context)),
                  _buildCupertinoStatItem(context, 'On-Time Streak', '${_metrics!.currentConsecutiveOnTimeStreak} (Max: ${_metrics!.longestConsecutiveOnTimeStreak})', CupertinoIcons.flame_fill),
                  _buildCupertinoStatItem(context, 'Late Streak', '${_metrics!.currentConsecutiveLateStreak} (Max: ${_metrics!.longestConsecutiveLateStreak})', CupertinoIcons.tortoise_fill),
                ]),
              ),
            ),
            SliverToBoxAdapter(child: _buildSectionHeader(context, 'Detailed Payment Log')),
            if (_metrics!.analyzedRecords.isEmpty)
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(20.0), child: Center(child: Text('No detailed records.', style: cupertinoTheme.textTheme.tabLabelTextStyle))))
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _PaymentLogRowTileCupertino(record: _metrics!.analyzedRecords[index]),
                  childCount: _metrics!.analyzedRecords.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)), // Bottom padding
          ],
        ],
      ),
    );
  }
}
