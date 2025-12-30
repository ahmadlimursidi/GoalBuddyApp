import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/theme.dart';

class ClassPerformanceAnalyticsWidget extends StatefulWidget {
  final String? coachId; // If null, show all classes in the branch
  final String? classAgeGroup; // If specified, filter by age group

  const ClassPerformanceAnalyticsWidget({
    super.key,
    this.coachId,
    this.classAgeGroup,
  });

  @override
  State<ClassPerformanceAnalyticsWidget> createState() =>
      _ClassPerformanceAnalyticsWidgetState();
}

class _ClassPerformanceAnalyticsWidgetState
    extends State<ClassPerformanceAnalyticsWidget> {
  late Future<Map<String, dynamic>> _analyticsData;

  @override
  void initState() {
    super.initState();
    _analyticsData = _fetchAnalyticsData();
  }

  Future<Map<String, dynamic>> _fetchAnalyticsData() async {
    try {
      Query query = FirebaseFirestore.instance.collection('sessions');

      // Apply filters if provided
      if (widget.coachId != null) {
        query = query.where('coachId', isEqualTo: widget.coachId);
      }
      
      if (widget.classAgeGroup != null) {
        query = query.where('ageGroup', isEqualTo: widget.classAgeGroup);
      }

      QuerySnapshot sessionSnapshot = await query.get();
      
      int totalSessions = sessionSnapshot.docs.length;
      int totalStudents = 0;
      int totalAttendance = 0;
      int completedSessions = 0;
      Map<String, int> ageGroupCounts = {};
      Map<String, double> overallAttendance = {};

      if (totalSessions > 0) {
        for (var sessionDoc in sessionSnapshot.docs) {
          var sessionData = sessionDoc.data() as Map<String, dynamic>;
          String ageGroup = sessionData['ageGroup'] ?? 'Unknown';
          
          // Count age groups
          ageGroupCounts[ageGroup] = (ageGroupCounts[ageGroup] ?? 0) + 1;
          
          // Count completed sessions
          if (sessionData['status'] == 'Completed') {
            completedSessions++;
          }
          
          // Get student attendance data for this session
          QuerySnapshot studentSnapshot = 
              await sessionDoc.reference.collection('students').get();
          
          totalStudents += studentSnapshot.docs.length;
          
          for (var studentDoc in studentSnapshot.docs) {
            var studentData = studentDoc.data() as Map<String, dynamic>;
            if (studentData['isPresent'] == true) {
              totalAttendance++;
            }
          }
        }
        
        // Calculate overall attendance rate
        if (totalStudents > 0) {
          overallAttendance['rate'] = (totalAttendance / totalStudents) * 100;
        }
      }

      return {
        'totalSessions': totalSessions,
        'totalStudents': totalStudents,
        'totalAttendance': totalAttendance,
        'completedSessions': completedSessions,
        'ageGroupCounts': ageGroupCounts,
        'overallAttendance': overallAttendance,
      };
    } catch (e) {
      print("Error fetching analytics: $e");
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _analyticsData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Text("Error loading analytics"),
                ),
              );
            }

            var data = snapshot.data!;
            int totalSessions = data['totalSessions'] ?? 0;
            int totalStudents = data['totalStudents'] ?? 0;
            int totalAttendance = data['totalAttendance'] ?? 0;
            int completedSessions = data['completedSessions'] ?? 0;
            Map<String, int> ageGroupCounts = data['ageGroupCounts'] ?? {};
            double overallAttendanceRate = data['overallAttendance']?['rate']?.toDouble() ?? 0.0;

            return SingleChildScrollView( // Make it scrollable if needed
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.leaderboard,
                        color: AppTheme.primaryRed,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Class Performance",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Key metrics
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricCard(
                        "Sessions",
                        totalSessions.toString(),
                        Icons.event
                      ),
                      _buildMetricCard(
                        "Students",
                        totalStudents.toString(),
                        Icons.people
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricCard(
                        "Completed",
                        completedSessions.toString(),
                        Icons.check_circle
                      ),
                      _buildMetricCard(
                        "Attendance",
                        "${overallAttendanceRate.toStringAsFixed(1)}%",
                        Icons.bar_chart
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Age group distribution
                  if (ageGroupCounts.isNotEmpty) ...[
                    const Text(
                      "Age Group Distribution",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...ageGroupCounts.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                entry.key,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: LinearProgressIndicator(
                                value: totalSessions > 0
                                    ? entry.value / totalSessions
                                    : 0,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryRed),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              entry.value.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 16),

                  // Performance insights
                  const Text(
                    "Performance Insights",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInsightCard(
                    "Completion Rate",
                    "${totalSessions > 0 ? ((completedSessions / totalSessions) * 100).toStringAsFixed(1) : '0.0'}%",
                    completedSessions / totalSessions >= 0.8
                        ? Colors.green
                        : completedSessions / totalSessions >= 0.6
                            ? Colors.orange
                            : Colors.red,
                  ),
                  const SizedBox(height: 8),
                  _buildInsightCard(
                    "Student Engagement",
                    "${totalStudents > 0 ? ((totalAttendance / totalStudents) * 100).toStringAsFixed(1) : '0.0'}%",
                    overallAttendanceRate >= 80
                        ? Colors.green
                        : overallAttendanceRate >= 60
                            ? Colors.orange
                            : Colors.red,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryRed, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.insights, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(title),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}