import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../services/local_storage_service.dart';
import '../providers/habit_provider.dart';

// Extracted widgets
import '../widgets/habit_header.dart';
import '../widgets/habit_category_chips.dart';
import '../widgets/habit_task_list.dart';
import '../widgets/custom_navbar.dart';

class HabitListScreen extends StatefulWidget {
  const HabitListScreen({super.key});

  @override
  State<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  int _navIndex = 0;
  bool _sortFinishedBottom = false;
  String _selectedCategoryFilter = "";

  Map<String, dynamic>? _userData;
  bool _loading = true;

  String _todayKey() => DateFormat("yyyy-MM-dd").format(DateTime.now());
  int _todayWeekday() => DateTime.now().weekday;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HabitProvider>(context, listen: false).loadCategories();
    });

    _loadFromCacheOrFirestore();
  }

  Future<void> _loadFromCacheOrFirestore() async {
    final cachedData = await LocalStorageService.getUserData();
    if (cachedData != null) {
      setState(() {
        _userData = cachedData;
        _loading = false;
      });
    } else {
      await _fetchFromFirestore();
    }
  }

  Future<void> _fetchFromFirestore() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _userData = data;
          _loading = false;
        });
        await LocalStorageService.saveUserData(data);
      } else {
        setState(() {
          _userData = null;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HabitProvider>(context);

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
                  HabitHeader(userData: _userData, loading: _loading),
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

                  HabitCategoryChips(
                    isLoading: provider.isLoading && provider.categories.isEmpty,
                    categories: provider.categories,
                    selectedCategory: _selectedCategoryFilter,
                    onCategorySelected: (cat) {
                      setState(() {
                        if (_selectedCategoryFilter == cat) {
                          _selectedCategoryFilter = "";
                        } else {
                          _selectedCategoryFilter = cat;
                        }
                      });
                    },
                    onCategoryAddedAndSelected: (newCat) {
                      setState(() => _selectedCategoryFilter = newCat);
                    },
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
                    child: HabitTaskList(
                      sortFinishedBottom: _sortFinishedBottom,
                      todayKey: _todayKey(),
                      todayWeekday: _todayWeekday(),
                      selectedCategoryFilter: _selectedCategoryFilter,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),

      // ===== Bottom Nav (with + inside) =====
      bottomNavigationBar: CustomNavBar(
        currentIndex: _navIndex,
        onIndexChange: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}
