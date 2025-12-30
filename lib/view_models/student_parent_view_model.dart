import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:goalbuddy/utils/age_calculator.dart';

class StudentParentViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _studentId;
  String? _studentName;
  String? _parentContact;
  String? _medicalNotes;
  DateTime? _childDob; // Add child's date of birth
  final List<SessionAttendanceRecord> _allAttendanceRecords = []; // Store all records before filtering
  final List<SessionAttendanceRecord> _attendanceRecords = [];
  bool _isLoading = false;

  // Additional properties for parent dashboard
  int _presentDaysCount = 0;
  int _absentDaysCount = 0;
  int _totalDaysCount = 0;
  List<Map<String, dynamic>> _recentAttendance = [];
  bool _isPaymentDue = false;
  List<Map<String, dynamic>> _childBadges = [];

  // Getters
  String? get studentName => _studentName;
  String? get parentContact => _parentContact;
  String? get medicalNotes => _medicalNotes;
  DateTime? get childDob => _childDob;
  List<SessionAttendanceRecord> get attendanceRecords => _attendanceRecords;
  bool get isLoading => _isLoading;

  // Getters for parent dashboard features
  int get presentDaysCount => _presentDaysCount;
  int get absentDaysCount => _absentDaysCount;
  int get totalDaysCount => _totalDaysCount;
  List<Map<String, dynamic>> get recentAttendance => _recentAttendance;
  bool get isPaymentDue => _isPaymentDue;
  List<Map<String, dynamic>> get childBadges => _childBadges;

  // Getters for child and parent names
  String? get parentName => _getParentName();
  String? get childName => _studentName;
  String? get childAgeGroup => _getChildAgeGroup();

  // Get child classes stream
  Stream<QuerySnapshot>? get childClassesStream => _getChildClassesStream();

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Initialize with student data - for now we'll find the student associated with the current user
  Future<void> initializeStudentData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _findAndLoadStudentData();
      await _loadAdditionalData();
    } catch (e) {
      print("Error loading student data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Find student data associated with the current user
  Future<void> _findAndLoadStudentData() async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;
    
    try {
      // First, try to find if this user is directly linked to a student in a user profile
      DocumentSnapshot userDoc = await _db.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (userData.containsKey('linkedStudentId')) {
          _studentId = userData['linkedStudentId'];
        }
      }
      
      // If not found in user profile, try to find by parent contact info
      if (_studentId == null) {
        await _findStudentByParentContact();
      }

      if (_studentId != null) {
        await _loadStudentProfile();
        await _loadAttendanceRecords();
      }
    } catch (e) {
      print("Error finding student data: $e");
    }
  }

  // Find student by parent contact information (simplified approach for demo)
  Future<void> _findStudentByParentContact() async {
    try {
      String? userEmail = _auth.currentUser?.email;

      // First, try to find from the users collection (where parent accounts are linked)
      DocumentSnapshot userDoc = await _db.collection('users').doc(_auth.currentUser?.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (userData.containsKey('linkedStudentId')) {
          _studentId = userData['linkedStudentId'];
          _studentName = userData['linkedStudentName'] ?? 'Demo Student';

          // Now find this student in sessions to get full details
          QuerySnapshot sessionQuery = await _db.collection('sessions').get();
          for (var sessionDoc in sessionQuery.docs) {
            DocumentSnapshot studentDoc = await sessionDoc.reference.collection('students').doc(_studentId!).get();
            if (studentDoc.exists) {
              var studentData = studentDoc.data() as Map<String, dynamic>;
              _parentContact = studentData['parentContact'] ?? userEmail ?? 'Not Provided';
              _medicalNotes = studentData['medicalNotes'] ?? '';
              break;
            }
          }
          return;
        }
      }

      // If not found in user profile, try to find by email in the main students collection
      if (userEmail != null) {
        QuerySnapshot studentQuery = await _db.collection('students')
            .where('parentEmail', isEqualTo: userEmail)
            .limit(1)
            .get();

        if (studentQuery.docs.isNotEmpty) {
          var studentDoc = studentQuery.docs.first;
          var studentData = studentDoc.data() as Map<String, dynamic>;

          _studentId = studentDoc.id;
          _studentName = studentData['name'];
          _parentContact = studentData['parentEmail'];
          _medicalNotes = studentData['medicalNotes'] ?? '';
          _childDob = (studentData['dateOfBirth'] as Timestamp?)?.toDate();

          return;
        }
      }

      // Query all sessions to find potential student matches by parent contact
      QuerySnapshot sessionQuery = await _db.collection('sessions').get();

      for (var sessionDoc in sessionQuery.docs) {
        QuerySnapshot studentQuery = await sessionDoc.reference.collection('students').get();

        for (var studentDoc in studentQuery.docs) {
          var studentData = studentDoc.data() as Map<String, dynamic>;

          // Check if the parent contact matches user email or other identifying info
          String? parentContact = studentData['parentContact'];
          String? studentName = studentData['name'];

          // For demo purposes: find a student whose parent contact matches user email
          // In a real app, you'd have a proper parent-student linking system
          if (parentContact != null && studentName != null &&
              (parentContact.contains(userEmail ?? ''))) {
            _studentId = studentDoc.id; // Use the student document ID
            _studentName = studentName;
            _parentContact = parentContact;
            _medicalNotes = studentData['medicalNotes'] ?? '';
            return; // Stop after finding the first match
          }
        }
      }

      // For demo purposes, if no match found by contact, default to first student
      // with a placeholder ID
      _studentId ??= 'demo_student_1';
    } catch (e) {
      print("Error in finding student: $e");
    }
  }

  // Load student profile from Firestore
  Future<void> _loadStudentProfile() async {
    if (_studentId == null) return;

    try {
      // In the current database structure, student data is stored within sessions
      // For demonstration, we'll use mock data or look for the first session with this student
      QuerySnapshot sessionQuery = await _db.collection('sessions').get();

      for (var sessionDoc in sessionQuery.docs) {
        DocumentSnapshot studentDoc = await sessionDoc.reference.collection('students').doc(_studentId!).get();

        if (studentDoc.exists) {
          var studentData = studentDoc.data() as Map<String, dynamic>;
          _studentName = studentData['name'] ?? 'Demo Student';
          _parentContact = studentData['parentContact'] ?? 'Not Provided';
          _medicalNotes = studentData['medicalNotes'] ?? 'None';

          // If date of birth is available in the student data, load it
          var dobTimestamp = studentData['dateOfBirth'] as Timestamp?;
          if (dobTimestamp != null) {
            _childDob = dobTimestamp.toDate();
          }

          break;
        }
      }
    } catch (e) {
      print("Error loading student profile: $e");
    }
  }

  // Load attendance records for this student
  Future<void> _loadAttendanceRecords() async {
    if (_studentId == null) return;

    try {
      _allAttendanceRecords.clear();

      // Query all sessions ordered by start time (newest first)
      QuerySnapshot sessionQuery = await _db.collection('sessions')
          .orderBy('startTime', descending: true)
          .get();

      for (var sessionDoc in sessionQuery.docs) {
        var sessionData = sessionDoc.data() as Map<String, dynamic>;
        DocumentSnapshot studentDoc = await sessionDoc.reference.collection('students').doc(_studentId!).get();

        if (studentDoc.exists) {
          var studentData = studentDoc.data() as Map<String, dynamic>;

          // Create a session record with attendance info
          var sessionRecord = SessionAttendanceRecord(
            sessionId: sessionDoc.id,
            className: sessionData['className'] ?? 'Unknown Class',
            venue: sessionData['venue'] ?? 'Unknown Venue',
            date: (sessionData['startTime'] as Timestamp?)?.toDate(),
            isPresent: studentData['isPresent'] ?? false,
            status: sessionData['status'] ?? 'Unknown',
            ageGroup: sessionData['ageGroup'] ?? 'Unknown',
          );

          _allAttendanceRecords.add(sessionRecord);
        }
      }

      // Filter records based on the child's age group
      _applyAgeFilter();
    } catch (e) {
      print("Error loading attendance records: $e");
    }
  }

  // Add ageGroup property to SessionAttendanceRecord
  void _applyAgeFilter() {
    String? targetAgeGroup;

    if (_childDob != null) {
      // If DOB is available, calculate the age group
      double childAge = AgeCalculator.calculateAgeInYears(_childDob!);
      targetAgeGroup = AgeCalculator.getAgeGroupForChild(childAge);
    } else {
      // If no DOB is available, try to determine the age group from the student's session data
      if (_studentId != null) {
        // Find the most recent session for this student to get the age group
        for (var record in _allAttendanceRecords) {
          // Get the age group from the first available record
          if (record.ageGroup != 'Unknown') {
            targetAgeGroup = record.ageGroup;
            break;
          }
        }
      }
    }

    _attendanceRecords.clear();
    if (targetAgeGroup != null && targetAgeGroup != 'Unknown') {
      // Filter records to only show those matching the target age group
      for (var record in _allAttendanceRecords) {
        if (record.ageGroup == targetAgeGroup) {
          _attendanceRecords.add(record);
        }
      }
    } else {
      // If we still can't determine the age group, show all records as fallback
      _attendanceRecords.addAll(_allAttendanceRecords);
    }

    notifyListeners();
  }

  // Get only upcoming classes that are age-appropriate
  List<SessionAttendanceRecord> get upcomingAgeAppropriateClasses {
    return _attendanceRecords
        .where((record) => record.status == 'Upcoming')
        .toList()
      ..sort((a, b) => (a.date?.compareTo(b.date ?? DateTime(0))) ?? 0);
  }

  // Get recent attendance history (excluding upcoming classes)
  List<SessionAttendanceRecord> get recentAttendanceHistory {
    return _attendanceRecords
        .where((record) => record.status != 'Upcoming')
        .toList()
      ..sort((a, b) => (b.date?.compareTo(a.date ?? DateTime(0))) ?? 0);
  }

  // Load additional data for parent dashboard
  Future<void> _loadAdditionalData() async {
    if (_studentId == null) return;

    try {
      await _loadAttendanceStats();
      await _loadRecentAttendance();
      await _loadChildBadges();
      await _loadPaymentStatus();
    } catch (e) {
      print("Error loading additional data: $e");
    }
  }

  // Load attendance statistics
  Future<void> _loadAttendanceStats() async {
    try {
      _presentDaysCount = 0;
      _absentDaysCount = 0;
      _totalDaysCount = 0;

      for (var record in _allAttendanceRecords) {
        if (record.status != 'Upcoming') { // Only count completed sessions
          _totalDaysCount++;
          if (record.isPresent) {
            _presentDaysCount++;
          } else {
            _absentDaysCount++;
          }
        }
      }
    } catch (e) {
      print("Error loading attendance stats: $e");
    }
  }

  // Load recent attendance records
  Future<void> _loadRecentAttendance() async {
    try {
      _recentAttendance = [];

      // Take the most recent attendance records
      final recentRecords = _allAttendanceRecords
          .where((record) => record.status != 'Upcoming')
          .take(7) // Take only the 7 most recent
          .toList();

      for (var record in recentRecords) {
        String dateStr = record.date != null
            ? "${record.date!.day}/${record.date!.month}"
            : "Unknown";

        _recentAttendance.add({
          'date': dateStr,
          'status': record.isPresent ? 'Present' : 'Absent',
        });
      }
    } catch (e) {
      print("Error loading recent attendance: $e");
    }
  }

  // Load child badges
  Future<void> _loadChildBadges() async {
    try {
      _childBadges = [];

      // In the current structure, badges might be stored differently
      // Let's look for badges in the student document or session data
      if (_studentId != null) {
        // Query all sessions to find badge-related data
        QuerySnapshot sessionQuery = await _db.collection('sessions').get();

        for (var sessionDoc in sessionQuery.docs) {
          DocumentSnapshot studentDoc = await sessionDoc.reference.collection('students').doc(_studentId!).get();

          if (studentDoc.exists) {
            var studentData = studentDoc.data() as Map<String, dynamic>?;
            if (studentData != null && studentData.containsKey('badges')) {
              var badgesList = studentData['badges'] as List<dynamic>?;
              if (badgesList != null) {
                for (var badge in badgesList) {
                  if (badge is Map<String, dynamic>) {
                    String badgeName = badge['name'] ?? 'Badge';
                    String badgeType = badge['type'] ?? 'Unknown';

                    _childBadges.add({
                      'name': badgeName,
                      'type': badgeType,
                    });
                  }
                }
              }
            }
          }
        }

        // If no badges found in sessions, try to get from a main student collection if it exists
        if (_childBadges.isEmpty) {
          DocumentSnapshot mainStudentDoc = await _db.collection('students').doc(_studentId).get();
          if (mainStudentDoc.exists) {
            var data = mainStudentDoc.data() as Map<String, dynamic>?;
            if (data != null && data.containsKey('earnedBadges')) {
              var badgesList = data['earnedBadges'] as List<dynamic>?;
              if (badgesList != null) {
                for (var badge in badgesList) {
                  // Assuming badges are stored as strings in the format "badge_type_badge_name"
                  String badgeStr = badge.toString();
                  String badgeName = _formatBadgeName(badgeStr);
                  String badgeType = _extractBadgeType(badgeStr);

                  _childBadges.add({
                    'name': badgeName,
                    'type': badgeType,
                  });
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print("Error loading child badges: $e");
    }
  }

  // Load payment status
  Future<void> _loadPaymentStatus() async {
    try {
      // Check if payment is due for current month
      final now = DateTime.now();
      final currentMonthYear = "${now.year}-${now.month.toString().padLeft(2, '0')}";

      // In a real app, you would check a payments collection for this student
      // For now, we'll simulate based on whether there are upcoming classes
      _isPaymentDue = false; // Default to not due

      // You could implement actual payment checking logic here
      // For example, checking a 'payments' collection for the current month
      // Or checking if the student has upcoming classes but no payment record
    } catch (e) {
      print("Error loading payment status: $e");
    }
  }

  // Extract badge type from badge ID
  String _extractBadgeType(String badgeId) {
    if (badgeId.toLowerCase().contains('red')) return 'Red';
    if (badgeId.toLowerCase().contains('yellow')) return 'Yellow';
    if (badgeId.toLowerCase().contains('green')) return 'Green';
    if (badgeId.toLowerCase().contains('purple')) return 'Purple';
    return 'Unknown';
  }

  // Format badge name from badge ID
  String _formatBadgeName(String badgeId) {
    // Convert snake_case or kebab-case to Title Case
    return badgeId
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  // Helper method to get parent name
  String? _getParentName() {
    // Try to get parent name from the user profile
    if (_studentName != null) {
      // If we have the student's name, we can derive parent name from it
      // In a real app, this would come from the parent's user profile
      return "Parent of $_studentName"; // Placeholder implementation
    }
    return "Parent";
  }

  // Helper method to get child age group
  String? _getChildAgeGroup() {
    // Calculate age group based on child's date of birth
    if (_childDob != null) {
      double childAge = AgeCalculator.calculateAgeInYears(_childDob!);
      return AgeCalculator.getAgeGroupForChild(childAge);
    }
    return "Age Group";
  }

  // Helper method to get child classes stream
  Stream<QuerySnapshot>? _getChildClassesStream() {
    // Return a stream for classes matching the child's age group
    String? childAgeGroup;

    if (_childDob != null) {
      // If DOB is available, calculate the age group
      double childAge = AgeCalculator.calculateAgeInYears(_childDob!);
      childAgeGroup = AgeCalculator.getAgeGroupForChild(childAge);
    } else if (_studentId != null) {
      // If no DOB, try to get age group from the student's session data
      // We'll need to fetch the student's current age group from their session
      // For now, we'll fetch the student's age group from their session records
      // This requires a more complex approach - we'll get the age group from the session
      // where this student is enrolled
    }

    // Try to determine the age group from the attendance records we've already loaded
    if (childAgeGroup == null || childAgeGroup.isEmpty || childAgeGroup == 'Unknown') {
      for (var record in _allAttendanceRecords) {
        if (record.ageGroup != 'Unknown') {
          childAgeGroup = record.ageGroup;
          break;
        }
      }
    }

    if (childAgeGroup != null && childAgeGroup.isNotEmpty && childAgeGroup != 'Unknown') {
      return _db.collection('sessions')
          .where('ageGroup', isEqualTo: childAgeGroup)
          .orderBy('startTime', descending: true)
          .snapshots();
    }

    // If no age group can be determined, return all sessions as fallback
    return _db.collection('sessions')
        .orderBy('startTime', descending: true)
        .snapshots();
  }

  // Method to load child data (for the refresh indicator)
  Future<void> loadChildData() async {
    await refreshData();
  }

  // Method to refresh data
  Future<void> refreshData() async {
    await _findAndLoadStudentData();
    await _loadAdditionalData();
    notifyListeners();
  }
}

// Model class for session attendance records
class SessionAttendanceRecord {
  final String sessionId;
  final String className;
  final String venue;
  final DateTime? date;
  final bool isPresent;
  final String status;
  final String ageGroup; // Added age group property

  SessionAttendanceRecord({
    required this.sessionId,
    required this.className,
    required this.venue,
    this.date,
    required this.isPresent,
    required this.status,
    required this.ageGroup, // Added age group parameter
  });
}