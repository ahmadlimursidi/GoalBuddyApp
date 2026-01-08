import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../view_models/dashboard_view_model.dart';
import '../../view_models/auth_view_model.dart';
import '../resources/drill_library_view.dart';

class CoachDashboardView extends StatefulWidget {
  const CoachDashboardView({super.key});

  @override
  State<CoachDashboardView> createState() => _CoachDashboardViewState();
}

class _CoachDashboardViewState extends State<CoachDashboardView> {
  @override
  void initState() {
    super.initState();
    // Refresh dashboard data when the view is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<DashboardViewModel>(context, listen: false);
      viewModel.refreshDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access the ViewModel
    final viewModel = Provider.of<DashboardViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      body: viewModel.sessionsStream == null
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed))
        : StreamBuilder<QuerySnapshot>(
            stream: viewModel.sessionsStream,
            builder: (context, snapshot) {

              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
              }

              final docs = snapshot.data?.docs ?? [];
              final classCount = docs.length;

          return CustomScrollView(
            slivers: [
              // 1. Modern Sliver App Bar Header
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: AppTheme.primaryRed,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      // Gradient Background
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.primaryRed, Color(0xFFC41A1F)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      // Decorative Circles
                      Positioned(
                        right: -30,
                        top: -30,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      Positioned(
                        left: -20,
                        bottom: -40,
                        child: CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      // Content inside Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 80, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<String>(
                              future: authViewModel.getCurrentUserName(),
                              builder: (context, nameSnapshot) {
                                final coachName = nameSnapshot.data ?? 'Coach';
                                final initial = coachName.isNotEmpty ? coachName[0].toUpperCase() : 'C';

                                return Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.white,
                                      child: Text(initial, style: const TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold, fontSize: 20)),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Welcome back,",
                                          style: TextStyle(color: Colors.white70, fontSize: 14),
                                        ),
                                        Text(
                                          "Coach $coachName",
                                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.calendar_today, color: Colors.white, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    "$classCount Upcoming ${classCount == 1 ? 'Class' : 'Classes'}",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () async {
                      await authViewModel.logout();
                      // After logout, clear dashboard data
                      viewModel.refreshDashboard();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                      }
                    },
                  ),
                ],
              ),

              // 2. Body Content
              if (docs.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverToBoxAdapter(child: _buildEmptyState(context)),
                ),

              if (docs.isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  sliver: const SliverToBoxAdapter(
                    child: Text(
                      "Your Schedule",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildClassCard(context, docs[index]),
                      childCount: docs.length,
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 24, bottom: 16),
                      child: Text(
                        "Quick Actions",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                      ),
                    ),
                  ),
                ),

                // 3. Grid for Quick Actions
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.3,
                    children: [
                      _buildActionCard(
                        icon: Icons.sports_soccer,
                        title: "Browse\nDrills",
                        color: Colors.blueAccent,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DrillLibraryView())),
                      ),
                      _buildActionCard(
                        icon: Icons.checklist,
                        title: "Student\nList",
                        color: Colors.orange,
                        onTap: () => Navigator.pushNamed(context, '/student_list'),
                      ),
                      _buildActionCard(
                        icon: Icons.school,
                        title: "Coach\nResources",
                        color: Colors.purple,
                        onTap: () => Navigator.pushNamed(context, '/coach_resources'),
                      ),
                      _buildActionCard(
                        icon: Icons.settings,
                        title: "My\nSettings",
                        color: Colors.grey,
                        onTap: () {}, // Placeholder
                      ),
                    ],
                  ),
                ),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ],
          );
        },
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
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
          selectedItemColor: AppTheme.primaryRed,
          unselectedItemColor: Colors.grey[400],
          currentIndex: 0,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          onTap: (index) {
            if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (context) => const DrillLibraryView()));
            if (index == 2) Navigator.pushNamed(context, '/student_list');
            if (index == 3) Navigator.pushNamed(context, '/coach_resources');
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: "Schedule"),
            BottomNavigationBarItem(icon: Icon(Icons.sports_soccer_rounded), label: "Drills"),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: "Students"),
            BottomNavigationBarItem(icon: Icon(Icons.school_rounded), label: "Resources"),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.event_busy_rounded, size: 60, color: Colors.grey[400]),
          ),
          const SizedBox(height: 20),
          Text(
            "No classes assigned",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),
          Text(
            "Looks like you have a free day!\nContact admin if this is a mistake.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final startTime = data['startTime'] as Timestamp?;
    final now = Timestamp.now();
    
    // Logic for Highlighting "Next" Class
    bool isNext = false;
    bool isPast = false;
    
    if (startTime != null) {
      final classDate = startTime.toDate();
      final nowDate = now.toDate();
      isPast = classDate.isBefore(nowDate);
      // Simple logic: if not past, consider it upcoming/next
      if (!isPast) isNext = true; 
    }

    String timeString = "00:00";
    String dateString = "Unknown";
    String dayString = "";

    if (startTime != null) {
      final dt = startTime.toDate();
      timeString = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      dateString = DateFormat('MMM d').format(dt);
      dayString = DateFormat('EEE').format(dt).toUpperCase();
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
          onTap: () => Navigator.pushNamed(context, '/active_session', arguments: {'sessionId': doc.id}),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Column
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isNext ? AppTheme.pitchGreen.withOpacity(0.1) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(dayString, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isNext ? AppTheme.pitchGreen : Colors.grey)),
                          const SizedBox(height: 4),
                          Text(dateString, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Content Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isNext)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              margin: const EdgeInsets.only(bottom: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.pitchGreen,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text("UPCOMING", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          Text(
                            data['className'] ?? 'Unknown Class',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.group_outlined, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(data['ageGroup'] ?? 'All Ages', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                            ],
                          ),
                        ],
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
                    _buildInfoChip(Icons.access_time_filled_rounded, timeString, isNext ? AppTheme.primaryRed : Colors.grey),
                    _buildInfoChip(Icons.location_on_rounded, data['venue'] ?? 'Unknown', Colors.grey),
                    
                    // Action Arrow
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isNext ? AppTheme.primaryRed : Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isNext ? Icons.play_arrow_rounded : Icons.chevron_right_rounded,
                        color: isNext ? Colors.white : Colors.grey,
                        size: 20,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
}