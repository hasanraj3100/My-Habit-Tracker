import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';

class HabitDetailsScreen extends StatefulWidget {
  final String habitId;

  const HabitDetailsScreen({super.key, required this.habitId});

  @override
  State<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends State<HabitDetailsScreen> {
  bool _isChartWeekly = false;

  String _todayKey() => DateFormat("yyyy-MM-dd").format(DateTime.now());

  Future<Map<String, dynamic>?> _fetchHabit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('habits')
        .doc(widget.habitId)
        .get();
    return doc.data();
  }

  Future<void> _toggleHabit(DocumentReference docRef, Map<String, dynamic> data) async {
    final history = List<String>.from(data['history'] ?? []);
    final today = _todayKey();

    if (history.contains(today)) {
      history.remove(today);
    } else {
      history.add(today);
    }

    final streak = _calculateStreak(history, data['frequency'], data['weekdays'] ?? []);
    final maxStreak = (data['maxStreak'] is int) ? data['maxStreak'] : 0;
    final newMaxStreak = streak > maxStreak ? streak : maxStreak;

    await docRef.update({
      'history': history,
      'streak': streak,
      'maxStreak': newMaxStreak,
    });
  }

  int _calculateStreak(List<String> history, String frequency, List<dynamic> weekdays) {
    if (history.isEmpty) return 0;

    history.sort((a, b) => b.compareTo(a)); // latest first
    final parsed = history.map((d) => DateTime.parse(d)).toList();

    int streak = 0;
    DateTime today = DateTime.now();

    if (frequency == "Daily") {
      DateTime check = today;
      for (var date in parsed) {
        if (date.year == check.year && date.month == check.month && date.day == check.day) {
          streak++;
          check = check.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    } else if (frequency == "Weekly") {
      DateTime check = today;
      while (true) {
        if (weekdays.contains(check.weekday)) {
          bool matched = parsed.any((d) =>
          d.year == check.year && d.month == check.month && d.day == check.day);
          if (matched) {
            streak++;
            check = check.subtract(const Duration(days: 7));
          } else {
            break;
          }
        } else {
          check = check.subtract(const Duration(days: 1));
          if (check.isBefore(parsed.last)) break;
        }
      }
    }

    return streak;
  }

  bool _isDoneToday(Map<String, dynamic> data) {
    final history = List<String>.from(data['history'] ?? []);
    return history.contains(_todayKey());
  }

  Map<DateTime, bool> _getCalendarEvents(List<String> history, String frequency, List<int> weekdays) {
    final events = <DateTime, bool>{};
    for (var dateStr in history) {
      final date = DateTime.parse(dateStr);
      events[DateTime(date.year, date.month, date.day)] = true;
    }
    return events;
  }

  List<FlSpot> _getChartData(Map<String, dynamic> data, bool isWeekly) {
    final history = List<String>.from(data['history'] ?? []);
    final frequency = data['frequency'] ?? 'Daily';
    final weekdays = List<int>.from(data['weekdays'] ?? []);
    final now = DateTime.now();
    final spots = <FlSpot>[];

    if (isWeekly) {
      // Weekly completion % for the last 8 weeks
      for (int i = 7; i >= 0; i--) {
        final weekStart = now.subtract(Duration(days: now.weekday + 7 * i));
        final weekEnd = weekStart.add(const Duration(days: 6));
        int totalDays = frequency == 'Daily' ? 7 : weekdays.length;
        if (totalDays == 0) totalDays = 1; // Avoid division by zero
        int completedDays = 0;

        for (var dateStr in history) {
          final date = DateTime.parse(dateStr);
          if (date.isAfter(weekStart) && date.isBefore(weekEnd.add(const Duration(days: 1)))) {
            if (frequency == 'Daily' || weekdays.contains(date.weekday)) {
              completedDays++;
            }
          }
        }
        final percentage = (completedDays / totalDays) * 100;
        spots.add(FlSpot(7 - i.toDouble(), percentage));
      }
    } else {
      // Monthly completion % for the last 6 months
      for (int i = 5; i >= 0; i--) {
        final monthStart = DateTime(now.year, now.month - i, 1);
        final monthEnd = DateTime(now.year, now.month - i + 1, 1).subtract(const Duration(days: 1));
        int totalDays = frequency == 'Daily' ? monthEnd.day : weekdays.length * ((monthEnd.day / 7).ceil());
        if (totalDays == 0) totalDays = 1; // Avoid division by zero
        int completedDays = 0;

        for (var dateStr in history) {
          final date = DateTime.parse(dateStr);
          if (date.isAfter(monthStart.subtract(const Duration(days: 1))) && date.isBefore(monthEnd.add(const Duration(days: 1)))) {
            if (frequency == 'Daily' || weekdays.contains(date.weekday)) {
              completedDays++;
            }
          }
        }
        final percentage = (completedDays / totalDays) * 100;
        spots.add(FlSpot(5 - i.toDouble(), percentage));
      }
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchHabit(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Habit not found', style: TextStyle(color: AppColors.textSecondary)));
          }

          final data = snapshot.data!;
          final done = _isDoneToday(data);
          final events = _getCalendarEvents(List<String>.from(data['history'] ?? []), data['frequency'] ?? 'Daily', List<int>.from(data['weekdays'] ?? []));
          final frequency = data['frequency'] ?? 'Daily';
          final weekdays = List<int>.from(data['weekdays'] ?? []);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['category'] ?? '',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['title'] ?? 'Untitled',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Streak: ${data['streak'] ?? 0}',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Max Streak: ${(data['maxStreak'] is int) ? data['maxStreak'] : 0}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () => _toggleHabit(
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('habits')
                                    .doc(widget.habitId),
                                data,
                              ),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.textSecondary.withOpacity(.6), width: 1.4),
                                  color: done ? AppColors.success.withOpacity(.15) : Colors.transparent,
                                ),
                                child: done
                                    ? const Icon(Icons.check, size: 20, color: AppColors.success)
                                    : const SizedBox.shrink(),
                              ),
                            ),
                          ],
                        ),
                        if (data['note'] != null && data['note'].isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            data['note'],
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Calendar
                  const Text(
                    'Completion History',
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
                    child: TableCalendar(
                      firstDay: DateTime.now().subtract(const Duration(days: 365)),
                      lastDay: DateTime.now(),
                      focusedDay: DateTime.now(),
                      calendarFormat: CalendarFormat.month,
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        defaultTextStyle: const TextStyle(color: AppColors.textPrimary),
                        weekendTextStyle: const TextStyle(color: AppColors.textPrimary),
                        outsideTextStyle: const TextStyle(color: AppColors.textSecondary),
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(color: AppColors.textSecondary),
                        weekendStyle: TextStyle(color: AppColors.textSecondary),
                      ),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, _) {
                          final dateKey = DateTime(date.year, date.month, date.day);
                          if (frequency == 'Weekly' && !weekdays.contains(date.weekday)) {
                            return null; // Don't show markers for non-scheduled days
                          }
                          if (events.containsKey(dateKey)) {
                            return Container(
                              margin: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.success,
                              ),
                              width: 8,
                              height: 8,
                            );
                          }
                          return Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.textSecondary.withOpacity(0.3),
                            ),
                            width: 8,
                            height: 8,
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Frequency Chart
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
                              selected: _isChartWeekly,
                              onSelected: (_) => setState(() => _isChartWeekly = true),
                              selectedColor: AppColors.primary.withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: _isChartWeekly ? AppColors.primary : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('Monthly'),
                              selected: !_isChartWeekly,
                              onSelected: (_) => setState(() => _isChartWeekly = false),
                              selectedColor: AppColors.primary.withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: !_isChartWeekly ? AppColors.primary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: true),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
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
                                    getTitlesWidget: (value, meta) => Text(
                                      _isChartWeekly ? 'W${value.toInt() + 1}' : 'M${value.toInt() + 1}',
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
                              borderData: FlBorderData(show: true, border: Border.all(color: AppColors.textSecondary.withOpacity(0.2))),
                              minX: 0,
                              maxX: _isChartWeekly ? 7 : 5,
                              minY: 0,
                              maxY: 100,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _getChartData(data, _isChartWeekly),
                                  isCurved: true,
                                  color: AppColors.primary,
                                  barWidth: 3,
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: AppColors.primary.withOpacity(0.2),
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

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}