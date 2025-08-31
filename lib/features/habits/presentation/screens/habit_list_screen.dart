import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HabitListScreen extends StatefulWidget {
  const HabitListScreen({super.key});

  @override
  State<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  // Static demo data
  final List<Map<String, dynamic>> _habits = [
    {
      "title": "Walk 3 KM",
      "category": "Fitness",
      "frequency": "Daily",
      "streak": 23,
      "done": true,
    },
    {
      "title": "Drink 8 glass of water",
      "category": "Health",
      "frequency": "Daily",
      "streak": 15,
      "done": false,
    },
    {
      "title": "Study Math",
      "category": "Study",
      "frequency": "Weekly",
      "streak": 3,
      "done": false,
    },
  ];

  final List<String> _categories = ["Study", "Health", "Work", "Personal", "+ Add Category"];

  void _toggleDone(int i) {
    setState(() => _habits[i]["done"] = !_habits[i]["done"]);
  }

  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Header + Quote (ONLY this has the background image) =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 20 + 24, 16, 24), // safe-ish top
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                image: const DecorationImage(
                  image: AssetImage("assets/images/header_bg.jpg"), // add to pubspec
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
                              Text(
                                "Tony Stark",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
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
                  // quote
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "We are what we repeatedly do.\nExcellence, then, is not an act,\nbut a habit.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.95),
                        fontSize: 20,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ===== Categories =====
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Categories",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
                    onSelected: (_) {},
                    labelStyle: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: isAdd ? Colors.white : AppColors.surface,
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: isAdd ? AppColors.textSecondary.withOpacity(.35) : AppColors.primary.withOpacity(.35),
                        width: 1.2,
                      ),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemCount: _categories.length,
              ),
            ),

            const SizedBox(height: 24),

            // ===== Ongoing Tasks =====
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Ongoing Tasks",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // habit cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: List.generate(_habits.length, (i) {
                  final h = _habits[i];
                  return _HabitCard(
                    title: h["title"],
                    category: h["category"],
                    frequency: h["frequency"],
                    streak: h["streak"],
                    done: h["done"],
                    onToggle: () => _toggleDone(i),
                  );
                }),
              ),
            ),

            const SizedBox(height: 96), // bottom padding so list doesn't hide behind nav
          ],
        ),
      ),

      // ===== Center big ADD button (highlighted & lifted) =====
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        height: 68,
        width: 68,
        child: FloatingActionButton(
          heroTag: 'fab_add_habit',
          onPressed: () {},
          backgroundColor: AppColors.primary,
          elevation: 8,
          child: const Icon(Icons.add, size: 34, color: Colors.white),
        ),
      ),

      // ===== Floating bottom nav with 5 destinations (center notch) =====
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
                  const SizedBox(width: 48), // space for the notch/FAB
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

  Widget _navItem({required IconData icon, required int index}) {
    final selected = _navIndex == index;
    return IconButton(
      onPressed: () => setState(() => _navIndex = index),
      icon: Icon(icon,
          color: selected ? AppColors.secondary : Colors.white.withOpacity(.85), size: selected ? 28 : 24),
    );
  }
}

// ====== Widgets ======

class _HabitCard extends StatelessWidget {
  final String title;
  final String category;
  final String frequency; // "Daily" | "Weekly"
  final int streak;
  final bool done;
  final VoidCallback onToggle;

  const _HabitCard({
    required this.title,
    required this.category,
    required this.frequency,
    required this.streak,
    required this.done,
    required this.onToggle,
  });

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
          // checkbox
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

          // title + meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // category label
                Text(
                  category,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                // title
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 8),
                // frequency pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.textSecondary.withOpacity(.25)),
                  ),
                  child: Text(
                    frequency,
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

          // streak at right
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "$streak",
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

// round translucent icon button for header
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
