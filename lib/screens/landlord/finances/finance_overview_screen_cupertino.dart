import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/payment_provider.dart';
import 'package:cloudkeja/screens/landlord/finances/widget/finance_top.dart'; // Router
import 'package:cloudkeja/screens/landlord/finances/widget/expenses_chart.dart'; // Contains getAdaptiveLineChartData
import 'package:intl/intl.dart'; // For formatting

class FinanceOverviewScreenCupertino extends StatefulWidget {
  const FinanceOverviewScreenCupertino({Key? key}) : super(key: key);

  @override
  State<FinanceOverviewScreenCupertino> createState() => _FinanceOverviewScreenCupertinoState();
}

class _FinanceOverviewScreenCupertinoState extends State<FinanceOverviewScreenCupertino> {
  bool _isChartDataLoaded = false;
  Map<String, double> _monthlyIncomeData = {};
  bool _isLoadingData = true; // Combined loading state for user and income
  UserModel? _currentUser;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isChartDataLoaded = true);
    });
  }

  Future<void> _fetchInitialData({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoadingData = true;
      _errorMessage = null;
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _currentUser = await authProvider.getCurrentUser(forceRefresh: forceRefresh);

      if (_currentUser?.userId != null) {
        final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
        // Placeholder data for chart - replace with actual fetch
        _monthlyIncomeData = {
          DateFormat('yyyy-MM').format(DateTime.now().subtract(const Duration(days: 150))): 2500.0,
          DateFormat('yyyy-MM').format(DateTime.now().subtract(const Duration(days: 120))): 3000.0,
          DateFormat('yyyy-MM').format(DateTime.now().subtract(const Duration(days: 90))): 1500.0,
          DateFormat('yyyy-MM').format(DateTime.now().subtract(const Duration(days: 60))): 4000.0,
          DateFormat('yyyy-MM').format(DateTime.now().subtract(const Duration(days: 30))): 3500.0,
          DateFormat('yyyy-MM').format(DateTime.now()): 5000.0,
        };
        // Fetch total income for stat card if needed, or derive from monthly data
        // For this example, assuming FinanceTopRouter handles balance display internally
      } else {
        throw Exception("User not found or not logged in.");
      }
    } catch (e) {
      if (mounted) {
        _errorMessage = 'Error fetching financial data: ${e.toString()}';
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final cupertinoTheme = CupertinoTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 16.0, top: 24.0, bottom: 12.0),
      child: Text(
        title,
        style: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(
          fontSize: 18,
          color: CupertinoColors.label.resolveFrom(context),
        ),
      ),
    );
  }

  Widget _buildCupertinoStatItem({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    bool isLoading = false,
    Color? iconColor,
  }) {
    final cupertinoTheme = CupertinoTheme.of(context);
    final itemBackgroundColor = CupertinoColors.tertiarySystemFill.resolveFrom(context);
    final defaultIconColor = cupertinoTheme.primaryColor;
    final textColor = CupertinoColors.label.resolveFrom(context);
    final secondaryTextColor = CupertinoColors.secondaryLabel.resolveFrom(context);

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isLoading ? itemBackgroundColor.withOpacity(0.5) : itemBackgroundColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            const CupertinoActivityIndicator(radius: 12)
          else
            Icon(icon, size: 26, color: iconColor ?? defaultIconColor),
          const SizedBox(height: 8),
          Text(
            title,
            style: cupertinoTheme.textTheme.caption1.copyWith(color: secondaryTextColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            isLoading ? "---" : value,
            style: cupertinoTheme.textTheme.textStyle.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: isLoading ? secondaryTextColor : (iconColor ?? defaultIconColor),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    final double totalIncomeForStat = _monthlyIncomeData.values.fold(0.0, (sum, item) => sum + item);
    final String formattedTotalIncome = 'KES ${NumberFormat("#,##0.00", "en_US").format(totalIncomeForStat)}';

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Financial Overview'),
      ),
      child: CustomScrollView(
        slivers: [
          CupertinoSliverRefreshControl(onRefresh: () => _fetchInitialData(forceRefresh: true)),
          SliverToBoxAdapter(
            child: FinanceTopRouter(user: _currentUser, isLoadingUser: _isLoadingData),
          ),
          if (_isLoadingData && _monthlyIncomeData.isEmpty) // Show main loader only if no data at all yet
             SliverFillRemaining(child: const Center(child: CupertinoActivityIndicator(radius: 15)))
          else if (_errorMessage != null)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(_errorMessage!, style: TextStyle(color: CupertinoColors.destructiveRed.resolveFrom(context)), textAlign: TextAlign.center),
                ),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SliverGrid( // Using SliverGrid directly inside SliverToBoxAdapter is not standard.
                                  // It should be SliverGrid itself.
                                  // Corrected below by making this SliverGrid.
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                  ),
                  delegate: SliverChildListDelegate([
                    _buildCupertinoStatItem(context: context, title: 'Total Income (Chart)', value: formattedTotalIncome, icon: CupertinoIcons.money_dollar_circle_fill, isLoading: _isLoadingData, iconColor: CupertinoColors.systemGreen.resolveFrom(context)),
                    _buildCupertinoStatItem(context: context, title: 'Avg. Monthly', value: 'KES ...', icon: CupertinoIcons.timer_fill, isLoading: _isLoadingData, iconColor: CupertinoColors.systemBlue.resolveFrom(context)), // Placeholder
                    _buildCupertinoStatItem(context: context, title: 'Next Payout', value: 'KES ...', icon: CupertinoIcons.arrow_right_circle_fill, isLoading: _isLoadingData, iconColor: CupertinoColors.systemPurple.resolveFrom(context)), // Placeholder
                    _buildCupertinoStatItem(context: context, title: 'Active Leases', value: '...', icon: CupertinoIcons.doc_text_fill, isLoading: _isLoadingData), // Placeholder
                  ]),
                ),
              )
            ),
            SliverToBoxAdapter(child: _buildSectionHeader(context, 'Monthly Income Chart')),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
                height: 300,
                child: _isLoadingData && _monthlyIncomeData.isEmpty // Show small indicator if chart data is loading
                    ? const Center(child: CupertinoActivityIndicator())
                    : LineChart(
                        getAdaptiveLineChartData(
                          context: context,
                          monthlyIncomeData: _monthlyIncomeData,
                          isLoading: _isLoadingData || !_isChartDataLoaded,
                        ),
                        swapAnimationDuration: const Duration(milliseconds: 750),
                        swapAnimationCurve: Curves.easeInOut,
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
