import 'package:flutter/material.dart';
import 'package:my_habit_tracker/core/extensions%20/theme_extension.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';

class HabitCategoryChips extends StatelessWidget {
  final bool isLoading;
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<String> onCategoryAddedAndSelected;

  const HabitCategoryChips({
    super.key,
    required this.isLoading,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onCategoryAddedAndSelected,
  });

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final provider = Provider.of<HabitProvider>(context, listen: false);
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
      await provider.addCategory(result);
      onCategoryAddedAndSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final isAdd = i == categories.length;
          final cat = isAdd ? '+ Add Category' : categories[i];
          final selected = selectedCategory == cat;

          return ChoiceChip(
            label: Text(cat),
            selected: selected,
            onSelected: (_) {
              if (isAdd) {
                _showAddCategoryDialog(context);
              } else {
                onCategorySelected(cat);
              }
            },
            labelStyle: TextStyle(
              color: selected ? Colors.white : context.colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: isAdd ? Colors.white : context.colors.surface,
            selectedColor: context.colors.primary,
            shape: StadiumBorder(
              side: BorderSide(
                color: isAdd
                    ? context.colors.textSecondary.withOpacity(.35)
                    : context.colors.primary.withOpacity(.35),
                width: 1.2,
              ),
            ),
          );
        },
      ),
    );
  }
}
