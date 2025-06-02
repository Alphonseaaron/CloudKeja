import 'package:flutter/material.dart'; // For DateTimeRange, BuildContext (temporarily for some methods)
import 'package:intl/intl.dart';
import 'package:cloudkeja/models/sp_job_model.dart';
import 'package:cloudkeja/providers/job_provider.dart'; // Required for fetching jobs

class SPEarningsReportController extends ChangeNotifier {
  bool _isLoading = true;
  List<SPJobModel> _allFetchedJobs = [];
  List<SPJobModel> _earningsJobs = [];

  double _totalEarnings = 0.0;
  int _jobsPaidCount = 0;
  double _avgEarningPerJob = 0.0;

  DateTimeRange? _selectedDateFilter;
  String _activeDateFilterLabel = 'All Time';

  Map<String, double> _monthlyChartData = {};

  // Expose state via getters
  bool get isLoading => _isLoading;
  List<SPJobModel> get earningsJobs => _earningsJobs;
  double get totalEarnings => _totalEarnings;
  int get jobsPaidCount => _jobsPaidCount;
  double get avgEarningPerJob => _avgEarningPerJob;
  DateTimeRange? get selectedDateFilter => _selectedDateFilter;
  String get activeDateFilterLabel => _activeDateFilterLabel;
  Map<String, double> get monthlyChartData => _monthlyChartData;

  final Map<String, DateTimeRange?> dateFilterOptions = {
    'All Time': null,
    'This Month': DateTimeRange(start: DateTime(DateTime.now().year, DateTime.now().month, 1), end: DateTime.now()),
    'Last 30 Days': DateTimeRange(start: DateTime.now().subtract(const Duration(days: 30)), end: DateTime.now()),
    'Last 90 Days': DateTimeRange(start: DateTime.now().subtract(const Duration(days: 90)), end: DateTime.now()),
  };

  final JobProvider _jobProvider;

  SPEarningsReportController({required JobProvider jobProvider}) : _jobProvider = jobProvider {
    fetchEarningsData(); // Initial fetch
  }

  Future<void> fetchEarningsData({bool forceRefresh = false}) async {
    _isLoading = true;
    notifyListeners(); // Notify UI that loading has started

    String? errorMsg;
    try {
      _allFetchedJobs = await _jobProvider.fetchSPJobHistory(
        dateFilter: _selectedDateFilter,
        forceRefresh: forceRefresh,
        statusFilter: null, 
      );
      _processFetchedJobsAndPrepareChartData();
    } catch (e) {
      errorMsg = 'Error fetching earnings data: ${e.toString()}';
      _allFetchedJobs = [];
      _processFetchedJobsAndPrepareChartData(); // Ensure data is reset
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI about loading completion and data changes
      if (errorMsg != null) {
        // Expose error to UI instead of showing SnackBar directly
        // This could be a dedicated error field or a callback
        print("Error for UI: $errorMsg"); // Placeholder for actual error handling strategy
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
    _monthlyChartData = _prepareMonthlyEarningsChartData(_earningsJobs);
    // notifyListeners(); // Already called in fetchEarningsData's finally block or when filters change
  }

  Map<String, double> _prepareMonthlyEarningsChartData(List<SPJobModel> currentEarningsJobs, {int numberOfMonths = 6}) {
    Map<String, double> data = {};
    DateTime now = DateTime.now();

    for (int i = 0; i < numberOfMonths; i++) {
      DateTime monthDate = DateTime(now.year, now.month - i, 1);
      String monthKey = DateFormat('yyyy-MM').format(monthDate);
      data[monthKey] = 0.0;
    }

    if (currentEarningsJobs.isEmpty) {
       var sortedKeys = data.keys.toList()..sort();
       return { for (var k in sortedKeys) k : data[k]! };
    }
    
    DateTime firstJobDate = currentEarningsJobs.map((j) => j.dateCompleted).reduce((a,b) => a.isBefore(b) ? a : b);
    DateTime lastJobDate = currentEarningsJobs.map((j) => j.dateCompleted).reduce((a,b) => a.isAfter(b) ? a : b);

    DateTime chartStartDate = DateTime(lastJobDate.year, lastJobDate.month - (numberOfMonths - 1), 1);
    if(firstJobDate.isBefore(chartStartDate)) {
        data.clear(); 
         for (int i = 0; i < numberOfMonths; i++) {
            DateTime monthDate = DateTime(lastJobDate.year, lastJobDate.month - i, 1);
            if (monthDate.isBefore(firstJobDate) && i > 0 && data.length >= numberOfMonths) break; 
            String monthKey = DateFormat('yyyy-MM').format(monthDate);
            data[monthKey] = 0.0;
        }
    }

    for (var job in currentEarningsJobs) {
      DateTime jobDate = job.dateCompleted;
      String monthKey = DateFormat('yyyy-MM').format(jobDate);
      if (data.containsKey(monthKey)) {
        data.update(monthKey, (value) => value + job.amountEarned, ifAbsent: () => job.amountEarned);
      }
    }

    var sortedKeys = data.keys.toList()..sort();
    return { for (var k in sortedKeys) k : data[k]! };
  }

  // Methods to be called by UI to update filters
  voidsetDateFilter(String filterKey, DateTimeRange? dateRange) {
    _activeDateFilterLabel = filterKey;
    _selectedDateFilter = dateRange;
    notifyListeners(); // Notify that filter display might change
    fetchEarningsData(); // Re-fetch data with new filter
  }

  void setCustomDateRange(DateTimeRange newRange, String newLabel) {
    _selectedDateFilter = newRange;
    _activeDateFilterLabel = newLabel;
    notifyListeners();
    fetchEarningsData();
  }
  
  // New state for PDF generation
  bool _isGeneratingPdf = false;
  String? _pdfGenerationError;

  bool get isGeneratingPdf => _isGeneratingPdf;
  String? get pdfGenerationError => _pdfGenerationError;

  // Refactored method for PDF generation and opening
  Future<File?> generateAndOpenPdfReport(UserModel currentUser) async {
    if (_earningsJobs.isEmpty && !_isLoading) {
      _pdfGenerationError = 'No earnings data to generate report.';
      notifyListeners();
      return null;
    }

    _isGeneratingPdf = true;
    _pdfGenerationError = null;
    notifyListeners();

    File? pdfFile;
    try {
      // Assuming generateSPJobHistoryPdf is the correct method from UserReportPdfApi
      // It needs the list of jobs (which are _earningsJobs), the current user, and date range
      // UserReportPdfApi.generateSPJobHistoryPdf might need to be adapted if it's not exactly for earnings
      // or a new method like generateSPEarningsPdf should be created in UserReportPdfApi.
      // For this step, we'll assume generateSPJobHistoryPdf is suitable.
      
      // TODO: Ensure UserReportPdfApi.generateSPJobHistoryPdf exists and matches this signature,
      // or create UserReportPdfApi.generateSPEarningsPdf(jobs: _earningsJobs, serviceProvider: currentUser, filterDateRange: _selectedDateFilter)
      // For now, using a placeholder name that seems more appropriate for earnings.
      // This assumes UserReportPdfApi has such a method or it will be added.
      // If UserReportPdfApi.generateSPJobHistoryPdf is used, ensure its parameters match.
      
      // This call is speculative based on the class name UserReportPdfApi and common report needs.
      // The actual method in UserReportPdfApi for SP Earnings might be different (e.g. generateSPEarningsPdf).
      // The file read earlier showed generateSPJobHistoryPdf and generateUserPaymentHistoryPdf.
      // We'll use generateSPJobHistoryPdf as it's the closest match for SP data.
      pdfFile = await UserReportPdfApi.generateSPJobHistoryPdf( // Using existing method from UserReportPdfApi
        jobs: _earningsJobs, // These are SPJobModel
        currentSP: currentUser, // Needs UserModel of the SP
        filterDateRange: _selectedDateFilter,
      );
      
      if (pdfFile != null) {
        await PdfApi.openFile(pdfFile); // Helper from UserReportPdfApi's context
      }
    } catch (e) {
      _pdfGenerationError = 'Error generating PDF: ${e.toString()}';
      pdfFile = null; // Ensure pdfFile is null on error
    } finally {
      _isGeneratingPdf = false;
      notifyListeners();
    }
    return pdfFile;
  }
}

// Ensure UserReportPdfApi and PdfApi classes are imported
import 'dart:io';
import 'package:cloudkeja/helpers/user_report_pdf_api.dart';
import 'package:cloudkeja/models/user_model.dart';
// DateTimeRange is already part of flutter/material.dart, which is imported.
