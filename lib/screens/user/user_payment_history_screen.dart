import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';
import 'package:cloudkeja/widgets/tiles/payment_history_tile.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/providers/payment_provider.dart';
import 'package:cloudkeja/models/payment_model.dart';

class UserPaymentHistoryScreen extends StatefulWidget {
  const UserPaymentHistoryScreen({Key? key}) : super(key: key);
  static const String routeName = '/user-payment-history';

  @override
  State<UserPaymentHistoryScreen> createState() => _UserPaymentHistoryScreenState();
}

class _UserPaymentHistoryScreenState extends State<UserPaymentHistoryScreen> {
  bool _isLoading = true;
  List<PaymentModel> _payments = [];
  DateTimeRange? _selectedDateFilter;
  String _activeFilterLabel = 'All Time';

  // Define filter options
  final Map<String, DateTimeRange?> _filterOptions = {
    'All Time': null,
    'Last 30 Days': DateTimeRange(start: DateTime.now().subtract(const Duration(days: 30)), end: DateTime.now()),
    'Last 90 Days': DateTimeRange(start: DateTime.now().subtract(const Duration(days: 90)), end: DateTime.now()),
    // 'Last 6 Months' can be added similarly
  };


  @override
  void initState() {
    super.initState();
    _fetchPaymentHistory();
  }

  Future<void> _fetchPaymentHistory({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
      _payments = await paymentProvider.fetchUserPaymentHistory(
        dateFilter: _selectedDateFilter,
        forceRefresh: forceRefresh, // Pass forceRefresh if provider supports it
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching payment history: ${e.toString()}', style: TextStyle(color: Theme.of(context).colorScheme.onError)), backgroundColor: Theme.of(context).colorScheme.error),
        );
         _payments = []; // Clear payments on error
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectCustomDateRange() async {
    final theme = Theme.of(context); // For theming the picker
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5), // Allow selection up to 5 years back
      lastDate: DateTime.now(),
      currentDate: _selectedDateFilter?.start ?? DateTime.now(),
      initialDateRange: _selectedDateFilter,
      builder: (context, child) { // Theme the date picker
        return Theme(
          data: theme.copyWith(
            // Customize date picker theme colors if needed, though M3 defaults are good
            // colorScheme: theme.colorScheme.copyWith(
            //   primary: theme.colorScheme.primary,
            //   onPrimary: theme.colorScheme.onPrimary,
            //   surface: theme.colorScheme.surface,
            //   onSurface: theme.colorScheme.onSurface,
            // ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateFilter = picked;
        _activeFilterLabel = 'Custom'; // Or format the range: '${DateFormat.yMd().format(picked.start)} - ${DateFormat.yMd().format(picked.end)}';
      });
      _fetchPaymentHistory();
    }
  }

  Future<void> _downloadPdfReport() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (_payments.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No payment data to generate report.', style: TextStyle(color: colorScheme.onError)), backgroundColor: colorScheme.error),
      );
      return;
    }
    // TODO: Implement PDF generation using Invoice model and PdfInvoiceApi in a future subtask
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF Download: This functionality will be implemented using the fetched payment data.')),
    );
    print('Download PDF action triggered with ${_payments.length} payment records.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Payment History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_for_offline_outlined),
            tooltip: 'Download PDF Report',
            onPressed: (_payments.isEmpty && !_isLoading) ? null : _downloadPdfReport,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchPaymentHistory(forceRefresh: true),
        child: Column(
          children: [
            // Date Filter Chips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              color: colorScheme.surfaceContainerLowest, // Subtle background for filter bar
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ..._filterOptions.entries.map((entry) {
                      final bool isSelected = _activeFilterLabel == entry.key;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(entry.key),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedDateFilter = entry.value;
                                _activeFilterLabel = entry.key;
                              });
                              _fetchPaymentHistory();
                            }
                          },
                          // Chip styling comes from ChipThemeData
                        ),
                      );
                    }).toList(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: TextButton.icon( // Changed to TextButton.icon for better UI
                        icon: const Icon(Icons.calendar_month_outlined, size: 18),
                        label: const Text('Custom'),
                        onPressed: _selectCustomDateRange,
                        style: TextButton.styleFrom(
                          foregroundColor: _activeFilterLabel == 'Custom' ? colorScheme.primary : colorScheme.onSurfaceVariant,
                          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Divider(height: 1, thickness: 1, color: theme.dividerColor), // Optional divider

            // Payment List
            Expanded(
              child: Skeletonizer(
                enabled: _isLoading,
                effect: ShimmerEffect(
                  baseColor: colorScheme.surfaceVariant.withOpacity(0.4),
                  highlightColor: colorScheme.surfaceVariant.withOpacity(0.8),
                ),
                child: (_payments.isEmpty && !_isLoading)
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 80, color: colorScheme.primary.withOpacity(0.3)),
                              const SizedBox(height: 20),
                              Text('No Payments Found', style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.8))),
                              const SizedBox(height: 8),
                              Text(
                                _activeFilterLabel == 'All Time'
                                  ? 'Your payment records will appear here.'
                                  : 'No payments found for the selected period.',
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.6))
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        itemCount: _isLoading ? 5 : _payments.length,
                        itemBuilder: (context, index) {
                          if (_isLoading) {
                            return PaymentHistoryTile(paymentData: PaymentModel.empty(), isSkeleton: true);
                          }
                          final payment = _payments[index];
                          return PaymentHistoryTile(paymentData: payment);
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
