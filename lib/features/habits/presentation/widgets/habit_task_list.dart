import 'package:flutter/material.dart';
import 'package:my_habit_tracker/core/extensions%20/theme_extension.dart';
import 'package:provider/provider.dart';
import '../../data/models/habit_model.dart';
import '../providers/habit_provider.dart';
import '../screens/habit_details_screen.dart';
import 'habit_card.dart';

class HabitTaskList extends StatelessWidget {
  final bool sortFinishedBottom;
  final String todayKey;
  final int todayWeekday;
  final String selectedCategoryFilter;

  const HabitTaskList({
    super.key,
    required this.sortFinishedBottom,
    required this.todayKey,
    required this.todayWeekday,
    required this.selectedCategoryFilter,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HabitProvider>(context);

    return StreamBuilder<List<HabitModel>>(
      stream: provider.getHabits(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              "No habits yet. Add one!",
              style: TextStyle(color: context.colors.textSecondary),
            ),
          );
        }

        var habits = snapshot.data!;
        if (sortFinishedBottom) {
          habits.sort((a, b) {
            final aDone = a.history.contains(todayKey);
            final bDone = b.history.contains(todayKey);
            if (aDone == bDone) return 0;
            return aDone ? 1 : -1;
          });
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: habits.length,
          itemBuilder: (context, index) {
            final habit = habits[index];

            // Filter by frequency and category
            final matchesFrequency = habit.frequency == 'Daily' ||
                (habit.frequency == 'Weekly' && habit.weekdays.contains(todayWeekday));
            final matchesCategory =
                selectedCategoryFilter.isEmpty || habit.category == selectedCategoryFilter;

            if (!matchesFrequency || !matchesCategory) {
              return const SizedBox.shrink();
            }

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HabitDetailsScreen(habitId: habit.id!),
                  ),
                );
              },
              child: HabitCard(habit: habit),
            );
          },
        );
      },
    );
  }
}
