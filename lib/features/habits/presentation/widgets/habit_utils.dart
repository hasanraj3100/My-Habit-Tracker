import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

int calculateStreak(List<String> history, String frequency, List<dynamic> weekdays) {
  if (history.isEmpty) return 0;
  history.sort((a, b) => b.compareTo(a));
  final parsed = history.map((d) => DateTime.parse(d)).toList();
  int streak = 0;
  DateTime today = DateTime.now();

  if (frequency == "Daily") {
    DateTime check = today;
    for (var date in parsed) {
      if (date.year == check.year && date.month == check.month && date.day == check.day) {
        streak++;
        check = check.subtract(const Duration(days: 1));
      } else break;
    }
  } else if (frequency == "Weekly") {
    DateTime check = today;
    while (true) {
      if (weekdays.contains(check.weekday)) {
        bool matched = parsed.any((d) => d.year == check.year && d.month == check.month && d.day == check.day);
        if (matched) {
          streak++;
          check = check.subtract(const Duration(days: 7));
        } else break;
      } else {
        check = check.subtract(const Duration(days: 1));
        if (check.isBefore(parsed.last)) break;
      }
    }
  }
  return streak;
}

bool isDoneToday(Map<String, dynamic> data, String todayKey) {
  final history = List<String>.from(data['history'] ?? []);
  return history.contains(todayKey);
}

Map<DateTime, bool> getCalendarEvents(List<String> history) {
  final events = <DateTime, bool>{};
  for (var dateStr in history) {
    final date = DateTime.parse(dateStr);
    events[DateTime(date.year, date.month, date.day)] = true;
  }
  return events;
}

List<DateTime> getMissedDays(List<String> history, String frequency, List<int> weekdays) {
  final missedDays = <DateTime>[];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final start = today.subtract(const Duration(days: 365));

  for (var date = start; date.isBefore(today); date = date.add(const Duration(days: 1))) {
    final dateKey = "${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}";
    final isExpected = frequency == 'Daily' || (frequency == 'Weekly' && weekdays.contains(date.weekday));
    if (isExpected && !history.contains(dateKey)) {
      missedDays.add(DateTime(date.year, date.month, date.day));
    }
  }
  return missedDays;
}

Future<void> toggleHabit(DocumentReference docRef, Map<String, dynamic> data) async {
  final history = List<String>.from(data['history'] ?? []);
  final today = "${DateTime.now().toIso8601String().split('T').first}";
  if (history.contains(today)) {
    history.remove(today);
  } else {
    history.add(today);
  }
  final streak = calculateStreak(history, data['frequency'], data['weekdays'] ?? []);
  final maxStreak = (data['maxStreak'] is int) ? data['maxStreak'] : 0;
  final newMaxStreak = streak > maxStreak ? streak : maxStreak;

  await docRef.update({
    'history': history,
    'streak': streak,
    'maxStreak': newMaxStreak,
  });
}

List<FlSpot> getChartData(Map<String, dynamic> data, bool isWeekly) {
  final history = List<String>.from(data['history'] ?? []);
  final frequency = data['frequency'] ?? 'Daily';
  final weekdays = List<int>.from(data['weekdays'] ?? []);
  final now = DateTime.now();
  final spots = <FlSpot>[];

  if (isWeekly) {
    for (int i = 7; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: now.weekday + 7 * i));
      final weekEnd = weekStart.add(const Duration(days: 6));
      int totalDays = frequency == 'Daily' ? 7 : weekdays.length;
      if (totalDays == 0) totalDays = 1;
      int completedDays = history.where((d) {
        final date = DateTime.parse(d);
        return date.isAfter(weekStart) && date.isBefore(weekEnd.add(const Duration(days: 1))) &&
            (frequency == 'Daily' || weekdays.contains(date.weekday));
      }).length;
      spots.add(FlSpot(7 - i.toDouble(), (completedDays / totalDays) * 100));
    }
  } else {
    for (int i = 5; i >= 0; i--) {
      final monthStart = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(now.year, now.month - i + 1, 1).subtract(const Duration(days: 1));
      int totalDays = frequency == 'Daily' ? monthEnd.day : weekdays.length * ((monthEnd.day / 7).ceil());
      if (totalDays == 0) totalDays = 1;
      int completedDays = history.where((d) {
        final date = DateTime.parse(d);
        return date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
            date.isBefore(monthEnd.add(const Duration(days: 1))) &&
            (frequency == 'Daily' || weekdays.contains(date.weekday));
      }).length;
      spots.add(FlSpot(5 - i.toDouble(), (completedDays / totalDays) * 100));
    }
  }
  return spots;
}
