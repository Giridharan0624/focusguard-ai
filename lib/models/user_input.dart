import 'package:cloud_firestore/cloud_firestore.dart';

class UserInput {
  final String? id;
  final DateTime date;
  final double sleepHours;
  final double workHours;
  final int mood;
  final int meetings;
  final int caffeine;
  final DateTime createdAt;

  UserInput({
    this.id,
    required this.date,
    required this.sleepHours,
    required this.workHours,
    required this.mood,
    required this.meetings,
    required this.caffeine,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert to Firestore document
  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String().substring(0, 10),
        'sleep_hours': sleepHours,
        'work_hours': workHours,
        'mood': mood,
        'meetings': meetings,
        'caffeine': caffeine,
        'created_at': Timestamp.fromDate(createdAt),
      };

  /// Create from Firestore document
  factory UserInput.fromMap(Map<String, dynamic> map, {String? id}) =>
      UserInput(
        id: id,
        date: DateTime.parse(map['date'] as String),
        sleepHours: (map['sleep_hours'] as num).toDouble(),
        workHours: (map['work_hours'] as num).toDouble(),
        mood: (map['mood'] as num).toInt(),
        meetings: (map['meetings'] as num).toInt(),
        caffeine: (map['caffeine'] as num).toInt(),
        createdAt: map['created_at'] is Timestamp
            ? (map['created_at'] as Timestamp).toDate()
            : DateTime.parse(map['created_at'] as String),
      );

  factory UserInput.fromSnapshot(DocumentSnapshot doc) =>
      UserInput.fromMap(doc.data() as Map<String, dynamic>, id: doc.id);

  UserInput copyWith({
    String? id,
    DateTime? date,
    double? sleepHours,
    double? workHours,
    int? mood,
    int? meetings,
    int? caffeine,
  }) =>
      UserInput(
        id: id ?? this.id,
        date: date ?? this.date,
        sleepHours: sleepHours ?? this.sleepHours,
        workHours: workHours ?? this.workHours,
        mood: mood ?? this.mood,
        meetings: meetings ?? this.meetings,
        caffeine: caffeine ?? this.caffeine,
        createdAt: createdAt,
      );

  /// Date string key used for upsert (one check-in per day)
  String get dateKey => date.toIso8601String().substring(0, 10);
}
