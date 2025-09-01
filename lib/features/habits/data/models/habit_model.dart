import 'package:cloud_firestore/cloud_firestore.dart';

class HabitModel {
  final String? id; // Firestore document ID
  final String title;
  final String note;
  final String category;
  final String frequency;
  final List<int> weekdays;
  final List<String> history; // Stores completion dates
  final int streak;
  final int maxStreak;
  final DateTime? createdAt;

  HabitModel({
    this.id,
    required this.title,
    required this.note,
    required this.category,
    required this.frequency,
    required this.weekdays,
    required this.history,
    required this.streak,
    required this.maxStreak,
    this.createdAt,
  });

  // Factory to create HabitModel from Firestore document
  factory HabitModel.fromFirestore(Map<String, dynamic> data, String id) {
    return HabitModel(
      id: id,
      title: data['title'] ?? '',
      note: data['note'] ?? '',
      category: data['category'] ?? '',
      frequency: data['frequency'] ?? 'Daily',
      weekdays: List<int>.from(data['weekdays'] ?? []),
      history: List<String>.from(data['history'] ?? []),
      streak: data['streak'] ?? 0,
      maxStreak: data['maxStreak'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convert HabitModel to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'note': note,
      'category': category,
      'frequency': frequency,
      'weekdays': weekdays,
      'history': history,
      'streak': streak,
      'maxStreak': maxStreak,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  // CopyWith method for updating specific fields
  HabitModel copyWith({
    String? id,
    String? title,
    String? note,
    String? category,
    String? frequency,
    List<int>? weekdays,
    List<String>? history,
    int? streak,
    int? maxStreak,
    DateTime? createdAt,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      weekdays: weekdays ?? this.weekdays,
      history: history ?? this.history,
      streak: streak ?? this.streak,
      maxStreak: maxStreak ?? this.maxStreak,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}