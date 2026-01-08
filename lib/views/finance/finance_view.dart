import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';

class FinanceView extends StatefulWidget {
  const FinanceView({super.key});

  @override
  State<FinanceView> createState() => _FinanceViewState();
}

class _FinanceViewState extends State<FinanceView> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      body: Column(
        children: [
          // 1. Header matching AdminAnalyticsView style
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors : [Color(0xFFE65100), Color(0xFFFFA726)], // Professional Orange Gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Decorative Background Icon
                Positioned(
                  right: -20,
                  top: 40,
                  child: Icon(
                    Icons.monetization_on_outlined,
                    size: 150,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Finance Dashboard",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Track payments and revenue",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Tab Bar inside Header
                      Container(
                        height: 50,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(21),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelColor: const Color(0xFFE65100),
                          unselectedLabelColor: Colors.white.withOpacity(0.9),
                          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
                          tabs: const [
                            Tab(text: "Coach Payments"),
                            Tab(text: "Student Fees"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const CoachPaymentsScreen(),
                const StudentFeesScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CoachPaymentsScreen extends StatelessWidget {
  const CoachPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent to show parent bg
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'coach')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState("No coaches registered yet", Icons.people_outline);
          }

          final coaches = snapshot.data!.docs;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('sessions')
                .where('status', isEqualTo: 'Completed')
                .orderBy('startTime', descending: true)
                .snapshots(),
            builder: (context, sessionsSnapshot) {
              if (sessionsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
              }

              // Get all completed sessions from sessions collection
              List<DocumentSnapshot> allSessions = [];
              if (sessionsSnapshot.hasData && sessionsSnapshot.data!.docs.isNotEmpty) {
                allSessions = sessionsSnapshot.data!.docs;
              }

              // Also get completed sessions from pastSessions collection
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pastSessions')
                    .orderBy('completedAt', descending: true)
                    .snapshots(),
                builder: (context, pastSessionsSnapshot) {
                  if (pastSessionsSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
                  }

                  // Add past sessions to the list
                  if (pastSessionsSnapshot.hasData && pastSessionsSnapshot.data!.docs.isNotEmpty) {
                    allSessions.addAll(pastSessionsSnapshot.data!.docs);
                  }

                  // Group completed sessions by coach (from both collections)
                  Map<String, List<DocumentSnapshot>> completedSessionsByCoach = {};
                  for (var session in allSessions) {
                    final data = session.data() as Map<String, dynamic>;
                    final coachId = data['coachId'] as String?;

                    if (coachId != null) {
                      if (completedSessionsByCoach.containsKey(coachId)) {
                        completedSessionsByCoach[coachId]!.add(session);
                      } else {
                        completedSessionsByCoach[coachId] = [session];
                      }
                    }
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: coaches.length,
                    itemBuilder: (context, index) {
                      final coachDoc = coaches[index];
                      final coachData = coachDoc.data() as Map<String, dynamic>;
                      final coachId = coachDoc.id;
                      final coachName = coachData['name'] ?? 'Unknown Coach';
                      final rawRate = coachData['ratePerHour'];
                      final double coachRate = (rawRate is num) ? rawRate.toDouble() : 50.0;

                      // Get this coach's completed sessions
                      final coachCompletedSessions = completedSessionsByCoach[coachId] ?? [];
                      int totalCompletedSessions = coachCompletedSessions.length;
                      double totalPayment = totalCompletedSessions * coachRate;

                      return _buildCoachPaymentCard(
                        context,
                        coachName,
                        totalPayment,
                        totalCompletedSessions,
                        coachRate,
                        coachId,
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCoachPaymentCard(
    BuildContext context,
    String name,
    double payment,
    int sessions,
    double rate,
    String id,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryRed.withOpacity(0.1),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'C',
                    style: const TextStyle(
                      color: AppTheme.primaryRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkText,
                        ),
                      ),
                      Text(
                        "ID: ${id.substring(0, 6)}...",
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "RM ${payment.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem("Sessions", "$sessions", Icons.check_circle_outline, Colors.blue),
                _buildStatItem("Rate", "RM ${rate.toStringAsFixed(0)}/hr", Icons.monetization_on_outlined, Colors.orange),
                _buildStatItem("Status", sessions > 0 ? "Active" : "Idle", Icons.analytics_outlined, sessions > 0 ? AppTheme.pitchGreen : Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.darkText)),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class StudentFeesScreen extends StatefulWidget {
  const StudentFeesScreen({super.key});

  @override
  State<StudentFeesScreen> createState() => _StudentFeesScreenState();
}

class _StudentFeesScreenState extends State<StudentFeesScreen> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final monthYear = "${DateFormat('MMMM').format(selectedDate)} ${selectedDate.year}";

    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent to show parent bg
      body: Column(
        children: [
          // Month Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.grey[700], size: 20),
                const SizedBox(width: 12),
                Text(
                  "Payment Month:",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _showMonthPicker(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE65100).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE65100).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            monthYear,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE65100),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Color(0xFFE65100)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Student List with Payment Stream
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('students').snapshots(),
              builder: (context, studentsSnapshot) {
                if (studentsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
                }

                if (!studentsSnapshot.hasData || studentsSnapshot.data!.docs.isEmpty) {
                  return _buildEmptyState("No students registered yet", Icons.school_outlined);
                }

                final students = studentsSnapshot.data!.docs;

                return FutureBuilder<Map<String, String>>(
                  future: _fetchParentEmails(students),
                  builder: (context, emailSnapshot) {
                    if (emailSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
                    }

                    final parentEmails = emailSnapshot.data ?? {};

                    return _StudentListWithPaymentStream(
                      students: students,
                      parentEmails: parentEmails,
                      monthYear: monthYear,
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

  void _showMonthPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Select Payment Month",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkText,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 24, // Show last 24 months
                  itemBuilder: (context, index) {
                    final date = DateTime(
                      DateTime.now().year,
                      DateTime.now().month - index,
                      1,
                    );
                    final monthYearStr = "${DateFormat('MMMM').format(date)} ${date.year}";
                    final isSelected = selectedDate.year == date.year && selectedDate.month == date.month;

                    return ListTile(
                      selected: isSelected,
                      selectedTileColor: const Color(0xFFE65100).withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      leading: Icon(
                        Icons.calendar_today,
                        color: isSelected ? const Color(0xFFE65100) : Colors.grey[600],
                      ),
                      title: Text(
                        monthYearStr,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFFE65100) : AppTheme.darkText,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Color(0xFFE65100))
                          : null,
                      onTap: () {
                        setState(() {
                          selectedDate = date;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, String>> _fetchParentEmails(List<QueryDocumentSnapshot> students) async {
    Map<String, String> parentEmails = {};

    for (var student in students) {
      final studentData = student.data() as Map<String, dynamic>;
      String parentEmail = 'No Email';

      // Try multiple possible field names for parent/linked student reference
      String? linkedUserId = studentData['parentId'] ??
                            studentData['linkedStudentId'] ??
                            studentData['linkedStudent'] ??
                            studentData['userId'];

      if (linkedUserId != null && linkedUserId.isNotEmpty) {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(linkedUserId)
              .get();
          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>?;
            if (userData != null) {
              parentEmail = userData['email'] ?? 'No Email';
            }
          }
        } catch (e) {
          print("Error fetching parent email for ${student.id}: $e");
        }
      }

      // If still no email found, check if email is stored directly in student document
      if (parentEmail == 'No Email') {
        parentEmail = studentData['email'] ??
                     studentData['parentEmail'] ??
                     studentData['parentContact'] ??
                     'No Email';
      }

      parentEmails[student.id] = parentEmail;
    }

    return parentEmails;
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// Widget that builds the student list with real-time payment status updates
class _StudentListWithPaymentStream extends StatelessWidget {
  final List<QueryDocumentSnapshot> students;
  final Map<String, String> parentEmails;
  final String monthYear;

  const _StudentListWithPaymentStream({
    required this.students,
    required this.parentEmails,
    required this.monthYear,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: _getPaymentStatusStream(),
      builder: (context, paymentSnapshot) {
        if (paymentSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
        }

        // Process payment data
        int paidCount = 0;
        int pendingCount = 0;
        int unpaidCount = 0;

        Map<String, String> paymentStatuses = {};

        if (paymentSnapshot.hasData) {
          for (int i = 0; i < students.length; i++) {
            final student = students[i];
            final studentId = student.id;

            // Get the payment document for this student by index
            String status = 'unpaid';
            if (i < paymentSnapshot.data!.length) {
              final paymentDoc = paymentSnapshot.data![i];
              if (paymentDoc.exists) {
                final data = paymentDoc.data() as Map<String, dynamic>?;
                if (data != null) {
                  status = (data['status'] as String?)?.toLowerCase() ?? 'unpaid';
                }
              }
            }

            paymentStatuses[studentId] = status;

            if (status == 'paid' || status == 'confirmed') {
              paidCount++;
            } else if (status == 'pending') {
              pendingCount++;
            } else {
              unpaidCount++;
            }
          }
        }

        return Column(
          children: [
            // Summary Cards
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      "Paid",
                      paidCount.toString(),
                      Colors.green,
                      Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      "Pending",
                      pendingCount.toString(),
                      Colors.orange,
                      Icons.pending_actions,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      "Unpaid",
                      unpaidCount.toString(),
                      Colors.red,
                      Icons.warning_amber_rounded,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Student List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  final data = student.data() as Map<String, dynamic>;
                  final paymentStatus = paymentStatuses[student.id] ?? 'unpaid';
                  final parentEmail = parentEmails[student.id] ?? 'No Email';

                  return _buildStudentFeeCard(
                    context,
                    student,
                    data,
                    paymentStatus,
                    parentEmail,
                    monthYear,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Stream<List<DocumentSnapshot>> _getPaymentStatusStream() async* {
    // Use a simple polling approach that listens to all payment documents
    final docId = monthYear.replaceAll(' ', '_');

    // Create a combined stream by listening to changes in any payment document
    await for (var _ in Stream.periodic(const Duration(milliseconds: 500))) {
      List<DocumentSnapshot> docs = [];

      for (var student in students) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('students')
              .doc(student.id)
              .collection('payments')
              .doc(docId)
              .get();
          docs.add(doc);
        } catch (e) {
          // If error, create empty doc placeholder
          print("Error fetching payment for ${student.id}: $e");
        }
      }

      yield docs;
    }
  }

  Widget _buildSummaryCard(String title, String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentFeeCard(
    BuildContext context,
    DocumentSnapshot studentDoc,
    Map<String, dynamic> data,
    String paymentStatus,
    String parentEmail,
    String monthYear,
  ) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (paymentStatus) {
      case 'paid':
      case 'confirmed':
        statusColor = Colors.green;
        statusIcon = Icons.check;
        statusText = "PAID";
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = "PENDING";
        break;
      default:
        statusColor = Colors.red;
        statusIcon = Icons.priority_high;
        statusText = "UNPAID";
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: statusColor.withOpacity(0.1),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        parentEmail,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            // Show action buttons for pending payments
            if (paymentStatus == 'pending') ...[
              const SizedBox(height: 8),
              _buildPaymentActionButtons(context, studentDoc.id, data['name'] ?? 'Unknown Student', monthYear),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentActionButtons(BuildContext context, String studentId, String studentName, String monthYear) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                await _confirmPayment(studentId, monthYear, 'confirmed');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Payment confirmed for $studentName"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.check, size: 14),
              label: const Text("Confirm", style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                await _confirmPayment(studentId, monthYear, 'rejected');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Payment marked as rejected for $studentName"),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              icon: const Icon(Icons.close, size: 14),
              label: const Text("Reject", style: TextStyle(fontSize: 11)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red, width: 1),
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmPayment(String studentId, String monthYear, String newStatus) async {
    try {
      final paymentDocRef = FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .collection('payments')
          .doc(monthYear.replaceAll(' ', '_'));

      final docSnapshot = await paymentDocRef.get();

      if (docSnapshot.exists) {
        await paymentDocRef.update({
          'status': newStatus,
          'adminConfirmed': newStatus == 'confirmed',
          'adminConfirmedAt': FieldValue.serverTimestamp(),
          'adminNotes': 'Admin updated status to $newStatus',
        });
      } else {
        await paymentDocRef.set({
          'month': monthYear,
          'amount': 0,
          'status': newStatus,
          'parentConfirmed': false,
          'adminConfirmed': newStatus == 'confirmed',
          'parentConfirmedAt': null,
          'adminConfirmedAt': FieldValue.serverTimestamp(),
          'notes': 'Admin created payment record with status $newStatus',
          'studentId': studentId,
          'studentName': '',
        });
      }
    } catch (e) {
      print("ERROR in _confirmPayment: $e");
    }
  }
}