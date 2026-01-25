import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../coach/coach_profile_view.dart';

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
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Finance Dashboard",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Tab Bar inside Header
                      Container(
                        height: 42,
                        padding: const EdgeInsets.all(3),
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

class CoachPaymentsScreen extends StatefulWidget {
  const CoachPaymentsScreen({super.key});

  @override
  State<CoachPaymentsScreen> createState() => _CoachPaymentsScreenState();
}

class _CoachPaymentsScreenState extends State<CoachPaymentsScreen> {
  late DateTime selectedDate;
  bool _summaryExpanded = false;

  // Cache data to avoid spinners on dropdown toggle
  List<QueryDocumentSnapshot>? _cachedCoaches;
  List<DocumentSnapshot>? _cachedSessions;
  List<DocumentSnapshot>? _cachedPastSessions;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Month Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                Icon(Icons.calendar_month, color: Colors.grey[700], size: 18),
                const SizedBox(width: 10),
                Text(
                  "Month:",
                  style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 10),
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
                            "${DateFormat('MMMM').format(selectedDate)} ${selectedDate.year}",
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Color(0xFFE65100), size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Coach List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'coach')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) _cachedCoaches = snapshot.data!.docs;
          final coaches = snapshot.data?.docs ?? _cachedCoaches;

          if (coaches == null) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
          }

          if (coaches.isEmpty) {
            return _buildEmptyState("No coaches registered yet", Icons.people_outline);
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('sessions')
                .where('status', isEqualTo: 'Completed')
                .orderBy('startTime', descending: true)
                .snapshots(),
            builder: (context, sessionsSnapshot) {
              if (sessionsSnapshot.hasData) _cachedSessions = sessionsSnapshot.data!.docs;
              final sessions = sessionsSnapshot.data?.docs ?? _cachedSessions ?? [];

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pastSessions')
                    .orderBy('completedAt', descending: true)
                    .snapshots(),
                builder: (context, pastSessionsSnapshot) {
                  if (pastSessionsSnapshot.hasData) _cachedPastSessions = pastSessionsSnapshot.data!.docs;
                  final pastSessions = pastSessionsSnapshot.data?.docs ?? _cachedPastSessions ?? [];

                  // Combine all sessions
                  List<DocumentSnapshot> allSessions = [...sessions, ...pastSessions];

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

                  // Calculate monthly and yearly totals based on selected month
                  double totalMonthlyPayment = 0;
                  double totalYearlyPayment = 0;
                  int totalMonthlySessions = 0;
                  int totalYearlySessions = 0;

                  Map<String, Map<String, dynamic>> coachStats = {};

                  for (var coachDoc in coaches) {
                    final coachId = coachDoc.id;
                    final coachData = coachDoc.data() as Map<String, dynamic>;
                    final rawRate = coachData['ratePerHour'];
                    final double coachRate = (rawRate is num) ? rawRate.toDouble() : 50.0;

                    final coachCompletedSessions = completedSessionsByCoach[coachId] ?? [];
                    int monthlySessions = 0;
                    int yearlySessions = 0;

                    for (var session in coachCompletedSessions) {
                      final sessionData = session.data() as Map<String, dynamic>;
                      DateTime? sessionDate;

                      if (sessionData['completedAt'] != null) {
                        sessionDate = (sessionData['completedAt'] as Timestamp).toDate();
                      } else if (sessionData['startTime'] != null) {
                        sessionDate = (sessionData['startTime'] as Timestamp).toDate();
                      }

                      if (sessionDate != null) {
                        if (sessionDate.year == selectedDate.year) {
                          yearlySessions++;
                          if (sessionDate.month == selectedDate.month) {
                            monthlySessions++;
                          }
                        }
                      }
                    }

                    coachStats[coachId] = {
                      'monthlySessions': monthlySessions,
                      'yearlySessions': yearlySessions,
                      'monthlyPayment': monthlySessions * coachRate,
                      'yearlyPayment': yearlySessions * coachRate,
                      'totalSessions': coachCompletedSessions.length,
                      'totalPayment': coachCompletedSessions.length * coachRate,
                    };

                    totalMonthlySessions += monthlySessions;
                    totalYearlySessions += yearlySessions;
                    totalMonthlyPayment += monthlySessions * coachRate;
                    totalYearlyPayment += yearlySessions * coachRate;
                  }

                  return Column(
                    children: [
                      // Collapsible Summary
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () => setState(() => _summaryExpanded = !_summaryExpanded),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                child: Row(
                                  children: [
                                    Icon(Icons.analytics_outlined, size: 18, color: Colors.grey[700]),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "Payment Summary",
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                                      ),
                                    ),
                                    // Quick stats when collapsed
                                    if (!_summaryExpanded) ...[
                                      Text(
                                        "RM ${totalMonthlyPayment.toStringAsFixed(0)}",
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Icon(
                                      _summaryExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                      color: Colors.grey[600],
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_summaryExpanded)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildPaymentSummaryCard(
                                        DateFormat('MMM yyyy').format(selectedDate),
                                        "RM ${totalMonthlyPayment.toStringAsFixed(0)}",
                                        "$totalMonthlySessions sessions",
                                        Colors.blue,
                                        Icons.calendar_today,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _buildPaymentSummaryCard(
                                        "${selectedDate.year}",
                                        "RM ${totalYearlyPayment.toStringAsFixed(0)}",
                                        "$totalYearlySessions sessions",
                                        Colors.green,
                                        Icons.calendar_month,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Coach List
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            setState(() {
                              _cachedCoaches = null;
                              _cachedSessions = null;
                              _cachedPastSessions = null;
                            });
                          },
                          color: AppTheme.primaryRed,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: coaches.length,
                            itemBuilder: (context, index) {
                              final coachDoc = coaches[index];
                              final coachData = coachDoc.data() as Map<String, dynamic>;
                              final coachId = coachDoc.id;
                              final coachName = coachData['name'] ?? 'Unknown Coach';
                              final rawRate = coachData['ratePerHour'];
                              final double coachRate = (rawRate is num) ? rawRate.toDouble() : 50.0;

                              final stats = coachStats[coachId] ?? {};

                              return _buildCoachPaymentCard(
                                context,
                                coachName,
                                (stats['totalPayment'] as num?)?.toDouble() ?? 0,
                                (stats['totalSessions'] as int?) ?? 0,
                                coachRate,
                                coachId,
                                monthlyPayment: (stats['monthlyPayment'] as num?)?.toDouble() ?? 0,
                                yearlyPayment: (stats['yearlyPayment'] as num?)?.toDouble() ?? 0,
                                monthlySessions: (stats['monthlySessions'] as int?) ?? 0,
                                yearlySessions: (stats['yearlySessions'] as int?) ?? 0,
                                selectedMonth: selectedDate,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
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
                    "Select Month",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText),
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
                  itemCount: 24,
                  itemBuilder: (context, index) {
                    final date = DateTime(DateTime.now().year, DateTime.now().month - index, 1);
                    final monthYearStr = "${DateFormat('MMMM').format(date)} ${date.year}";
                    final isSelected = selectedDate.year == date.year && selectedDate.month == date.month;

                    return ListTile(
                      selected: isSelected,
                      selectedTileColor: const Color(0xFFE65100).withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      leading: Icon(Icons.calendar_today, color: isSelected ? const Color(0xFFE65100) : Colors.grey[600]),
                      title: Text(
                        monthYearStr,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFFE65100) : AppTheme.darkText,
                        ),
                      ),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFFE65100)) : null,
                      onTap: () {
                        setState(() => selectedDate = date);
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

  Widget _buildPaymentSummaryCard(String title, String amount, String subtitle, Color color, IconData icon) {
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
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(amount, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(subtitle, style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildCoachPaymentCard(
    BuildContext context,
    String name,
    double payment,
    int sessions,
    double rate,
    String id, {
    double monthlyPayment = 0,
    double yearlyPayment = 0,
    int monthlySessions = 0,
    int yearlySessions = 0,
    DateTime? selectedMonth,
  }) {
    final monthLabel = selectedMonth != null ? DateFormat('MMM yyyy').format(selectedMonth) : "This Month";
    final yearLabel = selectedMonth != null ? "${selectedMonth.year}" : "This Year";
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
                // Tappable coach avatar and name - navigates to coach profile
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CoachProfileView(coachId: id),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
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
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.darkText,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
                                  ],
                                ),
                                Text(
                                  "Tap to view profile",
                                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            // Monthly & Yearly breakdown
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 12, color: Colors.blue[700]),
                            const SizedBox(width: 4),
                            Text(monthLabel, style: TextStyle(fontSize: 10, color: Colors.blue[700], fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("RM ${monthlyPayment.toStringAsFixed(0)}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[700])),
                        Text("$monthlySessions sessions", style: TextStyle(fontSize: 10, color: Colors.blue[400])),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_month, size: 12, color: Colors.green[700]),
                            const SizedBox(width: 4),
                            Text(yearLabel, style: TextStyle(fontSize: 10, color: Colors.green[700], fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("RM ${yearlyPayment.toStringAsFixed(0)}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[700])),
                        Text("$yearlySessions sessions", style: TextStyle(fontSize: 10, color: Colors.green[400])),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem("Total", "$sessions", Icons.check_circle_outline, Colors.purple),
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
            final userData = userDoc.data();
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
class _StudentListWithPaymentStream extends StatefulWidget {
  final List<QueryDocumentSnapshot> students;
  final Map<String, String> parentEmails;
  final String monthYear;

  const _StudentListWithPaymentStream({
    required this.students,
    required this.parentEmails,
    required this.monthYear,
  });

  @override
  State<_StudentListWithPaymentStream> createState() => _StudentListWithPaymentStreamState();
}

class _StudentListWithPaymentStreamState extends State<_StudentListWithPaymentStream> {
  bool _revenueExpanded = false;
  List<DocumentSnapshot>? _cachedPaymentData;

  List<QueryDocumentSnapshot> get students => widget.students;
  Map<String, String> get parentEmails => widget.parentEmails;
  String get monthYear => widget.monthYear;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: _getPaymentStatusStream(),
      builder: (context, paymentSnapshot) {
        // Use cached data if available to avoid spinner on dropdown toggle
        if (paymentSnapshot.hasData) {
          _cachedPaymentData = paymentSnapshot.data;
        }
        final paymentData = paymentSnapshot.data ?? _cachedPaymentData;

        if (paymentData == null) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
        }

        // Process payment data
        int paidCount = 0;
        int pendingCount = 0;
        int unpaidCount = 0;
        double totalMonthlyPaid = 0;

        Map<String, String> paymentStatuses = {};
        Map<String, Map<String, dynamic>> studentPaymentData = {};

        for (int i = 0; i < students.length; i++) {
          final student = students[i];
          final studentId = student.id;

          String status = 'unpaid';
          if (i < paymentData.length) {
            final paymentDoc = paymentData[i];
            if (paymentDoc.exists) {
              final data = paymentDoc.data() as Map<String, dynamic>?;
              if (data != null) {
                status = (data['status'] as String?)?.toLowerCase() ?? 'unpaid';
                studentPaymentData[studentId] = data;
                if (status == 'paid' || status == 'confirmed') {
                  final amount = data['amount'];
                  totalMonthlyPaid += (amount is num) ? amount.toDouble() : 0;
                }
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

        return FutureBuilder<double>(
          future: _calculateYearlyRevenue(),
          builder: (context, yearlySnapshot) {
            final yearlyRevenue = yearlySnapshot.data ?? 0;

            return Column(
              children: [
                // Collapsible Revenue Summary
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => setState(() => _revenueExpanded = !_revenueExpanded),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              Icon(Icons.analytics_outlined, size: 18, color: Colors.grey[700]),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Revenue Summary",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                                ),
                              ),
                              if (!_revenueExpanded) ...[
                                Text(
                                  "RM ${totalMonthlyPaid.toStringAsFixed(0)}",
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Icon(
                                _revenueExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                color: Colors.grey[600],
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_revenueExpanded)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_today, size: 12, color: Colors.blue[700]),
                                              const SizedBox(width: 4),
                                              Text(monthYear, style: TextStyle(fontSize: 10, color: Colors.blue[700])),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text("RM ${totalMonthlyPaid.toStringAsFixed(0)}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[700])),
                                          Text("$paidCount paid", style: TextStyle(fontSize: 9, color: Colors.blue[400])),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_month, size: 12, color: Colors.green[700]),
                                              const SizedBox(width: 4),
                                              Text("${DateTime.now().year}", style: TextStyle(fontSize: 10, color: Colors.green[700])),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text("RM ${yearlyRevenue.toStringAsFixed(0)}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[700])),
                                          Text("Yearly total", style: TextStyle(fontSize: 9, color: Colors.green[400])),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: _buildSummaryCard("Paid", paidCount.toString(), Colors.green, Icons.check_circle)),
                                  const SizedBox(width: 8),
                                  Expanded(child: _buildSummaryCard("Pending", pendingCount.toString(), Colors.orange, Icons.pending_actions)),
                                  const SizedBox(width: 8),
                                  Expanded(child: _buildSummaryCard("Unpaid", unpaidCount.toString(), Colors.red, Icons.warning_amber_rounded)),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

            const SizedBox(height: 16),

            // Student List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _cachedPaymentData = null;
                  });
                },
                color: AppTheme.primaryRed,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final data = student.data() as Map<String, dynamic>;
                    final paymentStatus = paymentStatuses[student.id] ?? 'unpaid';
                    final parentEmail = parentEmails[student.id] ?? 'No Email';
                    final thisStudentPayment = studentPaymentData[student.id];

                    return _buildStudentFeeCard(
                      context,
                      student,
                      data,
                      paymentStatus,
                      parentEmail,
                      monthYear,
                      receiptUrl: thisStudentPayment?['receiptUrl'] as String?,
                      receiptFileName: thisStudentPayment?['receiptFileName'] as String?,
                      receiptType: thisStudentPayment?['receiptType'] as String?,
                      paymentAmount: (thisStudentPayment?['amount'] as num?)?.toDouble(),
                      aiExtractedAmount: (thisStudentPayment?['aiExtractedAmount'] as num?)?.toDouble(),
                      aiExtractedReference: thisStudentPayment?['aiExtractedReference'] as String?,
                      aiExtractedPaymentMethod: thisStudentPayment?['aiExtractedPaymentMethod'] as String?,
                    );
                  },
                ),
              ),
            ),
          ],
        );
        },
      );
      },
    );
  }

  Future<double> _calculateYearlyRevenue() async {
    double total = 0;
    final currentYear = DateTime.now().year;

    for (var student in students) {
      try {
        final paymentsSnapshot = await FirebaseFirestore.instance
            .collection('students')
            .doc(student.id)
            .collection('payments')
            .get();

        for (var paymentDoc in paymentsSnapshot.docs) {
          final data = paymentDoc.data();
          final status = (data['status'] as String?)?.toLowerCase() ?? '';
          if (status == 'paid' || status == 'confirmed') {
            // Check if payment is from current year
            final month = data['month'] as String? ?? '';
            if (month.contains(currentYear.toString())) {
              final amount = data['amount'];
              total += (amount is num) ? amount.toDouble() : 0;
            }
          }
        }
      } catch (e) {
        // Skip on error
      }
    }

    return total;
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
    String monthYear, {
    String? receiptUrl,
    String? receiptFileName,
    String? receiptType,
    double? paymentAmount,
    double? aiExtractedAmount,
    String? aiExtractedReference,
    String? aiExtractedPaymentMethod,
  }) {
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

    final bool hasReceipt = receiptUrl != null && receiptUrl.isNotEmpty;

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
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/student_profile',
                        arguments: {
                          'studentId': studentDoc.id,
                          'studentName': data['name'] ?? 'Unknown',
                          'isParentViewing': false,
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
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
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        data['name'] ?? 'Unknown',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppTheme.darkText,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
                                  ],
                                ),
                                Text(
                                  parentEmail,
                                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Receipt indicator
                if (hasReceipt) ...[
                  InkWell(
                    onTap: () => _showReceiptDialog(context, receiptUrl, receiptFileName, receiptType),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            receiptType?.startsWith('image/') == true
                                ? Icons.image
                                : Icons.picture_as_pdf,
                            color: Colors.blue,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            "Receipt",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
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
            // Show payment amount if available
            if (paymentAmount != null && paymentAmount > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.pitchGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 14, color: AppTheme.pitchGreen),
                    const SizedBox(width: 6),
                    Text(
                      "Amount: RM ${paymentAmount.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: AppTheme.pitchGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    if (paymentStatus == 'pending')
                      InkWell(
                        onTap: () => _showEditAmountDialog(context, studentDoc.id, monthYear, paymentAmount),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppTheme.pitchGreen),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit, size: 12, color: AppTheme.pitchGreen),
                              const SizedBox(width: 4),
                              Text(
                                "Edit",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.pitchGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Show AI-extracted info if available
              if (aiExtractedReference != null || aiExtractedPaymentMethod != null) ...[
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (aiExtractedPaymentMethod != null)
                      _buildAiInfoChip(Icons.payment, aiExtractedPaymentMethod),
                    if (aiExtractedReference != null)
                      _buildAiInfoChip(Icons.tag, aiExtractedReference),
                  ],
                ),
              ],
            ],
            // Show action buttons for pending payments
            if (paymentStatus == 'pending') ...[
              const SizedBox(height: 8),
              _buildPaymentActionButtons(context, studentDoc.id, data['name'] ?? 'Unknown Student', monthYear, hasReceipt: hasReceipt, receiptUrl: receiptUrl, receiptFileName: receiptFileName, receiptType: receiptType),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAiInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.grey[600]),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(fontSize: 9, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  void _showEditAmountDialog(BuildContext context, String studentId, String monthYear, double currentAmount) {
    final controller = TextEditingController(text: currentAmount.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Icon(Icons.edit, color: AppTheme.primaryRed, size: 20),
              const SizedBox(width: 8),
              const Text("Edit Payment Amount", style: TextStyle(fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Amount (RM)",
                  prefixText: "RM ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Update the payment amount if the AI-detected value is incorrect",
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () async {
                final newAmount = double.tryParse(controller.text) ?? currentAmount;
                await FirebaseFirestore.instance
                    .collection('students')
                    .doc(studentId)
                    .collection('payments')
                    .doc(monthYear.replaceAll(' ', '_'))
                    .update({'amount': newAmount});

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Amount updated to RM ${newAmount.toStringAsFixed(2)}"),
                      backgroundColor: AppTheme.pitchGreen,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                foregroundColor: Colors.white,
              ),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showReceiptDialog(BuildContext context, String? receiptUrl, String? fileName, String? fileType) {
    if (receiptUrl == null) return;

    final bool isImage = fileType?.startsWith('image/') == true;
    final bool isPdf = fileType == 'application/pdf';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isImage ? Icons.image : Icons.picture_as_pdf,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Payment Receipt",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (fileName != null)
                            Text(
                              fileName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    // Download button
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.blue),
                      tooltip: "Download Receipt",
                      onPressed: () => _downloadReceipt(receiptUrl, fileName),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // Content
              if (isImage)
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: InteractiveViewer(
                    child: Image.network(
                      receiptUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: AppTheme.primaryRed,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                "Failed to load image",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                )
              else if (isPdf)
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.picture_as_pdf, size: 64, color: Colors.red[400]),
                      const SizedBox(height: 16),
                      const Text(
                        "PDF Receipt",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tap the button below to open the PDF",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushNamed(
                            context,
                            '/pdf_viewer',
                            arguments: {'pdfUrl': receiptUrl, 'title': fileName ?? 'Receipt'},
                          );
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: const Text("Open PDF"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRed,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.insert_drive_file, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text("Receipt uploaded"),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _downloadReceipt(String url, String? fileName) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Could not launch URL: $url");
      }
    } catch (e) {
      debugPrint("Error downloading receipt: $e");
    }
  }

  Widget _buildPaymentActionButtons(
    BuildContext context,
    String studentId,
    String studentName,
    String monthYear, {
    bool hasReceipt = false,
    String? receiptUrl,
    String? receiptFileName,
    String? receiptType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          // View Receipt button if receipt exists
          if (hasReceipt) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showReceiptDialog(context, receiptUrl, receiptFileName, receiptType),
                icon: Icon(
                  receiptType?.startsWith('image/') == true
                      ? Icons.image
                      : Icons.picture_as_pdf,
                  size: 14,
                ),
                label: const Text("View Receipt", style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blue, width: 1),
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _confirmPayment(studentId, monthYear, 'confirmed');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Payment confirmed for $studentName"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
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
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Payment marked as rejected for $studentName"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
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