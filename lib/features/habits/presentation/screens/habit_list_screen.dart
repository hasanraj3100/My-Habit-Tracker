import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_habit_tracker/features/habits/presentation/screens/favourite_quote_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // ✅ for Clipboard
import '../../../../core/constants/app_colors.dart';
import '../../data/models/habit_model.dart';
import '../providers/habit_provider.dart';
import '../widgets/quote_section.dart';
import 'habit_create_screen.dart';
import 'habit_details_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class HabitListScreen extends StatefulWidget {
  const HabitListScreen({super.key});

  @override
  State<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  int _navIndex = 0;
  bool _sortFinishedBottom = false;
  String _selectedCategoryFilter = "";

  String _todayKey() => DateFormat("yyyy-MM-dd").format(DateTime.now());
  int _todayWeekday() => DateTime.now().weekday;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HabitProvider>(context, listen: false).loadCategories();
    });
  }

  // ---------------- QUOTE SECTION ----------------
  Widget _quoteSection() {
    return const QuoteSection();
  }

  // ---------------- ADD CATEGORY ----------------
  Future<void> _showAddCategoryDialog() async {
    final TextEditingController categoryController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add New Category"),
        content: TextField(
          controller: categoryController,
          decoration: const InputDecoration(hintText: "Enter category name"),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              final newCat = categoryController.text.trim();
              if (newCat.isNotEmpty) Navigator.pop(ctx, newCat);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await Provider.of<HabitProvider>(context, listen: false).addCategory(result);
      setState(() {
        _selectedCategoryFilter = result;
      });
    }
  }

  Widget _navItem({required IconData icon, required int index}) {
    final selected = _navIndex == index;
    return IconButton(
      onPressed: () {
        if (index == 4) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          return;
        }
        else if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const FavouriteQuotesPage()));
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
    final provider = Provider.of<HabitProvider>(context);
    final todayWeekday = _todayWeekday();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== Header =====
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 44, 16, 24),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                      image: DecorationImage(
                        image: AssetImage("assets/images/header_bg.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      children: [
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
                        // ✅ Quotes carousel instead of static text
                        _quoteSection(),
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
                    child: provider.isLoading && provider.categories.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: provider.categories.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final isAdd = i == provider.categories.length;
                        final cat = isAdd ? '+ Add Category' : provider.categories[i];
                        final selected = _selectedCategoryFilter == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: selected,
                          onSelected: (_) {
                            if (isAdd) {
                              _showAddCategoryDialog();
                            } else {
                              setState(() {
                                if (_selectedCategoryFilter == cat) {
                                  _selectedCategoryFilter = "";
                                } else {
                                  _selectedCategoryFilter = cat;
                                }
                              });
                            }
                          },
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          backgroundColor: isAdd ? Colors.white : AppColors.surface,
                          selectedColor: AppColors.primary,
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: isAdd
                                  ? AppColors.textSecondary.withOpacity(.35)
                                  : AppColors.primary.withOpacity(.35),
                              width: 1.2,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // ===== Ongoing Tasks Header =====
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Ongoing Tasks",
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _sortFinishedBottom ? Icons.sort_by_alpha : Icons.sort,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => setState(() => _sortFinishedBottom = !_sortFinishedBottom),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ===== Habit List =====
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.55,
                    child: StreamBuilder<List<HabitModel>>(
                      stream: provider.getHabits(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text(
                              "No habits yet. Add one!",
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          );
                        }

                        var habits = snapshot.data!;
                        if (_sortFinishedBottom) {
                          habits.sort((a, b) {
                            final aDone = a.history.contains(_todayKey());
                            final bDone = b.history.contains(_todayKey());
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
                                (habit.frequency == 'Weekly' &&
                                    habit.weekdays.contains(todayWeekday));
                            final matchesCategory =
                                _selectedCategoryFilter.isEmpty ||
                                    habit.category == _selectedCategoryFilter;

                            if (!matchesFrequency || !matchesCategory) {
                              return const SizedBox.shrink();
                            }

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        HabitDetailsScreen(habitId: habit.id!),
                                  ),
                                );
                              },
                              child: _HabitCard(habit: habit),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        height: 68,
        width: 68,
        child: FloatingActionButton(
          heroTag: 'fab_add_habit',
          onPressed: () async {
            await Navigator.push(
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
class _HabitCard extends StatefulWidget {
  final HabitModel habit;

  const _HabitCard({required this.habit, super.key});

  @override
  State<_HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<_HabitCard> {
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
        updatedHistory, widget.habit.frequency, widget.habit.weekdays);

    final updatedHabit =
    widget.habit.copyWith(history: updatedHistory, streak: streak);

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
                border:
                Border.all(color: AppColors.textSecondary.withOpacity(.6), width: 1.4),
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
                        color: AppColors.textSecondary.withOpacity(.6), width: 1.4),
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
