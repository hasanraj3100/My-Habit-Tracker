import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/habit_repository.dart';
import '../../data/models/habit_model.dart';

class HabitProvider with ChangeNotifier {
  final HabitRepository _repository;
  List<String> _categories = [];
  bool _isLoading = false;
  String? _error;

  HabitProvider({HabitRepository? repository}) : _repository = repository ?? HabitRepository();

  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load categories
  Future<void> loadCategories() async {
    _setLoading(true);
    try {
      _categories = await _repository.getCategories();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    notifyListeners();
  }

  // Add a new category
  Future<void> addCategory(String category) async {
    _setLoading(true);
    try {
      await _repository.addCategory(category);
      _categories = await _repository.getCategories();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    notifyListeners();
  }

  // Create a new habit
  Future<void> createHabit(HabitModel habit) async {
    _setLoading(true);
    try {
      await _repository.createHabit(habit);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    notifyListeners();
  }

  // Update an existing habit
  Future<void> updateHabit(HabitModel habit) async {
    try {
      await _repository.updateHabit(habit);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
  }

  // Delete a habit
  Future<void> deleteHabit(String habitId) async {
    _setLoading(true);
    try {
      await _repository.deleteHabit(habitId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    notifyListeners();
  }

  // Get stream of habits
  Stream<List<HabitModel>> getHabits() {
    return _repository.getHabits();
  }

  // Get a single habit
  Future<HabitModel> getHabit(String habitId) async {
    _setLoading(true);
    try {
      final habit = await _repository.getHabit(habitId);
      _error = null;
      return habit;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Calculate streak for a habit
  Future<int> calculateStreak(List<String> history, String frequency, List<int> weekdays) async {
    if (history.isEmpty) return 0;
    history.sort((a, b) => b.compareTo(a));
    final parsed = history.map((d) => DateTime.parse(d)).toList();
    int streak = 0;
    final today = DateTime.now();

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

  // Toggle habit completion for today
  Future<void> toggleHabit(HabitModel habit) async {
    try {
      final updatedHistory = List<String>.from(habit.history);
      final today = DateFormat("yyyy-MM-dd").format(DateTime.now());
      if (updatedHistory.contains(today)) {
        updatedHistory.remove(today);
      } else {
        updatedHistory.add(today);
      }
      final streak = await calculateStreak(updatedHistory, habit.frequency, habit.weekdays);
      final newMaxStreak = streak > habit.maxStreak ? streak : habit.maxStreak;
      final updatedHabit = habit.copyWith(
        history: updatedHistory,
        streak: streak,
        maxStreak: newMaxStreak,
      );
      await updateHabit(updatedHabit); // silently update DB
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // Check if habit is done today
  bool isDoneToday(HabitModel habit) {
    return habit.history.contains(DateFormat("yyyy-MM-dd").format(DateTime.now()));
  }

  // Get calendar events for habit history
  Map<DateTime, bool> getCalendarEvents(HabitModel habit) {
    final events = <DateTime, bool>{};
    for (var dateStr in habit.history) {
      final date = DateTime.parse(dateStr);
      events[DateTime(date.year, date.month, date.day)] = true;
    }
    return events;
  }

  // Get missed days for habit
  List<DateTime> getMissedDays(HabitModel habit) {
    final missedDays = <DateTime>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 365));

    for (var date = start; date.isBefore(today); date = date.add(const Duration(days: 1))) {
      final dateKey = DateFormat("yyyy-MM-dd").format(date);
      final isExpected =
          habit.frequency == 'Daily' || (habit.frequency == 'Weekly' && habit.weekdays.contains(date.weekday));
      if (isExpected && !habit.history.contains(dateKey)) {
        missedDays.add(DateTime(date.year, date.month, date.day));
      }
    }
    return missedDays;
  }

  // Get chart data for habit completion rate
  List<FlSpot> getChartData(HabitModel habit, bool isWeekly) {
    final spots = <FlSpot>[];
    final now = DateTime.now();

    if (isWeekly) {
      for (int i = 7; i >= 0; i--) {
        final weekStart = now.subtract(Duration(days: now.weekday + 7 * i));
        final weekEnd = weekStart.add(const Duration(days: 6));
        int totalDays = habit.frequency == 'Daily' ? 7 : habit.weekdays.length;
        if (totalDays == 0) totalDays = 1;
        int completedDays = 0;

        for (var dateStr in habit.history) {
          final date = DateTime.parse(dateStr);
          if (date.isAfter(weekStart) && date.isBefore(weekEnd.add(const Duration(days: 1)))) {
            if (habit.frequency == 'Daily' || habit.weekdays.contains(date.weekday)) {
              completedDays++;
            }
          }
        }
        final percentage = (completedDays / totalDays) * 100;
        spots.add(FlSpot(7 - i.toDouble(), percentage));
      }
    } else {
      for (int i = 5; i >= 0; i--) {
        final monthStart = DateTime(now.year, now.month - i, 1);
        final monthEnd = DateTime(now.year, now.month - i + 1, 1).subtract(const Duration(days: 1));
        int totalDays =
        habit.frequency == 'Daily' ? monthEnd.day : habit.weekdays.length * ((monthEnd.day / 7).ceil());
        if (totalDays == 0) totalDays = 1;
        int completedDays = 0;

        for (var dateStr in habit.history) {
          final date = DateTime.parse(dateStr);
          if (date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
              date.isBefore(monthEnd.add(const Duration(days: 1)))) {
            if (habit.frequency == 'Daily' || habit.weekdays.contains(date.weekday)) {
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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}