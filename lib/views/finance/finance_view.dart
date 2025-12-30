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
      appBar: AppBar(
        title: const Text("Finance Dashboard"),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Coach Payments"),
            Tab(text: "Student Fees"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const CoachPaymentsScreen(),
          const StudentFeesScreen(),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sessions')
            .where('status', isEqualTo: 'Completed')
            .orderBy('startTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No completed sessions yet"));
          }

          final sessions = snapshot.data!.docs;

          // Group sessions by coach
          Map<String, List<DocumentSnapshot>> coachSessions = {};
          for (var session in sessions) {
            final data = session.data() as Map<String, dynamic>;
            final coachId = data['coachId'] as String;
            
            if (coachSessions.containsKey(coachId)) {
              coachSessions[coachId]!.add(session);
            } else {
              coachSessions[coachId] = [session];
            }
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: coachSessions.length,
            itemBuilder: (context, index) {
              final coachId = coachSessions.keys.elementAt(index);
              final coachSessionsList = coachSessions[coachId]!;
              
              // Calculate total sessions and payment for this coach
              int totalSessions = coachSessionsList.length;
              double ratePerSession = 50.0; // Example rate
              double totalPayment = totalSessions * ratePerSession;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Coach",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "RM ${totalPayment.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "ID: $coachId",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text("$totalSessions Sessions • Rate: RM ${ratePerSession.toStringAsFixed(2)}/session"),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Total Payment: RM ${totalPayment.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class StudentFeesScreen extends StatelessWidget {
  const StudentFeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('students')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No students registered yet"));
          }

          final students = snapshot.data!.docs;

          // Filter students based on current month's payment status
          final now = DateTime.now();
          final currentMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";
          
          List<DocumentSnapshot> paidStudents = [];
          List<DocumentSnapshot> unpaidStudents = [];

          for (var student in students) {
            final data = student.data() as Map<String, dynamic>;
            final attendanceHistory = Map<String, dynamic>.from(data['attendanceHistory'] ?? {});
            
            // Check if fees are paid for current month (simplified logic)
            bool isPaid = attendanceHistory.entries.any((entry) {
              // Check if the date is in current month and has attendance
              String dateKey = entry.key;
              if (dateKey.startsWith(currentMonth)) {
                return true; // For demo, if there's attendance in current month, consider paid
              }
              return false;
            });

            if (isPaid) {
              paidStudents.add(student);
            } else {
              unpaidStudents.add(student);
            }
          }

          return Column(
            children: [
              // Summary Cards
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        "Paid", 
                        paidStudents.length.toString(), 
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        "Unpaid", 
                        unpaidStudents.length.toString(), 
                        Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              
              // List of students
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final data = student.data() as Map<String, dynamic>;
                    final attendanceHistory = Map<String, dynamic>.from(data['attendanceHistory'] ?? {});
                    
                    bool isPaid = attendanceHistory.entries.any((entry) {
                      String dateKey = entry.key;
                      if (dateKey.startsWith(currentMonth)) {
                        return true;
                      }
                      return false;
                    });

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isPaid ? Colors.white : Colors.red.shade50,
                      child: ListTile(
                        title: Text(data['name'] ?? 'Unknown'),
                        subtitle: Text(data['parentContact'] ?? ''),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isPaid ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isPaid ? "PAID" : "UNPAID",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}