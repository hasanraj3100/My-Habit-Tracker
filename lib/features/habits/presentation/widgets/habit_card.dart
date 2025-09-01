import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/habit_model.dart';
import '../providers/habit_provider.dart';

class HabitCard extends StatefulWidget {
  final HabitModel habit;

  const HabitCard({required this.habit, super.key});

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  late bool done;

  @override
  void initState() {
    super.initState();
    final today = DateFormat("yyyy-MM-dd").format(DateTime.now());
    done = widget.habit.history.contains(today);
  }

  void _toggleDone() async {
    setState(() => done = !done);

    final provider = Provider.of<HabitProvider>(context, listen: false);
    final today = DateFormat("yyyy-MM-dd").format(DateTime.now());
    final updatedHistory = List<String>.from(widget.habit.history);

    if (done) {
      updatedHistory.add(today);
    } else {
      updatedHistory.remove(today);
    }

    final streak = await provider.calculateStreak(
      updatedHistory,
      widget.habit.frequency,
      widget.habit.weekdays,
    );

    final updatedHabit = widget.habit.copyWith(
      history: updatedHistory,
      streak: streak,
    );

    provider.updateHabit(updatedHabit); // silently update DB
  }

  String _weekdayLabel(List<int> days) {
    if (days.isEmpty) return "";
    const labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days.map((d) => labels[d - 1]).join(", ");
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: _toggleDone,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.textSecondary.withOpacity(.6),
                  width: 1.4,
                ),
                color: done ? AppColors.success.withOpacity(.15) : Colors.transparent,
              ),
              child: done
                  ? const Icon(Icons.check, size: 18, color: AppColors.success)
                  : const SizedBox.shrink(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.category,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  habit.title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.textSecondary.withOpacity(.6),
                      width: 1.4,
                    ),
                  ),
                  child: Text(
                    habit.frequency == "Weekly"
                        ? "Weekly (${_weekdayLabel(habit.weekdays)})"
                        : habit.frequency,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${habit.streak}",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                "Streak",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
