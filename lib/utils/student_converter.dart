import '../models/student_model.dart';
import '../models/attendance_model.dart';

class StudentConverter {
  // Convert Student model to StudentAttendance model for compatibility with existing systems
  static StudentAttendance convertToStudentAttendance(Student student, {bool isPresent = false, bool isNew = false}) {
    return StudentAttendance(
      id: student.id,
      name: student.name,
      isPresent: isPresent,
      isNew: isNew,
      parentContact: student.parentEmail, // Use parentEmail instead of parentContact
      medicalNotes: student.medicalNotes,
    );
  }

  // Convert StudentAttendance model to Student model
  static Student convertToStudent(StudentAttendance attendance, {String assignedClassId = ''}) {
    return Student(
      id: attendance.id,
      name: attendance.name,
      dateOfBirth: null, // Default to null since StudentAttendance doesn't have dateOfBirth
      ageGroup: 'Unknown', // Default to Unknown since StudentAttendance doesn't have ageGroup
      parentEmail: attendance.parentContact,
      parentPhone: '', // Default to empty string
      medicalNotes: attendance.medicalNotes,
      assignedClassId: assignedClassId,
      attendanceHistory: {}, // Initialize with empty history
      createdAt: DateTime.now(), // Set creation time
    );
  }
}