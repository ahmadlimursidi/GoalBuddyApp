import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DatabaseSeeder {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==============================================================================
  // 🌱 MAIN SEEDER: POPULATE DATABASE
  // ==============================================================================
  Future<void> seedData(BuildContext context) async {
    User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: You must be logged in to seed data.")));
      return;
    }

    // We assign the seed data to the current user so you can see it immediately
    String coachId = user.uid;

    try {
      WriteBatch batch = _db.batch();

      // 1. DELETE OLD DRILLS (To prevent duplicates during testing)
      // Note: Only safe for development!
      var oldDrills = await _db.collection('drills').get();
      for (var doc in oldDrills.docs) {
        batch.delete(doc.reference);
      }

      // ==============================================================================
      // 📚 DRILL LIBRARY (Curriculum: Week 5 & 11)
      // ==============================================================================
      List<Map<String, dynamic>> drills = [
        // --- LITTLE KICKS (1.5 - 2.5 Years) ---
        // Source: Little Kicks - Badge #1 Week 5 & 11.pdf
        {
          'title': 'Free Play & Intro',
          'category': 'Intro',
          'durationSeconds': 300, // 5 mins
          'ageGroup': 'Little Kicks',
          'icon': 'diversity_3', // Represents group circle
          'instructions': 'Muster & Intro: Sit in circle. Go through names. Warm up: Reach for sky, frog jumps, kangaroo jumps. Daily health check.'
        },
        {
          'title': 'Magic Goals',
          'category': 'Warm Up',
          'durationSeconds': 600, // 10 mins
          'ageGroup': 'Little Kicks',
          'icon': 'visibility_off', // Hiding
          'instructions': 'Run around the track. When the "Sleeping Coach" wakes up, hide in the magic goals so he can\'t see you! Progression: Airplane arms, slow walking.'
        },
        {
          'title': 'Beat the Goalie',
          'category': 'Skill',
          'durationSeconds': 300, // 5 mins
          'ageGroup': 'Little Kicks',
          'icon': 'sports_soccer',
          'instructions': 'Coach is the goalkeeper (sleeping). Children take turns to score. Coach must over-exaggerate diving and missing the ball.'
        },
        {
          'title': 'Fruit Game',
          'category': 'Learning',
          'durationSeconds': 600, // 10 mins
          'ageGroup': 'Little Kicks',
          'icon': 'restaurant',
          'instructions': 'Pick fruit (cones) and put in basket (goal). Ask questions: "What colour is this apple/cone?"'
        },
        {
          'title': 'Body Part Free Play',
          'category': 'Fun Game',
          'durationSeconds': 600, // 10 mins
          'ageGroup': 'Little Kicks',
          'icon': 'accessibility_new',
          'instructions': 'Fast big kicks. On whistle, sit on ball. Touch head/tummy/knees.'
        },

        // --- JUNIOR KICKERS (2.5 - 3.5 Years) ---
        // Source: Junior Kickers - Badge #1 Week 5&11.pdf
        {
          'title': 'Muster & Warm Up',
          'category': 'Intro',
          'durationSeconds': 300, // 5 mins
          'ageGroup': 'Junior Kickers',
          'icon': 'waving_hand',
          'instructions': 'Sit on magic wall. Soldier & Star Jumps. Blast off like a rocket ship (Count down 5 to 0)!'
        },
        {
          'title': 'Farmer Relay',
          'category': 'Warm Up',
          'durationSeconds': 600, // 10 mins
          'ageGroup': 'Junior Kickers',
          'icon': 'directions_run',
          'instructions': 'Split into teams. Run to your colored garden, collect one piece of fruit (cone), run back. First team to collect all fruit wins.',
          'animationSteps': [
            'assets/drills/farmer_relay_step1.gif',
            'assets/drills/farmer_relay_step2.gif'
          ],
          'stepInstructions': [
            'Step 1: Set up the relay stations with cones.',
            'Step 2: Run to the cone, perform the task, then return.'
          ]
        },
        {
          'title': 'Fruit Exploration',
          'category': 'Technical',
          'durationSeconds': 600, // 10 mins
          'ageGroup': 'Junior Kickers',
          'icon': 'forest',
          'instructions': 'Small kicks inside the forest (cones). Stop ball with foot if you see a tree. "Small kicks so you don\'t knock down trees!"'
        },
        {
          'title': 'Fruit Collection (Big Kicks)',
          'category': 'Skill',
          'durationSeconds': 600, // 10 mins
          'ageGroup': 'Junior Kickers',
          'icon': 'touch_app',
          'instructions': 'Dribble to a tree, do a BIG KICK to knock the fruit off. Collect the cone. Count how many you have at the end.'
        },
        {
          'title': 'Multiple Shooting',
          'category': 'Match',
          'durationSeconds': 600, // 10 mins
          'ageGroup': 'Junior Kickers',
          'icon': 'sports_score',
          'instructions': 'Set up 3 goals at varying angles. Children strike ball into goals. Progression: Place ball on cone (tee) to help lift it.'
        },

        // --- MIGHTY KICKERS (3.5 - 5 Years) ---
        // Source: Mighty Kickers - Badge #5 Week 5&11.pdf
        {
          'title': 'Magic Carpet Intro',
          'category': 'Intro',
          'durationSeconds': 300, // 5 mins
          'ageGroup': 'Mighty Kickers',
          'icon': 'airline_seat_recline_extra',
          'instructions': 'Bicycle ride on backs (uphill/downhill). Superman stretch. Helicopter spins.'
        },
        {
          'title': 'Sea Creatures',
          'category': 'Warm Up',
          'durationSeconds': 600, // 10 mins
          'ageGroup': 'Mighty Kickers',
          'icon': 'water',
          'instructions': 'Coaches are sharks/crabs. Kids run to "Islands" (mats) to be safe when whistle blows. If caught, they get tickled.'
        },
        {
          'title': 'Invisible Forest',
          'category': 'Technical',
          'durationSeconds': 900, // 15 mins
          'ageGroup': 'Mighty Kickers',
          'icon': 'visibility_off',
          'instructions': 'Sneak through forest dribbling. Collect treasure (yellow cones). If Coach turns around, hide behind a tree and cover ball!'
        },
        {
          'title': 'Square Races',
          'category': 'Game',
          'durationSeconds': 600, // 10 mins
          'ageGroup': 'Mighty Kickers',
          'icon': 'crop_square',
          'instructions': 'Run around square, enter, get ball, score in color-coded goal. Race against partner starting at opposite corner.'
        },
        {
          'title': 'Basic Match',
          'category': 'Match',
          'durationSeconds': 300, // 5 mins
          'ageGroup': 'Mighty Kickers',
          'icon': 'groups',
          'instructions': '2 nets. No goalies. 1 ball. Directional play (score in other team\'s net).'
        },

        // --- MEGA KICKERS (5 - 8 Years) ---
        // Source: Mega Kickers - Badge #5 Week 5 & 11.pdf
        {
          'title': 'King of the Ring',
          'category': 'Warm Up',
          'durationSeconds': 900, // 15 mins
          'ageGroup': 'Mega Kickers',
          'icon': 'shield',
          'instructions': 'Dribble inside the ring. Coach enters to kick balls out. If your ball is out, you join the coach and help defend!'
        },
        {
          'title': 'Crazy Parrot',
          'category': 'Ball Mastery',
          'durationSeconds': 600, // 10 mins
          'ageGroup': 'Mega Kickers',
          'icon': 'pest_control_rodent',
          'instructions': 'Dribble around cage. Coach (Parrot) holds up colored feather (cone). Kids must sprint/dribble to that color cage safely.'
        },
        {
          'title': 'The Golden Circle',
          'category': 'Match',
          'durationSeconds': 1200, // 20 mins
          'ageGroup': 'Mega Kickers',
          'icon': 'radio_button_unchecked',
          'instructions': 'Match with a "Golden Circle" in the center. No players or ball allowed in circle. Encourages playing wide and accurate passing.'
        }
      ];

      // Add Drills to Database
      for (var drill in drills) {
        DocumentReference ref = _db.collection('drills').doc();
        batch.set(ref, drill);
      }

      // ==============================================================================
      // 📅 DELETE OLD SESSIONS FOR CURRENT COACH (To prevent duplicates)
      // ==============================================================================

      var oldSessions = await _db.collection('sessions').where('coachId', isEqualTo: coachId).get();
      for (var doc in oldSessions.docs) {
        // Delete students in each session first
        var oldSessionStudents = await doc.reference.collection('students').get();
        for (var studentDoc in oldSessionStudents.docs) {
          batch.delete(studentDoc.reference);
        }
        batch.delete(doc.reference);
      }

      // ==============================================================================
      // 📅 CREATE SESSIONS FOR TODAY WITH EXACT STUDENT ROSTERS
      // ==============================================================================

      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day); // Today at midnight
      DateTime today9am = DateTime(today.year, today.month, today.day, 9, 0);
      DateTime today10am = DateTime(today.year, today.month, today.day, 10, 0);
      DateTime today11am = DateTime(today.year, today.month, today.day, 11, 0);
      DateTime today12pm = DateTime(today.year, today.month, today.day, 12, 0);

      // Define student rosters (10% of students will be marked as "new")
      List<Map<String, dynamic>> sessionsWithStudents = [
        // Mega Kickers (12:00 PM)
        {
          'session': {
            'className': 'Mega Kickers (5 - 8yrs)',
            'venue': 'Cyber Putra Hall B',
            'startTime': Timestamp.fromDate(today12pm),
            'durationMinutes': 50,
            'coachId': coachId,
            'status': 'Upcoming',
            'ageGroup': 'Mega Kickers'
          },
          'students': [
            {'name': 'Rudhran Dinesh Kumar'},
            {'name': 'Awang Aedan'},
            {'name': 'Ariq Haidar'},
            {'name': 'Diaansh Kathuria'},
            {'name': 'Junseong Jang'},
            {'name': 'Muhammad Aaqil'},
            {'name': 'Lucas Wong'},
          ],
        },
        // Mighty Kickers (11:00 AM)
        {
          'session': {
            'className': 'Mighty Kickers (3.5 - 5yrs)',
            'venue': 'Cyber Putra Hall A',
            'startTime': Timestamp.fromDate(today11am),
            'durationMinutes': 45,
            'coachId': coachId,
            'status': 'Upcoming',
            'ageGroup': 'Mighty Kickers'
          },
          'students': [
            {'name': 'Jayden Lee'},
            {'name': 'Kayla Tan'},
            {'name': 'Iman Haris'},
            {'name': 'Chloe Yap'},
            {'name': 'Isaac Gan'},
            {'name': 'Daniel Low'},
            {'name': 'Emily Chia'},
            {'name': 'Matthew Ong'},
            {'name': 'Grace Lim'},
            {'name': 'Samuel Ting'},
          ],
        },
        // Junior Kickers (10:00 AM)
        {
          'session': {
            'className': 'Junior Kickers (2.5 - 3.5yrs)',
            'venue': 'Cyber Putra Hall A',
            'startTime': Timestamp.fromDate(today10am),
            'durationMinutes': 45,
            'coachId': coachId,
            'status': 'Live Now',
            'ageGroup': 'Junior Kickers'
          },
          'students': [
            {'name': 'Ethan Khoo'},
            {'name': 'Mia Sara'},
            {'name': 'Lucas Lim'},
            {'name': 'Aiden Wong'},
            {'name': 'Olivia Ng'},
            {'name': 'Ryan Teoh'},
            {'name': 'Sophie Tan'},
            {'name': 'Liam Chen'},
            {'name': 'Charlotte Lee'},
            {'name': 'Mason Liew'},
          ],
        },
        // Little Kicks (9:00 AM)
        {
          'session': {
            'className': 'Little Kicks (1.5 - 2.5yrs)',
            'venue': 'Cyber Putra Hall A',
            'startTime': Timestamp.fromDate(today9am),
            'durationMinutes': 45,
            'coachId': coachId,
            'status': 'Completed',
            'ageGroup': 'Little Kicks'
          },
          'students': [
            {'name': 'Muhammad Adam Rayyan'},
            {'name': 'Sofia Lee'},
            {'name': 'Noah Tan'},
            {'name': 'Zara Amani'},
            {'name': 'Leo Chen'},
            {'name': 'Avery Teoh'},
            {'name': 'Lucas Gan'},
            {'name': 'Hannah Yeoh'},
            {'name': 'Mikael Haziq'},
          ],
        },
      ];

      // Add sessions and students
      for (var sessionData in sessionsWithStudents) {
        DocumentReference sessionRef = _db.collection('sessions').doc();
        batch.set(sessionRef, sessionData['session']);

        // Add students to the session
        List<Map<String, dynamic>> students = sessionData['students'];
        for (int i = 0; i < students.length; i++) {
          Map<String, dynamic> studentData = students[i];
          String studentName = studentData['name'];
          String studentId = 'std_${DateTime.now().millisecondsSinceEpoch}_$i'; // Unique ID for each student

          // Randomly mark ~10% of students as new
          bool isNew = i < (students.length * 0.1).round();

          // Generate age-appropriate earned badges
          List<String> earnedBadges = _generateEarnedBadgesForStudent(studentName, sessionData['session']['ageGroup']);

          batch.set(sessionRef.collection('students').doc(studentId), {
            'name': studentName,
            'isPresent': false, // Set all students as not present by default
            'isNew': isNew,
            'parentContact': 'N/A',
            'medicalNotes': 'None',
            'earnedBadges': earnedBadges,
          });
        }
      }

      // ==============================================================================
      // 👨‍👩‍👧‍👦 CREATE PARENT ACCOUNTS (For testing)
      // ==============================================================================
      // Find Ethan Khoo in the Junior Kickers session and get his student ID
      // First, let's query for the Junior Kickers session to find Ethan Khoo
      QuerySnapshot juniorKickersSessions = await _db.collection('sessions')
          .where('ageGroup', isEqualTo: 'Junior Kickers')
          .get();

      String? ethanStudentId;
      String ethanStudentName = 'Ethan Khoo';

      for (var sessionDoc in juniorKickersSessions.docs) {
        QuerySnapshot studentsInSession = await sessionDoc.reference.collection('students').get();

        for (var studentDoc in studentsInSession.docs) {
          var studentData = studentDoc.data() as Map<String, dynamic>;
          if (studentData['name'] == ethanStudentName) {
            ethanStudentId = studentDoc.id;
            break;
          }
        }

        if (ethanStudentId != null) break;
      }

      // If we found Ethan, create a parent account linked to him
      if (ethanStudentId != null) {
        await _db.collection('users').doc('mock_parent_user_id').set({
          'role': 'parent',
          'name': 'Mock Parent',
          'email': 'parent@test.com',
          'linkedStudentId': ethanStudentId, // Link to Ethan Khoo
          'linkedStudentName': ethanStudentName,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // Also update the student's parent contact field to match the parent's email
        // This helps with linking in the app
        for (var sessionDoc in juniorKickersSessions.docs) {
          DocumentReference studentRef = sessionDoc.reference.collection('students').doc(ethanStudentId);
          batch.set(studentRef, {
            'parentContact': 'parent@test.com',
            'medicalNotes': 'Test student for parent dashboard',
          }, SetOptions(merge: true));
        }
      } else {
        // If we couldn't find Ethan, create him first and then link the parent
        // This is a fallback in case the student doesn't exist yet
        var juniorKickersSession = await _db.collection('sessions')
            .where('ageGroup', isEqualTo: 'Junior Kickers')
            .limit(1)
            .get();

        if (juniorKickersSession.docs.isNotEmpty) {
          DocumentReference sessionRef = juniorKickersSession.docs.first.reference;
          String newStudentId = 'ethan_khoo_test_${DateTime.now().millisecondsSinceEpoch}';

          batch.set(sessionRef.collection('students').doc(newStudentId), {
            'name': 'Ethan Khoo',
            'isPresent': false,
            'isNew': false,
            'parentContact': 'parent@test.com',
            'medicalNotes': 'Test student for parent dashboard',
            'earnedBadges': ['jk_kicking', 'jk_imagination'],
          });

          await _db.collection('users').doc('mock_parent_user_id').set({
            'role': 'parent',
            'name': 'Mock Parent',
            'email': 'parent@test.com',
            'linkedStudentId': newStudentId,
            'linkedStudentName': 'Ethan Khoo',
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("✅ Week 5 & 11 Curriculum Seeded with 2025 Class Lists! Pull to refresh."),
        backgroundColor: Colors.green,
      ));

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // Helper function to generate earned badges for a student based on their age group
  List<String> _generateEarnedBadgesForStudent(String studentName, String ageGroup) {
    List<String> possibleBadges = [];

    if (ageGroup == 'Mega Kickers') {
      possibleBadges = [
        'lk_attention_listening', 'lk_kicking', // Little Kicks badges
        'jk_physical_literacy', 'jk_team_player', // Junior Kickers badges
        'mk_leadership', 'mk_kicking', 'mk_match_play', // Mighty Kickers badges
        'mega_attacking', 'mega_tactician' // Some Mega Kickers badges
      ];
    } else if (ageGroup == 'Mighty Kickers') {
      possibleBadges = [
        'lk_attention_listening', 'lk_confidence', // Little Kicks badges
        'jk_imagination', 'jk_kicking', // Junior Kickers badges
        'mk_physical_literacy', 'mk_all_rounder', 'mk_problem_solver' // Mighty Kickers badges
      ];
    } else if (ageGroup == 'Junior Kickers') {
      possibleBadges = [
        'lk_attention_listening', 'lk_sharing', // Little Kicks badges
        'jk_kicking', 'jk_imagination' // Junior Kickers badges
      ];
    } else { // Little Kicks
      possibleBadges = [
        'lk_attention_listening', 'lk_confidence' // Little Kicks badges
      ];
    }

    // Randomly select some badges as earned (about 30-50% of possible badges)
    List<String> earnedBadges = [];
    int badgeCount = (possibleBadges.length * (0.3 + (studentName.hashCode % 21) / 100)).round();
    if (badgeCount > possibleBadges.length) badgeCount = possibleBadges.length;

    // Select random badges from the possible list
    List<String> availableBadges = List.from(possibleBadges);
    for (int i = 0; i < badgeCount && availableBadges.isNotEmpty; i++) {
      int index = (studentName.hashCode + i) % availableBadges.length;
      earnedBadges.add(availableBadges[index]);
      availableBadges.removeAt(index);
    }

    return earnedBadges;
  }
}