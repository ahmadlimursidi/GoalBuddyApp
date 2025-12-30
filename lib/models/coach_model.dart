import 'package:cloud_firestore/cloud_firestore.dart';

class Coach {
  final String id;
  final String name;
  final String email;
  final String phone;
  final double ratePerHour;
  final String role; // 'Lead' or 'Assistant'
  final List<String> assignedClasses; // List of assigned class/session IDs
  final DateTime? createdAt;
  final DateTime? lastUpdated;

  Coach({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.ratePerHour,
    required this.role,
    this.assignedClasses = const [],
    this.createdAt,
    this.lastUpdated,
  });

  // Factory constructor to create from Firestore map data
  factory Coach.fromMap(Map<String, dynamic> data, String id) {
    return Coach(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      ratePerHour: (data['ratePerHour'] as num?)?.toDouble() ?? 0.0,
      role: data['coachRole'] ?? data['role'] ?? 'Coach',
      assignedClasses: List<String>.from(data['assignedClasses'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  // Convert to map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'ratePerHour': ratePerHour,
      'coachRole': role,
      'assignedClasses': assignedClasses,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : FieldValue.serverTimestamp(),
    };
  }
}