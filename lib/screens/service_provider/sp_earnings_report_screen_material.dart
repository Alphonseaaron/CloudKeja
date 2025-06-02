import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:cloudkeja/models/sp_job_model.dart';
import 'package:cloudkeja/widgets/tiles/sp_earning_item_tile.dart';
import 'package:cloudkeja/providers/job_provider.dart';
import 'package:cloudkeja/screens/service_provider/sp_earnings_report_controller.dart';
import 'package:cloudkeja/screens/service_provider/widgets/sp_earnings_fl_chart.dart';

class SPEarningsReportScreenMaterial extends StatefulWidget {
  const SPEarningsReportScreenMaterial({Key? key}) : super(key: key);

  @override
  State<SPEarningsReportScreenMaterial> createState() => _SPEarningsReportScreenMaterialState();
}

class _SPEarningsReportScreenMaterialState extends State<SPEarningsReportScreenMaterial> {
  late SPEarningsReportController _controller;

  @override
  void initState() {
    super.initState();
    // Assuming JobProvider is available via context.read or passed differently if not using Provider for controller creation.
    // For simplicity here, directly instantiating. If JobProvider is from Provider, adjust accordingly.
    _controller = SPEarningsReportController(jobProvider: Provider.of<JobProvider>(context, listen: false));
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {}); // Trigger rebuild when controller notifies changes
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectCustomDateRange() async {
    final theme = Theme.of(context);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime.now(),
      initialDateRange: _controller.selectedDateFilter ?? DateTimeRange(start: DateTime.now().subtract(const Duration(days: 7)), end: DateTime.now()),
      builder: (context, child) => Theme(data: theme, child: child!), // Apply app theme to picker
    );

    if (picked != null) {
      final newLabel = '${DateFormat.yMd().format(picked.start)} - ${DateFormat.yMd().format(picked.end)}';
      _controller.setCustomDateRange(picked, newLabel);
    }
  }

  Future<void> _downloadPdfReport() async {
    // Get current user for the report
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUserData;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not available. Cannot generate report.")),
        );
      }
      return;
    }

    final file = await _controller.generateAndOpenPdfReport(currentUser);
    
    if (mounted && _controller.pdfGenerationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("PDF Generation Error: ${_controller.pdfGenerationError!}"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } else if (mounted && file != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF Report generated and opened: ${file.path}")),
      );
    }
    // If file is null and no error, it might mean no data, which is handled by controller state _pdfGenerationError.
  }
  
  Widget _buildSummaryCard(BuildContext context, String title, String value, IconData icon, Color iconColor) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: iconColor.withOpacity(0.9)),
            const SizedBox(height: 8),
            Text(title, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(_controller.isLoading && value.contains("0.00") ? "..." : value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: iconColor), textAlign: TextAlign.center),
          ],
        ),
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
        title: const Text('Earnings Report'),
        actions: [
          _controller.isGeneratingPdf 
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
              )
            : IconButton(
                icon: const Icon(Icons.download_for_offline_outlined),
                tooltip: 'Download Earnings PDF',
                onPressed: (_controller.earningsJobs.isEmpty && !_controller.isLoading) ? null : _downloadPdfReport,
              ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _controller.fetchEarningsData(forceRefresh: true),
        child: Column(
          children: [
            // Date Filter Chips
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              color: colorScheme.surfaceContainerLowest,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    ..._controller.dateFilterOptions.entries.map((entry) {
                      final bool isSelected = _controller.activeDateFilterLabel == entry.key;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(entry.key),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              _controller.setDateFilter(entry.key, entry.value);
                            }
                          },
                        ),
                      );
                    }).toList(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ActionChip(
                        avatar: const Icon(Icons.calendar_month_outlined, size: 18),
                        label: Text(_controller.activeDateFilterLabel == 'Custom' || !_controller.dateFilterOptions.containsKey(_controller.activeDateFilterLabel) 
                                    ? _controller.activeDateFilterLabel 
                                    : 'Custom Range'),
                        onPressed: _selectCustomDateRange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, thickness: 1, color: theme.dividerColor),

            // Summary Section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Skeletonizer.zone(
                enabled: _controller.isLoading,
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: MediaQuery.of(context).size.width > 600 ? 1.7 : 1.45,
                  children: [
                    _buildSummaryCard(context, 'Total Earnings', 'KES ${_controller.totalEarnings.toStringAsFixed(2)}', Icons.account_balance_wallet_outlined, Colors.green.shade700),
                    _buildSummaryCard(context, 'Jobs Accounted', _controller.jobsPaidCount.toString(), Icons.check_circle_outline_rounded, colorScheme.primary),
                    _buildSummaryCard(context, 'Avg. Earning/Job', 'KES ${_controller.avgEarningPerJob.toStringAsFixed(2)}', Icons.pie_chart_outline_rounded, Colors.orange.shade700),
                  ],
                ),
              ),
            ),

            // Chart Section
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Monthly Earnings Trend", style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))
              ),
            ),
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Card(
                child: Container(
                  height: 200, 
                  padding: const EdgeInsets.only(top: 16, right: 16, bottom: 8, left: 8), // Padding for chart
                  alignment: Alignment.center,
                  child: (_controller.monthlyChartData.isEmpty && !_controller.isLoading)
                      ? Text("Not enough data for chart", style: textTheme.bodyMedium)
                      : LineChart(getSPEarningsChartData(context: context, monthlyEarningsMap: _controller.monthlyChartData, isLoading: _controller.isLoading)),
                ),
              ),
            ),
            Divider(indent: 16, endIndent: 16, height: 1, thickness: 1, color: theme.dividerColor),

            // Earnings Items List
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Earnings Breakdown", style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))
              ),
            ),
            Expanded(
              child: Skeletonizer(
                enabled: _controller.isLoading,
                 effect: ShimmerEffect(
                  baseColor: colorScheme.surfaceVariant.withOpacity(0.4),
                  highlightColor: colorScheme.surfaceVariant.withOpacity(0.8),
                ),
                child: (_controller.earningsJobs.isEmpty && !_controller.isLoading)
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.monetization_on_outlined, size: 80, color: colorScheme.primary.withOpacity(0.3)),
                              const SizedBox(height: 20),
                              Text('No Earnings Records Found', style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.8))),
                              const SizedBox(height: 8),
                              Text(
                                _controller.activeDateFilterLabel == 'All Time'
                                ? 'Your earnings details from completed/paid jobs will appear here.'
                                : 'No earnings found for the selected period.',
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.6))
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top:8.0, bottom: 8.0),
                        itemCount: _controller.isLoading ? 3 : _controller.earningsJobs.length,
                        itemBuilder: (context, index) {
                          if (_controller.isLoading) {
                            return SPEarningItemTile(job: SPJobModel.empty(), isSkeleton: true);
                          }
                          final job = _controller.earningsJobs[index];
                          return SPEarningItemTile(job: job);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
