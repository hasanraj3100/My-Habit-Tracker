import 'package:flutter/material.dart';
import 'package:my_habit_tracker/core/extensions%20/theme_extension.dart';
import 'package:my_habit_tracker/features/settings/presentation/screens/settings_screen.dart';
import '../screens/habit_create_screen.dart';
import '../screens/favourite_quote_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChange;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onIndexChange,
  });

  Widget _navItem({
    required BuildContext context,
    required IconData icon,
    required int index,
    required int currentIndex,
    bool isAdd = false,
  }) {
    final selected = currentIndex == index;

    return GestureDetector(
      onTap: () async {
        if (isAdd) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HabitCreateScreen()),
          );
          return;
        }
        if (index == 4) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          return;
        } else if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const FavouriteQuotesPage()));
          return;
        }
        else if (index == 3) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
          return;
        }
        onIndexChange(index);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: isAdd
            ? BoxDecoration(
          color: context.colors.primary,
          shape: BoxShape.circle,
        )
            : null,
        child: Icon(
          icon,
          color: isAdd
              ? Colors.white
              : (selected ? context.colors.secondary : Colors.white.withOpacity(.85)),
          size: isAdd ? 34 : (selected ? 28 : 24),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BottomAppBar(
          color: context.colors.navBackground.withOpacity(.9),
          elevation: 8,
          child: SizedBox(
            height: 72,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(
                  context: context,
                  icon: Icons.home_rounded,
                  index: 0,
                  currentIndex: currentIndex,
                ),
                _navItem(
                  context: context,
                  icon: Icons.favorite_border_rounded,
                  index: 1,
                  currentIndex: currentIndex,
                ),
                _navItem(
                  context: context,
                  icon: Icons.add,
                  index: 2,
                  currentIndex: currentIndex,
                  isAdd: true,
                ),
                _navItem(
                  context: context,
                  icon: Icons.settings_rounded,
                  index: 3,
                  currentIndex: currentIndex,
                ),
                _navItem(
                  context: context,
                  icon: Icons.person_rounded,
                  index: 4,
                  currentIndex: currentIndex,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
