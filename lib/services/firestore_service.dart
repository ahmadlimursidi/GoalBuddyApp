import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/session_template.dart';
import '../models/notification_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==============================================================================
  // 📅 DASHBOARD & SESSIONS
  // ==============================================================================

  /// Get all classes assigned to a specific coach (as lead or assistant)
  Stream<QuerySnapshot> getCoachSessions(String coachId) {
    // Query sessions where the coach is either the lead coach or assistant coach
    // Using coachId field for backward compatibility
    return _db
        .collection('sessions')
        .where('coachId', isEqualTo: coachId)
        .orderBy('startTime')
        .snapshots();
  }

  /// Get sessions where coach is assigned as assistant
  Stream<QuerySnapshot> getAssistantCoachSessions(String coachId) {
    return _db
        .collection('sessions')
        .where('assistantCoachId', isEqualTo: coachId)
        .orderBy('startTime')
        .snapshots();
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
        // Note: coachRole is NOT set here - coaches are assigned as Lead/Assistant per session
        await _db.collection('users').doc(coachId).set({
          'name': name,
          'email': email,
          'phone': phone,
          'role': 'coach', // User type role (coach vs admin vs parent)
          'ratePerHour': ratePerHour,
          'assignedClasses': [], // Will be populated when assigned to sessions
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
    String? password, // Optional password for parent account
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
      await _createParentAccount(parentEmail, studentId, name, password);

      return true;
    } catch (e) {
      print("Error registering student: $e");
      return false;
    }
  }

  /// Create parent account if it doesn't exist
  Future<void> _createParentAccount(String parentEmail, String studentId, String studentName, [String? password]) async {
    try {
      // Check if a user with this email already exists in the users collection
      QuerySnapshot querySnapshot = await _db.collection('users')
          .where('email', isEqualTo: parentEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        String? parentId;

        // Create a Firebase Auth account for the parent (with a default or provided password)
        try {
          // If no password is provided, generate a secure random password
          String actualPassword = password ?? _generateRandomPassword();

          UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
            email: parentEmail,
            password: actualPassword,
          );
          parentId = userCredential.user!.uid;

          // Create the corresponding Firestore user document with the same ID as the auth user
          await _db.collection('users').doc(parentId).set({
            'email': parentEmail,
            'role': 'student_parent',
            'linkedStudentId': studentId,
            'linkedStudentName': studentName,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } on FirebaseAuthException catch (e) {
          print("Error creating parent auth account: ${e.code} - ${e.message}");
          // If auth creation fails, we can't create a proper parent account
          // The parent won't be able to sign in without an auth account
          rethrow; // Re-throw to indicate failure
        }
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

  /// Generate a random password for parent accounts
  String _generateRandomPassword() {
    const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%&*';
    final Random random = Random();
    String password = '';

    // Ensure at least one character from each category
    password += 'abcdefghijklmnopqrstuvwxyz'[random.nextInt(26)];
    password += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'[random.nextInt(26)];
    password += '0123456789'[random.nextInt(10)];
    password += '!@#\$%&*'[random.nextInt(7)];

    // Add more characters to reach desired length
    int length = 8 + random.nextInt(5);
    for (int i = password.length; i < length; i++) {
      password += chars[random.nextInt(chars.length)];
    }

    // Shuffle the password characters
    List<String> passwordList = password.split('');
    passwordList.shuffle();
    return passwordList.join();
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
    String? pdfUrl,
    String? pdfFileName,
  }) async {
    try {
      await _db.collection('session_templates').add({
        'title': title,
        'ageGroup': ageGroup,
        'badgeFocus': badgeFocus,
        'drills': drills,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': createdBy,
        'pdfUrl': pdfUrl,
        'pdfFileName': pdfFileName,
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
      // Get the template to copy PDF URL and other metadata
      DocumentSnapshot templateDoc = await _db.collection('session_templates').doc(templateId).get();
      Map<String, dynamic>? templateData = templateDoc.data() as Map<String, dynamic>?;

      String? pdfUrl = templateData?['pdfUrl'];
      String? pdfFileName = templateData?['pdfFileName'];

      await _db.collection('sessions').add({
        'templateId': templateId,
        'className': className,
        'venue': venue,
        'startTime': Timestamp.fromDate(dateTime),
        'ageGroup': ageGroup,
        'coachId': coachId,
        'durationMinutes': durationMinutes,
        'badgeFocus': badgeFocus,
        'pdfUrl': pdfUrl,        // Copy PDF URL from template
        'pdfFileName': pdfFileName, // Copy PDF file name from template
        'status': 'Scheduled', // New scheduled classes are always scheduled
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error creating scheduled class: $e");
      rethrow;
    }
  }

  /// Creates a scheduled class using a template with drills included
  Future<String> createScheduledClassWithDrills({
    required String templateId,
    required String className,
    required String venue,
    required DateTime dateTime,
    required String ageGroup,
    required String leadCoachId,
    String? assistantCoachId,
    required int durationMinutes,
    required String badgeFocus,
    required List<Map<String, dynamic>> drills,
  }) async {
    try {
      // Get the template to copy PDF URL and other metadata
      DocumentSnapshot templateDoc = await _db.collection('session_templates').doc(templateId).get();
      Map<String, dynamic>? templateData = templateDoc.data() as Map<String, dynamic>?;

      String? pdfUrl = templateData?['pdfUrl'];
      String? pdfFileName = templateData?['pdfFileName'];

      DocumentReference docRef = await _db.collection('sessions').add({
        'templateId': templateId,
        'className': className,
        'venue': venue,
        'startTime': Timestamp.fromDate(dateTime),
        'ageGroup': ageGroup,
        'leadCoachId': leadCoachId,
        'assistantCoachId': assistantCoachId,
        'coachId': leadCoachId, // Keep for backward compatibility
        'durationMinutes': durationMinutes,
        'badgeFocus': badgeFocus,
        'drillIds': drills.map((drill) => drill['id'] ?? '').toList(),
        'drills': drills,
        'pdfUrl': pdfUrl,        // Copy PDF URL from template
        'pdfFileName': pdfFileName, // Copy PDF file name from template
        'status': 'Scheduled',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print("Error creating scheduled class with drills: $e");
      rethrow;
    }
  }

  /// Auto-assign all students with matching age group to a class
  Future<void> autoAssignStudentsToClass({
    required String sessionId,
    required String ageGroup,
  }) async {
    try {
      print("DEBUG: Auto-assigning students with age group '$ageGroup' to session '$sessionId'");

      QuerySnapshot studentsQuery = await _db
          .collection('students')
          .where('ageGroup', isEqualTo: ageGroup)
          .get();

      print("DEBUG: Found ${studentsQuery.docs.length} students with age group '$ageGroup'");

      WriteBatch batch = _db.batch();
      int updateCount = 0;

      for (var studentDoc in studentsQuery.docs) {
        batch.update(studentDoc.reference, {
          'assignedClassId': sessionId,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        updateCount++;
        print("DEBUG: Queued update for student: ${studentDoc.id} (${(studentDoc.data() as Map)['name']})");
      }

      if (updateCount > 0) {
        await batch.commit();
        print("DEBUG: Successfully assigned $updateCount students to session $sessionId");
      }
    } catch (e) {
      print("Error auto-assigning students to class: $e");
      rethrow;
    }
  }

  /// Gets all scheduled classes
  Stream<QuerySnapshot> getScheduledClasses() {
    return _db
        .collection('sessions')
        .orderBy('startTime', descending: true)
        .snapshots();
  }

  /// Gets scheduled classes for a specific coach
  Stream<QuerySnapshot> getScheduledClassesForCoach(String coachId) {
    return _db
        .collection('sessions')
        .where('coachId', isEqualTo: coachId)
        .orderBy('startTime', descending: true)
        .snapshots();
  }

  /// Gets a scheduled class by ID
  Future<DocumentSnapshot> getScheduledClass(String sessionId) async {
    return await _db.collection('sessions').doc(sessionId).get();
  }

  /// Gets ALL scheduled classes (for admin view)
  Stream<QuerySnapshot> getAllScheduledClasses() {
    return _db
        .collection('sessions')
        .orderBy('startTime', descending: false)
        .snapshots();
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

  /// Get session details by ID
  Future<DocumentSnapshot> getSession(String sessionId) async {
    return await _db.collection('sessions').doc(sessionId).get();
  }

  /// Get a specific coach by ID
  Future<DocumentSnapshot> getCoachById(String? coachId) async {
    if (coachId == null) {
      throw Exception('Coach ID is null');
    }
    return await _db.collection('users').doc(coachId).get();
  }

  /// Complete a session by marking it as Completed
  Future<void> completeSession(String sessionId) async {
    try {
      // Update in sessions collection
      await _db.collection('sessions').doc(sessionId).update({
        'status': 'Completed',
        'completedAt': FieldValue.serverTimestamp(),
      });
      print('Session $sessionId marked as Completed');
    } catch (e) {
      print('Error completing session: $e');
      rethrow;
    }
  }

  /// Archive a completed session by moving it to pastSessions collection
  Future<void> archiveSession(String sessionId) async {
    try {
      // Get the session document
      DocumentSnapshot sessionDoc = await _db.collection('sessions').doc(sessionId).get();

      if (!sessionDoc.exists) {
        throw Exception('Session not found');
      }

      Map<String, dynamic> sessionData = sessionDoc.data() as Map<String, dynamic>;

      // Ensure it's completed before archiving
      if (sessionData['status'] != 'Completed') {
        throw Exception('Only completed sessions can be archived');
      }

      // Add to pastSessions collection with the same ID
      await _db.collection('pastSessions').doc(sessionId).set({
        ...sessionData,
        'archivedAt': FieldValue.serverTimestamp(),
      });

      // Copy student attendance data from sessions/{sessionId}/students to pastSessions/{sessionId}/students
      QuerySnapshot studentsSnapshot = await _db
          .collection('sessions')
          .doc(sessionId)
          .collection('students')
          .get();

      if (studentsSnapshot.docs.isNotEmpty) {
        WriteBatch batch = _db.batch();

        for (QueryDocumentSnapshot studentDoc in studentsSnapshot.docs) {
          batch.set(
            _db.collection('pastSessions').doc(sessionId).collection('students').doc(studentDoc.id),
            studentDoc.data() as Map<String, dynamic>
          );
        }

        await batch.commit();
      }

      // Delete from sessions collection
      await _db.collection('sessions').doc(sessionId).delete();

      print('Session $sessionId archived successfully with attendance data');
    } catch (e) {
      print('Error archiving session: $e');
      rethrow;
    }
  }

  /// Get archived/past sessions
  Stream<QuerySnapshot> getPastSessions() {
    return _db
        .collection('pastSessions')
        .orderBy('completedAt', descending: true)
        .snapshots();
  }

  /// Get archived/past sessions for a specific coach
  Stream<QuerySnapshot> getPastSessionsForCoach(String coachId) {
    return _db
        .collection('pastSessions')
        .where('coachId', isEqualTo: coachId)
        .orderBy('archivedAt', descending: true)
        .snapshots();
  }

  /// Delete a session permanently (including any subcollections)
  Future<void> deleteSession(String sessionId) async {
    try {
      // First, delete any students subcollection documents
      QuerySnapshot studentsSnapshot = await _db
          .collection('sessions')
          .doc(sessionId)
          .collection('students')
          .get();

      if (studentsSnapshot.docs.isNotEmpty) {
        WriteBatch batch = _db.batch();
        for (QueryDocumentSnapshot studentDoc in studentsSnapshot.docs) {
          batch.delete(studentDoc.reference);
        }
        await batch.commit();
        print('Deleted ${studentsSnapshot.docs.length} student records from session $sessionId');
      }

      // Then delete the session document itself
      await _db.collection('sessions').doc(sessionId).delete();
      print('Session $sessionId deleted successfully');
    } catch (e) {
      print('Error deleting session: $e');
      rethrow;
    }
  }

  // ==============================================================================
  // 🔔 NOTIFICATIONS
  // ==============================================================================

  /// Update user's FCM token
  Future<void> updateUserFcmToken(String userId, String token) async {
    try {
      await _db.collection('users').doc(userId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating FCM token: $e');
      rethrow;
    }
  }

  /// Get FCM tokens for multiple users
  Future<List<String>> getUserFcmTokens(List<String> userIds) async {
    List<String> tokens = [];
    try {
      for (String userId in userIds) {
        DocumentSnapshot doc = await _db.collection('users').doc(userId).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null && data['fcmToken'] != null) {
            tokens.add(data['fcmToken'] as String);
          }
        }
      }
    } catch (e) {
      print('Error getting FCM tokens: $e');
    }
    return tokens;
  }

  /// Get all coach FCM tokens
  Future<Map<String, String>> getCoachTokens() async {
    Map<String, String> tokens = {};
    try {
      QuerySnapshot snapshot = await _db
          .collection('users')
          .where('role', isEqualTo: 'coach')
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['fcmToken'] != null) {
          tokens[doc.id] = data['fcmToken'] as String;
        }
      }
    } catch (e) {
      print('Error getting coach tokens: $e');
    }
    return tokens;
  }

  /// Get all parent FCM tokens
  Future<Map<String, String>> getParentTokens() async {
    Map<String, String> tokens = {};
    try {
      QuerySnapshot snapshot = await _db
          .collection('users')
          .where('role', isEqualTo: 'student_parent')
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['fcmToken'] != null) {
          tokens[doc.id] = data['fcmToken'] as String;
        }
      }
    } catch (e) {
      print('Error getting parent tokens: $e');
    }
    return tokens;
  }

  /// Save a notification to Firestore
  Future<void> saveNotification(NotificationModel notification) async {
    try {
      await _db.collection('notifications').add(notification.toMap());
    } catch (e) {
      print('Error saving notification: $e');
      rethrow;
    }
  }

  /// Save notifications for multiple users (batch)
  Future<void> saveNotificationsForUsers({
    required List<String> userIds,
    required String title,
    required String body,
    required String type,
    String? relatedSessionId,
    String? targetRole,
  }) async {
    try {
      WriteBatch batch = _db.batch();

      for (String userId in userIds) {
        DocumentReference docRef = _db.collection('notifications').doc();
        batch.set(docRef, {
          'title': title,
          'body': body,
          'type': type,
          'targetUserId': userId,
          'targetRole': targetRole,
          'relatedSessionId': relatedSessionId,
          'createdAt': FieldValue.serverTimestamp(),
          'read': false,
        });
      }

      await batch.commit();
      print('Saved notifications for ${userIds.length} users');
    } catch (e) {
      print('Error saving notifications batch: $e');
      rethrow;
    }
  }

  /// Get notifications for a user
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('targetUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  /// Get unread notification count for a user
  Stream<int> getUnreadNotificationCount(String userId) {
    return _db
        .collection('notifications')
        .where('targetUserId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Mark a notification as read
  Future<void> markNotificationRead(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).update({
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read for a user
  Future<void> markAllNotificationsRead(String userId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('notifications')
          .where('targetUserId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) return;

      WriteBatch batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {
          'read': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }

  /// Get user document by ID
  Future<DocumentSnapshot> getUser(String userId) async {
    return await _db.collection('users').doc(userId).get();
  }

  /// Get parents for students in a specific age group
  Future<List<String>> getParentIdsForAgeGroup(String ageGroup) async {
    List<String> parentIds = [];
    try {
      // Get all students with this age group
      QuerySnapshot studentsSnapshot = await _db
          .collection('students')
          .where('ageGroup', isEqualTo: ageGroup)
          .get();

      // Get parent emails from students
      Set<String> parentEmails = {};
      for (var doc in studentsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['parentEmail'] != null) {
          parentEmails.add(data['parentEmail'] as String);
        }
      }

      // Find user IDs for these parent emails
      for (String email in parentEmails) {
        QuerySnapshot userSnapshot = await _db
            .collection('users')
            .where('email', isEqualTo: email)
            .where('role', isEqualTo: 'student_parent')
            .limit(1)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          parentIds.add(userSnapshot.docs.first.id);
        }
      }
    } catch (e) {
      print('Error getting parent IDs for age group: $e');
    }
    return parentIds;
  }
}