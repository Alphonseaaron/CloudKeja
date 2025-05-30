import 'dart:io'; // For File type
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';
import 'package:cloudkeja/models/sp_job_model.dart';
import 'package:cloudkeja/models/user_model.dart'; // For UserModel
import 'package:cloudkeja/widgets/tiles/sp_job_history_tile.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/providers/job_provider.dart';
import 'package:cloudkeja/providers/auth_provider.dart'; // For fetching current user
import 'package:cloudkeja/helpers/user_report_pdf_api.dart'; // Import the PDF API

class SPJobHistoryScreen extends StatefulWidget {
  const SPJobHistoryScreen({Key? key}) : super(key: key);
  static const String routeName = '/sp-job-history';

  @override
  State<SPJobHistoryScreen> createState() => _SPJobHistoryScreenState();
}

class _SPJobHistoryScreenState extends State<SPJobHistoryScreen> {
  bool _isLoading = true;
  List<SPJobModel> _jobs = [];

  String _selectedStatusFilter = 'All';
  DateTimeRange? _selectedDateFilter;
  String _activeDateFilterLabel = 'Any Date';
  bool _isGeneratingPdf = false; // State for PDF generation loading

  final List<String> _statusFilterOptions = ['All', 'Scheduled', 'InProgress', 'Completed', 'PendingPayment', 'Cancelled'];
  final Map<String, DateTimeRange?> _dateFilterOptions = {
    'Any Date': null,
    'Today': DateTimeRange(start: DateTime.now().subtract(const Duration(days:0)), end: DateTime.now()),
    'This Week': DateTimeRange(start: DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)), end: DateTime.now()),
    'This Month': DateTimeRange(start: DateTime(DateTime.now().year, DateTime.now().month, 1), end: DateTime.now()),
  };

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  Future<void> _fetchJobs({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      _jobs = await jobProvider.fetchSPJobHistory(
        statusFilter: _selectedStatusFilter,
        dateFilter: _selectedDateFilter,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching job history: ${e.toString()}', style: TextStyle(color: Theme.of(context).colorScheme.onError)), backgroundColor: Theme.of(context).colorScheme.error),
        );
        _jobs = [];
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
      _fetchJobs();
    }
  }

  Future<void> _downloadPdfReport() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_jobs.isEmpty && !_isLoading) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No job data to generate report.', style: TextStyle(color: colorScheme.onError)), backgroundColor: colorScheme.error),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isGeneratingPdf = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final UserModel? currentSP = authProvider.user; // Assuming user in AuthProvider is the SP

      if (currentSP == null) {
        throw Exception('Current user data not available for PDF report.');
      }

      final File pdfFile = await UserReportPdfApi.generateSPJobHistoryPdf(
        _jobs,
        currentSP,
        _selectedDateFilter
      );

      await PdfApi.openFile(pdfFile);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate or open PDF: ${e.toString()}', style: TextStyle(color: colorScheme.onError)), backgroundColor: colorScheme.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Job History'),
        actions: [
          _isGeneratingPdf
            ? Padding( // Show loader in place of button
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: colorScheme.onPrimary)),
              )
            : IconButton(
                icon: const Icon(Icons.download_for_offline_outlined),
                tooltip: 'Download Job Report',
                onPressed: (_jobs.isEmpty && !_isLoading) ? null : _downloadPdfReport,
              ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchJobs(forceRefresh: true),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter UI Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              color: colorScheme.surfaceContainerLowest,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Filter by Status:', style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    child: Row(
                      children: _statusFilterOptions.map((status) {
                        final bool isSelected = _selectedStatusFilter == status;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Text(status),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedStatusFilter = status);
                                _fetchJobs();
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
                    child: Text('Filter by Date:', style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
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
                                  _fetchJobs();
                                }
                              },
                            ),
                          );
                        }).toList(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ActionChip(
                            avatar: const Icon(Icons.calendar_month_outlined, size: 18),
                            label: Text(_activeDateFilterLabel == 'Custom' || !_dateFilterOptions.containsKey(_activeDateFilterLabel) ? _activeDateFilterLabel : 'Custom'),
                            onPressed: _selectCustomDateRange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness:1, color: theme.dividerColor),

            // Job List
            Expanded(
              child: Skeletonizer(
                enabled: _isLoading,
                effect: ShimmerEffect(
                  baseColor: colorScheme.surfaceVariant.withOpacity(0.4),
                  highlightColor: colorScheme.surfaceVariant.withOpacity(0.8),
                ),
                child: (_jobs.isEmpty && !_isLoading)
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.work_history_outlined, size: 80, color: colorScheme.primary.withOpacity(0.3)),
                              const SizedBox(height: 20),
                              Text(
                                'No Job Records Found',
                                style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.8)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedStatusFilter == 'All' && _selectedDateFilter == null
                                ? 'Your job history will appear here.'
                                : 'No jobs match your current filters.',
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        itemCount: _isLoading ? 5 : _jobs.length,
                        itemBuilder: (context, index) {
                          if (_isLoading) {
                            return SPJobHistoryTile(job: SPJobModel.empty(), isSkeleton: true);
                          }
                          final job = _jobs[index];
                          return SPJobHistoryTile(job: job);
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
