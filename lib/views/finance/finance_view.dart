import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

              // Get all completed sessions
              List<DocumentSnapshot> allSessions = [];
              if (sessionsSnapshot.hasData && sessionsSnapshot.data!.docs.isNotEmpty) {
                allSessions = sessionsSnapshot.data!.docs;
              }

              // Group completed sessions by coach
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

class StudentFeesScreen extends StatelessWidget {
  const StudentFeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent to show parent bg
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState("No students registered yet", Icons.school_outlined);
          }

          final students = snapshot.data!.docs;
          final now = DateTime.now();
          final currentMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";
          
          List<DocumentSnapshot> paidStudents = [];
          List<DocumentSnapshot> unpaidStudents = [];

          for (var student in students) {
            final data = student.data() as Map<String, dynamic>;
            final attendanceHistory = Map<String, dynamic>.from(data['attendanceHistory'] ?? {});
            
            // Simplified logic: If attended this month, assume paid (for demo purposes)
            bool isPaid = attendanceHistory.entries.any((entry) {
              return entry.key.startsWith(currentMonth);
            });

            if (isPaid) {
              paidStudents.add(student);
            } else {
              unpaidStudents.add(student);
            }
          }

          return Column(
            children: [
              // 1. Summary Cards
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        "Paid", 
                        paidStudents.length.toString(), 
                        Colors.green,
                        Icons.check_circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        "Unpaid", 
                        unpaidStudents.length.toString(), 
                        Colors.red,
                        Icons.warning_amber_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),

              // 2. Student List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final data = student.data() as Map<String, dynamic>;
                    final attendanceHistory = Map<String, dynamic>.from(data['attendanceHistory'] ?? {});
                    
                    bool isPaid = attendanceHistory.entries.any((entry) {
                      return entry.key.startsWith(currentMonth);
                    });

                    return _buildStudentFeeCard(data, isPaid);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStudentFeeCard(Map<String, dynamic> data, bool isPaid) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isPaid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              child: Icon(
                isPaid ? Icons.check : Icons.priority_high,
                color: isPaid ? Colors.green : Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['parentContact'] ?? 'No Contact Info',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isPaid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isPaid ? "PAID" : "UNPAID",
                style: TextStyle(
                  color: isPaid ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            count,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
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