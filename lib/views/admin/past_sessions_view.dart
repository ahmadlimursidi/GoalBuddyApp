import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme.dart';
import '../../services/firestore_service.dart';
import 'package:intl/intl.dart';

class PastSessionsView extends StatelessWidget {
  const PastSessionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Past Sessions"),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryRed, Color(0xFFC41A1F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Session Archive",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Completed Sessions",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // List Content
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getPastSessions(),
              builder: (context, snapshot) {
                // Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryRed),
                  );
                }

                // Error State
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.grey[700])),
                      ],
                    ),
                  );
                }

                // Empty State
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final sessions = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    final data = session.data() as Map<String, dynamic>;
                    return _buildSessionCard(context, session.id, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, String sessionId, Map<String, dynamic> data) {
    // Format dates
    String formattedDate = 'N/A';
    String formattedTime = 'N/A';

    if (data['startTime'] != null) {
      final timestamp = data['startTime'] as Timestamp;
      final dateTime = timestamp.toDate();
      formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
      formattedTime = DateFormat('h:mm a').format(dateTime);
    }

    String archivedDate = 'N/A';
    if (data['archivedAt'] != null) {
      final timestamp = data['archivedAt'] as Timestamp;
      final dateTime = timestamp.toDate();
      archivedDate = DateFormat('MMM dd, yyyy').format(dateTime);
    }

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            _showSessionDetails(context, sessionId, data);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.pitchGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.check_circle, color: AppTheme.pitchGreen, size: 24),
                    ),
                    const SizedBox(width: 16),
                    // Title & Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['className'] ?? 'Untitled Session',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkText,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    formattedTime,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Completed Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.pitchGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'COMPLETED',
                        style: TextStyle(
                          color: AppTheme.pitchGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 16),
                // Metadata Row
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      icon: Icons.location_on,
                      label: data['venue'] ?? 'Unknown Venue',
                      color: Colors.blue,
                    ),
                    _buildInfoChip(
                      icon: Icons.child_care,
                      label: data['ageGroup'] ?? 'All Ages',
                      color: AppTheme.pitchGreen,
                    ),
                    if (data['badgeFocus'] != null)
                      _buildInfoChip(
                        icon: Icons.emoji_events,
                        label: data['badgeFocus'],
                        color: Colors.orange,
                      ),
                    _buildInfoChip(
                      icon: Icons.archive,
                      label: 'Archived $archivedDate',
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
              ],
            ),
            child: Icon(Icons.archive, size: 48, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            'No archived sessions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Completed sessions will appear here',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _showSessionDetails(BuildContext context, String sessionId, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        // Format dates
        String formattedDate = 'N/A';
        String formattedTime = 'N/A';

        if (data['startTime'] != null) {
          final timestamp = data['startTime'] as Timestamp;
          final dateTime = timestamp.toDate();
          formattedDate = DateFormat('EEEE, MMM dd, yyyy').format(dateTime);
          formattedTime = DateFormat('h:mm a').format(dateTime);
        }

        String completedDate = 'N/A';
        if (data['completedAt'] != null) {
          final timestamp = data['completedAt'] as Timestamp;
          final dateTime = timestamp.toDate();
          completedDate = DateFormat('MMM dd, yyyy h:mm a').format(dateTime);
        }

        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5)),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.pitchGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.check_circle, color: AppTheme.pitchGreen, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Session Details',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  data['className'] ?? 'Untitled Session',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.darkText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Details
                      _buildDetailRow(Icons.calendar_today, 'Date', formattedDate),
                      _buildDetailRow(Icons.access_time, 'Time', formattedTime),
                      _buildDetailRow(Icons.location_on, 'Venue', data['venue'] ?? 'Unknown'),
                      _buildDetailRow(Icons.child_care, 'Age Group', data['ageGroup'] ?? 'N/A'),
                      if (data['badgeFocus'] != null)
                        _buildDetailRow(Icons.emoji_events, 'Badge Focus', data['badgeFocus']),
                      _buildDetailRow(Icons.check_circle_outline, 'Completed', completedDate),
                      _buildCoachInfoRow(data), // Add coach information

                      const SizedBox(height: 24),

                      // Attendance Section
                      const Text(
                        'Attendance',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildAttendanceForSession(sessionId),

                      const SizedBox(height: 24),

                      // Close Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryRed,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text('Close', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachInfoRow(Map<String, dynamic> data) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(data['coachId']).get(),
      builder: (context, coachSnapshot) {
        String coachName = 'Unknown Coach';
        if (coachSnapshot.hasData && coachSnapshot.data!.exists) {
          final coachData = coachSnapshot.data!.data() as Map<String, dynamic>?;
          coachName = coachData?['name'] ?? 'Coach ID: ${data['coachId']}';
        } else if (data['coachId'] != null) {
          coachName = 'Coach ID: ${data['coachId']}';
        }

        Widget? assistantCoachWidget;
        if (data['assistantCoachId'] != null) {
          assistantCoachWidget = FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(data['assistantCoachId']).get(),
            builder: (context, assistantSnapshot) {
              String assistantCoachName = 'Assistant Coach';
              if (assistantSnapshot.hasData && assistantSnapshot.data!.exists) {
                final assistantData = assistantSnapshot.data!.data() as Map<String, dynamic>?;
                assistantCoachName = assistantData?['name'] ?? 'Assistant ID: ${data['assistantCoachId']}';
              } else {
                assistantCoachName = 'Assistant ID: ${data['assistantCoachId']}';
              }

              return _buildDetailRow(Icons.person_outline, 'Assistant Coach', assistantCoachName);
            },
          );
        }

        return Column(
          children: [
            _buildDetailRow(Icons.person, 'Lead Coach', coachName),
            if (assistantCoachWidget != null) assistantCoachWidget,
          ],
        );
      },
    );
  }

  Widget _buildAttendanceForSession(String sessionId) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('pastSessions')
          .doc(sessionId)
          .collection('students')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryRed),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Text(
              'Error loading attendance',
              style: TextStyle(color: Colors.red[700]),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.people_outline, size: 32, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'No attendance recorded',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }

        final students = snapshot.data!.docs;
        final presentCount = students.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['isPresent'] == true;
        }).length;
        final totalCount = students.length;

        return Column(
          children: [
            // Summary Row
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryRed.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttendanceStat('Total', totalCount.toString(), Icons.people, Colors.blue),
                  Container(width: 1, height: 30, color: Colors.grey[300]),
                  _buildAttendanceStat('Present', presentCount.toString(), Icons.check_circle, AppTheme.pitchGreen),
                  Container(width: 1, height: 30, color: Colors.grey[300]),
                  _buildAttendanceStat('Absent', (totalCount - presentCount).toString(), Icons.cancel, Colors.red),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Student List
            Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: students.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
                itemBuilder: (context, index) {
                  final studentDoc = students[index];
                  final data = studentDoc.data() as Map<String, dynamic>;
                  final isPresent = data['isPresent'] ?? false;
                  final studentName = data['name'] ?? 'Unknown';

                  return ListTile(
                    dense: true,
                    leading: Icon(
                      isPresent ? Icons.check_circle : Icons.cancel,
                      color: isPresent ? AppTheme.pitchGreen : Colors.red,
                      size: 20,
                    ),
                    title: Text(
                      studentName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkText,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPresent
                            ? AppTheme.pitchGreen.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isPresent ? 'P' : 'A',
                        style: TextStyle(
                          color: isPresent ? AppTheme.pitchGreen : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
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
    );
  }

  Widget _buildAttendanceStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
