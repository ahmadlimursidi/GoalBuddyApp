import 'package:cloud_firestore/cloud_firestore.dart';
import 'note_model.dart';

class Student {
  final String id;
  final String name;
  final DateTime? dateOfBirth;
  final String ageGroup;
  final String parentEmail;
  final String parentPhone;
  final String medicalNotes;
  final String assignedClassId;
  final List<String> earnedBadges; // List of badge IDs the student has earned
  final Map<String, String> attendanceHistory; // Key: date string (YYYY-MM-DD), Value: 'Present'/'Absent'
  final List<Note> notes; // List of coach notes
  final DateTime? createdAt;
  final DateTime? lastUpdated;

  Student({
    required this.id,
    required this.name,
    this.dateOfBirth,
    required this.ageGroup,
    required this.parentEmail,
    required this.parentPhone,
    required this.medicalNotes,
    required this.assignedClassId,
    this.earnedBadges = const [],
    this.attendanceHistory = const {},
    this.notes = const [],
    this.createdAt,
    this.lastUpdated,
  });

  // Factory constructor to create from Firestore map data
  factory Student.fromMap(Map<String, dynamic> data, String id) {
    // Parse notes from Firestore data
    List<Note> parsedNotes = [];
    if (data['notes'] != null) {
      Map<String, dynamic> notesData = Map<String, dynamic>.from(data['notes'] as Map);
      notesData.forEach((noteId, noteData) {
        if (noteData is Map<String, dynamic>) {
          parsedNotes.add(Note.fromMap(noteData, noteId));
        }
      });
    }

    return Student(
      id: id,
      name: data['name'] ?? '',
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      ageGroup: data['ageGroup'] ?? 'Unknown',
      parentEmail: data['parentEmail'] ?? '',
      parentPhone: data['parentPhone'] ?? '',
      medicalNotes: data['medicalNotes'] ?? '',
      assignedClassId: data['assignedClassId'] ?? '',
      earnedBadges: List<String>.from(data['earnedBadges'] ?? []),
      attendanceHistory: Map<String, String>.from(data['attendanceHistory'] ?? {}),
      notes: parsedNotes,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  // Convert to map for Firestore storage
  Map<String, dynamic> toMap() {
    // Convert notes to map format for Firestore
    Map<String, dynamic> notesMap = {};
    for (Note note in notes) {
      notesMap[note.id] = note.toMap();
    }

    return {
      'name': name,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'ageGroup': ageGroup,
      'parentEmail': parentEmail,
      'parentPhone': parentPhone,
      'medicalNotes': medicalNotes,
      'assignedClassId': assignedClassId,
      'earnedBadges': earnedBadges,
      'attendanceHistory': attendanceHistory,
      'notes': notesMap,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : FieldValue.serverTimestamp(),
    };
  }
}