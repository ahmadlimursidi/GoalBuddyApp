import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goalbuddy/utils/database_seeder.dart'; // Import the Seeder
import '../../config/theme.dart';
import '../../view_models/dashboard_view_model.dart';
import '../../view_models/auth_view_model.dart';

class CoachDashboardView extends StatelessWidget {
  const CoachDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the ViewModel
    final viewModel = Provider.of<DashboardViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);

    // DEBUG: Confirm this widget is rebuilding
    debugPrint("Building CoachDashboardView...");

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Schedule"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authViewModel.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
          const CircleAvatar(
            backgroundColor: AppTheme.primaryRed,
            child: Text("C", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),

      // --- THE BIG SEED DB BUTTON ---
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange,
        onPressed: () {
          // Trigger the Database Seeder
          DatabaseSeeder().seedData(context);
        },
        label: const Text("Seed DB"),
        icon: const Icon(Icons.cloud_upload),
      ),
      // ---------------------------------

      body: StreamBuilder<QuerySnapshot>(
        stream: viewModel.sessionsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No classes found for today."),
                  SizedBox(height: 8),
                  Text("Click the orange button to generate test data!", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // We have data!
          final docs = snapshot.data!.docs;

          // Find the "next" class (closest upcoming)
          final now = Timestamp.now();
          var nextClassDoc = docs.first;
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final startTime = data['startTime'] as Timestamp?;
            final status = data['status'] as String?;

            // Consider "Live Now" or upcoming classes with start time after now
            if (status == 'Live Now') {
              nextClassDoc = doc;
              break;
            }
            if (startTime != null && startTime.compareTo(now) > 0) {
              nextClassDoc = doc;
              break;
            }
          }

          final nextClassData = nextClassDoc.data() as Map<String, dynamic>;
          final nextClassId = nextClassDoc.id;

          // Format time for display
          String timeString = "00:00";
          if (nextClassData['startTime'] != null) {
            final dt = (nextClassData['startTime'] as Timestamp).toDate();
            timeString = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
          }

          // We have data!
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryRed, Color(0xFFC41A1F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.sports_soccer, size: 60, color: Colors.white),
                      const SizedBox(height: 16),
                      const Text(
                        "Welcome back, Coach!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "You have ${docs.length} classes today.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Next Class Card (Prominent) - Moved to be first
                Text(
                  "Next Class",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),

                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: AppTheme.pitchGreen.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.pitchGreen.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nextClassData['className'] ?? 'Unknown Class',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${nextClassData['venue'] ?? 'Unknown Venue'} • ${nextClassData['ageGroup'] ?? 'All Ages'}",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.pitchGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    timeString,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.pitchGreen,
                                    ),
                                  ),
                                  Text(
                                    ((nextClassData['startTime'] as Timestamp?)?.toDate().hour ?? 0) < 12 ? 'AM' : 'PM',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.pitchGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Status Indicator
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.pitchGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.radio_button_checked, size: 16, color: AppTheme.pitchGreen),
                                  const SizedBox(width: 4),
                                  Text(
                                    "UPCOMING",
                                    style: TextStyle(
                                      color: AppTheme.pitchGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Big "Start Session" Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Navigate to Active Session View with sessionId
                              Navigator.pushNamed(context, '/active_session', arguments: {
                                'sessionId': nextClassId,
                              });
                            },
                            icon: const Icon(Icons.play_arrow, color: Colors.white),
                            label: const Text(
                              "Start Session",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.pitchGreen,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Stats - Now comes after Next Class
                Text(
                  "Quick Stats",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),

                // Stats Grid (2x2) - Dynamic height to prevent overflow
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // Important: Disable scrolling for GridView inside SingleChildScrollView
                  childAspectRatio: 1.6, // Make them wider and shorter to prevent overflow
                  children: [
                    _buildStatCard(
                      context,
                      "Classes Today",
                      docs.length.toString(),
                      Icons.event,
                      Colors.blue
                    ),
                    _buildStatCard(
                      context,
                      "Active Students",
                      (docs.length * 8).toString(), // Estimate ~8 per class
                      Icons.people,
                      Colors.green
                    ),
                    _buildStatCard(
                      context,
                      "Avg Attendance",
                      "78%", // Placeholder
                      Icons.bar_chart,
                      Colors.orange
                    ),
                    _buildStatCard(
                      context,
                      "Completion Rate",
                      "92%", // Placeholder
                      Icons.check_circle,
                      Colors.purple
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Quick Actions
                Text(
                  "Quick Actions",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 16),

                _buildActionRow(
                  icon: Icons.checklist,
                  title: "Take Attendance",
                  onTap: () {
                    // Navigate to attendance if we have sessions
                    if (docs.isNotEmpty) {
                      Navigator.pushNamed(context, '/attendance', arguments: {
                        'sessionId': docs.first.id,
                      });
                    }
                  },
                ),
                _buildActionRow(
                  icon: Icons.sports_soccer,
                  title: "Browse Drills",
                  onTap: () {
                    Navigator.pushNamed(context, '/drills_list');
                  },
                ),
              ],
            ),
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppTheme.primaryRed,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) Navigator.pushNamed(context, '/drills_list');
          if (index == 2) Navigator.pushNamed(context, '/student_list');
          if (index == 3) Navigator.pushNamed(context, '/coach_resources');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Schedule"),
          BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: "Drills"),
          BottomNavigationBarItem(icon: Icon(Icons.checklist), label: "Student List"),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Resources"),
        ],
      ),
    );
  }

  Widget _buildActionRow({required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryRed),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // Helper method to build compact stat cards - Fixed overflow issue
  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(10), // Reduced padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6), // Reduced padding
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color), // Smaller icon
            ),
            const SizedBox(height: 6), // Reduced space
            Text(
              value,
              style: TextStyle(
                fontSize: 16, // Smaller font size
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2), // Reduced space
            Text(
              title,
              style: const TextStyle(
                fontSize: 10, // Smaller title font
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}