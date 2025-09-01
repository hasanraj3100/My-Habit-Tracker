import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_habit_tracker/core/extensions%20/theme_extension.dart';

class HabitCreateScreen extends StatefulWidget {
  const HabitCreateScreen({super.key});

  @override
  State<HabitCreateScreen> createState() => _HabitCreateScreenState();
}

class _HabitCreateScreenState extends State<HabitCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _selectedCategory = "";
  String _selectedFrequency = "Daily";
  List<int> _selectedWeekdays = [];

  bool _isSaving = false;
  final user = FirebaseAuth.instance.currentUser;

  List<String> _categories = ["Add New"];
  final Map<int, String> _weekdays = const {
    1: "Monday",
    2: "Tuesday",
    3: "Wednesday",
    4: "Thursday",
    5: "Friday",
    6: "Saturday",
    7: "Sunday",
  };

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('settings')
        .doc('preferences')
        .get();
    final categories = List<String>.from(doc.data()?['categories'] ?? []);
    setState(() {
      _categories = [...categories, "Add New"];
      if (_categories.isNotEmpty) _selectedCategory = _categories.first;
    });
  }

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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
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
      // Save new category to Firestore
      final prefRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('settings')
          .doc('preferences');

      final currentDoc = await prefRef.get();
      final currentCategories =
      List<String>.from(currentDoc.data()?['categories'] ?? []);
      if (!currentCategories.contains(result)) {
        currentCategories.add(result);
        await prefRef.set({'categories': currentCategories});
      }

      setState(() {
        _categories.insert(_categories.length - 1, result);
        _selectedCategory = result;
      });
    }
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFrequency == "Weekly" && _selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one weekday.")),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (user == null) throw Exception("No logged in user");

      final habitData = <String, dynamic>{
        "title": _titleController.text.trim(),
        "note": _noteController.text.trim(),
        "category": _selectedCategory,
        "frequency": _selectedFrequency,
        "weekdays": _selectedFrequency == "Weekly" ? _selectedWeekdays : [],
        "history": <String>[],
        "streak": 0,
        "maxStreak": 0,
        "createdAt": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .collection("habits")
          .add(habitData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Habit created successfully.")),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create habit: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.primary,
        foregroundColor: Colors.white,
        title: const Text("Add Habit"),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Habit Title",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) =>
                (value == null || value.trim().isEmpty) ? "Please enter a title" : null,
              ),
              const SizedBox(height: 14),

              // Note
              TextFormField(
                controller: _noteController,
                minLines: 3,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: "Note (optional)",
                  hintText: "Describe this habit or add any reminders...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory.isNotEmpty ? _selectedCategory : null,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  if (value == "Add New") {
                    _showAddCategoryDialog();
                  } else {
                    setState(() => _selectedCategory = value);
                  }
                },
                decoration: InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),

              // Frequency Dropdown
              DropdownButtonFormField<String>(
                value: _selectedFrequency,
                items: ["Daily", "Weekly"]
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedFrequency = value;
                    if (_selectedFrequency != "Weekly") _selectedWeekdays = [];
                  });
                },
                decoration: InputDecoration(
                  labelText: "Frequency",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              // Weekly Days Selector
              if (_selectedFrequency == "Weekly") ...[
                const Text("Select weekdays:",
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _weekdays.entries.map((entry) {
                    final isSelected = _selectedWeekdays.contains(entry.key);
                    return FilterChip(
                      label: Text(entry.value),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _selectedWeekdays.add(entry.key);
                          } else {
                            _selectedWeekdays.remove(entry.key);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 18),

              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _saveHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Save Habit",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
