import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../view_models/student_parent_view_model.dart';
import '../../models/drill_data.dart';
import '../admin/session_template_details_view.dart';

class ParentScheduleView extends StatefulWidget {
  const ParentScheduleView({super.key});

  @override
  State<ParentScheduleView> createState() => _ParentScheduleViewState();
}

class _ParentScheduleViewState extends State<ParentScheduleView> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StudentParentViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Upcoming Classes"),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => viewModel.refreshData(),
        child: Consumer<StudentParentViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
            }

            // Get the child's age group to filter sessions
            String? childAgeGroup = viewModel.ageGroup;
            
            if (childAgeGroup == null || childAgeGroup.isEmpty || childAgeGroup == 'Unknown') {
              // If no age group is available, try to calculate from DOB
              if (viewModel.childDob != null) {
                double childAge = DateTime.now().difference(viewModel.childDob!).inDays / 365.25;
                
                if (childAge >= 1 && childAge < 2.5) {
                  childAgeGroup = 'Little Kicks';
                } else if (childAge >= 2.5 && childAge < 3.5) {
                  childAgeGroup = 'Junior Kickers';
                } else if (childAge >= 3.5 && childAge < 5.0) {
                  childAgeGroup = 'Mighty Kickers';
                } else if (childAge >= 5.0 && childAge <= 8.0) {
                  childAgeGroup = 'Mega Kickers';
                } else {
                  childAgeGroup = 'Unknown';
                }
              }
            }

            // If still no age group, try to get it from the registered classes
            if ((childAgeGroup == null || childAgeGroup == 'Unknown') && viewModel.registeredClasses.isNotEmpty) {
              // Get the age group from the first registered class
              childAgeGroup = viewModel.registeredClasses.first['ageGroup'] as String?;
            }

            if (childAgeGroup == null || childAgeGroup == 'Unknown') {
              return const Center(
                child: Text(
                  "Age group not found.\nPlease contact admin.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            // Query sessions collection filtered by the child's age group
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('sessions')  // Main sessions collection
                  .where('ageGroup', isEqualTo: childAgeGroup)
                  .orderBy('startTime', descending: false) // Order from earliest to latest
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final docs = snapshot.data?.docs ?? [];
                
                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No upcoming classes found for your age group.\nCheck back later!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    
                    final startTime = data['startTime'] as Timestamp?;
                    final now = Timestamp.now();

                    // Determine if class is upcoming or past
                    bool isUpcoming = false;
                    bool isPast = false;

                    if (startTime != null) {
                      final classDate = startTime.toDate();
                      final nowDate = now.toDate();
                      isPast = classDate.isBefore(nowDate);
                      if (!isPast) isUpcoming = true;
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

                    // Debug: Check if templateId exists
                    debugPrint('📅 Session: ${data['className']}');
                    debugPrint('   - templateId: ${data['templateId']}');
                    debugPrint('   - Has templateId: ${data['templateId'] != null}');

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
                      child: Column(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              onTap: () {
                                // Navigate to class details view showing activities (without timer)
                                Navigator.pushNamed(
                                  context,
                                  '/class_details',
                                  arguments: {
                                    'sessionId': doc.id,
                                    'className': data['className'],
                                  },
                                );
                              },
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
                                            color: isUpcoming ? AppTheme.pitchGreen.withOpacity(0.1) : Colors.grey[100],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(dayString, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isUpcoming ? AppTheme.pitchGreen : Colors.grey)),
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
                                              if (isUpcoming)
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
                                        _buildInfoChip(Icons.access_time_filled_rounded, timeString, isUpcoming ? AppTheme.primaryRed : Colors.grey),
                                        _buildInfoChip(Icons.location_on_rounded, data['venue'] ?? 'Unknown', Colors.grey),

                                        // Action Arrow
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: isUpcoming ? AppTheme.primaryRed : Colors.grey[100],
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.chevron_right_rounded,
                                            color: isUpcoming ? Colors.white : Colors.grey,
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
                          // View Session Plan button
                          if (data['templateId'] != null)
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.grey[200]!, width: 1),
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                  onTap: () {
                                    _navigateToSessionTemplate(context, data['templateId']);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.library_books, size: 16, color: AppTheme.pitchGreen),
                                        const SizedBox(width: 8),
                                        Text(
                                          'View Session Plan',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.pitchGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _navigateToSessionTemplate(BuildContext context, String templateId) async {
    try {
      // Fetch template details from Firestore
      final templateDoc = await FirebaseFirestore.instance
          .collection('session_templates')
          .doc(templateId)
          .get();

      if (!templateDoc.exists) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session template not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final templateData = templateDoc.data() as Map<String, dynamic>;

      // Parse drills
      List<DrillData> drills = [];
      if (templateData['drills'] != null && templateData['drills'] is List) {
        for (var drill in templateData['drills']) {
          if (drill is Map<String, dynamic>) {
            drills.add(DrillData(
              title: drill['title']?.toString() ?? '',
              duration: drill['duration']?.toString() ?? '',
              instructions: drill['instructions']?.toString() ?? '',
              equipment: drill['equipment']?.toString() ?? '',
              progressionEasier: drill['progression_easier']?.toString() ?? '',
              progressionHarder: drill['progression_harder']?.toString() ?? '',
              learningGoals: drill['learning_goals']?.toString() ?? '',
              animationUrl: drill['animationUrl']?.toString(),
              animationJson: drill['animationJson']?.toString(),
              visualType: drill['visualType']?.toString(),
            ));
          }
        }
      }

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SessionTemplateDetailsView(
              templateId: templateId,
              templateTitle: templateData['title']?.toString() ?? 'Session Plan',
              ageGroup: templateData['ageGroup']?.toString() ?? '',
              badgeFocus: templateData['badgeFocus']?.toString() ?? '',
              drills: drills,
              pdfUrl: templateData['pdfUrl']?.toString(),
              pdfFileName: templateData['pdfFileName']?.toString(),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading session plan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
}