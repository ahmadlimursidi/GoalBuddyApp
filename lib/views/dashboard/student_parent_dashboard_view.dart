import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/student_parent_view_model.dart';
import '../../widgets/badge_grid.dart'; // Ensure this is imported for the progress tab

class StudentParentDashboardView extends StatefulWidget {
  const StudentParentDashboardView({super.key});

  @override
  State<StudentParentDashboardView> createState() => _StudentParentDashboardViewState();
}

class _StudentParentDashboardViewState extends State<StudentParentDashboardView> {
  int _currentIndex = 0;

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
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await authViewModel.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }
            },
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

                  // Stats Row
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatContainer(
                              "Badges Earned",
                              "${viewModel.childBadges.length}",
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
                          ageGroup: viewModel.childAgeGroup ?? 'Junior Kickers',
                          earnedBadgeIds: viewModel.childBadges.map((b) => b['id'] as String).toList(),
                          currentBadgeId: null, // Optional: highlight next badge
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

  // --- Helper Widgets ---

  // Show payment confirmation dialog
  void _showPaymentConfirmationDialog(BuildContext context, StudentParentViewModel viewModel) {
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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Payment Confirmation"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Have you paid for $monthYear?"),
              const SizedBox(height: 16),
              Text(
                "Please confirm that you have made the payment for this month. "
                "Your confirmation will be sent to the admin for verification.",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Record payment intent in Firestore
                try {
                  await FirebaseFirestore.instance
                      .collection('students')
                      .doc(viewModel.studentId!)
                      .collection('payments')
                      .doc(monthYear.replaceAll(' ', '_'))
                      .set({
                    'month': monthYear,
                    'amount': 0, // This would be set by admin
                    'status': 'pending', // pending, confirmed, rejected
                    'parentConfirmed': true,
                    'adminConfirmed': false,
                    'parentConfirmedAt': FieldValue.serverTimestamp(),
                    'adminConfirmedAt': null,
                    'notes': 'Parent confirmed payment for $monthYear',
                    'studentId': viewModel.studentId,
                    'studentName': viewModel.studentName,
                  });

                  Navigator.of(context).pop(); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Payment confirmation sent to admin"),
                      backgroundColor: AppTheme.pitchGreen,
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pop(); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error confirming payment: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text("Yes, I Paid"),
            ),
          ],
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
    );
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
        final data = doc.data() as Map<String, dynamic>?;
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
      print("Error checking payment status: $e");
      return 'unpaid'; // Default to unpaid if there's an error
    }
  }
}