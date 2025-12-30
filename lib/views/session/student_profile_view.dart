import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme.dart';
import '../../models/attendance_model.dart';
import '../../models/student_progress_model.dart';
import '../../widgets/badge_grid.dart';
import '../../services/firestore_service.dart';

class StudentProfileView extends StatefulWidget {
  const StudentProfileView({super.key});

  @override
  State<StudentProfileView> createState() => _StudentProfileViewState();
}

class _StudentProfileViewState extends State<StudentProfileView> {
  // Variables to hold student data
  StudentAttendance? _student;
  StudentProgress? _studentProgress;
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudentData();
      _loadNotes();
    });
  }

  // Load notes from Firestore
  void _loadNotes() {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final args = arguments as Map<String, dynamic>?;
    String? studentId = args?['studentId'] as String?;

    if (studentId != null) {
      FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .collection('notes')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        if (mounted) {
          setState(() {
            _notes = snapshot.docs.map((doc) {
              final docData = doc.data();
              return {
                'id': doc.id,
                'text': docData['text'] ?? '',
                'timestamp': (docData['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
              };
            }).toList();
          });
        }
      });
    }
  }

  Future<void> _loadStudentData() async {
    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments != null && arguments is Map<String, dynamic>) {
      String? studentId = arguments['studentId'] as String?;
      String studentName = arguments['studentName'] as String? ?? 'Student';
      bool isPresent = arguments['isPresent'] as bool? ?? false;
      bool isNew = arguments['isNew'] as bool? ?? false;
      String parentContact = arguments['parentContact'] as String? ?? 'N/A';
      String medicalNotes = arguments['medicalNotes'] as String? ?? 'N/A';

      if (studentId != null) {
        try {
          // Check if student exists in the main 'students' collection first
          DocumentSnapshot mainStudentDoc = await FirebaseFirestore.instance.collection('students').doc(studentId).get();

          if (mainStudentDoc.exists) {
            final data = mainStudentDoc.data() as Map<String, dynamic>;

            setState(() {
              _student = StudentAttendance(
                id: studentId,
                name: data['name'] ?? studentName,
                isPresent: isPresent,
                isNew: data['createdAt'] != null ?
                  DateTime.now().difference(data['createdAt'].toDate()).inDays <= 7 : isNew,
                parentContact: data['parentContact'] ?? parentContact,
                medicalNotes: data['medicalNotes'] ?? medicalNotes,
              );

              // Determine age group from assigned class or from the main collection
              String ageGroup = data['ageGroup'] ?? data['assignedClassId'] ?? 'Unknown';
              if (data['assignedClassId'] != null) {
                // If there's an assigned class ID, get the age group from the session
                _getAgeGroupFromSession(data['assignedClassId']).then((sessionAgeGroup) {
                  if (mounted) {
                    setState(() {
                      ageGroup = sessionAgeGroup;
                      _studentProgress = _createStudentProgress(studentId, data['name'] ?? studentName, ageGroup, data['earnedBadges'] ?? []);
                    });
                  }
                });
              } else {
                // Use age group from the main collection if available
                if (data['ageGroup'] != null) {
                  ageGroup = data['ageGroup'];
                }
                _studentProgress = _createStudentProgress(studentId, data['name'] ?? studentName, ageGroup, data['earnedBadges'] ?? []);
              }
            });
          } else {
            // If not in main 'students' collection, try to find student in session collections
            // This requires finding which session the student belongs to
            QuerySnapshot sessionsSnapshot = await FirebaseFirestore.instance.collection('sessions').get();

            for (var sessionDoc in sessionsSnapshot.docs) {
              DocumentSnapshot sessionStudentDoc = await sessionDoc.reference.collection('students').doc(studentId).get();
              if (sessionStudentDoc.exists) {
                final data = sessionStudentDoc.data() as Map<String, dynamic>;
                // Safely read session data and ageGroup (avoid calling [] on a nullable value)
                final sessionDataObj = sessionDoc.data();
                String sessionAgeGroup = 'Unknown';
                if (sessionDataObj is Map<String, dynamic>) {
                  sessionAgeGroup = sessionDataObj['ageGroup'] ?? 'Unknown';
                }

                setState(() {
                  _student = StudentAttendance(
                    id: studentId,
                    name: data['name'] ?? studentName,
                    isPresent: data['isPresent'] ?? isPresent,
                    isNew: data['isNew'] ?? isNew,
                    parentContact: data['parentContact'] ?? parentContact,
                    medicalNotes: data['medicalNotes'] ?? medicalNotes,
                  );

                  _studentProgress = _createStudentProgress(studentId, data['name'] ?? studentName, sessionAgeGroup, data['earnedBadges'] ?? []);
                });
                break; // Found the student, exit the loop
              }
            }
          }
        } catch (e) {
          print("Error loading student data: $e");
          // Fallback to the original data if there's an error
          setState(() {
            _student = StudentAttendance(
              id: studentId,
              name: studentName,
              isPresent: isPresent,
              isNew: isNew,
              parentContact: parentContact,
              medicalNotes: medicalNotes,
            );

            // For fallback, determine age group from name or use default
            String ageGroup = _guessAgeGroupFromName(studentName);
            _studentProgress = _createStudentProgress(studentId, studentName, ageGroup, []);
          });
        }
      }
    }
  }

  // Helper method to get age group from session
  Future<String> _getAgeGroupFromSession(String sessionId) async {
    try {
      DocumentSnapshot sessionDoc = await FirebaseFirestore.instance.collection('sessions').doc(sessionId).get();
      if (sessionDoc.exists) {
        final sessionData = sessionDoc.data() as Map<String, dynamic>;
        return sessionData['ageGroup'] ?? 'Unknown';
      }
    } catch (e) {
      print("Error getting age group from session: $e");
    }
    return 'Unknown';
  }

  // Helper method to create student progress based on age group
  StudentProgress _createStudentProgress(String studentId, String name, String ageGroup, List<dynamic> earnedBadgesList) {
    // Convert list of dynamic to list of strings
    List<String> earnedBadgeIds = [];
    for (var badge in earnedBadgesList) {
      if (badge is String) {
        earnedBadgeIds.add(badge);
      }
    }
  
    // Generate age-appropriate badge progression
    // For older age groups, allow earning badges from younger groups too
    List<String> possibleBadges = _getPossibleBadgesForAgeGroup(ageGroup);

    // Select a few badges as earned based on age group
    List<String> selectedEarnedBadges = [];
    if (earnedBadgeIds.isEmpty) {
      // If no badges are set in Firestore, generate some based on age group
      selectedEarnedBadges = _generateEarnedBadges(ageGroup, possibleBadges);
    } else {
      // Use the badges from Firestore
      selectedEarnedBadges = earnedBadgeIds;
    }

    // Select a badge as current based on progression
    String? currentBadgeId = _selectCurrentBadge(ageGroup, selectedEarnedBadges, possibleBadges);

    return StudentProgress(
      id: studentId,
      name: name,
      ageGroup: ageGroup,
      earnedBadgeIds: selectedEarnedBadges,
      currentBadgeId: currentBadgeId,
    );
  }

  // Get possible badges based on age group (older groups can earn from younger ones too)
  List<String> _getPossibleBadgesForAgeGroup(String ageGroup) {
    List<String> possibleBadges = [];

    if (ageGroup == 'Mega Kickers') {
      // Mega Kickers can earn badges from all age groups
      possibleBadges.addAll([
        'lk_attention_listening', 'lk_sharing', 'lk_kicking', 'lk_confidence', // Little Kicks
        'jk_kicking', 'jk_imagination', 'jk_physical_literacy', 'jk_team_player', // Junior Kickers
        'mk_leadership', 'mk_physical_literacy', 'mk_all_rounder', 'mk_problem_solver', 'mk_kicking', 'mk_match_play', // Mighty Kickers
        'mega_attacking', 'mega_defending', 'mega_tactician', 'mega_captain', 'mega_all_rounder', 'mega_referee' // Mega Kickers
      ]);
    } else if (ageGroup == 'Mighty Kickers') {
      // Mighty Kickers can earn from Mighty and below
      possibleBadges.addAll([
        'lk_attention_listening', 'lk_sharing', 'lk_kicking', 'lk_confidence', // Little Kicks
        'jk_kicking', 'jk_imagination', 'jk_physical_literacy', 'jk_team_player', // Junior Kickers
        'mk_leadership', 'mk_physical_literacy', 'mk_all_rounder', 'mk_problem_solver', 'mk_kicking', 'mk_match_play' // Mighty Kickers
      ]);
    } else if (ageGroup == 'Junior Kickers') {
      // Junior Kickers can earn from Junior and below
      possibleBadges.addAll([
        'lk_attention_listening', 'lk_sharing', 'lk_kicking', 'lk_confidence', // Little Kicks
        'jk_kicking', 'jk_imagination', 'jk_physical_literacy', 'jk_team_player' // Junior Kickers
      ]);
    } else {
      // Little Kicks can only earn Little Kicks badges
      possibleBadges.addAll([
        'lk_attention_listening', 'lk_sharing', 'lk_kicking', 'lk_confidence' // Little Kicks
      ]);
    }

    return possibleBadges;
  }

  // Generate some earned badges based on age group
  List<String> _generateEarnedBadges(String ageGroup, List<String> possibleBadges) {
    List<String> earnedBadges = [];

    // For each age group, select a random subset of possible badges as earned
    // The number of earned badges will vary by age group
    int maxBadges = 0;
    if (ageGroup == 'Mega Kickers') {
      maxBadges = 12; // Older students have more badges
    } else if (ageGroup == 'Mighty Kickers') {
      maxBadges = 8;
    } else if (ageGroup == 'Junior Kickers') {
      maxBadges = 4;
    } else {
      maxBadges = 2; // Little Kicks start with fewer badges
    }

    // Randomly select some badges
    int badgesToSelect = (maxBadges * 0.5).round(); // Start with about half earned
    if (badgesToSelect > possibleBadges.length) {
      badgesToSelect = possibleBadges.length;
    }

    // Use a simple algorithm to pick random badges without duplicates
    List<String> availableBadges = List.from(possibleBadges);
    for (int i = 0; i < badgesToSelect && availableBadges.isNotEmpty; i++) {
      int randomIndex = (DateTime.now().millisecondsSinceEpoch + i) % availableBadges.length;
      earnedBadges.add(availableBadges[randomIndex]);
      availableBadges.removeAt(randomIndex);
    }

    return earnedBadges;
  }

  // Select which badge the student should currently be working on
  String? _selectCurrentBadge(String ageGroup, List<String> earnedBadges, List<String> possibleBadges) {
    // Select a badge that hasn't been earned yet
    List<String> unearnedBadges = possibleBadges.where((badge) => !earnedBadges.contains(badge)).toList();

    if (unearnedBadges.isNotEmpty) {
      // Randomly select one of the unearned badges as current
      int randomIndex = (DateTime.now().millisecondsSinceEpoch + 999) % unearnedBadges.length;
      return unearnedBadges[randomIndex];
    }

    return null; // All badges earned
  }

  // Helper method to guess age group from name (fallback)
  String _guessAgeGroupFromName(String name) {
    // This is a simple heuristic - in reality, this would come from the session/assigned class
    if (name.contains('Lucas') || name.contains('Ethan') || name.contains('Aiden')) {
      return 'Junior Kickers';
    } else if (name.contains('Muhammad') || name.contains('Sofia')) {
      return 'Little Kicks';
    } else if (name.contains('Rudhran') || name.contains('Ariq')) {
      return 'Mega Kickers';
    } else if (name.contains('Jayden') || name.contains('Iman')) {
      return 'Mighty Kickers';
    }
    return 'Junior Kickers'; // Default
  }

  @override
  Widget build(BuildContext context) {
    // If no student data loaded yet, show loading
    if (_student == null) {
      return Scaffold(
        backgroundColor: AppTheme.lightBackground,
        appBar: AppBar(
          title: const Text("Student Profile"),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text("Student Profile"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header Profile Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Changed from CircleAvatar to rectangular container
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "${_student!.name.substring(0, 1).toUpperCase()}${_student!.name.split(' ').length > 1 ? _student!.name.split(' ')[_student!.name.split(' ').length - 1][0].toUpperCase() : ''}",
                        style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _student!.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text("${_studentProgress?.ageGroup ?? 'Junior Kickers'} • 3 Years Old", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),

                  // Medical Alert Badge (only show if medical notes exist)
                  if (_student!.medicalNotes != "None" && _student!.medicalNotes.isNotEmpty && _student!.medicalNotes.toLowerCase() != "none")
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.medical_services_outlined, size: 16, color: Colors.red[700]),
                          const SizedBox(width: 8),
                          Text("Medical: ${_student!.medicalNotes}", style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Action Buttons (Contact)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {}, // Mock Call
                      icon: const Icon(Icons.phone),
                      label: const Text("Call Parent"),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.pitchGreen),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {}, // Mock Incident Report
                      icon: const Icon(Icons.report_problem_outlined, color: Colors.orange),
                      label: const Text("Report Incident", style: TextStyle(color: Colors.orange)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.orange)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. Attendance History (New Section)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text("Recent Attendance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 12),
                   Row(
                     children: [
                       _buildAttendanceDot(true, "12 Oct"),
                       _buildAttendanceDot(true, "05 Oct"),
                       _buildAttendanceDot(false, "28 Sep"), // Absent
                       _buildAttendanceDot(true, "21 Sep"),
                       _buildAttendanceDot(true, "14 Sep"),
                     ],
                   )
                ],
              )
            ),

            const SizedBox(height: 24),

            // 4. Badge Progress Section
            if (_studentProgress != null)
              BadgeGrid(
                ageGroup: _studentProgress!.ageGroup,
                earnedBadgeIds: _studentProgress!.earnedBadgeIds,
                currentBadgeId: _studentProgress!.currentBadgeId,
              ),

            const SizedBox(height: 24),

            // 5. Coach Notes (New Section)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Coach Notes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add, color: AppTheme.primaryRed),
                        onPressed: () => _addNote(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_notes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "No notes yet. Tap the + button to add a note.",
                        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        final note = _notes[index];
                        return _buildNoteCard(
                          _formatDate(note['timestamp']),
                          note['text'],
                        );
                      },
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceDot(bool present, String date) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: present ? AppTheme.pitchGreen.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: present ? AppTheme.pitchGreen : Colors.red, width: 2),
            ),
            child: Icon(
              present ? Icons.check : Icons.close,
              size: 20,
              color: present ? AppTheme.pitchGreen : Colors.red
            ),
          ),
          const SizedBox(height: 4),
          Text(date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildNoteCard(String date, String note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(note, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // Add a new note
  void _addNote() async {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final args = arguments as Map<String, dynamic>?;
    String? studentId = args?['studentId'] as String?;

    if (studentId != null) {
      String? noteText = await showDialog<String>(
        context: context,
        builder: (context) {
          String inputText = '';
          return AlertDialog(
            title: const Text("Add Coach Note"),
            content: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "Enter your note here...",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                inputText = value;
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, inputText),
                child: const Text("Add Note", style: TextStyle(color: AppTheme.primaryRed)),
              ),
            ],
          );
        },
      );

      if (noteText != null && noteText.trim().isNotEmpty) {
        try {
          await _firestoreService.addNote(studentId, noteText.trim());
          // Note will be automatically added to the list via the stream listener
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error adding note: $e")),
          );
        }
      }
    }
  }

  // Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays.abs();

    if (difference == 0) {
      return "Today";
    } else if (difference == 1) {
      return "Yesterday";
    } else {
      return "${date.day} ${_getMonthName(date.month)}";
    }
  }

  // Helper to get month name
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

}