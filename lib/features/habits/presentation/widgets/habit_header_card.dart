import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_habit_tracker/core/extensions%20/theme_extension.dart';
import 'habit_utils.dart';

class HabitHeaderCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool done;
  final String habitId;

  const HabitHeaderCard({
    super.key,
    required this.data,
    required this.done,
    required this.habitId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['category'] ?? '',
            style: TextStyle(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data['title'] ?? 'Untitled',
            style: TextStyle(
              color: context.colors.textPrimary,
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
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Max Streak: ${(data['maxStreak'] is int) ? data['maxStreak'] : 0}',
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => toggleHabit(
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('habits')
                      .doc(habitId),
                  data,
                ),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: context.colors.textSecondary.withOpacity(.6), width: 1.4),
                    color: done ? context.colors.success.withOpacity(.15) : Colors.transparent,
                  ),
                  child: done
                      ? Icon(Icons.check, size: 20, color: context.colors.success)
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
          if (data['note'] != null && data['note'].isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              data['note'],
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
