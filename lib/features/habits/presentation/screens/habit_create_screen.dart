import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';

class HabitCreateScreen extends StatefulWidget {
  const HabitCreateScreen({super.key});

  @override
  State<HabitCreateScreen> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<HabitCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  String _selectedCategory = "Health";
  String _selectedFrequency = "Daily";

  final List<String> _categories = [
    "Health",
    "Fitness",
    "Study",
    "Work",
    "Personal",
    "Add New"
  ];

  Future<void> _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final habitData = {
        "title": _titleController.text.trim(),
        "category": _selectedCategory,
        "frequency": _selectedFrequency,
        "streak": 0,
        "isDone": false,
        "createdAt": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("habits")
          .add(habitData);

      Navigator.pop(context); // Go back after saving
    }
  }

  void _showAddCategoryDialog() {
    TextEditingController categoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Add New Category"),
          content: TextField(
            controller: categoryController,
            decoration: const InputDecoration(
              hintText: "Enter category name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (categoryController.text.trim().isNotEmpty) {
                  setState(() {
                    _categories.insert(_categories.length - 1, categoryController.text.trim());
                    _selectedCategory = categoryController.text.trim();
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Add Habit"),
        foregroundColor: Colors.white,
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Please enter a title" : null,
              ),
              const SizedBox(height: 20),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == "Add New") {
                    _showAddCategoryDialog();
                  } else {
                    setState(() => _selectedCategory = value!);
                  }
                },
                decoration: InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Frequency Dropdown
              DropdownButtonFormField<String>(
                value: _selectedFrequency,
                items: ["Daily", "Weekly"].map((freq) {
                  return DropdownMenuItem(
                    value: freq,
                    child: Text(freq),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedFrequency = value!);
                },
                decoration: InputDecoration(
                  labelText: "Frequency",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Save Button
              ElevatedButton(
                onPressed: _saveHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
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
