import 'package:flutter/material.dart';
import 'package:my_habit_tracker/core/extensions%20/theme_extension.dart';
import 'package:table_calendar/table_calendar.dart';

class HabitCalendar extends StatelessWidget {
  final Map<DateTime, bool> events;
  final List<DateTime> missedDays;
  final String frequency;
  final List<int> weekdays;

  const HabitCalendar({
    super.key,
    required this.events,
    required this.missedDays,
    required this.frequency,
    required this.weekdays,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Completion History',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surfaceMuted,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now(),
            focusedDay: DateTime.now(),
            calendarFormat: CalendarFormat.month,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: context.colors.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              defaultTextStyle: TextStyle(color: context.colors.textPrimary),
              weekendTextStyle: TextStyle(color: context.colors.textPrimary),
              outsideTextStyle: TextStyle(color: context.colors.textSecondary),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: context.colors.textSecondary),
              weekendStyle: TextStyle(color: context.colors.textSecondary),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, _) {
                final dateKey = DateTime(date.year, date.month, date.day);
                final isToday = dateKey.isAtSameMomentAs(DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0));
                if (frequency == 'Weekly' && !weekdays.contains(date.weekday)) {
                  return null;
                }
                if (events.containsKey(dateKey)) {
                  return Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.success,
                      border: Border.all(color: context.colors.success.withOpacity(0.8), width: 2),
                    ),
                    width: 12,
                    height: 12,
                  );
                }
                if (missedDays.contains(dateKey) && !isToday) {
                  return Container(
                    margin: const EdgeInsets.all(2),
                    child: const Icon(
                      Icons.close,
                      color: Colors.redAccent,
                      size: 16,
                    ),
                  );
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }
}
