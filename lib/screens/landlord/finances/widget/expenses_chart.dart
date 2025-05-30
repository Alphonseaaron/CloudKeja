import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting month names

// Renamed mainData to getThemedLineChartData for clarity and to accept parameters
LineChartData getThemedLineChartData({
  required BuildContext context, // To access Theme
  required Map<String, double> monthlyIncomeData, // "YYYY-MM": amount
  required bool isLoading,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  List<FlSpot> spots = [];
  List<String> monthLabels = []; // To store "MMM" labels for bottom titles

  if (!isLoading && monthlyIncomeData.isNotEmpty) {
    // Sort keys to ensure chronological order if not already sorted
    var sortedKeys = monthlyIncomeData.keys.toList()..sort();

    for (int i = 0; i < sortedKeys.length; i++) {
      String key = sortedKeys[i]; // "YYYY-MM"
      double income = monthlyIncomeData[key] ?? 0.0;
      spots.add(FlSpot(i.toDouble(), income / 1000)); // X-axis as index, Y-axis as income in thousands

      // Generate month labels from "YYYY-MM" keys
      try {
        DateTime date = DateFormat('yyyy-MM').parse(key);
        monthLabels.add(DateFormat('MMM').format(date));
      } catch (e) {
        monthLabels.add(''); // Fallback if parsing fails
      }
    }
  } else if (isLoading || monthlyIncomeData.isEmpty) {
    // Show a flat line or minimal data points if loading or no data
    // For 6 months, this would be 0 to 5 on x-axis
    int numberOfMonthsToShow = monthlyIncomeData.isEmpty ? 6 : monthlyIncomeData.length;
    if (numberOfMonthsToShow == 0 && isLoading) numberOfMonthsToShow = 6; // Default for loading skeleton

    for (int i = 0; i < numberOfMonthsToShow; i++) {
      spots.add(FlSpot(i.toDouble(), 0)); // Flat line at 0
       // Generate month labels for skeleton view
      DateTime monthDate = DateTime.now().subtract(Duration(days: (numberOfMonthsToShow - 1 - i) * 30));
      monthLabels.add(DateFormat('MMM').format(monthDate));
    }
     if (monthLabels.isEmpty && numberOfMonthsToShow > 0) { // Ensure monthLabels has some values for titles
        for (int i=0; i<numberOfMonthsToShow; ++i) monthLabels.add('...');
    }
  }

  double minY = 0;
  double maxY = 5; // Default max Y if no data
  if (spots.isNotEmpty) {
    minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    if (minY == maxY && minY == 0) { // All data is zero
        maxY = 5; // Set a sensible default max Y
    } else if (minY == maxY) { // All data points are the same non-zero value
        minY = 0; // Start y-axis from 0
        maxY = maxY * 1.5; // Add some padding
    } else {
        minY = 0; // Always start y-axis from 0 for income
        maxY = maxY * 1.2; // Add 20% padding to max Y
    }
    if (maxY == 0) maxY = 5; // Ensure maxY is not 0 if all incomes are 0
  }

  double maxX = spots.isNotEmpty ? (spots.length - 1).toDouble() : 5.0; // Default if no spots
  if (maxX < 1 && spots.length == 1) maxX = 1; // Ensure chart can draw if only one data point

  return LineChartData(
    gridData: FlGridData(
      show: true,
      drawVerticalLine: true,
      horizontalInterval: maxY / (maxY > 10 ? 5 : (maxY > 2 ? maxY/2 : 1)), // Dynamic interval
      verticalInterval: 1, // Show line for each month if possible
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
          interval: 1, // Show label for each spot
          getTitlesWidget: (value, meta) {
            int index = value.toInt();
            if (index >= 0 && index < monthLabels.length) {
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8.0,
                child: Text(monthLabels[index], style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: maxY / (maxY > 10 ? 5 : (maxY > 2 ? maxY/2 : 1)), // Dynamic interval
          getTitlesWidget: (value, meta) => Text(
            '${value.toInt()}k', // Assuming Y is in thousands
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          reservedSize: 42,
        ),
      ),
    ),
    borderData: FlBorderData(show: true, border: Border.all(color: colorScheme.outline.withOpacity(0.3))),
    minX: 0,
    maxX: maxX,
    minY: minY,
    maxY: maxY,
    lineTouchData: LineTouchData(
      enabled: !isLoading, // Disable touch if loading
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: colorScheme.surfaceVariant.withOpacity(0.9),
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((touchedSpot) {
            final monthIndex = touchedSpot.spotIndex;
            String monthLabel = (monthIndex >= 0 && monthIndex < monthLabels.length) ? monthLabels[monthIndex] : '';
            return LineTooltipItem(
              '${monthLabel.isNotEmpty ? monthLabel + ": " : ""}KES ${(touchedSpot.y * 1000).toStringAsFixed(0)}',
              textTheme.bodySmall!.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
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
        gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.3)]),
        barWidth: 3, // Slightly thicker line
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: spots.length < 15, // Show dots if not too many points
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            radius: 3,
            color: colorScheme.primary,
            strokeWidth: 1,
            strokeColor: colorScheme.surface, // Dot border to match chart background
          )
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [colorScheme.primary.withOpacity(0.2), colorScheme.primary.withOpacity(0.0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      // Removed the second static LineChartBarData as per instructions for now
    ],
  );
}
