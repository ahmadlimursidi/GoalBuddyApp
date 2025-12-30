import 'attendance_model.dart';

class StudentProgress {
  final String id;
  final String name;
  final String ageGroup;
  final List<String> earnedBadgeIds;
  final String? currentBadgeId;

  StudentProgress({
    required this.id,
    required this.name,
    required this.ageGroup,
    this.earnedBadgeIds = const [],
    this.currentBadgeId,
  });

  // Factory constructor to create from StudentAttendance and additional data
  factory StudentProgress.fromStudentAttendance(
    StudentAttendance student,
    String ageGroup,
    List<String> earnedBadgeIds,
    String? currentBadgeId,
  ) {
    return StudentProgress(
      id: student.id,
      name: student.name,
      ageGroup: ageGroup,
      earnedBadgeIds: earnedBadgeIds,
      currentBadgeId: currentBadgeId,
    );
  }

  // Factory constructor to create from map data
  factory StudentProgress.fromMap(Map<String, dynamic> data) {
    return StudentProgress(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      ageGroup: data['ageGroup'] ?? '',
      earnedBadgeIds: List<String>.from(data['earnedBadgeIds'] ?? []),
      currentBadgeId: data['currentBadgeId'],
    );
  }

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ageGroup': ageGroup,
      'earnedBadgeIds': earnedBadgeIds,
      'currentBadgeId': currentBadgeId,
    };
  }
}