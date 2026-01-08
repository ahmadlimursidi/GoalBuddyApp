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
  DateTime? _childDob;
  String? _assignedClassId;
  String? _ageGroup;
  final List<SessionAttendanceRecord> _allAttendanceRecords = [];
  final List<SessionAttendanceRecord> _attendanceRecords = [];
  bool _isLoading = false;

  // Additional properties for parent dashboard
  int _presentDaysCount = 0;
  int _absentDaysCount = 0;
  int _totalDaysCount = 0;
  List<Map<String, dynamic>> _recentAttendance = [];
  bool _isPaymentDue = false;
  List<Map<String, dynamic>> _childBadges = [];
  int _currentStreak = 0;
  int _longestStreak = 0;
  List<Map<String, dynamic>> _registeredClasses = [];
  double _attendanceRate = 0.0;

  // Getters
  String? get studentName => _studentName;
  String? get parentContact => _parentContact;
  String? get medicalNotes => _medicalNotes;
  DateTime? get childDob => _childDob;
  String? get assignedClassId => _assignedClassId;
  String? get ageGroup => _ageGroup;
  List<SessionAttendanceRecord> get attendanceRecords => _attendanceRecords;
  bool get isLoading => _isLoading;

  // Getters for parent dashboard features
  int get presentDaysCount => _presentDaysCount;
  int get absentDaysCount => _absentDaysCount;
  int get totalDaysCount => _totalDaysCount;
  List<Map<String, dynamic>> get recentAttendance => _recentAttendance;
  bool get isPaymentDue => _isPaymentDue;
  List<Map<String, dynamic>> get childBadges => _childBadges;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  List<Map<String, dynamic>> get registeredClasses => _registeredClasses;
  double get attendanceRate => _attendanceRate;

  // Getters for child and parent names
  String? get parentName => _getParentName();
  String? get childName => _studentName;
  String? get childAgeGroup => _getChildAgeGroup();

  // Get child classes stream
  Stream<QuerySnapshot>? get childClassesStream => _getChildClassesStream();

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get student ID
  String? get studentId => _studentId;

  // Get session activities/drills for a specific session
  Future<List<Map<String, dynamic>>> getSessionActivities(String sessionId) async {
    try {
      // Try scheduled_classes collection first (for admin-scheduled classes)
      DocumentSnapshot classDoc = await _db.collection('sessions').doc(sessionId).get();

      if (classDoc.exists) {
        final classData = classDoc.data() as Map<String, dynamic>;

        // Check if drills are embedded directly in the class document
        if (classData['drills'] != null) {
          return List<Map<String, dynamic>>.from(classData['drills']);
        }

        // Otherwise, fetch drills by ID
        final drillIds = List<String>.from(classData['drillIds'] ?? []);
        List<Map<String, dynamic>> activities = [];

        for (String drillId in drillIds) {
          DocumentSnapshot drillDoc = await _db.collection('drills').doc(drillId).get();
          if (drillDoc.exists) {
            final drillData = drillDoc.data() as Map<String, dynamic>;
            activities.add({
              'id': drillDoc.id,
              'title': drillData['title'] ?? 'Activity',
              'description': drillData['description'] ?? '',
              'duration': drillData['duration'] ?? 0,
              'drillType': drillData['drillType'] ?? 'Unknown',
              'badgeFocus': drillData['badgeFocus'] ?? 'Unknown',
              'ageGroup': drillData['ageGroup'] ?? 'Unknown',
            });
          }
        }

        return activities;
      }
    } catch (e) {
      print("Error loading session activities: $e");
    }

    return [];
  }

  // Initialize with student data - for now we'll find the student associated with the current user
  Future<void> initializeStudentData() async {
    _isLoading = true;
    notifyListeners();

    try {
      print("DEBUG: Starting initializeStudentData()");
      await _findAndLoadStudentData();
      print("DEBUG: _findAndLoadStudentData() completed. StudentId: $_studentId");
      await _loadAdditionalData();
      print("DEBUG: _loadAdditionalData() completed.");
    } catch (e) {
      print("Error loading student data: $e");
      print("Error stack trace: ${StackTrace.current}");
    } finally {
      _isLoading = false;
      print("DEBUG: Setting isLoading to false. StudentId: $_studentId");
      notifyListeners();
    }
  }

  // Find student data associated with the current user
  Future<void> _findAndLoadStudentData() async {
    String? userId = _auth.currentUser?.uid;
    print("DEBUG: _findAndLoadStudentData() - Current user ID: $userId");

    if (userId == null) {
      print("DEBUG: No user logged in");
      return;
    }

    try {
      // First, try to find if this user is directly linked to a student in a user profile
      DocumentSnapshot userDoc = await _db.collection('users').doc(userId).get();
      print("DEBUG: User document exists: ${userDoc.exists}");

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        print("DEBUG: User data keys: ${userData.keys.toList()}");

        if (userData.containsKey('linkedStudentId')) {
          _studentId = userData['linkedStudentId'];
          print("DEBUG: Found linkedStudentId in user profile: $_studentId");
        } else {
          print("DEBUG: No linkedStudentId found in user profile");
        }
      }

      // If not found in user profile, try to find by parent contact info
      if (_studentId == null) {
        print("DEBUG: Calling _findStudentByParentContact()");
        await _findStudentByParentContact();
        print("DEBUG: _findStudentByParentContact() completed. StudentId: $_studentId");
      }

      if (_studentId != null) {
        print("DEBUG: Loading student profile for ID: $_studentId");
        await _loadStudentProfile();
        await _loadAttendanceRecords();
      } else {
        print("DEBUG: Student ID is still null after search");
      }
    } catch (e) {
      print("Error finding student data: $e");
      print("Error stack trace: ${StackTrace.current}");
    }
  }

  // Find student by parent contact information (simplified approach for demo)
  Future<void> _findStudentByParentContact() async {
    try {
      String? userEmail = _auth.currentUser?.email;
      print("DEBUG _findStudentByParentContact: Starting with email: $userEmail, uid: ${_auth.currentUser?.uid}");

      // First, try to find from the users collection (where parent accounts are linked)
      DocumentSnapshot userDoc = await _db.collection('users').doc(_auth.currentUser?.uid).get();
      print("DEBUG _findStudentByParentContact: User doc exists: ${userDoc.exists}");
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        print("DEBUG _findStudentByParentContact: User data keys: ${userData.keys.toList()}");
        if (userData.containsKey('linkedStudentId')) {
          _studentId = userData['linkedStudentId'];
          _studentName = userData['linkedStudentName'] ?? 'Demo Student';
          print("DEBUG _findStudentByParentContact: Found linkedStudentId: $_studentId, name: $_studentName");

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
      print("DEBUG _findStudentByParentContact: Trying to find by email in main students collection");
      if (userEmail != null) {
        QuerySnapshot studentQuery = await _db.collection('students')
            .where('parentEmail', isEqualTo: userEmail)
            .limit(1)
            .get();

        print("DEBUG _findStudentByParentContact: Found ${studentQuery.docs.length} students with email $userEmail");

        if (studentQuery.docs.isNotEmpty) {
          var studentDoc = studentQuery.docs.first;
          var studentData = studentDoc.data() as Map<String, dynamic>;

          _studentId = studentDoc.id;
          _studentName = studentData['name'];
          _parentContact = studentData['parentEmail'];
          _medicalNotes = studentData['medicalNotes'] ?? '';
          _childDob = (studentData['dateOfBirth'] as Timestamp?)?.toDate();

          print("DEBUG _findStudentByParentContact: Found student from main collection - ID: $_studentId, name: $_studentName");
          print("DEBUG _findStudentByParentContact: Student data keys: ${studentData.keys.toList()}");

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

  // Load student profile from Firestore - Following student_profile_view.dart pattern
  Future<void> _loadStudentProfile() async {
    if (_studentId == null) {
      print("DEBUG: Cannot load profile - studentId is null");
      return;
    }

    try {
      print("DEBUG: Loading profile for studentId: $_studentId");
      // Check if student exists in the main 'students' collection first
      DocumentSnapshot mainStudentDoc = await _db.collection('students').doc(_studentId!).get();

      if (mainStudentDoc.exists) {
        final data = mainStudentDoc.data() as Map<String, dynamic>;
        print("DEBUG: Found student in main collection");
        print("DEBUG: Student data keys: ${data.keys}");

        _studentName = data['name'] ?? 'Student';
        _parentContact = data['parentEmail'] ?? data['parentPhone'] ?? 'Not Provided';
        _medicalNotes = data['medicalNotes'] ?? 'None';
        _assignedClassId = data['assignedClassId'];
        _ageGroup = data['ageGroup'];

        print("DEBUG: Loaded - Name: $_studentName, AssignedClass: $_assignedClassId, AgeGroup: $_ageGroup");

        // Load date of birth
        var dobTimestamp = data['dateOfBirth'] as Timestamp?;
        if (dobTimestamp != null) {
          _childDob = dobTimestamp.toDate();
        }

        // If no age group but has assignedClassId, get it from the session
        if ((_ageGroup == null || _ageGroup!.isEmpty) && _assignedClassId != null) {
          _ageGroup = await _getAgeGroupFromSession(_assignedClassId!);
          print("DEBUG: Fetched age group from session: $_ageGroup");
        }
      } else {
        print("DEBUG: Student not found in main collection, checking sessions");

        // Fallback: look for student data in session subcollections
        QuerySnapshot sessionQuery = await _db.collection('sessions').get();

        for (var sessionDoc in sessionQuery.docs) {
          DocumentSnapshot studentDoc = await sessionDoc.reference.collection('students').doc(_studentId!).get();

          if (studentDoc.exists) {
            var studentData = studentDoc.data() as Map<String, dynamic>;
            var sessionData = sessionDoc.data() as Map<String, dynamic>;

            _studentName = studentData['name'] ?? 'Student';
            _parentContact = studentData['parentContact'] ?? 'Not Provided';
            _medicalNotes = studentData['medicalNotes'] ?? 'None';
            _ageGroup = sessionData['ageGroup'] ?? 'Unknown';

            var dobTimestamp = studentData['dateOfBirth'] as Timestamp?;
            if (dobTimestamp != null) {
              _childDob = dobTimestamp.toDate();
            }

            break;
          }
        }
      }
    } catch (e) {
      print("Error loading student profile: $e");
    }
  }

  // Helper to get age group from session
  Future<String> _getAgeGroupFromSession(String sessionId) async {
    try {
      DocumentSnapshot sessionDoc = await _db.collection('sessions').doc(sessionId).get();
      if (sessionDoc.exists) {
        final data = sessionDoc.data() as Map<String, dynamic>;
        return data['ageGroup'] ?? 'Unknown';
      }
    } catch (e) {
      print("Error getting age group from session: $e");
    }
    return 'Unknown';
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
      await _calculateStreaks();
      await _loadChildBadges();
      await _loadPaymentStatus();
      await _loadRegisteredClasses();
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

      // Calculate attendance rate
      _attendanceRate = _totalDaysCount > 0
          ? (_presentDaysCount / _totalDaysCount) * 100
          : 0.0;
    } catch (e) {
      print("Error loading attendance stats: $e");
    }
  }

  // Calculate attendance streaks
  Future<void> _calculateStreaks() async {
    try {
      _currentStreak = 0;
      _longestStreak = 0;
      int tempStreak = 0;

      // Sort records by date (oldest first)
      final sortedRecords = _allAttendanceRecords
          .where((record) => record.status != 'Upcoming')
          .toList()
        ..sort((a, b) => (a.date?.compareTo(b.date ?? DateTime(0))) ?? 0);

      for (int i = 0; i < sortedRecords.length; i++) {
        if (sortedRecords[i].isPresent) {
          tempStreak++;
          if (tempStreak > _longestStreak) {
            _longestStreak = tempStreak;
          }
          // If this is the most recent record, it's the current streak
          if (i == sortedRecords.length - 1) {
            _currentStreak = tempStreak;
          }
        } else {
          // Reset streak on absence
          // But only set current streak to 0 if this is the most recent
          if (i == sortedRecords.length - 1) {
            _currentStreak = 0;
          }
          tempStreak = 0;
        }
      }
    } catch (e) {
      print("Error calculating streaks: $e");
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

  // Load payment status - Following finance_view.dart logic
  Future<void> _loadPaymentStatus() async {
    try {
      if (_studentId == null) {
        _isPaymentDue = false;
        return;
      }

      final now = DateTime.now();
      final currentMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";

      // Check main students collection for attendance history
      DocumentSnapshot studentDoc = await _db.collection('students').doc(_studentId!).get();

      if (studentDoc.exists) {
        final data = studentDoc.data() as Map<String, dynamic>;
        final attendanceHistory = Map<String, dynamic>.from(data['attendanceHistory'] ?? {});

        // If student attended this month, consider payment made (finance_view.dart logic)
        bool hasAttendedThisMonth = attendanceHistory.entries.any((entry) {
          return entry.key.startsWith(currentMonth);
        });

        // Payment is due if NOT attended this month (or has no attendance history)
        _isPaymentDue = !hasAttendedThisMonth;
      } else {
        // If student not in main collection, default to payment due
        _isPaymentDue = true;
      }
    } catch (e) {
      print("Error loading payment status: $e");
      _isPaymentDue = false; // Safe default
    }
  }

  // Load registered classes - Improved to use assignedClassId first
  Future<void> _loadRegisteredClasses() async {
    try {
      _registeredClasses = [];

      if (_studentId == null) {
        print("DEBUG: studentId is null, cannot load classes");
        return;
      }

      print("DEBUG: Loading classes for student: $_studentId");
      print("DEBUG: Assigned class ID: $_assignedClassId");
      print("DEBUG: Age group: $_ageGroup");

      // Priority 1: If student has an assignedClassId, get that specific class
      // Check for both null and empty string
      if (_assignedClassId != null && _assignedClassId!.trim().isNotEmpty) {
        print("DEBUG: Fetching assigned class: $_assignedClassId");
        DocumentSnapshot assignedClass = await _db.collection('sessions').doc(_assignedClassId!).get();

        if (assignedClass.exists) {
          var classData = assignedClass.data() as Map<String, dynamic>;
          print("DEBUG: Assigned class found. Status: ${classData['status']}");
          if (classData['status'] == 'Scheduled' || classData['status'] == 'Upcoming') {
            DateTime startTime = (classData['startTime'] as Timestamp).toDate();

            _registeredClasses.add({
              'id': assignedClass.id,
              'className': classData['className'] ?? 'Class',
              'venue': classData['venue'] ?? 'Venue',
              'startTime': startTime,
              'ageGroup': classData['ageGroup'] ?? _ageGroup ?? 'Unknown',
              'isAssigned': true,
            });
            print("DEBUG: Added assigned class: ${classData['className']}");
          } else {
            print("DEBUG: Assigned class status is not Scheduled: ${classData['status']}");
          }
        } else {
          print("DEBUG: Assigned class not found in scheduled_classes");
        }
      } else {
        print("DEBUG: No assigned class ID (null or empty)");
      }

      // Priority 2: Get other upcoming scheduled classes for student's age group
      String? childAgeGroup = _ageGroup;
      if (childAgeGroup == null || childAgeGroup.isEmpty || childAgeGroup == 'Unknown') {
        if (_childDob != null) {
          double childAge = AgeCalculator.calculateAgeInYears(_childDob!);
          childAgeGroup = AgeCalculator.getAgeGroupForChild(childAge);
        } else {
          // Get age group from attendance records
          for (var record in _allAttendanceRecords) {
            if (record.ageGroup != 'Unknown') {
              childAgeGroup = record.ageGroup;
              break;
            }
          }
        }
      }

      if (childAgeGroup != null && childAgeGroup != 'Unknown') {
        // Query scheduled_classes collection for upcoming classes
        QuerySnapshot upcomingClasses = await _db
            .collection('sessions')
            .where('ageGroup', isEqualTo: childAgeGroup)
            .get();

        // Filter for scheduled classes and sort by startTime
        List<QueryDocumentSnapshot> filteredClasses = upcomingClasses.docs
            .where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['status'] == 'Scheduled' || data['status'] == 'Upcoming';
            })
            .toList()
          ..sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = (aData['startTime'] as Timestamp?)?.toDate() ?? DateTime(0);
            final bTime = (bData['startTime'] as Timestamp?)?.toDate() ?? DateTime(0);
            return aTime.compareTo(bTime); // Ascending order
          });

        // Take first 5
        for (var classDoc in filteredClasses.take(5)) {
          // Skip if already added as assigned class
          if (classDoc.id == _assignedClassId) continue;

          var classData = classDoc.data() as Map<String, dynamic>;
          DateTime startTime = (classData['startTime'] as Timestamp).toDate();

          _registeredClasses.add({
            'id': classDoc.id,
            'className': classData['className'] ?? 'Class',
            'venue': classData['venue'] ?? 'Venue',
            'startTime': startTime,
            'ageGroup': classData['ageGroup'] ?? childAgeGroup,
            'isAssigned': false,
          });
        }
      }
    } catch (e) {
      print("Error loading registered classes: $e");
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

    // Use _ageGroup field if available (loaded from student profile)
    if (_ageGroup != null && _ageGroup!.isNotEmpty && _ageGroup != 'Unknown') {
      childAgeGroup = _ageGroup;
    }

    if (childAgeGroup != null && childAgeGroup.isNotEmpty && childAgeGroup != 'Unknown') {
      // Query scheduled_classes collection for classes matching the age group
      // Sorting will be done in the UI
      return _db.collection('sessions')
          .where('ageGroup', isEqualTo: childAgeGroup)
          .snapshots();
    }

    // If no age group can be determined, return all scheduled classes as fallback
    return _db.collection('sessions')
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