import 'package:flutter/material.dart';
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
    _setLoading(true);
    try {
      await _repository.updateHabit(habit);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    notifyListeners();
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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}