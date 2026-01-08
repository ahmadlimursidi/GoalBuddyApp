import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../view_models/auth_view_model.dart';
import '../../services/firestore_service.dart';

class ClassDetailsView extends StatefulWidget {
  final String classId;
  final Map<String, dynamic> classData;

  const ClassDetailsView({
    Key? key,
    required this.classId,
    required this.classData,
  }) : super(key: key);

  @override
  State<ClassDetailsView> createState() => _ClassDetailsViewState();
}

class _ClassDetailsViewState extends State<ClassDetailsView> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    // Format Data
    final timestamp = widget.classData['startTime'] as Timestamp?;
    final classDateTime = timestamp?.toDate() ?? DateTime.now();
    final formattedDate = DateFormat('EEEE, MMM d, yyyy').format(classDateTime);
    final formattedTime = DateFormat('h:mm a').format(classDateTime);
    
    int durationMinutes = widget.classData['durationMinutes'] ?? 0;
    String durationText = durationMinutes > 0 ? '$durationMinutes mins' : 'N/A';
    String status = widget.classData['status'] ?? 'Scheduled';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      body: CustomScrollView(
        slivers: [
          // 1. Modern Sliver App Bar
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryRed,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  authViewModel.logout();
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
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
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.classData['className'] ?? 'Class Details',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Content Body
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Section: Logistics
                _buildSectionTitle("Logistics & Timing"),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: _cardDecoration(),
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.calendar_today, "Date", formattedDate, Colors.blue),
                      const Divider(height: 24),
                      _buildInfoRow(Icons.access_time, "Time", formattedTime, Colors.orange),
                      const Divider(height: 24),
                      _buildInfoRow(Icons.timer, "Duration", durationText, Colors.purple),
                      const Divider(height: 24),
                      _buildInfoRow(Icons.location_on, "Venue", widget.classData['venue'] ?? 'N/A', AppTheme.primaryRed),
                    ],
                  ),
                ),

                // Section: Group Info
                const SizedBox(height: 24),
                _buildSectionTitle("Group Information"),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: _cardDecoration(),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildBadgeInfo(
                          Icons.people,
                          "Age Group",
                          widget.classData['ageGroup'] ?? 'N/A',
                          AppTheme.pitchGreen,
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      Expanded(
                        child: _buildBadgeInfo(
                          Icons.flag,
                          "Badge Focus",
                          widget.classData['badgeFocus'] ?? 'N/A',
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),

                // Section: Staff
                const SizedBox(height: 24),
                _buildSectionTitle("Coaching Team"),
                Column(
                  children: [
                    _buildCoachCard(
                      "Lead Coach",
                      widget.classData['coachId'] ?? widget.classData['leadCoachId'],
                      true,
                    ),
                    const SizedBox(height: 12),
                    _buildCoachCard(
                      "Assistant Coach",
                      widget.classData['assistantCoachId'],
                      false,
                    ),
                  ],
                ),

                // Section: Additional Info
                if (widget.classData['instructions'] != null ||
                    widget.classData['equipment'] != null ||
                    widget.classData['learningGoals'] != null) ...[
                  const SizedBox(height: 24),
                  _buildSectionTitle("Curriculum Details"),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.classData['instructions'] != null)
                          _buildDetailBlock("Instructions", widget.classData['instructions']),
                        if (widget.classData['equipment'] != null)
                          _buildDetailBlock("Equipment", widget.classData['equipment']),
                        if (widget.classData['learningGoals'] != null)
                          _buildDetailBlock("Learning Goals", widget.classData['learningGoals'], isLast: true),
                      ],
                    ),
                  ),
                ],

                // Bottom Padding
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.darkText,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppTheme.darkText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadgeInfo(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppTheme.darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildCoachCard(String role, String? coachId, bool isLead) {
    if (coachId == null) {
      if (!isLead) return const SizedBox.shrink(); // Don't show empty assistant card
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: Colors.grey[200], child: const Icon(Icons.person, color: Colors.grey)),
            const SizedBox(width: 16),
            Text("No $role Assigned", style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: _firestoreService.getCoachById(coachId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(height: 80, decoration: _cardDecoration(), child: const Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Text("$role info unavailable"),
          );
        }

        final coachData = snapshot.data!.data() as Map<String, dynamic>;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: isLead ? AppTheme.primaryRed : Colors.blue,
                child: Text(
                  coachData['name'] != null ? coachData['name'][0].toUpperCase() : 'C',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role,
                      style: TextStyle(
                        color: isLead ? AppTheme.primaryRed : Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      coachData['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.darkText,
                      ),
                    ),
                    if (coachData['phone'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.phone, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              coachData['phone'],
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailBlock(String title, String content, {bool isLast = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppTheme.primaryRed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(color: Colors.grey[700], height: 1.5),
        ),
        if (!isLast) const Divider(height: 32),
      ],
    );
  }
}