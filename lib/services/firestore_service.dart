import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/session_template.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==============================================================================
  // 📅 DASHBOARD & SESSIONS
  // ==============================================================================

  /// Get all classes assigned to a specific coach
  Stream<QuerySnapshot> getCoachSessions(String coachId) {
    return _db
        .collection('sessions')
        .where('coachId', isEqualTo: coachId)
        .orderBy('startTime') // Sort by time (e.g., 9:00 AM, 10:00 AM)
        .snapshots(); // 'snapshots' gives us a real-time stream (Live updates)
  }

  // ==============================================================================
  // 📋 ATTENDANCE
  // ==============================================================================

  /// Get the list of students enrolled in a specific class session
  Stream<QuerySnapshot> getSessionStudents(String sessionId) {
    return _db
        .collection('sessions')
        .doc(sessionId)
        .collection('students')
        .orderBy('name')
        .snapshots();
  }

  /// Mark a student as Present or Absent in a specific session
  Future<void> updateAttendance(String sessionId, String studentId, bool isPresent) async {
    try {
      await _db
          .collection('sessions')
          .doc(sessionId)
          .collection('students')
          .doc(studentId)
          .update({
        'isPresent': isPresent,
        'lastUpdated': FieldValue.serverTimestamp(), // Track when it was changed
      });
    } catch (e) {
      print("Error updating attendance: $e");
      rethrow;
    }
  }

  /// Mark a student as Present or Absent for a specific date (for the new students collection)
  Future<void> updateStudentAttendanceByDate(String studentId, DateTime date, String status) async {
    try {
      // Format date as YYYY-MM-DD for the key
      String dateKey = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      await _db.collection('students').doc(studentId).update({
        'attendanceHistory.$dateKey': status,
      });
    } catch (e) {
      print("Error updating student attendance by date: $e");
      rethrow;
    }
  }

  // ==============================================================================
  // ⚽ DRILL LIBRARY
  // ==============================================================================

  /// Fetch drills, optionally filtered by Age Group (Little Kicks, Junior, etc.)
  Future<List<Map<String, dynamic>>> getDrills({String? ageGroup}) async {
    Query query = _db.collection('drills');

    if (ageGroup != null && ageGroup != 'All') {
      query = query.where('ageGroup', isEqualTo: ageGroup);
    }

    QuerySnapshot snapshot = await query.get();

    // Convert the database snapshot into a clean List of Maps, filtering out null data
    List<Map<String, dynamic>> drills = snapshot.docs
        .map((doc) {
          final data = doc.data();
          if (data != null && data is Map<String, dynamic>) {
            return data.cast<String, dynamic>();
          }
          return <String, dynamic>{}; // Return empty map for null data
        })
        .where((data) => data.isNotEmpty) // Filter out empty maps
        .toList();

    // Sort drills by Little Kickers session structure order
    drills.sort((a, b) {
      return _getCategoryOrder(a['category'] as String?)
          .compareTo(_getCategoryOrder(b['category'] as String?));
    });

    return drills;
  }

  /// Helper method to determine the order of drill categories according to Little Kickers session structure
  int _getCategoryOrder(String? category) {
    if (category == null) return 999; // Put nulls at the end

    // Define the strict order for Little Kickers sessions
    switch (category.toLowerCase()) {
      case 'intro':
      case 'muster':
      case 'intro / muster':
        return 0; // First: Intro / Muster
      case 'warm up':
        return 1; // Second: Warm Up
      case 'technical':
      case 'skill':
      case 'technical / skill':
        return 2; // Third: Technical / Skill
      case 'match':
      case 'game':
      case 'fun game':
      case 'match / game':
        return 3; // Fourth: Match / Game
      default:
        return 999; // Any other categories go to the end
    }
  }

  // ==============================================================================
  // 👤 STUDENT PROFILE
  // ==============================================================================

  /// Add a new student to the students collection
  Future<void> addStudent({
    required String name,
    required DateTime joinDate,
    required String parentContact,
    required String medicalNotes,
    required String assignedClassId,
  }) async {
    try {
      await _db.collection('students').add({
        'name': name,
        'joinDate': Timestamp.fromDate(joinDate),
        'parentContact': parentContact,
        'medicalNotes': medicalNotes,
        'assignedClassId': assignedClassId,
        'attendanceHistory': {}, // Initialize with empty attendance history
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding student: $e");
      rethrow;
    }
  }

  /// Update student attendance for a specific date
  Future<void> updateStudentAttendance(String studentId, DateTime date, String status) async {
    try {
      // Format date as YYYY-MM-DD for the key
      String dateKey = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      await _db.collection('students').doc(studentId).update({
        'attendanceHistory.$dateKey': status,
      });
    } catch (e) {
      print("Error updating student attendance: $e");
      rethrow;
    }
  }

  /// Update student information
  Future<void> updateStudent(String studentId, Map<String, dynamic> data) async {
    try {
      await _db.collection('students').doc(studentId).update(data);
    } catch (e) {
      print("Error updating student: $e");
      rethrow;
    }
  }

  /// Get a specific student by ID
  Future<DocumentSnapshot> getStudent(String studentId) async {
    return await _db.collection('students').doc(studentId).get();
  }

  /// Add a note to a student
  Future<void> addNote(String studentId, String noteText) async {
    try {
      String noteId = _db.collection('students').doc(studentId).collection('notes').doc().id;
      await _db
          .collection('students')
          .doc(studentId)
          .collection('notes')
          .doc(noteId)
          .set({
        'text': noteText,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding note: $e");
      rethrow;
    }
  }

  /// Register a new coach with authentication and user profile
  Future<bool> registerCoach({
    required String name,
    required String email,
    required String phone,
    required String password,
    required double ratePerHour,
    required String role, // 'Lead' or 'Assistant'
  }) async {
    try {
      // Check if email already exists in Firebase Auth first
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String coachId = userCredential.user!.uid;

        // Create user profile document in Firestore
        await _db.collection('users').doc(coachId).set({
          'name': name,
          'email': email,
          'phone': phone,
          'role': 'coach', // Fixed role for coaches
          'coachRole': role, // 'Lead' or 'Assistant'
          'ratePerHour': ratePerHour,
          'assignedClasses': [], // Will be populated later
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        return true;
      } on FirebaseAuthException catch (e) {
        // Handle specific Firebase Auth errors
        if (e.code == 'email-already-in-use') {
          print("Error: Email already in use: $email");
        } else if (e.code == 'weak-password') {
          print("Error: Password is too weak");
        } else if (e.code == 'invalid-email') {
          print("Error: Invalid email format");
        } else {
          print("Firebase Auth Error: ${e.code} - ${e.message}");
        }
        return false;
      }
    } catch (e) {
      print("Error registering coach: $e");
      return false;
    }
  }

  /// Get all coaches for admin view
  Stream<QuerySnapshot> getCoaches() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'coach')
        .snapshots();
  }

  /// Register a new student with proper data structure
  Future<bool> registerStudent({
    required String name,
    required String parentEmail,
    required String parentPhone,
    required DateTime dateOfBirth,
    required String medicalNotes,
  }) async {
    try {
      // Calculate age group based on date of birth
      int ageInYears = DateTime.now().year - dateOfBirth.year;
      if (DateTime.now().month < dateOfBirth.month ||
          (DateTime.now().month == dateOfBirth.month && DateTime.now().day < dateOfBirth.day)) {
        ageInYears--;
      }

      String ageGroup;
      if (ageInYears >= 1 && ageInYears < 2.5) {
        ageGroup = 'Little Kicks';
      } else if (ageInYears >= 2.5 && ageInYears < 3.5) {
        ageGroup = 'Junior Kickers';
      } else if (ageInYears >= 3.5 && ageInYears < 5.0) {
        ageGroup = 'Mighty Kickers';
      } else if (ageInYears >= 5.0 && ageInYears <= 8.0) {
        ageGroup = 'Mega Kickers';
      } else {
        ageGroup = 'Unknown'; // Fallback for invalid ages
      }

      // Create student document in Firestore
      DocumentReference studentRef = await _db.collection('students').add({
        'name': name,
        'dateOfBirth': Timestamp.fromDate(dateOfBirth),
        'ageGroup': ageGroup,
        'parentEmail': parentEmail,
        'parentPhone': parentPhone,
        'medicalNotes': medicalNotes,
        'assignedClassId': '', // Will be assigned later
        'attendanceHistory': {},
        'earnedBadges': [],
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      String studentId = studentRef.id;

      // Create parent account if it doesn't exist
      await _createParentAccount(parentEmail, studentId, name);

      return true;
    } catch (e) {
      print("Error registering student: $e");
      return false;
    }
  }

  /// Create parent account if it doesn't exist
  Future<void> _createParentAccount(String parentEmail, String studentId, String studentName) async {
    try {
      // Check if a user with this email already exists in the users collection
      QuerySnapshot querySnapshot = await _db.collection('users')
          .where('email', isEqualTo: parentEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Create a temporary document ID for the parent account
        String parentId = _db.collection('users').doc().id;

        // Create a placeholder parent account
        await _db.collection('users').doc(parentId).set({
          'email': parentEmail,
          'role': 'student_parent',
          'linkedStudentId': studentId,
          'linkedStudentName': studentName,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Update existing parent account with new student info
        String existingUserId = querySnapshot.docs.first.id;
        await _db.collection('users').doc(existingUserId).update({
          'linkedStudentId': studentId,
          'linkedStudentName': studentName,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print("Error creating parent account: $e");
      // Continue without throwing - parent account is optional for now
    }
  }

  /// Get all students for admin view
  Stream<QuerySnapshot> getStudents() {
    return _db
        .collection('students')
        .snapshots();
  }

  /// Get students filtered by age group
  Stream<QuerySnapshot> getStudentsByAgeGroup(String ageGroup) {
    return _db
        .collection('students')
        .where('ageGroup', isEqualTo: ageGroup)
        .snapshots();
  }

  /// Register a new coach (legacy function - kept for compatibility)
  Future<void> registerCoachLegacy({
    required String name,
    required String email,
    required String phone,
    required int age,
    required double ratePerHour,
  }) async {
    try {
      await _db.collection('coaches').add({
        'name': name,
        'email': email,
        'phone': phone,
        'age': age,
        'ratePerHour': ratePerHour,
        'joinDate': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error registering coach: $e");
      rethrow;
    }
  }

  /// Get all students
  Stream<QuerySnapshot> getAllStudents() {
    return _db.collection('students').orderBy('name').snapshots();
  }

  // 🛠️ ADMIN: CREATE SESSIONS
  // ==============================================================================

  /// Creates a new class session in the database.
  Future<void> createSession({
    required String className,
    required String venue,
    required DateTime dateTime,
    required String ageGroup,
    required String coachId,
  }) async {
    try {
      await _db.collection('sessions').add({
        'className': className,
        'venue': venue,
        'startTime': Timestamp.fromDate(dateTime),
        'durationMinutes': ageGroup == 'Mega Kickers' ? 50 : 45, // Match seeder logic
        'coachId': coachId,
        'status': 'Upcoming', // New sessions are always upcoming
        'ageGroup': ageGroup,
      });
    } catch (e) {
      print("Error creating session: $e");
      rethrow;
    }
  }

  /// Creates a new class session in the database with detailed information.
  Future<void> createSessionWithDetails({
    required String className,
    required String venue,
    required DateTime dateTime,
    required String ageGroup,
    required String coachId,
    required int durationMinutes,
    String? instructions,
    String? equipment,
    String? progressionEasier,
    String? progressionHarder,
    String? learningGoals,
  }) async {
    try {
      await _db.collection('sessions').add({
        'className': className,
        'venue': venue,
        'startTime': Timestamp.fromDate(dateTime),
        'durationMinutes': durationMinutes,
        'coachId': coachId,
        'status': 'Upcoming', // New sessions are always upcoming
        'ageGroup': ageGroup,
        'instructions': instructions ?? '',
        'equipment': equipment ?? '',
        'progressionEasier': progressionEasier ?? '',
        'progressionHarder': progressionHarder ?? '',
        'learningGoals': learningGoals ?? '',
      });
    } catch (e) {
      print("Error creating session with details: $e");
      rethrow;
    }
  }

  /// Creates a new class session in the database with drills information.
  Future<void> createSessionWithDrills({
    required String className,
    required String venue,
    required DateTime dateTime,
    required String ageGroup,
    required String coachId,
    required int durationMinutes,
    required String badgeFocus,
    required List<Map<String, dynamic>> drills,
  }) async {
    try {
      await _db.collection('sessions').add({
        'className': className,
        'venue': venue,
        'startTime': Timestamp.fromDate(dateTime),
        'durationMinutes': durationMinutes,
        'coachId': coachId,
        'status': 'Upcoming', // New sessions are always upcoming
        'ageGroup': ageGroup,
        'badgeFocus': badgeFocus,
        'drills': drills, // Store the list of drills
      });
    } catch (e) {
      print("Error creating session with drills: $e");
      rethrow;
    }
  }

  /// Creates a new session template (content without scheduling)
  Future<void> createSessionTemplate({
    required String title,
    required String ageGroup,
    required String badgeFocus,
    required List<Map<String, dynamic>> drills,
    required String createdBy,
  }) async {
    try {
      await _db.collection('session_templates').add({
        'title': title,
        'ageGroup': ageGroup,
        'badgeFocus': badgeFocus,
        'drills': drills,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': createdBy,
      });
    } catch (e) {
      print("Error creating session template: $e");
      rethrow;
    }
  }

  /// Gets all session templates
  Stream<QuerySnapshot> getSessionTemplates() {
    return _db.collection('session_templates').orderBy('createdAt', descending: true).snapshots();
  }

  /// Gets session templates filtered by age group
  Stream<QuerySnapshot> getSessionTemplatesByAgeGroup(String ageGroup) {
    return _db
        .collection('session_templates')
        .where('ageGroup', isEqualTo: ageGroup)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Gets a specific session template by ID
  Future<SessionTemplate?> getSessionTemplateById(String templateId) async {
    try {
      DocumentSnapshot doc = await _db.collection('session_templates').doc(templateId).get();
      if (doc.exists) {
        return SessionTemplate.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      print("Error getting session template by ID: $e");
      return null;
    }
  }

  /// Gets all coaches
  // (Duplicate removed) getCoaches is defined earlier in this file.

  /// Creates a scheduled class using a template
  Future<void> createScheduledClass({
    required String templateId,
    required String className,
    required String venue,
    required DateTime dateTime,
    required String ageGroup,
    required String coachId,
    required int durationMinutes,
    required String badgeFocus,
  }) async {
    try {
      await _db.collection('scheduled_classes').add({
        'templateId': templateId,
        'className': className,
        'venue': venue,
        'startTime': Timestamp.fromDate(dateTime),
        'ageGroup': ageGroup,
        'coachId': coachId,
        'durationMinutes': durationMinutes,
        'badgeFocus': badgeFocus,
        'status': 'Scheduled', // New scheduled classes are always scheduled
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error creating scheduled class: $e");
      rethrow;
    }
  }

  /// Gets all scheduled classes
  Stream<QuerySnapshot> getScheduledClasses() {
    return _db
        .collection('scheduled_classes')
        .orderBy('startTime', descending: true)
        .snapshots();
  }

  /// Gets scheduled classes for a specific coach
  Stream<QuerySnapshot> getScheduledClassesForCoach(String coachId) {
    return _db
        .collection('scheduled_classes')
        .where('coachId', isEqualTo: coachId)
        .orderBy('startTime', descending: true)
        .snapshots();
  }

  /// Gets a scheduled class by ID
  Future<DocumentSnapshot> getScheduledClass(String sessionId) async {
    return await _db.collection('scheduled_classes').doc(sessionId).get();
  }

  // 🔐 USER ROLES & PERMISSIONS
  // ==============================================================================

  /// Get the role of a user (e.g., 'admin', 'coach', or 'student_parent')
  Future<String> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return data['role'] ?? 'coach'; // Default to coach if no role set
      }
      return 'coach'; // Default to coach if profile doesn't exist
    } catch (e) {
      print("Error getting user role: $e");
      return 'coach'; // Fail safe
    }
  }

  /// (Helper) Set a user's role. We use this in the Seeder.
  Future<void> setUserRole(String uid, String role) async {
    await _db.collection('users').doc(uid).set({
      'role': role,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // Merge so we don't wipe other data
  }
}