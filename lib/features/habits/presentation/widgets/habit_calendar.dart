import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/constants/app_colors.dart';

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
                final isToday = dateKey.isAtSameMomentAs(DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0));
                if (frequency == 'Weekly' && !weekdays.contains(date.weekday)) {
                  return null;
                }
                if (events.containsKey(dateKey)) {
                  return Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success,
                      border: Border.all(color: AppColors.success.withOpacity(0.8), width: 2),
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
