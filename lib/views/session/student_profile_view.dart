import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
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
                ageGroup: data['ageGroup'] ?? '',
              );

              // Determine age group
              String ageGroup = data['ageGroup'] ?? data['assignedClassId'] ?? 'Unknown';
              if (data['assignedClassId'] != null) {
                _getAgeGroupFromSession(data['assignedClassId']).then((sessionAgeGroup) {
                  if (mounted) {
                    setState(() {
                      ageGroup = sessionAgeGroup;
                      _studentProgress = _createStudentProgress(studentId, data['name'] ?? studentName, ageGroup, data['earnedBadges'] ?? []);
                    });
                  }
                });
              } else {
                if (data['ageGroup'] != null) {
                  ageGroup = data['ageGroup'];
                }
                _studentProgress = _createStudentProgress(studentId, data['name'] ?? studentName, ageGroup, data['earnedBadges'] ?? []);
              }
            });
          } else {
            // Fallback for session-based student records
            QuerySnapshot sessionsSnapshot = await FirebaseFirestore.instance.collection('sessions').get();

            for (var sessionDoc in sessionsSnapshot.docs) {
              DocumentSnapshot sessionStudentDoc = await sessionDoc.reference.collection('students').doc(studentId).get();
              if (sessionStudentDoc.exists) {
                final data = sessionStudentDoc.data() as Map<String, dynamic>;
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
                    ageGroup: sessionAgeGroup,
                  );

                  _studentProgress = _createStudentProgress(studentId, data['name'] ?? studentName, sessionAgeGroup, data['earnedBadges'] ?? []);
                });
                break;
              }
            }
          }
        } catch (e) {
          print("Error loading student data: $e");
          setState(() {
            _student = StudentAttendance(
              id: studentId,
              name: studentName,
              isPresent: isPresent,
              isNew: isNew,
              parentContact: parentContact,
              medicalNotes: medicalNotes,
              ageGroup: '',
            );
            String ageGroup = 'Junior Kickers';
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
    List<String> earnedBadgeIds = [];
    for (var badge in earnedBadgesList) {
      if (badge is String) {
        earnedBadgeIds.add(badge);
      }
    }
  
    List<String> possibleBadges = _getPossibleBadgesForAgeGroup(ageGroup);
    List<String> selectedEarnedBadges = earnedBadgeIds.isEmpty ? _generateEarnedBadges(ageGroup, possibleBadges) : earnedBadgeIds;
    String? currentBadgeId = _selectCurrentBadge(ageGroup, selectedEarnedBadges, possibleBadges);

    return StudentProgress(
      id: studentId,
      name: name,
      ageGroup: ageGroup,
      earnedBadgeIds: selectedEarnedBadges,
      currentBadgeId: currentBadgeId,
    );
  }

  // Get possible badges based on age group
  List<String> _getPossibleBadgesForAgeGroup(String ageGroup) {
    List<String> possibleBadges = [];
    if (ageGroup == 'Mega Kickers') {
      possibleBadges.addAll([
        'lk_attention_listening', 'lk_sharing', 'lk_kicking', 'lk_confidence',
        'jk_kicking', 'jk_imagination', 'jk_physical_literacy', 'jk_team_player',
        'mk_leadership', 'mk_physical_literacy', 'mk_all_rounder', 'mk_problem_solver', 'mk_kicking', 'mk_match_play',
        'mega_attacking', 'mega_defending', 'mega_tactician', 'mega_captain', 'mega_all_rounder', 'mega_referee'
      ]);
    } else if (ageGroup == 'Mighty Kickers') {
      possibleBadges.addAll([
        'lk_attention_listening', 'lk_sharing', 'lk_kicking', 'lk_confidence',
        'jk_kicking', 'jk_imagination', 'jk_physical_literacy', 'jk_team_player',
        'mk_leadership', 'mk_physical_literacy', 'mk_all_rounder', 'mk_problem_solver', 'mk_kicking', 'mk_match_play'
      ]);
    } else if (ageGroup == 'Junior Kickers') {
      possibleBadges.addAll([
        'lk_attention_listening', 'lk_sharing', 'lk_kicking', 'lk_confidence',
        'jk_kicking', 'jk_imagination', 'jk_physical_literacy', 'jk_team_player'
      ]);
    } else {
      possibleBadges.addAll([
        'lk_attention_listening', 'lk_sharing', 'lk_kicking', 'lk_confidence'
      ]);
    }
    return possibleBadges;
  }

  String? _selectCurrentBadge(String ageGroup, List<String> earnedBadges, List<String> possibleBadges) {
    List<String> unearnedBadges = possibleBadges.where((badge) => !earnedBadges.contains(badge)).toList();
    return unearnedBadges.isNotEmpty ? unearnedBadges[0] : null;
  }

  List<String> _generateEarnedBadges(String ageGroup, List<String> possibleBadges) {
    int count;
    switch (ageGroup) {
      case 'Mega Kickers': count = 6; break;
      case 'Mighty Kickers': count = 4; break;
      case 'Junior Kickers': count = 3; break;
      default: count = 2; break;
    }
    count = count.clamp(0, possibleBadges.length);
    return possibleBadges.take(count).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_student == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(title: const Text("Student Profile"), elevation: 0, backgroundColor: AppTheme.primaryRed),
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryRed),
        ),
      );
    }

    // Check if parent is viewing
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final args = arguments as Map<String, dynamic>?;
    final isParentViewing = args?['isParentViewing'] as bool? ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        title: const Text("Student Profile"),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Immersive Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryRed, Color(0xFFC41A1F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar with shadow
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      "${_student!.name.substring(0, 1).toUpperCase()}${_student!.name.split(' ').length > 1 ? _student!.name.split(' ')[1][0].toUpperCase() : ''}",
                      style: const TextStyle(fontSize: 32, color: AppTheme.primaryRed, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Name
                Text(
                  _student!.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                
                // Dynamic Age & Group Info
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('students').doc(_student?.id).get(),
                  builder: (context, snapshot) {
                    String ageInfo = _studentProgress?.ageGroup ?? 'Junior Kickers';
                    
                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data = snapshot.data!.data() as Map<String, dynamic>?;
                      if (data != null) {
                        if (data['ageGroup'] != null) ageInfo = data['ageGroup'];
                        if (data['dateOfBirth'] != null) {
                          DateTime dob = (data['dateOfBirth'] as Timestamp).toDate();
                          int age = DateTime.now().year - dob.year;
                          if (DateTime.now().month < dob.month || (DateTime.now().month == dob.month && DateTime.now().day < dob.day)) {
                            age--;
                          }
                          ageInfo += " • $age Years Old";
                        }
                      }
                    }
                    return Text(ageInfo, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500));
                  },
                ),
              ],
            ),
          ),

          // 2. Content Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Student Information Card
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('students').doc(_student?.id).get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data = snapshot.data!.data() as Map<String, dynamic>?;
                        String? dob;
                        String? parentEmail;
                        String? parentPhone;

                        if (data != null) {
                          if (data['dateOfBirth'] != null) {
                            DateTime dobDate = (data['dateOfBirth'] as Timestamp).toDate();
                            dob = "${dobDate.day.toString().padLeft(2, '0')}/${dobDate.month.toString().padLeft(2, '0')}/${dobDate.year}";
                          }
                          parentEmail = data['parentEmail'];
                          parentPhone = data['parentPhone'];
                        }

                        if (dob != null || parentEmail != null || parentPhone != null) {
                          return Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: _cardDecoration(),
                                child: Column(
                                  children: [
                                    if (dob != null) ...[
                                      _buildInfoRow(Icons.cake, "Date of Birth", dob),
                                      if (parentEmail != null || parentPhone != null) const Divider(height: 20),
                                    ],
                                    if (parentEmail != null) ...[
                                      _buildInfoRow(Icons.email_outlined, "Parent Email", parentEmail),
                                      if (parentPhone != null) const Divider(height: 20),
                                    ],
                                    if (parentPhone != null)
                                      _buildInfoRow(Icons.phone_outlined, "Parent Phone", parentPhone),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        }
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Action Buttons (Conditional Medical Info)
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('students').doc(_student?.id).get(),
                    builder: (context, snapshot) {
                      bool hasMedicalInfo = false;
                      Map<String, dynamic>? studentData;

                      if (snapshot.hasData && snapshot.data!.exists) {
                        studentData = snapshot.data!.data() as Map<String, dynamic>?;
                        String? notes = studentData?['medicalNotes'];
                        hasMedicalInfo = notes != null && notes.isNotEmpty && notes.toLowerCase() != 'none';
                      }

                      // Check if parent is viewing
                      final arguments = ModalRoute.of(context)?.settings.arguments;
                      final args = arguments as Map<String, dynamic>?;
                      final isParentViewing = args?['isParentViewing'] as bool? ?? false;

                      return Row(
                        children: [
                          if (!isParentViewing)
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.call,
                                label: "Contact Parent",
                                color: AppTheme.pitchGreen,
                                onTap: () async {
                                  final phone = studentData?['parentPhone'] as String?;
                                  if (phone != null && phone.isNotEmpty) {
                                    final uri = Uri.parse('tel:$phone');
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Could not launch phone app')),
                                        );
                                      }
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('No phone number available')),
                                    );
                                  }
                                },
                              ),
                            ),
                          if (!isParentViewing && hasMedicalInfo) const SizedBox(width: 12),
                          if (hasMedicalInfo)
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.medical_services_outlined,
                                label: "Medical Info",
                                color: Colors.red,
                                onTap: () => _showMedicalDialog(studentData),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Attendance Section
                  _buildSectionHeader("Recent Attendance", Icons.calendar_today),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _cardDecoration(),
                    child: FutureBuilder<List<Widget>>(
                      future: _getAttendanceDots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: snapshot.data!);
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Badges Section
                  if (_studentProgress != null) ...[
                    _buildSectionHeader("Badge Progress", Icons.emoji_events),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: _cardDecoration(),
                      child: BadgeGrid(
                        ageGroup: _studentProgress!.ageGroup,
                        earnedBadgeIds: _studentProgress!.earnedBadgeIds,
                        currentBadgeId: _studentProgress!.currentBadgeId,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Notes Section
                  Builder(
                    builder: (context) {
                      final arguments = ModalRoute.of(context)?.settings.arguments;
                      final args = arguments as Map<String, dynamic>?;
                      final isParentViewing = args?['isParentViewing'] as bool? ?? false;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionHeader("Coach Notes", Icons.note_alt_outlined),
                          if (!isParentViewing)
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: AppTheme.primaryRed),
                              onPressed: _addNote,
                            ),
                        ],
                      );
                    },
                  ),
                  if (_notes.isEmpty)
                    Builder(
                      builder: (context) {
                        final arguments = ModalRoute.of(context)?.settings.arguments;
                        final args = arguments as Map<String, dynamic>?;
                        final isParentViewing = args?['isParentViewing'] as bool? ?? false;

                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: _cardDecoration(),
                          child: Center(
                            child: Text(
                              isParentViewing
                                  ? "No coach notes yet."
                                  : "No notes yet.\nTap + to add one.",
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      },
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        final note = _notes[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: _cardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatDate(note['timestamp']),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 6),
                              Text(note['text'], style: const TextStyle(fontSize: 14, color: AppTheme.darkText, height: 1.4)),
                            ],
                          ),
                        );
                      },
                    ),

                  // Account Section - only show for parent viewing
                  if (isParentViewing) ...[
                    const SizedBox(height: 24),
                    _buildAccountSectionCard(
                      title: 'Account',
                      icon: Icons.settings_outlined,
                      children: [
                        _buildAccountActionTile(
                          context,
                          icon: Icons.lock_outline,
                          title: 'Change Password',
                          subtitle: 'Update your password',
                          color: Colors.blueAccent,
                          onTap: () => _showChangePasswordDialog(context),
                        ),
                        const SizedBox(height: 12),
                        _buildAccountActionTile(
                          context,
                          icon: Icons.logout_rounded,
                          title: 'Sign Out',
                          subtitle: 'Securely logout',
                          color: Colors.redAccent,
                          isDestructive: true,
                          onTap: () async {
                            await FirebaseAuth.instance.signOut();
                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryRed),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
      ],
    );
  }

  // Account Section Card (like coach_profile_view.dart)
  Widget _buildAccountSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey[800], size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  // Account Action Tile (like coach_profile_view.dart)
  Widget _buildAccountActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.withOpacity(0.04) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDestructive ? Colors.red.withOpacity(0.1) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : Colors.grey[900],
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDestructive ? Colors.red.withOpacity(0.6) : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  // --- Logic Helpers (Keep unchanged) ---
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Add Coach Note"),
            content: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "Enter your note here...",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => inputText = value,
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
              TextButton(onPressed: () => Navigator.pop(context, inputText), child: const Text("Add Note", style: TextStyle(color: AppTheme.primaryRed))),
            ],
          );
        },
      );

      if (noteText != null && noteText.trim().isNotEmpty) {
        try {
          await _firestoreService.addNote(studentId, noteText.trim());
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error adding note: $e")));
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays.abs();
    if (difference == 0) return "Today";
    if (difference == 1) return "Yesterday";
    return "${date.day} ${_getMonthName(date.month)}";
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Future<List<Widget>> _getAttendanceDots() async {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final args = arguments as Map<String, dynamic>?;
    String? studentId = args?['studentId'] as String?;

    if (studentId != null) {
      try {
        DocumentSnapshot studentDoc = await FirebaseFirestore.instance.collection('students').doc(studentId).get();
        if (studentDoc.exists) {
          final data = studentDoc.data() as Map<String, dynamic>?;
          final attendanceHistory = data?['attendanceHistory'] as Map<String, dynamic>?;

          if (attendanceHistory != null && attendanceHistory.isNotEmpty) {
            // Create a list of attendance entries with their session dates
            List<Map<String, dynamic>> attendanceWithDates = [];

            for (var entry in attendanceHistory.entries) {
              String sessionId = entry.key;
              String status = entry.value.toString();

              // Try to fetch the session date from the sessions or pastSessions collection
              DateTime? sessionDate = await _getSessionDate(sessionId);

              if (sessionDate != null) {
                attendanceWithDates.add({
                  'date': sessionDate,
                  'status': status,
                  'sessionId': sessionId,
                });
              }
            }

            // Sort by date, most recent first
            attendanceWithDates.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

            List<Widget> attendanceDots = [];
            int count = 0;
            for (var entry in attendanceWithDates) {
              if (count >= 5) break;
              DateTime date = entry['date'];
              String status = entry['status'];
              String displayDate = "${date.day} ${_getMonthName(date.month)}";
              bool present = status.toLowerCase() == 'present' || status.toLowerCase() == 'p';
              attendanceDots.add(_buildAttendanceDot(present, displayDate));
              count++;
            }

            while (attendanceDots.length < 5) {
              attendanceDots.add(_buildPlaceholderDot());
            }
            return attendanceDots;
          }
        }
      } catch (e) {
        print("Error loading attendance dots: $e");
      }
    }
    return List.generate(5, (index) => _buildPlaceholderDot());
  }

  // Helper method to get session date from sessionId
  Future<DateTime?> _getSessionDate(String sessionId) async {
    try {
      // Try sessions collection first
      DocumentSnapshot sessionDoc = await FirebaseFirestore.instance.collection('sessions').doc(sessionId).get();
      if (sessionDoc.exists) {
        final data = sessionDoc.data() as Map<String, dynamic>?;
        if (data != null && data['startTime'] != null) {
          return (data['startTime'] as Timestamp).toDate();
        }
      }

      // If not found, try pastSessions collection
      DocumentSnapshot pastSessionDoc = await FirebaseFirestore.instance.collection('pastSessions').doc(sessionId).get();
      if (pastSessionDoc.exists) {
        final data = pastSessionDoc.data() as Map<String, dynamic>?;
        if (data != null && data['startTime'] != null) {
          return (data['startTime'] as Timestamp).toDate();
        }
      }
    } catch (e) {
      print("Error fetching session date for $sessionId: $e");
    }
    return null;
  }

  Widget _buildAttendanceDot(bool present, String date) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: present ? AppTheme.pitchGreen.withOpacity(0.15) : Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: present ? AppTheme.pitchGreen : Colors.red, width: 2),
          ),
          child: Icon(present ? Icons.check : Icons.close, size: 20, color: present ? AppTheme.pitchGreen : Colors.red),
        ),
        const SizedBox(height: 6),
        Text(date, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildPlaceholderDot() {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[300]!, width: 2),
          ),
          child: const Icon(Icons.remove, size: 20, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        const Text("-", style: TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryRed),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.darkText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showMedicalDialog(Map<String, dynamic>? studentData) {
    if (studentData == null) return;

    String medicalNotes = studentData['medicalNotes'] ?? 'No medical information available';
    String allergies = studentData['allergies'] ?? 'None';
    String medications = studentData['medications'] ?? 'None';
    String emergencyContact = studentData['emergencyContact'] ?? 'N/A';
    String emergencyPhone = studentData['emergencyPhone'] ?? 'N/A';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red, Color(0xFFD32F2F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.medical_services_rounded, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Medical Information",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Medical Alert Banner
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200, width: 2),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 32),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  "Important Medical Alert",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Medical Notes
                        _buildMedicalInfoSection(
                          "Medical Notes",
                          medicalNotes,
                          Icons.note_alt_outlined,
                          Colors.red,
                        ),
                        const SizedBox(height: 16),

                        // Allergies
                        _buildMedicalInfoSection(
                          "Allergies",
                          allergies,
                          Icons.warning_outlined,
                          Colors.orange,
                        ),
                        const SizedBox(height: 16),

                        // Medications
                        _buildMedicalInfoSection(
                          "Current Medications",
                          medications,
                          Icons.medication_outlined,
                          Colors.blue,
                        ),
                        const SizedBox(height: 20),

                        // Emergency Contact
                        const Text(
                          "Emergency Contact",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person_outline, size: 20, color: AppTheme.primaryRed),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      emergencyContact,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                children: [
                                  const Icon(Icons.phone_outlined, size: 20, color: AppTheme.primaryRed),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      emergencyPhone,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Close",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMedicalInfoSection(String title, String content, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.darkText,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // Change Password Dialog for Parent
  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;
    bool showCurrentPassword = false;
    bool showNewPassword = false;
    bool showConfirmPassword = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.lock_outline, color: AppTheme.primaryRed),
              SizedBox(width: 12),
              Text('Change Password'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: !showCurrentPassword,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showCurrentPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () => setDialogState(() => showCurrentPassword = !showCurrentPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: !showNewPassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showNewPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () => setDialogState(() => showNewPassword = !showNewPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: !showConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () => setDialogState(() => showConfirmPassword = !showConfirmPassword),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      // Validation
                      if (currentPasswordController.text.isEmpty ||
                          newPasswordController.text.isEmpty ||
                          confirmPasswordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in all fields'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (newPasswordController.text.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('New password must be at least 6 characters'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (newPasswordController.text != confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('New passwords do not match'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isLoading = true);

                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null || user.email == null) {
                          throw Exception('User not found');
                        }

                        // Re-authenticate user
                        final credential = EmailAuthProvider.credential(
                          email: user.email!,
                          password: currentPasswordController.text,
                        );
                        await user.reauthenticateWithCredential(credential);

                        // Update password
                        await user.updatePassword(newPasswordController.text);

                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password updated successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        String message = 'Error updating password';
                        if (e.code == 'wrong-password') {
                          message = 'Current password is incorrect';
                        } else if (e.code == 'weak-password') {
                          message = 'New password is too weak';
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message), backgroundColor: Colors.red),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        if (dialogContext.mounted) {
                          setDialogState(() => isLoading = false);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Update Password', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}