import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../../config/theme.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/student_parent_view_model.dart';
import '../../widgets/badge_grid.dart';
import '../../models/drill_data.dart';
import '../../services/storage_service.dart';
import '../../services/firestore_service.dart';
import '../../services/gemini_receipt_service.dart';
import '../admin/session_template_details_view.dart';

class StudentParentDashboardView extends StatefulWidget {
  const StudentParentDashboardView({super.key});

  @override
  State<StudentParentDashboardView> createState() => _StudentParentDashboardViewState();
}

class _StudentParentDashboardViewState extends State<StudentParentDashboardView> {
  int _currentIndex = 0;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    // Initialize the student data associated with this parent account
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentParentViewModel>(context, listen: false).initializeStudentData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final studentParentViewModel = Provider.of<StudentParentViewModel>(context);

    // Build the body based on current index
    Widget currentBody;
    switch (_currentIndex) {
      case 0:
        currentBody = _buildHomeContent(studentParentViewModel);
        break;
      case 1:
        currentBody = _buildScheduleContent(studentParentViewModel);
        break;
      case 2:
        currentBody = _buildProgressContent(studentParentViewModel);
        break;
      default:
        currentBody = _buildHomeContent(studentParentViewModel);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        title: const Text("Parent Dashboard"),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          // Notification Bell with Badge
          StreamBuilder<int>(
            stream: authViewModel.currentUser != null
                ? _firestoreService.getUnreadNotificationCount(authViewModel.currentUser!.uid)
                : const Stream.empty(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.yellow,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: AppTheme.primaryRed,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) async {
              if (value == 'change_password') {
                _showChangePasswordDialog(context);
              } else if (value == 'logout') {
                await authViewModel.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'change_password',
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, color: Colors.blueAccent, size: 20),
                    SizedBox(width: 12),
                    Text('Change Password'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: currentBody,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: AppTheme.primaryRed,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          elevation: 0,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_rounded),
              label: "Schedule",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_rounded),
              label: "Progress",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent(StudentParentViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () => viewModel.refreshData(),
      child: Consumer<StudentParentViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
          }

          // Check if student data failed to load
          if (viewModel.studentId == null && !viewModel.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    "No student data found",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please contact admin to link your account",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryRed, Color(0xFFC41A1F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewModel.studentName != null ? 'Welcome Back, ${viewModel.studentName}!' : 'Welcome Back!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Your Child",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkText,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Child Profile Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              if (viewModel.studentId != null) {
                                Navigator.pushNamed(
                                  context,
                                  '/student_profile',
                                  arguments: {
                                    'studentId': viewModel.studentId,
                                    'studentName': viewModel.studentName ?? 'Student',
                                    'isPresent': true,
                                    'isNew': false,
                                    'parentContact': viewModel.parentContact ?? 'N/A',
                                    'medicalNotes': viewModel.medicalNotes ?? 'N/A',
                                    'isParentViewing': true,
                                  },
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                children: [
                                  // Avatar
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryRed.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        _getInitials(viewModel.studentName ?? "?"),
                                        style: const TextStyle(
                                          color: AppTheme.primaryRed,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          viewModel.studentName ?? "Child Name",
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.darkText,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.pitchGreen.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            viewModel.childAgeGroup ?? "Age Group",
                                            style: const TextStyle(
                                              color: AppTheme.pitchGreen,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        "Quick Actions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkText,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              icon: Icons.calendar_month,
                              label: "View\nSchedule",
                              color: Colors.blue,
                              onTap: () => setState(() => _currentIndex = 1),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildActionCard(
                              icon: Icons.emoji_events,
                              label: "Check\nProgress",
                              color: Colors.orange,
                              onTap: () => setState(() => _currentIndex = 2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Payment Action Card with status - full width
                      Consumer<StudentParentViewModel>(
                        builder: (context, viewModel, child) {
                          // Only show payment status if studentId is available and view model is ready
                          if (viewModel.studentId == null || viewModel.isLoading) {
                            return _buildPaymentCard(
                              icon: Icons.payment,
                              label: "Loading Status",
                              color: Colors.grey,
                              onTap: () {
                                // Disable tap until studentId is loaded
                              },
                            );
                          }

                          return FutureBuilder<String>(
                            future: _getPaymentStatus(viewModel.studentId),
                            builder: (context, snapshot) {
                              String status = "Check Payment Status";
                              Color color = Colors.green;
                              if (snapshot.hasData) {
                                String paymentStatus = snapshot.data!;
                                if (paymentStatus == "paid") {
                                  status = "Fees Paid";
                                  color = Colors.green;
                                } else if (paymentStatus == "pending") {
                                  status = "Payment Pending";
                                  color = Colors.orange;
                                } else {
                                  status = "Pay Fees";
                                  color = Colors.red;
                                }
                              } else if (snapshot.hasError) {
                                status = "Error Loading Status";
                                color = Colors.grey;
                              } else if (snapshot.connectionState == ConnectionState.waiting) {
                                status = "Loading Status";
                                color = Colors.grey;
                              }

                              return _buildPaymentCard(
                                icon: Icons.payment,
                                label: status,
                                color: color,
                                onTap: () {
                                  // Double check if studentId is still valid before opening dialog
                                  if (viewModel.studentId != null) {
                                    _showPaymentConfirmationDialog(context, viewModel);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Student data not loaded yet."),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleContent(StudentParentViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () => viewModel.refreshData(),
      child: Column(
        children: [
          // Simple Header for Tab
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Upcoming Sessions", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
                const SizedBox(height: 4),
                Text("Your child's next football classes", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ],
            ),
          ),

          Expanded(
            child: Consumer<StudentParentViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
                }

                // Check if student data failed to load
                if (viewModel.studentId == null && !viewModel.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          "No student data found",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Please contact admin to link your account",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return StreamBuilder(
                  stream: viewModel.childClassesStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy, size: 60, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              "No upcoming classes found",
                              style: TextStyle(color: Colors.grey[500], fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }

                    final classes = snapshot.data!.docs;
                    // Sort classes by startTime (newest first)
                    final sortedClasses = classes.toList()..sort((a, b) {
                      final aTime = (a.data() as Map<String, dynamic>)['startTime'] as Timestamp?;
                      final bTime = (b.data() as Map<String, dynamic>)['startTime'] as Timestamp?;
                      if (aTime == null || bTime == null) return 0;
                      return aTime.toDate().compareTo(bTime.toDate()); // Ascending for schedule
                    });

                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: sortedClasses.length,
                      itemBuilder: (context, index) {
                        final classData = sortedClasses[index].data() as Map<String, dynamic>;
                        final sessionId = sortedClasses[index].id;
                        final startTime = (classData['startTime'] as Timestamp).toDate();

                        return _buildScheduleCard(context, classData, startTime, sessionId);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressContent(StudentParentViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () => viewModel.refreshData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Achievements", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
                  const SizedBox(height: 4),
                  Text("Track your child's badges and skills", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Consumer<StudentParentViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
                  }

                  // Check if student data failed to load
                  if (viewModel.studentId == null && !viewModel.isLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text(
                            "No student data found",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Please contact admin to link your account",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  // Get age group and generate mock badges if real badges are empty
                  String ageGroup = _normalizeAgeGroup(viewModel.childAgeGroup ?? 'Junior Kickers');
                  List<String> possibleBadges = _getPossibleBadgesForAgeGroup(ageGroup);

                  // Use real badges if available, otherwise use mock badges
                  List<String> earnedBadgeIds = viewModel.childBadges.isNotEmpty
                      ? viewModel.childBadges.map((b) => b['id'] as String).toList()
                      : _generateMockBadges(ageGroup, possibleBadges);

                  // Calculate current badge (first unearned)
                  String? currentBadgeId = possibleBadges.firstWhere(
                    (badge) => !earnedBadgeIds.contains(badge),
                    orElse: () => '',
                  );
                  if (currentBadgeId.isEmpty) currentBadgeId = null;

                  // Stats Row
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatContainer(
                              "Badges Earned",
                              "${earnedBadgeIds.length}",
                              Icons.emoji_events,
                              Colors.amber,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatContainer(
                              "Attendance",
                              "${viewModel.attendanceRate.toStringAsFixed(0)}%",
                              Icons.check_circle,
                              AppTheme.pitchGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Badge Grid
                      if (viewModel.studentId != null)
                        BadgeGrid(
                          ageGroup: ageGroup,
                          earnedBadgeIds: earnedBadgeIds,
                          currentBadgeId: currentBadgeId,
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Normalize age group name to match badge_data.dart format
  String _normalizeAgeGroup(String ageGroup) {
    String normalized = ageGroup.toLowerCase().trim();

    if (normalized.contains('little') && normalized.contains('kick')) {
      return 'Little Kicks';
    } else if (normalized.contains('junior') && normalized.contains('kick')) {
      return 'Junior Kickers';
    } else if (normalized.contains('mighty') && normalized.contains('kick')) {
      return 'Mighty Kickers';
    } else if (normalized.contains('mega') && normalized.contains('kick')) {
      return 'Mega Kickers';
    }

    return ageGroup;
  }

  // Generate mock badges based on age group
  List<String> _generateMockBadges(String ageGroup, List<String> possibleBadges) {
    String normalizedAgeGroup = _normalizeAgeGroup(ageGroup);

    int count;
    switch (normalizedAgeGroup) {
      case 'Mega Kickers':
        count = 6;
        break;
      case 'Mighty Kickers':
        count = 4;
        break;
      case 'Junior Kickers':
        count = 3;
        break;
      case 'Little Kicks':
      default:
        count = 2;
        break;
    }
    count = count.clamp(0, possibleBadges.length);
    return possibleBadges.take(count).toList();
  }

  // Get possible badges based on age group
  List<String> _getPossibleBadgesForAgeGroup(String ageGroup) {
    String normalizedAgeGroup = _normalizeAgeGroup(ageGroup);

    List<String> possibleBadges = [];
    if (normalizedAgeGroup == 'Mega Kickers') {
      possibleBadges.addAll([
        'lk_attention_listening', 'lk_sharing', 'lk_kicking', 'lk_confidence',
        'jk_kicking', 'jk_imagination', 'jk_physical_literacy', 'jk_team_player',
        'mk_leadership', 'mk_physical_literacy', 'mk_all_rounder', 'mk_problem_solver', 'mk_kicking', 'mk_match_play',
        'mega_attacking', 'mega_defending', 'mega_tactician', 'mega_captain', 'mega_all_rounder', 'mega_referee'
      ]);
    } else if (normalizedAgeGroup == 'Mighty Kickers') {
      possibleBadges.addAll([
        'lk_attention_listening', 'lk_sharing', 'lk_kicking', 'lk_confidence',
        'jk_kicking', 'jk_imagination', 'jk_physical_literacy', 'jk_team_player',
        'mk_leadership', 'mk_physical_literacy', 'mk_all_rounder', 'mk_problem_solver', 'mk_kicking', 'mk_match_play'
      ]);
    } else if (normalizedAgeGroup == 'Junior Kickers') {
      possibleBadges.addAll([
        'lk_attention_listening', 'lk_sharing', 'lk_kicking', 'lk_confidence',
        'jk_kicking', 'jk_imagination', 'jk_physical_literacy', 'jk_team_player'
      ]);
    } else {
      // Little Kicks or default
      possibleBadges.addAll([
        'lk_attention_listening', 'lk_sharing', 'lk_kicking', 'lk_confidence'
      ]);
    }
    return possibleBadges;
  }

  // --- Helper Widgets ---

  // Show change password dialog
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

  // Show payment confirmation dialog with receipt upload
  void _showPaymentConfirmationDialog(BuildContext context, StudentParentViewModel viewModel) async {
    // Check if studentId is available before proceeding
    if (viewModel.studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to process payment. Student data not loaded yet."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final monthYear = "${_getMonthName(now.month)} ${now.year}";

    // Check current payment status
    final paymentStatus = await _getPaymentStatus(viewModel.studentId);

    if (!context.mounted) return;

    // If payment is pending or paid, show status dialog instead
    if (paymentStatus == 'pending') {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.hourglass_top, color: Colors.orange, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Payment Pending",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your payment for $monthYear is currently pending approval.",
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 12),
                Text(
                  "The admin will review and confirm your payment soon. You will be notified once it's approved.",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    if (paymentStatus == 'paid') {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Payment Confirmed",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your payment for $monthYear has been confirmed.",
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 12),
                Text(
                  "Thank you for your payment!",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    // Show upload dialog only for unpaid status
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return _PaymentConfirmationDialog(
          monthYear: monthYear,
          studentId: viewModel.studentId!,
          studentName: viewModel.studentName ?? 'Student',
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  Widget _buildActionCard({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Container(
      height: 120, // Fixed height for consistency
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12, // Slightly smaller font for consistency
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkText,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCard({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Tap to confirm payment",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, Map<String, dynamic> classData, DateTime startTime, String sessionId) {
    String formattedDate = "${startTime.day}/${startTime.month}/${startTime.year}";
    String formattedTime = "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";

    // Debug: Check if templateId exists
    debugPrint('📅 Session: ${classData['className']}');
    debugPrint('   - templateId: ${classData['templateId']}');
    debugPrint('   - Has templateId: ${classData['templateId'] != null}');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/class_details',
                  arguments: {
                    'sessionId': sessionId,
                    'className': classData['className'],
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Date Box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "${startTime.day}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryRed,
                            ),
                          ),
                          Text(
                            _getMonthAbbreviation(startTime.month),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            classData['className'] ?? 'Class',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(formattedTime, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                              const SizedBox(width: 12),
                              Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  classData['venue'] ?? 'Venue',
                                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
          // View Session Plan button
          if (classData['templateId'] != null) ...[
            // Debug: Confirm button is being built
            Builder(
              builder: (context) {
                debugPrint('✅ Building "View Session Plan" button for session');
                return const SizedBox.shrink();
              },
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  onTap: () {
                    _navigateToSessionTemplate(context, classData['templateId']);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.library_books, size: 16, color: AppTheme.pitchGreen),
                        const SizedBox(width: 8),
                        Text(
                          'View Session Plan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.pitchGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _navigateToSessionTemplate(BuildContext context, String templateId) async {
    debugPrint('🚀 Navigating to template: $templateId');

    try {
      // Fetch template details from Firestore
      debugPrint('📡 Fetching template from Firestore...');
      final templateDoc = await FirebaseFirestore.instance
          .collection('session_templates')
          .doc(templateId)
          .get();

      debugPrint('📄 Template exists: ${templateDoc.exists}');

      if (!templateDoc.exists) {
        debugPrint('❌ Template not found in Firestore');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session template not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final templateData = templateDoc.data() as Map<String, dynamic>;
      debugPrint('✅ Template data loaded: ${templateData['title']}');

      // Parse drills
      List<DrillData> drills = [];
      if (templateData['drills'] != null && templateData['drills'] is List) {
        for (var drill in templateData['drills']) {
          if (drill is Map<String, dynamic>) {
            drills.add(DrillData(
              title: drill['title']?.toString() ?? '',
              duration: drill['duration']?.toString() ?? '',
              instructions: drill['instructions']?.toString() ?? '',
              equipment: drill['equipment']?.toString() ?? '',
              progressionEasier: drill['progression_easier']?.toString() ?? '',
              progressionHarder: drill['progression_harder']?.toString() ?? '',
              learningGoals: drill['learning_goals']?.toString() ?? '',
              animationUrl: drill['animationUrl']?.toString(),
              animationJson: drill['animationJson']?.toString(),
              visualType: drill['visualType']?.toString(),
            ));
          }
        }
      }

      debugPrint('📋 Parsed ${drills.length} drills');
      debugPrint('🎯 About to navigate to SessionTemplateDetailsView');

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SessionTemplateDetailsView(
              templateId: templateId,
              templateTitle: templateData['title']?.toString() ?? 'Session Plan',
              ageGroup: templateData['ageGroup']?.toString() ?? '',
              badgeFocus: templateData['badgeFocus']?.toString() ?? '',
              drills: drills,
              pdfUrl: templateData['pdfUrl']?.toString(),
              pdfFileName: templateData['pdfFileName']?.toString(),
            ),
          ),
        );
        debugPrint('✅ Navigation pushed successfully');
      } else {
        debugPrint('⚠️ Context not mounted, skipping navigation');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading session plan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStatContainer(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  String _getMonthAbbreviation(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month];
  }

  // Get current payment status for the student
  Future<String> _getPaymentStatus(String? studentId) async {
    if (studentId == null) return "unpaid";

    try {
      final now = DateTime.now();
      final monthYear = "${_getMonthName(now.month)} ${now.year}";

      final doc = await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .collection('payments')
          .doc(monthYear.replaceAll(' ', '_'))
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          final status = data['status'] as String?;
          // Return the status: 'pending', 'confirmed'/'paid', or 'rejected'
          if (status != null) {
            if (status == 'confirmed' || status == 'paid') {
              return 'paid';
            } else if (status == 'pending') {
              return 'pending';
            }
          }
        }
      }
      return 'unpaid'; // Default to unpaid if no payment record exists
    } catch (e) {
      debugPrint("Error checking payment status: $e");
      return 'unpaid'; // Default to unpaid if there's an error
    }
  }
}

// Payment Confirmation Dialog with Receipt Upload
class _PaymentConfirmationDialog extends StatefulWidget {
  final String monthYear;
  final String studentId;
  final String studentName;

  const _PaymentConfirmationDialog({
    required this.monthYear,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<_PaymentConfirmationDialog> createState() => _PaymentConfirmationDialogState();
}

class _PaymentConfirmationDialogState extends State<_PaymentConfirmationDialog> {
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  String? _selectedFileType;
  bool _isUploading = false;
  bool _isAnalyzing = false;
  final StorageService _storageService = StorageService();
  final GeminiReceiptService _receiptService = GeminiReceiptService();

  // AI-extracted data
  final TextEditingController _amountController = TextEditingController();
  String? _extractedDate;
  String? _extractedReference;
  String? _extractedPaymentMethod;
  bool _hasAnalyzed = false;
  String? _errorMessage; // Error message to show in dialog

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          final contentType = _getContentType(file.extension ?? '');
          setState(() {
            _selectedFileBytes = file.bytes;
            _selectedFileName = file.name;
            _selectedFileType = contentType;
            _hasAnalyzed = false;
          });

          // Auto-analyze receipt with AI
          await _analyzeReceipt(file.bytes!, contentType);
        }
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error selecting file: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _analyzeReceipt(Uint8List bytes, String mimeType) async {
    if (!mounted) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      ReceiptData result;
      if (mimeType == 'application/pdf') {
        result = await _receiptService.extractFromPdf(bytes);
      } else {
        result = await _receiptService.extractFromImage(bytes, mimeType);
      }

      if (!mounted) return;

      if (result.success) {
        setState(() {
          if (result.amount != null) {
            _amountController.text = result.amount!.toStringAsFixed(2);
          }
          _extractedDate = result.date;
          _extractedReference = result.referenceNumber;
          _extractedPaymentMethod = result.paymentMethod;
          _hasAnalyzed = true;
          _isAnalyzing = false;
          _errorMessage = null;
        });
      } else {
        // Invalid file - clear selection and show error in dialog
        setState(() {
          _selectedFileBytes = null;
          _selectedFileName = null;
          _selectedFileType = null;
          _hasAnalyzed = false;
          _isAnalyzing = false;
          _errorMessage = result.error ?? 'Invalid file. Please upload a valid payment receipt.';
        });
      }
    } catch (e) {
      debugPrint("Error analyzing receipt: $e");
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _hasAnalyzed = false;
          _selectedFileBytes = null;
          _selectedFileName = null;
          _selectedFileType = null;
          _errorMessage = "Error analyzing file. Please try again.";
        });
      }
    }
  }

  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 10, color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitPayment() async {
    if (_selectedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload a receipt or screenshot as proof of payment"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload receipt to Firebase Storage
      final receiptUrl = await _storageService.uploadPaymentReceipt(
        fileBytes: _selectedFileBytes!,
        studentId: widget.studentId,
        monthYear: widget.monthYear,
        fileName: _selectedFileName ?? 'receipt',
        contentType: _selectedFileType ?? 'application/octet-stream',
      );

      if (receiptUrl == null) {
        throw Exception("Failed to upload receipt");
      }

      // Parse amount from controller
      final amount = double.tryParse(_amountController.text) ?? 0;

      // Save payment record to Firestore
      await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .collection('payments')
          .doc(widget.monthYear.replaceAll(' ', '_'))
          .set({
        'month': widget.monthYear,
        'amount': amount,
        'status': 'pending',
        'parentConfirmed': true,
        'adminConfirmed': false,
        'parentConfirmedAt': FieldValue.serverTimestamp(),
        'adminConfirmedAt': null,
        'notes': 'Parent confirmed payment for ${widget.monthYear}',
        'studentId': widget.studentId,
        'studentName': widget.studentName,
        'receiptUrl': receiptUrl,
        'receiptFileName': _selectedFileName,
        'receiptType': _selectedFileType,
        // AI-extracted data for admin reference
        'aiExtractedAmount': amount,
        'aiExtractedDate': _extractedDate,
        'aiExtractedReference': _extractedReference,
        'aiExtractedPaymentMethod': _extractedPaymentMethod,
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payment confirmation with receipt sent to admin"),
            backgroundColor: AppTheme.pitchGreen,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error submitting payment: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error confirming payment: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.payment, color: AppTheme.primaryRed, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Payment Confirmation",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Confirm payment for ${widget.monthYear}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Please upload a receipt or screenshot as proof of payment. "
              "Accepted formats: PDF, PNG, JPG, JPEG",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 20),

            // File Upload Section
            InkWell(
              onTap: _isUploading ? null : _pickFile,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _selectedFileBytes != null
                      ? AppTheme.pitchGreen.withValues(alpha: 0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedFileBytes != null
                        ? AppTheme.pitchGreen
                        : Colors.grey[300]!,
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedFileBytes != null
                          ? Icons.check_circle
                          : Icons.cloud_upload_outlined,
                      size: 48,
                      color: _selectedFileBytes != null
                          ? AppTheme.pitchGreen
                          : Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedFileName ?? "Tap to upload receipt",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _selectedFileBytes != null
                            ? AppTheme.pitchGreen
                            : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_selectedFileBytes == null) ...[
                      const SizedBox(height: 4),
                      Text(
                        "PDF, PNG, JPG, JPEG",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Error message display
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Preview for images
            if (_selectedFileBytes != null &&
                (_selectedFileType?.startsWith('image/') ?? false)) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  _selectedFileBytes!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],

            // AI Analysis Status
            if (_selectedFileBytes != null && _isAnalyzing) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "AI is reading your receipt...",
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Amount Field (editable, auto-filled by AI)
            if (_selectedFileBytes != null && _hasAnalyzed) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.pitchGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.pitchGreen.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 16, color: AppTheme.pitchGreen),
                        const SizedBox(width: 6),
                        Text(
                          "AI-Detected Payment Details",
                          style: TextStyle(
                            color: AppTheme.pitchGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Amount Field
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Payment Amount (RM)",
                        hintText: "Enter amount",
                        prefixText: "RM ",
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppTheme.pitchGreen),
                        ),
                      ),
                    ),
                    // Show extracted info
                    if (_extractedReference != null || _extractedPaymentMethod != null) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (_extractedPaymentMethod != null)
                            _buildInfoChip(Icons.payment, _extractedPaymentMethod!),
                          if (_extractedReference != null)
                            _buildInfoChip(Icons.tag, _extractedReference!),
                          if (_extractedDate != null)
                            _buildInfoChip(Icons.calendar_today, _extractedDate!),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      "You can edit the amount if it's incorrect",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Change file button
            if (_selectedFileBytes != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: (_isUploading || _isAnalyzing) ? null : _pickFile,
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: const Text("Change file"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        ElevatedButton(
          onPressed: _isUploading ? null : _submitPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text("Submit Payment"),
        ),
      ],
    );
  }
}