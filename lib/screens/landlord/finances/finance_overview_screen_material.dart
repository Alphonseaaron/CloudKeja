import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/payment_provider.dart';
import 'package:cloudkeja/screens/landlord/finances/widget/finance_top.dart'; // Router
import 'package:cloudkeja/screens/landlord/finances/widget/expenses_chart.dart'; // Contains getAdaptiveLineChartData
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';

class FinanceOverviewScreenMaterial extends StatefulWidget {
  const FinanceOverviewScreenMaterial({Key? key}) : super(key: key);

  @override
  State<FinanceOverviewScreenMaterial> createState() => _FinanceOverviewScreenMaterialState();
}

class _FinanceOverviewScreenMaterialState extends State<FinanceOverviewScreenMaterial> {
  bool _isChartDataLoaded = false;
  Map<String, double> _monthlyIncomeData = {}; // Changed to store actual data
  bool _isLoadingIncome = true;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    // Chart animation trigger can remain or be tied to _isLoadingIncome
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
      _currentUser = await authProvider.getCurrentUser();

      if (_currentUser?.userId != null) {
        final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
        // Assuming getLandlordMonthlyIncomeSummary returns Map<String, double>
        // where key is "YYYY-MM" and value is income.
        // This needs to be fetched. For now, using a placeholder.
        // _monthlyIncomeData = await paymentProvider.getLandlordMonthlyIncomeSummary(_currentUser!.userId!);
        // Placeholder data for chart:
        _monthlyIncomeData = {
          DateFormat('yyyy-MM').format(DateTime.now().subtract(Duration(days: 150))): 2500.0,
          DateFormat('yyyy-MM').format(DateTime.now().subtract(Duration(days: 120))): 3000.0,
          DateFormat('yyyy-MM').format(DateTime.now().subtract(Duration(days: 90))): 1500.0,
          DateFormat('yyyy-MM').format(DateTime.now().subtract(Duration(days: 60))): 4000.0,
          DateFormat('yyyy-MM').format(DateTime.now().subtract(Duration(days: 30))): 3500.0,
          DateFormat('yyyy-MM').format(DateTime.now()): 5000.0,
        };
        // For total income, it seems it was fetched separately, let's keep that logic for now
        // but ideally, it could be derived from _monthlyIncomeData or fetched consistently
        double totalIncome = await paymentProvider.getLandlordTotalIncomeFromLeasePayments(
          landlordId: _currentUser!.userId!,
        );
         if (mounted) {
          // This state update is mainly for _currentUser and the total income for stat card.
          // The chart data is now in _monthlyIncomeData.
           setState(() {
             // _totalIncomeFromLeasePayments = totalIncome; // Assuming this was used for a stat card
             // If _currentUser.balance is what FinanceTop uses, ensure it's updated here.
             // This might require _currentUser to be updated if balance is part of it.
           });
         }

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
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    bool isLoading = false,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Skeletonizer.zone(
          enabled: isLoading,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: isLoading ? Colors.transparent : (iconColor ?? colorScheme.primary).withOpacity(0.9)),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                isLoading ? "Loading..." : value,
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
    // final textTheme = theme.textTheme; // Not directly used as much now

    // Use _currentUser from state for balance in FinanceTopRouter
    // Calculate total income for stat card from the fetched monthly data, or use a separate variable if available
    final double totalIncomeForStat = _monthlyIncomeData.values.fold(0.0, (sum, item) => sum + item);
    final String formattedTotalIncome = 'KES ${NumberFormat("#,##0.00", "en_US").format(totalIncomeForStat)}';


    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text('Financial Overview', style: theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleLarge),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchInitialData,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          children: [
            FinanceTopRouter(user: _currentUser, isLoadingUser: _isLoadingIncome), // Use router

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  // FinanceTopRouter handles available balance, so this card is redundant or needs different data
                  // _buildStatCard(context, title: 'Available Balance', value: formattedBalance, icon: Icons.account_balance_wallet_outlined, isLoading: _isLoadingUser, iconColor: colorScheme.secondary),
                  _buildStatCard(context, title: 'Total Income (Chart)', value: formattedTotalIncome, icon: Icons.trending_up_rounded, isLoading: _isLoadingIncome, iconColor: Colors.green.shade700),
                  _buildStatCard(context, title: 'Avg. Monthly', value: 'KES ...', icon: Icons.av_timer_outlined, isLoading: _isLoadingIncome, iconColor: colorScheme.tertiary), // Placeholder
                  _buildStatCard(context, title: 'Next Payout', value: 'KES ...', icon: Icons.next_plan_outlined, isLoading: _isLoadingIncome, iconColor: Colors.blue.shade600), // Placeholder
                ],
              ),
            ),

            _buildSectionTitle(context, 'Monthly Income Chart'),
            Container(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0), // Added bottom padding
              height: 300, // Adjusted height for chart
              child: LineChart(
                getAdaptiveLineChartData( // Use adaptive chart data function
                  context: context,
                  monthlyIncomeData: _monthlyIncomeData,
                  isLoading: _isLoadingIncome || !_isChartDataLoaded, // Pass loading state
                ),
                swapAnimationCurve: Curves.easeInOut,
                swapAnimationDuration: const Duration(milliseconds: 750), // Standard duration
              ),
            ),
          ],
        ),
      ),
    );
  }
}
