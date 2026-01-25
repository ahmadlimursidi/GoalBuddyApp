import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../view_models/dashboard_view_model.dart';
import '../../view_models/auth_view_model.dart';
import '../../services/firestore_service.dart';
import '../resources/drill_library_view.dart';
import '../coach/coach_profile_view.dart';

class CoachDashboardView extends StatefulWidget {
  const CoachDashboardView({super.key});

  @override
  State<CoachDashboardView> createState() => _CoachDashboardViewState();
}

class _CoachDashboardViewState extends State<CoachDashboardView> {
  // Light blue color for assistant coach sessions
  static const Color assistantBlue = Color(0xFF42A5F5);
  final FirestoreService _firestoreService = FirestoreService();

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
            builder: (context, leadSnapshot) {
              // Also listen to assistant sessions
              return StreamBuilder<QuerySnapshot>(
                stream: viewModel.assistantSessionsStream,
                builder: (context, assistantSnapshot) {

              if (leadSnapshot.hasError) {
                return Center(child: Text("Error: ${leadSnapshot.error}"));
              }

              if (assistantSnapshot.hasError) {
                print('DEBUG: Assistant snapshot error: ${assistantSnapshot.error}');
              }

              if (leadSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
              }

              // Debug connection states
              print('DEBUG: Lead snapshot state: ${leadSnapshot.connectionState}');
              print('DEBUG: Assistant snapshot state: ${assistantSnapshot.connectionState}');

              final leadDocs = leadSnapshot.data?.docs ?? [];
              final assistantDocs = assistantSnapshot.data?.docs ?? [];

              // Debug logging
              print('DEBUG: Lead coach sessions count: ${leadDocs.length}');
              print('DEBUG: Assistant coach sessions count: ${assistantDocs.length}');
              print('DEBUG: Current user ID: ${viewModel.currentUserId}');

              for (var doc in assistantDocs) {
                final data = doc.data() as Map<String, dynamic>;
                print('DEBUG: Assistant session - ID: ${doc.id}, assistantCoachId: ${data['assistantCoachId']}, className: ${data['className']}');
              }

              // Combine and deduplicate sessions (in case same session appears in both)
              final Map<String, MapEntry<DocumentSnapshot, bool>> sessionMap = {};
              for (var doc in leadDocs) {
                sessionMap[doc.id] = MapEntry(doc, false); // false = lead coach
              }
              for (var doc in assistantDocs) {
                if (!sessionMap.containsKey(doc.id)) {
                  sessionMap[doc.id] = MapEntry(doc, true); // true = assistant coach
                }
              }

              final allSessions = sessionMap.values.toList();

              // Sort by start time
              allSessions.sort((a, b) {
                final aData = a.key.data() as Map<String, dynamic>;
                final bData = b.key.data() as Map<String, dynamic>;
                final aTime = aData['startTime'] as Timestamp?;
                final bTime = bData['startTime'] as Timestamp?;
                if (aTime == null && bTime == null) return 0;
                if (aTime == null) return 1;
                if (bTime == null) return -1;
                return aTime.compareTo(bTime);
              });

              // Count only upcoming (non-completed) sessions
              final upcomingCount = allSessions.where((entry) {
                final data = entry.key.data() as Map<String, dynamic>;
                final status = (data['status'] ?? '').toString().toUpperCase();
                return status != 'COMPLETED';
              }).length;

          return RefreshIndicator(
            onRefresh: () async {
              viewModel.refreshDashboard();
            },
            color: AppTheme.primaryRed,
            child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const CoachProfileView(),
                                          ),
                                        );
                                      },
                                      child: CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Colors.white,
                                        child: Text(initial, style: const TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold, fontSize: 20)),
                                      ),
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
                                    "$upcomingCount Upcoming ${upcomingCount == 1 ? 'Class' : 'Classes'}",
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
              if (allSessions.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverToBoxAdapter(child: _buildEmptyState(context)),
                ),

              if (allSessions.isNotEmpty) ...[
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
                      (context, index) {
                        final entry = allSessions[index];
                        final doc = entry.key;
                        final isAssistant = entry.value;
                        return _buildClassCard(context, doc, isAssistant: isAssistant);
                      },
                      childCount: allSessions.length,
                    ),
                  ),
                ),
              ],

              // Quick Actions - Always visible regardless of schedule
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
                      icon: Icons.person,
                      title: "My\nProfile",
                      color: Colors.teal,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CoachProfileView(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
          );
                },
              );
        },
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

  Widget _buildClassCard(BuildContext context, DocumentSnapshot doc, {bool isAssistant = false}) {
    final data = doc.data() as Map<String, dynamic>;
    final startTime = data['startTime'] as Timestamp?;
    final now = Timestamp.now();
    final status = (data['status'] ?? '').toString().toUpperCase();

    // Light blue color for assistant coach sessions
    final Color accentColor = isAssistant ? assistantBlue : AppTheme.primaryRed;

    // Logic for Highlighting "Next" Class
    bool isNext = false;
    bool isPast = false;
    bool isCompleted = status == 'COMPLETED';

    if (startTime != null) {
      final classDate = startTime.toDate();
      final nowDate = now.toDate();
      isPast = classDate.isBefore(nowDate);
      // Simple logic: if not past and not completed, consider it upcoming/next
      if (!isPast && !isCompleted) isNext = true;
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
        border: Border.all(
          color: isAssistant
              ? assistantBlue.withOpacity(0.3)
              : AppTheme.primaryRed.withOpacity(0.3),
          width: 2,
        ),
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
                        color: isCompleted
                            ? AppTheme.pitchGreen.withOpacity(0.15)
                            : isNext
                                ? (isAssistant ? assistantBlue.withOpacity(0.1) : AppTheme.pitchGreen.withOpacity(0.1))
                                : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            dayString,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isCompleted ? AppTheme.pitchGreen : (isNext ? (isAssistant ? assistantBlue : AppTheme.pitchGreen) : Colors.grey),
                            ),
                          ),
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
                          // Role badge row
                          Row(
                            children: [
                              if (isCompleted)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  margin: const EdgeInsets.only(bottom: 6, right: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.pitchGreen,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text("COMPLETED", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                )
                              else if (isNext)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  margin: const EdgeInsets.only(bottom: 6, right: 6),
                                  decoration: BoxDecoration(
                                    color: isAssistant ? assistantBlue : AppTheme.pitchGreen,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text("UPCOMING", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              // Role badge - LEAD or ASSISTANT
                              if (isAssistant)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  margin: const EdgeInsets.only(bottom: 6),
                                  decoration: BoxDecoration(
                                    color: assistantBlue.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: assistantBlue.withOpacity(0.5)),
                                  ),
                                  child: Text("ASSISTANT", style: TextStyle(color: assistantBlue, fontSize: 10, fontWeight: FontWeight.bold)),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  margin: const EdgeInsets.only(bottom: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryRed.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppTheme.primaryRed.withOpacity(0.5)),
                                  ),
                                  child: const Text("LEAD", style: TextStyle(color: AppTheme.primaryRed, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                            ],
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
                    _buildInfoChip(Icons.access_time_filled_rounded, timeString, isCompleted ? AppTheme.pitchGreen : isNext ? accentColor : Colors.grey),
                    _buildInfoChip(Icons.location_on_rounded, data['venue'] ?? 'Unknown', Colors.grey),

                    // Action Arrow / Checkmark
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppTheme.pitchGreen
                            : isNext
                                ? accentColor
                                : Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check_circle_rounded
                            : isNext
                                ? Icons.play_arrow_rounded
                                : Icons.chevron_right_rounded,
                        color: isCompleted || isNext ? Colors.white : Colors.grey,
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