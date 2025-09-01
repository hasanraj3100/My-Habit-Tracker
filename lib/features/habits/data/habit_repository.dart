import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'models/habit_model.dart';

class HabitRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  HabitRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // Get the user's habits collection reference
  CollectionReference _habitsCollection() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No logged-in user');
    return _firestore.collection('users').doc(user.uid).collection('habits');
  }

  // Get the user's settings document reference for categories
  DocumentReference _settingsDoc() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No logged-in user');
    return _firestore.collection('users').doc(user.uid).collection('settings').doc('preferences');
  }

  // Create a new habit
  Future<void> createHabit(HabitModel habit) async {
    try {
      await _habitsCollection().add(habit.toFirestore());
    } catch (e) {
      throw Exception('Failed to create habit: $e');
    }
  }

  // Update an existing habit
  Future<void> updateHabit(HabitModel habit) async {
    if (habit.id == null) throw Exception('Habit ID is required for update');
    try {
      await _habitsCollection().doc(habit.id).update(habit.toFirestore());
    } catch (e) {
      throw Exception('Failed to update habit: $e');
    }
  }

  // Delete a habit
  Future<void> deleteHabit(String habitId) async {
    try {
      await _habitsCollection().doc(habitId).delete();
    } catch (e) {
      throw Exception('Failed to delete habit: $e');
    }
  }

  // Get all habits for the user
  Stream<List<HabitModel>> getHabits() {
    return _habitsCollection().snapshots().map((snapshot) => snapshot.docs
        .map((doc) => HabitModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  // Get a single habit by ID
  Future<HabitModel> getHabit(String habitId) async {
    try {
      final doc = await _habitsCollection().doc(habitId).get();
      if (!doc.exists) throw Exception('Habit not found');
      return HabitModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Failed to fetch habit: $e');
    }
  }

  // Load categories
  Future<List<String>> getCategories() async {
    try {
      final doc = await _settingsDoc().get();
      final data = doc.data() as Map<String, dynamic>?; // Explicit cast
      return List<String>.from(data?['categories'] ?? []);
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  // Add a new category
  Future<void> addCategory(String category) async {
    try {
      final doc = await _settingsDoc().get();
      final data = doc.data() as Map<String, dynamic>?; // Explicit cast
      final currentCategories = List<String>.from(data?['categories'] ?? []);
      if (!currentCategories.contains(category)) {
        currentCategories.add(category);
        await _settingsDoc().set({'categories': currentCategories});
      }
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }
}