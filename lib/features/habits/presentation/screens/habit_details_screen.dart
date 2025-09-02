import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:my_habit_tracker/core/extensions%20/theme_extension.dart';
import '../widgets/habit_calendar.dart';
import '../widgets/habit_completion_chart.dart';
import '../widgets/habit_delete_button.dart';
import '../widgets/habit_header_card.dart';
import '../widgets/habit_utils.dart';

class HabitDetailsScreen extends StatefulWidget {
  final String habitId;

  const HabitDetailsScreen({super.key, required this.habitId});

  @override
  State<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends State<HabitDetailsScreen> {

  @override
  void initState() {
    super.initState();
    _updateMaxStreak();
  }

  String _todayKey() => DateFormat("yyyy-MM-dd").format(DateTime.now());

  Stream<DocumentSnapshot<Map<String, dynamic>>> _habitStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty() as Stream<DocumentSnapshot<Map<String, dynamic>>>;
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('habits')
        .doc(widget.habitId)
        .snapshots();
  }

  Future<void> _updateMaxStreak() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('habits')
        .doc(widget.habitId);

    final doc = await docRef.get();
    final data = doc.data();
    if (data == null) return;

    final streak = (data['streak'] is int) ? data['streak'] : 0;
    final maxStreak = (data['maxStreak'] is int) ? data['maxStreak'] : 0;

    if (streak > maxStreak) {
      await docRef.update({'maxStreak': streak});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _habitStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return  Center(
                child: Text('Habit not found',
                    style: TextStyle(color: context.colors.textSecondary)));
          }

          final data = snapshot.data!.data()!;
          final done = isDoneToday(data, _todayKey());
          final events = getCalendarEvents(List<String>.from(data['history'] ?? []));
          final missedDays = getMissedDays(
              List<String>.from(data['history'] ?? []),
              data['frequency'] ?? 'Daily',
              List<int>.from(data['weekdays'] ?? []));
          final frequency = data['frequency'] ?? 'Daily';
          final weekdays = List<int>.from(data['weekdays'] ?? []);
          final note = data['note'] ?? '';

          return Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HabitHeaderCard(
                      data: data,
                      done: done,
                      habitId: widget.habitId,
                    ),
                    const SizedBox(height: 16),

                    // --- Habit Note Card ---
                    if (note.isNotEmpty)
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        color: context.colors.surfaceMuted,
                        margin: const EdgeInsets.only(bottom: 24),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Note',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                note,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    HabitCalendar(
                      events: events,
                      missedDays: missedDays,
                      frequency: frequency,
                      weekdays: weekdays,
                    ),
                    const SizedBox(height: 24),
                    HabitCompletionChart(
                      data: data,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              HabitDeleteButton(habitId: widget.habitId),
            ],
          );
        },
      ),
    );
  }
}
