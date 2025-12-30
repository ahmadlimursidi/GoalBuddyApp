import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/attendance_model.dart';

class AttendanceViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  String? _sessionId;
  List<StudentAttendance> _students = [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<QuerySnapshot>? _subscription;

  // Getters
  List<StudentAttendance> get students => _students;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
      // Stream the attendance data for real-time updates
      _subscription = _firestoreService.getSessionStudents(sessionId).listen((querySnapshot) {
        if (kDebugMode) {
          debugPrint("Firestore snapshot received for session $sessionId, docs: ${querySnapshot.docs.length}");
        }
        _students = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return StudentAttendance(
            id: doc.id,
            name: data['name'] ?? '',
            isPresent: data['isPresent'] ?? false,
            isNew: data['isNew'] ?? false,
            parentContact: data['parentContact'] ?? '',
            medicalNotes: data['medicalNotes'] ?? '',
          );
        }).toList();

        _isLoading = false;
        notifyListeners();
      }, onError: (error) {
        _isLoading = false;
        _errorMessage = error.toString();
        notifyListeners();
      });
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
      await _firestoreService.updateAttendance(_sessionId!, studentId, isPresent);
      
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
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
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
        medicalNotes: ''
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