import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';
import 'package:cloudkeja/models/sp_job_model.dart';
import 'package:cloudkeja/widgets/tiles/sp_earning_item_tile.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/providers/job_provider.dart'; // Import JobProvider
// Import chart widget once created
// import 'package:cloudkeja/screens/service_provider/widgets/sp_earnings_fl_chart.dart';
// import 'package:fl_chart/fl_chart.dart'; // Will be used when chart is integrated

class SPEarningsReportScreen extends StatefulWidget {
  const SPEarningsReportScreen({Key? key}) : super(key: key);
  static const String routeName = '/sp-earnings-report';

  @override
  State<SPEarningsReportScreen> createState() => _SPEarningsReportScreenState();
}

class _SPEarningsReportScreenState extends State<SPEarningsReportScreen> {
  bool _isLoading = true;
  List<SPJobModel> _allFetchedJobs = [];
  List<SPJobModel> _earningsJobs = [];

  double _totalEarnings = 0.0;
  int _jobsPaidCount = 0;
  double _avgEarningPerJob = 0.0;

  DateTimeRange? _selectedDateFilter;
  String _activeDateFilterLabel = 'All Time';

  // New state for chart data
  Map<String, double> _monthlyChartData = {};

  final Map<String, DateTimeRange?> _dateFilterOptions = {
    'All Time': null,
    'This Month': DateTimeRange(start: DateTime(DateTime.now().year, DateTime.now().month, 1), end: DateTime.now()),
    'Last 30 Days': DateTimeRange(start: DateTime.now().subtract(const Duration(days: 30)), end: DateTime.now()),
    'Last 90 Days': DateTimeRange(start: DateTime.now().subtract(const Duration(days: 90)), end: DateTime.now()),
  };

  @override
  void initState() {
    super.initState();
    _fetchEarningsData();
  }

  Future<void> _fetchEarningsData({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      _allFetchedJobs = await jobProvider.fetchSPJobHistory(
        dateFilter: _selectedDateFilter,
        forceRefresh: forceRefresh,
        // Fetch all relevant statuses for earnings calculation initially
        statusFilter: null, // Or specify ['Completed', 'PendingPayment'] if provider supports list
      );
      _processFetchedJobsAndPrepareChartData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching earnings data: ${e.toString()}', style: TextStyle(color: Theme.of(context).colorScheme.onError)), backgroundColor: Theme.of(context).colorScheme.error),
        );
        _allFetchedJobs = [];
        _processFetchedJobsAndPrepareChartData();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _processFetchedJobsAndPrepareChartData() {
    _earningsJobs = _allFetchedJobs.where((job) =>
      job.status.toLowerCase() == 'completed' ||
      job.status.toLowerCase() == 'pendingpayment'
    ).toList();

    if (_earningsJobs.isNotEmpty) {
      _totalEarnings = _earningsJobs.fold(0.0, (sum, job) => sum + job.amountEarned);
      _jobsPaidCount = _earningsJobs.length;
      _avgEarningPerJob = _jobsPaidCount > 0 ? _totalEarnings / _jobsPaidCount : 0.0;
    } else {
      _totalEarnings = 0.0;
      _jobsPaidCount = 0;
      _avgEarningPerJob = 0.0;
    }
    // Prepare chart data after processing earnings jobs
    _monthlyChartData = _prepareMonthlyEarningsChartData(_earningsJobs);
  }

  Map<String, double> _prepareMonthlyEarningsChartData(List<SPJobModel> earningsJobs, {int numberOfMonths = 6}) {
    Map<String, double> monthlyData = {};
    DateTime now = DateTime.now();

    // Initialize map for the last N months with 0.0 income
    for (int i = 0; i < numberOfMonths; i++) {
      DateTime monthDate = DateTime(now.year, now.month - i, 1);
      String monthKey = DateFormat('yyyy-MM').format(monthDate);
      monthlyData[monthKey] = 0.0;
    }

    if (earningsJobs.isEmpty) {
       // Return sorted empty months if no jobs
       var sortedKeys = monthlyData.keys.toList()..sort();
       return { for (var k in sortedKeys) k : monthlyData[k]! };
    }

    // Determine the actual range of months from the jobs, up to numberOfMonths
    DateTime firstJobDate = earningsJobs.map((j) => j.dateCompleted).reduce((a,b) => a.isBefore(b) ? a : b);
    DateTime lastJobDate = earningsJobs.map((j) => j.dateCompleted).reduce((a,b) => a.isAfter(b) ? a : b);

    // Ensure our chart range covers at least the job data range or default numberOfMonths
    DateTime chartStartDate = DateTime(lastJobDate.year, lastJobDate.month - (numberOfMonths - 1), 1);
    if(firstJobDate.isBefore(chartStartDate)) {
        // If jobs span more than numberOfMonths, adjust chartStartDate
        // or decide to only show latest N months. For now, let's ensure we cover the jobs.
        // This logic will re-initialize monthlyData to cover the actual range up to numberOfMonths from latest.
        monthlyData.clear(); // Clear and re-initialize based on actual data range or N months
         for (int i = 0; i < numberOfMonths; i++) {
            DateTime monthDate = DateTime(lastJobDate.year, lastJobDate.month - i, 1);
            if (monthDate.isBefore(firstJobDate) && i > 0 && monthlyData.length >= numberOfMonths) break; // Limit to N months if jobs are older
            String monthKey = DateFormat('yyyy-MM').format(monthDate);
            monthlyData[monthKey] = 0.0;
        }
    }


    for (var job in earningsJobs) {
      DateTime jobDate = job.dateCompleted;
      String monthKey = DateFormat('yyyy-MM').format(jobDate);

      // Only include if the month is one we are tracking
      if (monthlyData.containsKey(monthKey)) {
        monthlyData.update(monthKey, (value) => value + job.amountEarned, ifAbsent: () => job.amountEarned);
      }
    }

    // Sort the map by month ascending for the chart
    var sortedKeys = monthlyData.keys.toList()..sort();
    Map<String, double> sortedMonthlyData = { for (var k in sortedKeys) k : monthlyData[k]! };

    return sortedMonthlyData;
  }

  Future<void> _selectCustomDateRange() async {
    final theme = Theme.of(context);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateFilter ?? DateTimeRange(start: DateTime.now().subtract(const Duration(days: 7)), end: DateTime.now()),
      builder: (context, child) => Theme(data: theme, child: child!),
    );

    if (picked != null) {
      setState(() {
        _selectedDateFilter = picked;
        _activeDateFilterLabel = '${DateFormat.yMd().format(picked.start)} - ${DateFormat.yMd().format(picked.end)}';
      });
      _fetchEarningsData();
    }
  }

  Future<void> _downloadPdfReport() async {
    // ... (existing PDF download logic)
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (_earningsJobs.isEmpty && !_isLoading) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No earnings data to generate report.', style: TextStyle(color: colorScheme.onError)), backgroundColor: colorScheme.error),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF Download for earnings will be implemented in a future task.')),
    );
    print('Download PDF for earnings action triggered with ${_earningsJobs.length} earning records.');
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, IconData icon, Color iconColor) {
    // ... (existing summary card logic - unchanged)
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
            Text(_isLoading && value.contains("0.00") ? "..." : value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: iconColor), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (existing build method structure up to chart placeholder)
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Earnings Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_for_offline_outlined),
            tooltip: 'Download Earnings PDF',
            onPressed: (_earningsJobs.isEmpty && !_isLoading) ? null : _downloadPdfReport,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchEarningsData(forceRefresh: true),
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
                    ..._dateFilterOptions.entries.map((entry) {
                      final bool isSelected = _activeDateFilterLabel == entry.key;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(entry.key),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedDateFilter = entry.value;
                                _activeDateFilterLabel = entry.key;
                              });
                              _fetchEarningsData();
                            }
                          },
                        ),
                      );
                    }).toList(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ActionChip(
                        avatar: const Icon(Icons.calendar_month_outlined, size: 18),
                        label: Text(_activeDateFilterLabel == 'Custom' || !_dateFilterOptions.containsKey(_activeDateFilterLabel) ? _activeDateFilterLabel : 'Custom Range'),
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
                enabled: _isLoading,
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: MediaQuery.of(context).size.width > 600 ? 1.7 : 1.45,
                  children: [
                    _buildSummaryCard(context, 'Total Earnings', 'KES ${_totalEarnings.toStringAsFixed(2)}', Icons.account_balance_wallet_outlined, Colors.green.shade700),
                    _buildSummaryCard(context, 'Jobs Accounted', _jobsPaidCount.toString(), Icons.check_circle_outline_rounded, colorScheme.primary),
                    _buildSummaryCard(context, 'Avg. Earning/Job', 'KES ${_avgEarningPerJob.toStringAsFixed(2)}', Icons.pie_chart_outline_rounded, Colors.orange.shade700),
                  ],
                ),
              ),
            ),

            // Placeholder for Chart - will be implemented in next step
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
                  height: 200, // Standard height for chart
                  alignment: Alignment.center,
                  // child: _isLoadingChartData // Use a specific flag for chart loading if needed
                  //     ? const CircularProgressIndicator()
                  //     : _monthlyChartData.isEmpty && !_isLoading
                  //         ? Text("Not enough data for chart", style: textTheme.bodyMedium)
                  //         : LineChart(getSPEarningsChartData(context: context, monthlyEarningsMap: _monthlyChartData, isLoading: _isLoading)),
                  child: Text("(Chart placeholder - to be implemented with sp_earnings_fl_chart.dart)", style: textTheme.bodyMedium),
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
                enabled: _isLoading,
                effect: ShimmerEffect(
                  baseColor: colorScheme.surfaceVariant.withOpacity(0.4),
                  highlightColor: colorScheme.surfaceVariant.withOpacity(0.8),
                ),
                child: (_earningsJobs.isEmpty && !_isLoading)
                    ? Center(/* ... existing empty state ... */
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
                                _activeDateFilterLabel == 'All Time'
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
                        itemCount: _isLoading ? 3 : _earningsJobs.length,
                        itemBuilder: (context, index) {
                          if (_isLoading) {
                            return SPEarningItemTile(job: SPJobModel.empty(), isSkeleton: true);
                          }
                          final job = _earningsJobs[index];
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
