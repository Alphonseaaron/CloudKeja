import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting month names and currency

LineChartData getSPEarningsChartData({
  required BuildContext context,
  required Map<String, double> monthlyEarningsMap, // "YYYY-MM": totalEarningsForMonth
  required bool isLoading, // To show loading state on chart
}) {
  // Platform detection
  final TargetPlatform platform = Theme.of(context).platform;
  final bool isCupertino = platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

  // Theme access
  final materialTheme = Theme.of(context);
  final cupertinoTheme = CupertinoTheme.of(context); // Ensure this context can resolve CupertinoTheme

  // Colors and TextStyles based on platform
  final Color gridColor = isCupertino
      ? CupertinoColors.systemGrey4.resolveFrom(context).withOpacity(0.5)
      : materialTheme.colorScheme.outline.withOpacity(0.2);
  final Color borderColor = isCupertino
      ? CupertinoColors.systemGrey3.resolveFrom(context)
      : materialTheme.colorScheme.outline.withOpacity(0.3);
  final TextStyle labelTextStyle = isCupertino
      ? cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(color: CupertinoColors.secondaryLabel.resolveFrom(context))
      : materialTheme.textTheme.bodySmall!.copyWith(color: materialTheme.colorScheme.onSurfaceVariant);
  final Color tooltipBgColor = isCupertino
      ? CupertinoColors.systemGrey.withOpacity(0.9) // A darker grey for tooltip
      : materialTheme.colorScheme.surfaceContainerHighest.withOpacity(0.9);
  final TextStyle tooltipTextStyle = isCupertino
      ? cupertinoTheme.textTheme.caption1.copyWith(color: CupertinoColors.white, fontWeight: FontWeight.bold)
      : materialTheme.textTheme.bodySmall!.copyWith(color: materialTheme.colorScheme.onSurface, fontWeight: FontWeight.bold);
  final List<Color> lineGradientColors = isCupertino
      ? [cupertinoTheme.primaryColor, cupertinoTheme.primaryColor.withOpacity(0.3)]
      : [materialTheme.colorScheme.primary, materialTheme.colorScheme.primary.withOpacity(0.3)];
  final List<Color> belowBarGradientColors = isCupertino
      ? [cupertinoTheme.primaryColor.withOpacity(0.2), cupertinoTheme.primaryColor.withOpacity(0.0)]
      : [materialTheme.colorScheme.primary.withOpacity(0.2), materialTheme.colorScheme.primary.withOpacity(0.0)];
  final Color dotColor = isCupertino ? cupertinoTheme.primaryColor : materialTheme.colorScheme.primary;
  final Color dotStrokeColor = isCupertino ? cupertinoTheme.scaffoldBackgroundColor : materialTheme.colorScheme.surface;


  List<FlSpot> spots = [];
  List<String> monthLabels = []; // "MMM" format for X-axis

  if (!isLoading && monthlyEarningsMap.isNotEmpty) {
    // Keys are "YYYY-MM", already sorted by _prepareMonthlyEarningsChartData
    var sortedKeys = monthlyEarningsMap.keys.toList();

    for (int i = 0; i < sortedKeys.length; i++) {
      String key = sortedKeys[i]; // "YYYY-MM"
      double earnings = monthlyEarningsMap[key] ?? 0.0;
      // Y-axis: earnings, potentially scaled (e.g., in thousands if amounts are large)
      // For now, direct value. Scaling can be added if max value is very high.
      spots.add(FlSpot(i.toDouble(), earnings / 1000)); // Example: Show earnings in thousands (e.g., 1.5 for KES 1500)

      try {
        DateTime date = DateFormat('yyyy-MM').parse(key);
        monthLabels.add(DateFormat('MMM').format(date)); // "Jan", "Feb", etc.
      } catch (e) {
        monthLabels.add(''); // Fallback
        debugPrint("Error parsing month key for chart: $key, $e");
      }
    }
  } else { // isLoading or empty map
    int numberOfMonthsToShow = 6; // Default number of months for skeleton
    DateTime now = DateTime.now();
    for (int i = 0; i < numberOfMonthsToShow; i++) {
      spots.add(FlSpot(i.toDouble(), 0)); // Flat line at 0 for loading/empty
      DateTime monthDate = DateTime(now.year, now.month - (numberOfMonthsToShow - 1 - i), 1);
      monthLabels.add(DateFormat('MMM').format(monthDate));
    }
    if (monthLabels.isEmpty && numberOfMonthsToShow > 0) { // Fallback for monthLabels
        for (int i=0; i<numberOfMonthsToShow; ++i) monthLabels.add('...');
    }
  }

  double minY = 0;
  double maxY = 5; // Default max Y (representing 5k if units are thousands)
  if (spots.isNotEmpty && !isLoading) {
    double tempMaxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    if (tempMaxY == 0) { // All data is zero
        maxY = 5; // Sensible default if all earnings are 0
    } else {
        maxY = tempMaxY * 1.2; // Add 20% padding
    }
    // Min Y is always 0 for earnings
  }

  double maxX = spots.isNotEmpty ? (spots.length - 1).toDouble() : 5.0;
  if (maxX < 1 && spots.length == 1) maxX = 1.0; // Ensure chart can draw if only one data point

  return LineChartData(
    gridData: FlGridData(
      show: true,
      drawVerticalLine: true,
      horizontalInterval: maxY > 0 ? maxY / 5 : 1,
      verticalInterval: 1,
      getDrawingHorizontalLine: (value) => FlLine(color: gridColor, strokeWidth: 0.5),
      getDrawingVerticalLine: (value) => FlLine(color: gridColor, strokeWidth: 0.5),
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
            int index = value.toInt();
            if (index >= 0 && index < monthLabels.length) {
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8.0,
                child: Text(monthLabels[index], style: labelTextStyle),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: maxY > 0 ? maxY / 5 : 1,
          getTitlesWidget: (value, meta) => Text('${value.toInt()}k', style: labelTextStyle),
          reservedSize: 42,
        ),
      ),
    ),
    borderData: FlBorderData(show: true, border: Border.all(color: borderColor)),
    minX: 0,
    maxX: maxX,
    minY: minY,
    maxY: maxY,
    lineTouchData: LineTouchData(
      enabled: !isLoading,
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: tooltipBgColor,
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((touchedSpot) {
            final monthIndex = touchedSpot.spotIndex;
            String monthLabel = (monthIndex >= 0 && monthIndex < monthLabels.length) ? monthLabels[monthIndex] : '';
            return LineTooltipItem(
              '${monthLabel.isNotEmpty ? monthLabel + ": " : ""}KES ${(touchedSpot.y * 1000).toStringAsFixed(0)}',
              tooltipTextStyle,
            );
          }).toList();
        },
      ),
      handleBuiltInTouches: true,
    ),
    lineBarsData: [
      LineChartBarData(
        spots: spots,
        isCurved: true,
        gradient: LinearGradient(colors: lineGradientColors),
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: spots.length < 15 && spots.any((s) => s.y > 0),
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            radius: 3,
            color: dotColor,
            strokeWidth: 1,
            strokeColor: dotStrokeColor,
          )
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: belowBarGradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    ],
  );
}
