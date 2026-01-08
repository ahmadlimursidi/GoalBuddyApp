import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/attendance_model.dart';

class AttendanceViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  String? _sessionId;
  String? _sessionAgeGroup;
  List<StudentAttendance> _students = [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<QuerySnapshot>? _subscription;

  // Getters
  List<StudentAttendance> get students => _students;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get sessionAgeGroup => _sessionAgeGroup;

  // Load students for a specific session
  Future<void> loadStudents(String sessionId) async {
    _sessionId = sessionId;
    if (kDebugMode) {
      debugPrint("AttendanceViewModel.loadStudents called with sessionId: $sessionId");
    }

    // Cancel any existing subscription to prevent memory leaks
    await _subscription?.cancel();

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get the session from the sessions collection (we'll use only one collection now)
      DocumentSnapshot sessionDoc = await _firestoreService.getSession(sessionId);

      if (!sessionDoc.exists) {
        _isLoading = false;
        _errorMessage = "Session not found in database";
        notifyListeners();
        return;
      }

      final sessionData = sessionDoc.data() as Map<String, dynamic>?;
      if (sessionData == null) {
        _isLoading = false;
        _errorMessage = "Session data is empty";
        notifyListeners();
        return;
      }

      _sessionAgeGroup = sessionData['ageGroup'] ?? '';

      if (kDebugMode) {
        debugPrint("Session age group: $_sessionAgeGroup");
      }

      // Load students from the main students collection, filtered by age group
      if (_sessionAgeGroup != null && _sessionAgeGroup!.isNotEmpty) {
        _subscription = _firestoreService.getStudentsByAgeGroup(_sessionAgeGroup!).listen((querySnapshot) {
          if (kDebugMode) {
            debugPrint("Firestore snapshot received for age group $_sessionAgeGroup, docs: ${querySnapshot.docs.length}");
          }

          // Map students from Firestore
          final allStudents = querySnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            // For now, default to not present - we'll update with actual attendance later
            bool isPresent = false;

            return StudentAttendance(
              id: doc.id,
              name: data['name'] ?? '',
              isPresent: isPresent, // Default to not present
              isNew: data['createdAt'] != null
                  ? DateTime.now().difference((data['createdAt'] as Timestamp).toDate()).inDays <= 7
                  : false,
              parentContact: data['parentEmail'] ?? data['parentContact'] ?? '',
              medicalNotes: data['medicalNotes'] ?? '',
              ageGroup: data['ageGroup'] ?? '',
            );
          }).toList();

          // Students are already filtered by age group from Firestore query
          _students = allStudents;

          // Now update attendance status asynchronously using the sessions collection
          _updateAttendanceStatusForStudents(querySnapshot.docs, 'sessions');

          if (kDebugMode) {
            debugPrint("Loaded ${_students.length} students for age group: $_sessionAgeGroup");
          }

          _isLoading = false;
          notifyListeners();
        }, onError: (error) {
          _isLoading = false;
          _errorMessage = error.toString();
          notifyListeners();
        });
      } else {
        // No age group specified, load empty list
        _students = [];
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Dispose of the subscription when the view model is disposed
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // Update student attendance status
  Future<void> updateStudentAttendance(String studentId, bool isPresent) async {
    if (_sessionId == null) {
      _errorMessage = "Session ID is not set";
      notifyListeners();
      return;
    }

    try {
      // Update local state immediately for better UX
      final index = _students.indexWhere((student) => student.id == studentId);
      if (index != -1) {
        _students[index] = StudentAttendance(
          id: _students[index].id,
          name: _students[index].name,
          isPresent: isPresent,
          isNew: _students[index].isNew,
          parentContact: _students[index].parentContact,
          medicalNotes: _students[index].medicalNotes,
          ageGroup: _students[index].ageGroup,
        );
        notifyListeners();

        // Save attendance to session subcollection for record keeping
        await _saveAttendanceToSession(studentId, _students[index]);
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Save attendance record to session subcollection AND update student's attendanceHistory
  Future<void> _saveAttendanceToSession(String studentId, StudentAttendance student) async {
    if (_sessionId == null) return;

    // Determine which collection to save to by checking which one contains the session
    try {
      // Check if the session exists in scheduled_classes collection
      DocumentSnapshot scheduledClassDoc = await FirebaseFirestore.instance
          .collection('scheduled_classes')
          .doc(_sessionId!)
          .get();

      String collectionName = scheduledClassDoc.exists ? 'scheduled_classes' : 'sessions';

      // 1. Save to session's subcollection for immediate session tracking
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(_sessionId!)
          .collection('students')
          .doc(studentId)
          .set({
        'name': student.name,
        'isPresent': student.isPresent,
        'isNew': student.isNew,
        'parentContact': student.parentContact,
        'medicalNotes': student.medicalNotes,
        'ageGroup': student.ageGroup,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Update the student's attendanceHistory field in the main students collection
      // This makes the attendance visible in:
      // - Student profile view
      // - Analytics view
      // - Parent dashboard
      // - Past sessions view
      await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .update({
        'attendanceHistory.$_sessionId': student.isPresent ? 'Present' : 'Absent',
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint("Attendance saved for student $studentId in session $_sessionId: ${student.isPresent ? 'Present' : 'Absent'}");
      }
    } catch (e) {
      debugPrint("Error saving attendance: $e");
    }
  }

  // Update attendance status for all students
  Future<void> _updateAttendanceStatusForStudents(List<DocumentSnapshot> studentDocs, String sessionCollection) async {
    for (var doc in studentDocs) {
      try {
        bool isPresent = false;

        // Try to get attendance from session subcollection first
        DocumentSnapshot attendanceDoc = await FirebaseFirestore.instance
            .collection(sessionCollection)
            .doc(_sessionId)
            .collection('students')
            .doc(doc.id)
            .get();

        if (attendanceDoc.exists) {
          final attendanceData = attendanceDoc.data() as Map<String, dynamic>?;
          isPresent = attendanceData != null ? attendanceData['isPresent'] ?? false : false;
        } else {
          // Fallback: check student's attendanceHistory for this session
          final studentData = doc.data() as Map<String, dynamic>?;
          if (studentData != null) {
            final attendanceHistory = studentData['attendanceHistory'] as Map<String, dynamic>?;
            if (attendanceHistory != null && attendanceHistory.containsKey(_sessionId)) {
              String status = attendanceHistory[_sessionId].toString().toLowerCase();
              isPresent = (status == 'present' || status == 'p');
            }
          }
        }

        // Update the student in the list
        final index = _students.indexWhere((student) => student.id == doc.id);
        if (index != -1) {
          _students[index] = StudentAttendance(
            id: _students[index].id,
            name: _students[index].name,
            isPresent: isPresent,
            isNew: _students[index].isNew,
            parentContact: _students[index].parentContact,
            medicalNotes: _students[index].medicalNotes,
            ageGroup: _students[index].ageGroup,
          );
        }
      } catch (e) {
        debugPrint("Error getting attendance for student ${doc.id}: $e");
      }
    }

    // Notify listeners after updating all attendance statuses
    notifyListeners();
  }

  // Toggle student attendance status
  Future<void> toggleStudentAttendance(String studentId) async {
    final student = _students.firstWhere((s) => s.id == studentId, orElse: () =>
      StudentAttendance(
        id: '',
        name: '',
        isPresent: false,
        isNew: false,
        parentContact: '',
        medicalNotes: '',
        ageGroup: '',
      )
    );
    await updateStudentAttendance(studentId, !student.isPresent);
  }

  // Get total attendance count
  int get totalStudents => _students.length;
  
  int get presentStudents => _students.where((student) => student.isPresent).length;
  
  int get absentStudents => _students.where((student) => !student.isPresent).length;
  
  double get attendancePercentage {
    if (_students.isEmpty) return 0.0;
    return (presentStudents / totalStudents) * 100;
  }
}