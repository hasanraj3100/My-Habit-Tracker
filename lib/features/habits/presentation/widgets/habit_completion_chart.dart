import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import 'habit_utils.dart'; // Make sure this file contains the getChartData function

class HabitCompletionChart extends StatefulWidget {
  final Map<String, dynamic> data;

  const HabitCompletionChart({
    super.key,
    required this.data,
  });

  @override
  State<HabitCompletionChart> createState() => _HabitCompletionChartState();
}

class _HabitCompletionChartState extends State<HabitCompletionChart> {
  bool _isWeekly = true; // State is now managed locally

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Completion Rate',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ChoiceChip(
                    label: const Text('Weekly'),
                    selected: _isWeekly,
                    onSelected: (selected) {
                      setState(() {
                        _isWeekly = true;
                      });
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: _isWeekly ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Monthly'),
                    selected: !_isWeekly,
                    onSelected: (selected) {
                      setState(() {
                        _isWeekly = false;
                      });
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: !_isWeekly ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) => AppColors.surface, // Or Colors.white
                        getTooltipItems: (spots) => spots.map((spot) {
                          return LineTooltipItem(
                            '${spot.y.toInt()}%',
                            const TextStyle(color: AppColors.textPrimary),
                          );
                        }).toList(),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: AppColors.textSecondary.withOpacity(0.1),
                        strokeWidth: 1,
                      ),
                      getDrawingVerticalLine: (value) => FlLine(
                        color: AppColors.textSecondary.withOpacity(0.1),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: 20,
                          getTitlesWidget: (value, meta) => Text(
                            '${value.toInt()}%',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) => Text(
                            _isWeekly ? 'W${value.toInt() + 1}' : 'M${value.toInt() + 1}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
                    ),
                    minX: 0,
                    maxX: _isWeekly ? 6 : 5,
                    minY: 0,
                    maxY: 100,
                    lineBarsData: [
                      LineChartBarData(
                        spots: getChartData(widget.data, _isWeekly),
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withOpacity(0.15),
                        ),
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}