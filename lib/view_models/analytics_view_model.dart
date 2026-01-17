import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _selectedAgeGroup;
  bool _isLoading = false;
  String? _errorMessage;

  // Analytics data
  int _totalStudents = 0;
  int _totalClasses = 0;
  int _totalSessions = 0;
  double _overallAttendanceRate = 0.0;
  Map<String, AttendanceData> _ageGroupAttendance = {};
  Map<String, int> _ageGroupStudentCounts = {};
  Map<String, int> _ageGroupClassCounts = {};

  // Age group capacities
  static const Map<String, int> ageGroupCapacities = {
    'Mega Kickers': 22,
    'Mighty Kickers': 20,
    'Junior Kickers': 12,
    'Little Kickers': 10,
  };

  // Getters
  String? get selectedAgeGroup => _selectedAgeGroup;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalStudents => _totalStudents;
  int get totalClasses => _totalClasses;
  int get totalSessions => _totalSessions;
  double get overallAttendanceRate => _overallAttendanceRate;
  Map<String, AttendanceData> get ageGroupAttendance => _ageGroupAttendance;
  Map<String, int> get ageGroupStudentCounts => _ageGroupStudentCounts;
  Map<String, int> get ageGroupClassCounts => _ageGroupClassCounts;

  // Calculate overall capacity utilization
  double get capacityUtilization {
    int totalCapacity = 0;
    int totalEnrolled = 0;

    for (var entry in _ageGroupClassCounts.entries) {
      String ageGroup = entry.key;
      int classCount = entry.value;
      int capacity = ageGroupCapacities[ageGroup] ?? 15;
      int enrolled = _ageGroupStudentCounts[ageGroup] ?? 0;

      totalCapacity += (classCount * capacity);
      totalEnrolled += enrolled;
    }

    return totalCapacity > 0 ? (totalEnrolled / totalCapacity) : 0.0;
  }

  List<String> get ageGroups => ['All', 'Little Kickers', 'Junior Kickers', 'Mighty Kickers', 'Mega Kickers'];

  AnalyticsViewModel() {
    _selectedAgeGroup = 'All';
    fetchAnalytics();
  }

  void setAgeGroup(String? ageGroup) {
    _selectedAgeGroup = ageGroup;
    notifyListeners();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch all students
      QuerySnapshot studentSnapshot = await _firestore.collection('students').get();

      // Fetch all sessions
      QuerySnapshot sessionSnapshot = await _firestore.collection('sessions').get();

      // Reset counters
      _totalStudents = 0;
      _totalClasses = 0;
      _totalSessions = sessionSnapshot.docs.length;
      int totalAttendanceCount = 0;
      int totalAttendanceSlots = 0;
      Map<String, int> ageGroupPresent = {};
      Map<String, int> ageGroupTotal = {};
      _ageGroupStudentCounts = {};
      _ageGroupClassCounts = {};

      // Process students
      for (var studentDoc in studentSnapshot.docs) {
        try {
          final studentData = studentDoc.data() as Map<String, dynamic>?;
          if (studentData == null) continue;

          String ageGroup = studentData['ageGroup'] ?? 'Unknown';

          // Filter by selected age group if not "All"
          if (_selectedAgeGroup != null && _selectedAgeGroup != 'All' && ageGroup != _selectedAgeGroup) {
            continue;
          }

          _totalStudents++;
          _ageGroupStudentCounts[ageGroup] = (_ageGroupStudentCounts[ageGroup] ?? 0) + 1;

          // Calculate attendance from attendanceHistory
          Map<String, dynamic>? attendanceHistory = studentData['attendanceHistory'] as Map<String, dynamic>?;
          if (attendanceHistory != null) {
            for (var entry in attendanceHistory.entries) {
              String status = entry.value.toString().toLowerCase();
              totalAttendanceSlots++;
              ageGroupTotal[ageGroup] = (ageGroupTotal[ageGroup] ?? 0) + 1;

              if (status == 'present' || status == 'p') {
                totalAttendanceCount++;
                ageGroupPresent[ageGroup] = (ageGroupPresent[ageGroup] ?? 0) + 1;
              }
            }
          }
        } catch (studentError) {
          debugPrint("Error processing student document: $studentError");
          continue;
        }
      }

      // Process sessions to count unique classes
      Set<String> uniqueClasses = {};
      Map<String, Set<String>> ageGroupClasses = {};

      for (var sessionDoc in sessionSnapshot.docs) {
        try {
          final sessionData = sessionDoc.data() as Map<String, dynamic>?;
          if (sessionData == null) continue;

          String className = sessionData['className'] ?? 'Unknown';
          String ageGroup = sessionData['ageGroup'] ?? 'Unknown';

          // Filter by selected age group
          if (_selectedAgeGroup != null && _selectedAgeGroup != 'All' && ageGroup != _selectedAgeGroup) {
            continue;
          }

          uniqueClasses.add('$className-$ageGroup');

          // Track classes per age group
          if (!ageGroupClasses.containsKey(ageGroup)) {
            ageGroupClasses[ageGroup] = {};
          }
          ageGroupClasses[ageGroup]!.add(className);
        } catch (sessionError) {
          debugPrint("Error processing session document: $sessionError");
          continue;
        }
      }
      _totalClasses = uniqueClasses.length;

      // Count classes per age group
      ageGroupClasses.forEach((ageGroup, classes) {
        _ageGroupClassCounts[ageGroup] = classes.length;
      });

      // Calculate overall attendance rate
      if (totalAttendanceSlots > 0) {
        _overallAttendanceRate = (totalAttendanceCount / totalAttendanceSlots) * 100;
      } else {
        _overallAttendanceRate = 0.0;
      }

      // Calculate age group attendance rates
      _ageGroupAttendance = {};
      for (String ageGroup in ageGroupTotal.keys) {
        int present = ageGroupPresent[ageGroup] ?? 0;
        int total = ageGroupTotal[ageGroup] ?? 0;
        double rate = total > 0 ? (present / total) * 100 : 0.0;
        _ageGroupAttendance[ageGroup] = AttendanceData(
          present: present,
          total: total,
          rate: rate,
        );
      }

    } catch (e) {
      _errorMessage = "Error fetching analytics: ${e.toString()}";
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get attendance data for a specific age group
  AttendanceData? getAttendanceForAgeGroup(String ageGroup) {
    return _ageGroupAttendance[ageGroup];
  }

  // Get color based on attendance rate
  Color getAttendanceColor(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 60) return Colors.orange;
    return Colors.red;
  }

}

class AttendanceData {
  final int present;
  final int total;
  final double rate;

  AttendanceData({
    required this.present,
    required this.total,
    required this.rate,
  });
}
