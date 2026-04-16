import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String name;
  final int? age;
  final String? occupation;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    this.age,
    this.occupation,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'name': name,
        'age': age,
        'occupation': occupation,
        'created_at': Timestamp.fromDate(createdAt),
        'updated_at': Timestamp.fromDate(updatedAt),
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        uid: map['uid'] as String,
        email: map['email'] as String,
        name: map['name'] as String,
        age: map['age'] as int?,
        occupation: map['occupation'] as String?,
        createdAt: map['created_at'] is Timestamp
            ? (map['created_at'] as Timestamp).toDate()
            : DateTime.parse(map['created_at'] as String),
        updatedAt: map['updated_at'] is Timestamp
            ? (map['updated_at'] as Timestamp).toDate()
            : DateTime.parse(map['updated_at'] as String),
      );

  factory UserProfile.fromSnapshot(DocumentSnapshot doc) =>
      UserProfile.fromMap(doc.data() as Map<String, dynamic>);
}
