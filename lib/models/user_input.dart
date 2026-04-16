import 'package:cloud_firestore/cloud_firestore.dart';

class UserInput {
  final String? id;
  final DateTime date;
  final double sleepHours;
  final double workHours;
  final int mood;
  final double screenTime;
  final int caffeine;
  final DateTime createdAt;

  UserInput({
    this.id,
    required this.date,
    required this.sleepHours,
    required this.workHours,
    required this.mood,
    required this.screenTime,
    required this.caffeine,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String().substring(0, 10),
        'sleep_hours': sleepHours,
        'work_hours': workHours,
        'mood': mood,
        'screen_time': screenTime,
        'caffeine': caffeine,
        'created_at': Timestamp.fromDate(createdAt),
      };

  factory UserInput.fromMap(Map<String, dynamic> map, {String? id}) =>
      UserInput(
        id: id,
        date: DateTime.parse(map['date'] as String),
        sleepHours: (map['sleep_hours'] as num).toDouble(),
        workHours: (map['work_hours'] as num).toDouble(),
        mood: (map['mood'] as num).toInt(),
        screenTime: (map['screen_time'] as num?)?.toDouble() ?? 4.0,
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
    double? screenTime,
    int? caffeine,
  }) =>
      UserInput(
        id: id ?? this.id,
        date: date ?? this.date,
        sleepHours: sleepHours ?? this.sleepHours,
        workHours: workHours ?? this.workHours,
        mood: mood ?? this.mood,
        screenTime: screenTime ?? this.screenTime,
        caffeine: caffeine ?? this.caffeine,
        createdAt: createdAt,
      );

  String get dateKey => date.toIso8601String().substring(0, 10);
}
