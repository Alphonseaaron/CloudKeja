import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For Icons in summary, and potentially for LineChart if not fully Cupertino-ized by fl_chart
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart'; // For LineChart
import 'package:skeletonizer/skeletonizer.dart'; // Skeletonizer might have Material dependencies in its default look

import 'package:cloudkeja/models/sp_job_model.dart';
import 'package:cloudkeja/widgets/tiles/sp_earning_item_tile.dart'; // This is a Material styled tile
import 'package:cloudkeja/providers/job_provider.dart';
import 'package:cloudkeja/screens/service_provider/sp_earnings_report_controller.dart';
import 'package:cloudkeja/screens/service_provider/widgets/sp_earnings_fl_chart.dart';

class SPEarningsReportScreenCupertino extends StatefulWidget {
  const SPEarningsReportScreenCupertino({Key? key}) : super(key: key);

  @override
  State<SPEarningsReportScreenCupertino> createState() => _SPEarningsReportScreenCupertinoState();
}

class _SPEarningsReportScreenCupertinoState extends State<SPEarningsReportScreenCupertino> {
  late SPEarningsReportController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SPEarningsReportController(jobProvider: Provider.of<JobProvider>(context, listen: false));
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectCustomDateRange() async {
    final picked = await showCupertinoModalPopup<DateTimeRange>(
      context: context,
      builder: (BuildContext context) {
        // A basic date range picker, can be improved with a custom Cupertino style picker
        DateTimeRange? tempPickedDateRange = _controller.selectedDateFilter;
        return SizedBox(
          height: 300,
          child: CupertinoTheme(
            data: CupertinoTheme.of(context), // Inherit theme
            child: Column(
              children: [
                SizedBox(
                  height: 240, // Adjust to fit DateRangePicker
                  child: CalendarDatePicker( // Using Material's CalendarDatePicker inside modal
                    initialDateRange: tempPickedDateRange,
                    firstDate: DateTime(DateTime.now().year - 5),
                    lastDate: DateTime.now(),
                    onDateRangeChanged: (range) => tempPickedDateRange = range,
                  ),
                ),
                CupertinoButton(
                  child: const Text('Done'),
                  onPressed: () => Navigator.of(context).pop(tempPickedDateRange),
                )
              ],
            ),
          ),
        );
      },
    );

    if (picked != null) {
      final newLabel = '${DateFormat.yMd().format(picked.start)} - ${DateFormat.yMd().format(picked.end)}';
      _controller.setCustomDateRange(picked, newLabel);
    }
  }

  Future<void> _showDateFilterActionSheet() async {
    final cupertinoTheme = CupertinoTheme.of(context);
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Select Date Filter'),
        actions: <CupertinoActionSheetAction>[
          ..._controller.dateFilterOptions.entries.map((entry) => CupertinoActionSheetAction(
            isDefaultAction: _controller.activeDateFilterLabel == entry.key,
            onPressed: () {
              _controller.setDateFilter(entry.key, entry.value);
              Navigator.pop(context);
            },
            child: Text(entry.key),
          )).toList(),
          CupertinoActionSheetAction(
            child: const Text('Custom Range...'),
            onPressed: () {
              Navigator.pop(context);
              _selectCustomDateRange();
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Future<void> _downloadPdfReport() async {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUserData;
    if (currentUser == null) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: const Text("User not available. Cannot generate report."),
            actions: [CupertinoDialogAction(isDefaultAction: true, child: const Text('OK'), onPressed: () => Navigator.pop(context))],
          )
        );
      }
      return;
    }

    final file = await _controller.generateAndOpenPdfReport(currentUser);

    if (mounted && _controller.pdfGenerationError != null) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('PDF Generation Error'),
          content: Text(_controller.pdfGenerationError!),
          actions: [CupertinoDialogAction(isDefaultAction: true, child: const Text('OK'), onPressed: () => Navigator.pop(context))],
        )
      );
    } else if (mounted && file != null) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('PDF Report Generated'),
          content: Text("Report saved to: ${file.path} and opened."),
          actions: [CupertinoDialogAction(isDefaultAction: true, child: const Text('OK'), onPressed: () => Navigator.pop(context))],
        )
      );
    }
    // If file is null and no error, it might mean no data, which is handled by controller state _pdfGenerationError.
  }

  Widget _buildSummaryItem(BuildContext context, String title, String value, IconData icon, Color iconColor) {
    final cupertinoTheme = CupertinoTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: cupertinoTheme.barBackgroundColor, // Similar to card background
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: iconColor), // Material icons are used here
          const SizedBox(height: 8),
          Text(title, style: cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(color: CupertinoColors.secondaryLabel.resolveFrom(context)), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(
            _controller.isLoading && value.contains("0.00") ? "..." : value,
            style: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 18, color: iconColor),
            textAlign: TextAlign.center
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(context), // Standard grouped background
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Earnings Report'),
        trailing: _controller.isGeneratingPdf
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0), // Adjust padding to center well
              child: CupertinoActivityIndicator(radius: 12), // Standard size for nav bar
            )
          : CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.cloud_download, size: 24),
              onPressed: (_controller.earningsJobs.isEmpty && !_controller.isLoading) ? null : _downloadPdfReport,
            ),
      ),
      child: SafeArea( // Important for content within CupertinoPageScaffold
        child: CustomScrollView(
          slivers: <Widget>[
            CupertinoSliverRefreshControl(
              onRefresh: () => _controller.fetchEarningsData(forceRefresh: true),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                // Date Filter Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: CupertinoButton(
                    color: cupertinoTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    onPressed: _showDateFilterActionSheet,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(CupertinoIcons.calendar, size: 20),
                        const SizedBox(width: 8),
                        Text(_controller.activeDateFilterLabel, style: const TextStyle(color: CupertinoColors.white)),
                        const SizedBox(width: 4),
                        const Icon(CupertinoIcons.chevron_down, size: 16, color: CupertinoColors.white),
                      ],
                    ),
                  ),
                ),

                // Summary Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Skeletonizer.zone( // Skeletonizer might need Cupertino theming if defaults are too Material
                    enabled: _controller.isLoading,
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5, // Adjusted for Cupertino
                      children: [
                        _buildSummaryItem(context, 'Total Earnings', 'KES ${_controller.totalEarnings.toStringAsFixed(2)}', CupertinoIcons.money_dollar_circle, CupertinoColors.systemGreen.resolveFrom(context)),
                        _buildSummaryItem(context, 'Jobs Accounted', _controller.jobsPaidCount.toString(), CupertinoIcons.check_mark_circled, cupertinoTheme.primaryColor),
                        _buildSummaryItem(context, 'Avg. Earning/Job', 'KES ${_controller.avgEarningPerJob.toStringAsFixed(2)}', CupertinoIcons.chart_pie, CupertinoColors.systemOrange.resolveFrom(context)),
                      ],
                    ),
                  ),
                ),

                // Chart Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text("Monthly Earnings Trend", style: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(fontSize: 18)),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  padding: const EdgeInsets.only(top: 16, right: 16, bottom: 8, left: 8),
                  height: 220, // Adjusted height
                  decoration: BoxDecoration(
                    color: cupertinoTheme.barBackgroundColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: (_controller.monthlyChartData.isEmpty && !_controller.isLoading)
                      ? Center(child: Text("Not enough data for chart", style: cupertinoTheme.textTheme.tabLabelTextStyle))
                      : LineChart(getSPEarningsChartData(context: context, monthlyEarningsMap: _controller.monthlyChartData, isLoading: _controller.isLoading)),
                ),

                // Earnings Breakdown Title
                 Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
                  child: Text("Earnings Breakdown", style: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(fontSize: 18)),
                ),
              ]),
            ),
            // Earnings Items List (using SliverChildBuilderDelegate for performance if list is long)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 0), // No padding for section itself
              sliver: Skeletonizer(
                enabled: _controller.isLoading,
                // TODO: Consider Cupertino-specific shimmer effect if Skeletonizer default is too Material
                child: SliverList(
                  delegate: (_controller.earningsJobs.isEmpty && !_controller.isLoading)
                      ? SliverChildListDelegate([
                          Container(
                            padding: const EdgeInsets.all(32.0),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.money_dollar, size: 60, color: CupertinoColors.systemGrey.resolveFrom(context)),
                                const SizedBox(height: 16),
                                Text('No Earnings Records Found', style: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(fontSize: 18)),
                                const SizedBox(height: 8),
                                Text(
                                  _controller.activeDateFilterLabel == 'All Time'
                                  ? 'Details from completed/paid jobs will appear here.'
                                  : 'No earnings found for the selected period.',
                                  textAlign: TextAlign.center,
                                  style: cupertinoTheme.textTheme.tabLabelTextStyle,
                                ),
                              ],
                            ),
                          )
                        ])
                      : SliverChildBuilderDelegate(
                          (context, index) {
                            if (_controller.isLoading && _controller.earningsJobs.isEmpty) { // Show shimmer tiles only if jobs list is empty during load
                              return SPEarningItemTile(job: SPJobModel.empty(), isSkeleton: true);
                            }
                            final job = _controller.earningsJobs[index];
                            // Wrap SPEarningItemTile or adapt it if its Material style is too jarring
                            // For now, using it directly.
                            return Container(
                                color: cupertinoTheme.barBackgroundColor, // Match section background
                                child: Column(
                                  children: [
                                    SPEarningItemTile(job: job),
                                    if (index < _controller.earningsJobs.length -1)
                                      Divider(height: 1, indent: 16, endIndent: 0, color: CupertinoColors.separator.resolveFrom(context))
                                  ],
                                ),
                            );
                          },
                          childCount: (_controller.isLoading && _controller.earningsJobs.isEmpty) ? 3 : _controller.earningsJobs.length,
                        ),
                ),
              ),
            ),
             SliverToBoxAdapter(child: const SizedBox(height: 20)), // Bottom padding
          ],
        ),
      ),
    );
  }
}
