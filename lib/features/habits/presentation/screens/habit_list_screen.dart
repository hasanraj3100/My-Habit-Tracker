import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import 'habit_create_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class HabitListScreen extends StatefulWidget {
  const HabitListScreen({super.key});

  @override
  State<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  final List<String> _categories = ["Study", "Health", "Work", "Personal", "+ Add Category"];
  int _navIndex = 0;
  bool _sortFinishedBottom = false;

  String _todayKey() => DateFormat("yyyy-MM-dd").format(DateTime.now());

  int _todayWeekday() {
    // Dart: Monday=1, ..., Sunday=7
    return DateTime.now().weekday;
  }

  // Stream of habit documents for current user
  Stream<QuerySnapshot<Map<String, dynamic>>> _habitsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty() as Stream<QuerySnapshot<Map<String, dynamic>>>;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('habits')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _toggleHabit(DocumentReference docRef, Map<String, dynamic> data) async {
    final history = List<String>.from(data['history'] ?? []);
    final today = _todayKey();

    if (history.contains(today)) {
      // Uncheck → remove today
      history.remove(today);
    } else {
      // Check → add today
      history.add(today);
    }

    final streak = _calculateStreak(history, data['frequency'], data['weekdays'] ?? []);

    await docRef.update({
      'history': history,
      'streak': streak,
    });
  }

  bool _isDoneToday(Map<String, dynamic> data) {
    final history = List<String>.from(data['history'] ?? []);
    return history.contains(_todayKey());
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
      // check streak by week/day match
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

  Widget _navItem({required IconData icon, required int index}) {
    final selected = _navIndex == index;
    return IconButton(
      onPressed: () {
        if (index == 4) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          return;
        }
        setState(() => _navIndex = index);
      },
      icon: Icon(
        icon,
        color: selected ? AppColors.secondary : Colors.white.withOpacity(.85),
        size: selected ? 28 : 24,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Header + Quote =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 44, 16, 24),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                image: const DecorationImage(
                  image: AssetImage("assets/images/header_bg.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  // top row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white.withOpacity(.9),
                            child: const Icon(Icons.person, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Hello,", style: TextStyle(color: Colors.white, fontSize: 14)),
                              Text("Tony Stark",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _roundIconButton(Icons.nightlight_round, onPressed: () {}),
                          const SizedBox(width: 10),
                          _roundIconButton(Icons.notifications_none_rounded, onPressed: () {}),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "We are what we repeatedly do.\nExcellence, then, is not an act,\nbut a habit.",
                      style: TextStyle(
                          color: Colors.white.withOpacity(.95),
                          fontSize: 20,
                          height: 1.35,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ===== Categories =====
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Categories",
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, i) {
                  final isAdd = _categories[i].startsWith('+');
                  return ChoiceChip(
                    label: Text(_categories[i]),
                    selected: false,
                    onSelected: (_) {
                      if (isAdd) {
                        // TODO: Add category
                      }
                    },
                    labelStyle: const TextStyle(
                        color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    backgroundColor: isAdd ? Colors.white : AppColors.surface,
                    shape: StadiumBorder(
                      side: BorderSide(
                          color: isAdd
                              ? AppColors.textSecondary.withOpacity(.35)
                              : AppColors.primary.withOpacity(.35),
                          width: 1.2),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemCount: _categories.length,
              ),
            ),

            const SizedBox(height: 24),

            // ===== Ongoing Tasks =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Ongoing Tasks",
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  IconButton(
                    icon: Icon(
                        _sortFinishedBottom ? Icons.sort_by_alpha : Icons.sort,
                        color: AppColors.textSecondary),
                    onPressed: () =>
                        setState(() => _sortFinishedBottom = !_sortFinishedBottom),
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),

            // habits list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _habitsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                            child: Text("No habits yet. Add one!",
                                style: TextStyle(color: AppColors.textSecondary))));
                  }

                  var docs = snapshot.data!.docs;

                  if (_sortFinishedBottom) {
                    docs.sort((a, b) {
                      final aDone = _isDoneToday(a.data());
                      final bDone = _isDoneToday(b.data());
                      if (aDone == bDone) return 0;
                      return aDone ? 1 : -1;
                    });
                  }

                  final todayWeekday = _todayWeekday();
                  return Column(
                    children: docs.where((doc) {
                      final data = doc.data();
                      final frequency = data['frequency'] ?? '';
                      final weekdays = List<int>.from(data['weekdays'] ?? []);
                      // Show daily habits or weekly habits where today is a scheduled day
                      return frequency == 'Daily' || (frequency == 'Weekly' && weekdays.contains(todayWeekday));
                    }).map((doc) {
                      final data = doc.data();
                      final done = _isDoneToday(data);

                      return _HabitCard(
                        title: data['title'] ?? 'Untitled',
                        category: data['category'] ?? '',
                        frequency: data['frequency'] ?? '',
                        weekdays: List<int>.from(data['weekdays'] ?? []),
                        streak: (data['streak'] is int) ? data['streak'] : 0,
                        done: done,
                        onToggle: () => _toggleHabit(doc.reference, data),
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            const SizedBox(height: 96),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        height: 68,
        width: 68,
        child: FloatingActionButton(
          heroTag: 'fab_add_habit',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HabitCreateScreen()),
            );
          },
          backgroundColor: AppColors.primary,
          elevation: 8,
          child: const Icon(Icons.add, size: 34, color: Colors.white),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomAppBar(
            color: AppColors.textPrimary.withOpacity(.9),
            elevation: 8,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            child: SizedBox(
              height: 68,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(icon: Icons.home_rounded, index: 0),
                  _navItem(icon: Icons.favorite_border_rounded, index: 1),
                  const SizedBox(width: 48),
                  _navItem(icon: Icons.settings_rounded, index: 3),
                  _navItem(icon: Icons.person_rounded, index: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ====== Widgets ======

class _HabitCard extends StatelessWidget {
  final String title;
  final String category;
  final String frequency;
  final List<int> weekdays;
  final int streak;
  final bool done;
  final VoidCallback onToggle;

  const _HabitCard({
    required this.title,
    required this.category,
    required this.frequency,
    required this.weekdays,
    required this.streak,
    required this.done,
    required this.onToggle,
  });

  String _weekdayLabel(List<int> days) {
    if (days.isEmpty) return "";
    const labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days.map((d) => labels[d - 1]).join(", ");
  }

  @override
  Widget build(BuildContext context) {
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
            onTap: onToggle,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.textSecondary.withOpacity(.6), width: 1.4),
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
                Text(category,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
                const SizedBox(height: 4),
                Text(title,
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        decoration: done
                            ? TextDecoration.lineThrough
                            : TextDecoration.none)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.textSecondary.withOpacity(.25)),
                  ),
                  child: Text(
                    frequency == "Weekly"
                        ? "Weekly (${_weekdayLabel(weekdays)})"
                        : frequency,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("$streak",
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary)),
              const Text("Streak",
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _roundIconButton(IconData icon, {required VoidCallback onPressed}) {
  return Material(
    color: Colors.white.withOpacity(.25),
    shape: const CircleBorder(),
    child: InkWell(
      onTap: onPressed,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, color: Colors.white),
      ),
    ),
  );
}