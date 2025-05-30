import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
// import 'package:get/route_manager.dart'; // Not used in this file
import 'package:provider/provider.dart';
// import 'package:cloudkeja/helpers/constants.dart'; // kPrimaryColor replaced by theme
import 'package:cloudkeja/models/user_model.dart'; // For UserModel
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/payment_provider.dart'; // For getLandlordTotalIncome
import 'package:cloudkeja/screens/landlord/finances/widget/finance_top.dart'; // Assuming this is themed or simple
import 'package:skeletonizer/skeletonizer.dart'; // For loading state
import 'package:intl/intl.dart'; // For formatting currency

class FinanceOverviewScreen extends StatefulWidget {
  const FinanceOverviewScreen({Key? key}) : super(key: key);

  @override
  State<FinanceOverviewScreen> createState() => _FinanceOverviewScreenState();
}

class _FinanceOverviewScreenState extends State<FinanceOverviewScreen> {
  bool _isChartDataLoaded = false; // For chart animation
  double? _totalIncomeFromLeasePayments;
  bool _isLoadingIncome = true;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    // Trigger chart animation after a delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isChartDataLoaded = true;
        });
      }
    });
  }

  Future<void> _fetchInitialData() async {
    if (!mounted) return;
    setState(() => _isLoadingIncome = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _currentUser = await authProvider.getCurrentUser(); // Fetch current user details

      if (_currentUser?.userId != null) {
        final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
        _totalIncomeFromLeasePayments = await paymentProvider.getLandlordTotalIncomeFromLeasePayments(
          landlordId: _currentUser!.userId!,
          // dateFilter: can be added here if date filters are implemented on this screen
        );
      } else {
        throw Exception("User not found or not logged in.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching financial data: ${e.toString()}', style: TextStyle(color: Theme.of(context).colorScheme.onError)), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingIncome = false);
      }
    }
  }


  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 12.0),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    bool isLoading = false, // For skeletonizer
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      // Uses CardTheme from AppTheme
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Skeletonizer.zone( // Apply skeleton to card content
          enabled: isLoading,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: isLoading ? Colors.transparent : (iconColor ?? colorScheme.primary).withOpacity(0.9)),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                isLoading ? "Loading..." : value, // Show "Loading..." or actual value
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isLoading ? Colors.transparent : (iconColor ?? colorScheme.primary),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    // final size = MediaQuery.of(context).size; // Not used directly now

    // Use _currentUser from state, which is fetched in initState
    final currentBalance = _currentUser?.balance ?? 0.0;
    final String formattedBalance = 'KES ${NumberFormat("#,##0.00", "en_US").format(currentBalance)}';
    final String formattedTotalIncome = _totalIncomeFromLeasePayments != null
        ? 'KES ${NumberFormat("#,##0.00", "en_US").format(_totalIncomeFromLeasePayments)}'
        : 'KES 0.00';

    return Scaffold(
      backgroundColor: colorScheme.background, // Themed background
      appBar: AppBar(
        title: const Text('Financial Overview'), // Updated title
        // AppBar uses global AppBarTheme
      ),
      body: RefreshIndicator( // Added RefreshIndicator
        onRefresh: _fetchInitialData,
        child: ListView( // Changed Column to ListView for scrollability & RefreshIndicator
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          children: [
            // const FinanceTop(), // Assuming FinanceTop is a summary card or similar, needs theming if complex

            // Stats Grid
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6, // Adjusted for potentially taller content
                children: [
                  _buildStatCard(context, title: 'Available Balance', value: formattedBalance, icon: Icons.account_balance_wallet_outlined, isLoading: _isLoadingUser, iconColor: colorScheme.secondary),
                  _buildStatCard(context, title: 'Total Income (Leases)', value: formattedTotalIncome, icon: Icons.trending_up_rounded, isLoading: _isLoadingIncome, iconColor: Colors.green.shade700),
                  _buildStatCard(context, title: 'Ratings Earned', value: '4.5', icon: Icons.star_border_purple500_outlined, isLoading: false, iconColor: Colors.amber.shade700), // Placeholder
                  _buildStatCard(context, title: 'Active Tenants', value: '3', icon: Icons.people_alt_outlined, isLoading: false, iconColor: colorScheme.tertiary), // Placeholder
                ],
              ),
            ),

            _buildSectionTitle(context, 'Recent Transactions Chart'),
            Container(
              padding: const EdgeInsets.all(16.0),
              height: 250, // Adjusted height for chart
              child: LineChart( // Placeholder data, use themed data
                mainData(
                  isLoaded: _isChartDataLoaded,
                  colorScheme: colorScheme,
                  textTheme: textTheme
                ),
                swapAnimationCurve: Curves.easeInOut,
                swapAnimationDuration: const Duration(milliseconds: 1000),
              ),
            ),
            // Add more sections like transaction lists etc. here
          ],
        ),
      ),
    );
  }

  // --- Themed LineChartData ---
  LineChartData mainData({required bool isLoaded, required ColorScheme colorScheme, required TextTheme textTheme}) {
    // Dummy data for chart - replace with actual data from provider
    List<FlSpot> spots = const [
      FlSpot(0, 3), FlSpot(2.6, 2), FlSpot(4.9, 5), FlSpot(6.8, 3.1), FlSpot(8, 4), FlSpot(9.5, 3), FlSpot(11, 4),
    ];
    List<FlSpot> spots2 = const [ // Example second line
      FlSpot(0, 1), FlSpot(2.6, 3), FlSpot(4.9, 2), FlSpot(6.8, 4.1), FlSpot(8, 2), FlSpot(9.5, 4), FlSpot(11, 2.5),
    ];


    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) => FlLine(color: colorScheme.outline.withOpacity(0.2), strokeWidth: 0.5),
        getDrawingVerticalLine: (value) => FlLine(color: colorScheme.outline.withOpacity(0.2), strokeWidth: 0.5),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              String text = '';
              switch (value.toInt()) {
                case 2: text = 'MAR'; break; case 5: text = 'JUN'; break; case 8: text = 'SEP'; break;
              }
              return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)));
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) => Text('KES ${value.toInt()}k', style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(show: true, border: Border.all(color: colorScheme.outline.withOpacity(0.3))),
      minX: 0, maxX: 11, minY: 0, maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: isLoaded ? spots : const [FlSpot(0,0), FlSpot(11,0)], // Animate from flat line
          isCurved: true,
          gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.5)]),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [colorScheme.primary.withOpacity(0.3), colorScheme.primary.withOpacity(0.0)])),
        ),
         LineChartBarData( // Example second line
          spots: isLoaded ? spots2 : const [FlSpot(0,0), FlSpot(11,0)],
          isCurved: true,
          gradient: LinearGradient(colors: [colorScheme.secondary, colorScheme.secondary.withOpacity(0.5)]),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [colorScheme.secondary.withOpacity(0.2), colorScheme.secondary.withOpacity(0.0)])),
        ),
      ],
      lineTouchData: LineTouchData( // Themed tooltip
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: colorScheme.surfaceVariant,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                'KES ${spot.y * 1000}', // Assuming y is in thousands
                textTheme.bodySmall!.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
              );
            }).toList();
          }
        )
      )
    );
  }
}
