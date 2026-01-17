import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme.dart';
import '../../services/firestore_service.dart';
import '../../models/drill_data.dart';
import '../../widgets/pdf_viewer_widget.dart';
import 'session_template_details_view.dart';

class SessionTemplatesListView extends StatelessWidget {
  const SessionTemplatesListView({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background for contrast
      appBar: AppBar(
        title: const Text("Session Templates"),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Enhanced Gradient Header
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
                  "Manage Curriculum",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "All Templates",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 2. List Content
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getSessionTemplates(),
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

                final templates = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    final data = template.data() as Map<String, dynamic>;
                    final drills = data['drills'] as List<dynamic>? ?? [];

                    // Convert drills to DrillData objects
                    List<DrillData> drillDataList = drills.map((drill) {
                      final drillMap = drill as Map<String, dynamic>;
                      return DrillData(
                        title: drillMap['title'] ?? 'Untitled Drill',
                        duration: drillMap['duration']?.toString() ?? '5',
                        instructions: drillMap['instructions'] ?? '',
                        equipment: drillMap['equipment'] ?? '',
                        progressionEasier: drillMap['progression_easier'] ?? '',
                        progressionHarder: drillMap['progression_harder'] ?? '',
                        learningGoals: drillMap['learning_goals'] ?? '',
                        animationUrl: drillMap['animationUrl'],
                        animationJson: drillMap['animationJson'],
                        visualType: drillMap['visualType'],
                      );
                    }).toList();

                    // Calculate total duration safely
                    int totalDuration = drillDataList.fold(
                      0,
                      (sum, drill) => sum + (int.tryParse(drill.duration.toString()) ?? 0),
                    );

                    return _buildTemplateCard(
                      context,
                      template.id,
                      data,
                      drillDataList,
                      totalDuration,
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

  Widget _buildTemplateCard(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
    List<DrillData> drillDataList,
    int totalDuration,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SessionTemplateDetailsView(
                  templateId: docId,
                  templateTitle: data['title'] ?? 'Untitled',
                  ageGroup: data['ageGroup'] ?? 'All Ages',
                  badgeFocus: data['badgeFocus'] ?? 'None',
                  drills: drillDataList,
                  pdfUrl: data['pdfUrl']?.toString(),
                  pdfFileName: data['pdfFileName']?.toString(),
                ),
              ),
            );
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
                        color: AppTheme.primaryRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.library_books, color: AppTheme.primaryRed, size: 24),
                    ),
                    const SizedBox(width: 16),
                    // Title & Stats
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['title'] ?? 'Untitled Template',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkText,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${drillDataList.length} Drills • $totalDuration mins',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editTemplate(context, docId, data);
                        } else if (value == 'delete') {
                          _deleteTemplate(context, docId, data);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18, color: AppTheme.primaryRed),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 16),
                // Metadata Chips and PDF Button
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      icon: Icons.child_care,
                      label: data['ageGroup'] ?? 'All Ages',
                      color: AppTheme.pitchGreen,
                    ),
                    _buildInfoChip(
                      icon: Icons.emoji_events,
                      label: data['badgeFocus'] ?? 'None',
                      color: Colors.orange,
                    ),
                    // Show PDF badge if PDF is available
                    if (data['pdfUrl'] != null && data['pdfUrl'].toString().isNotEmpty)
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PdfViewerWidget(
                                pdfUrl: data['pdfUrl'].toString(),
                                fileName: data['pdfFileName']?.toString() ?? 'Session Plan',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.picture_as_pdf, size: 14, color: Colors.blue),
                              const SizedBox(width: 6),
                              Text(
                                'View PDF',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      // DEBUG: Show when NO PDF (remove this after testing)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              'No PDF',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
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
            child: Icon(Icons.library_add, size: 48, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            'No templates yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload a PDF to create your first template!',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _editTemplate(BuildContext context, String templateId, Map<String, dynamic> templateData) {
    final TextEditingController titleController = TextEditingController(text: templateData['title'] ?? '');
    String? selectedAgeGroup = templateData['ageGroup'] ?? 'Little Kickers';
    String? selectedBadgeFocus = templateData['badgeFocus'] ?? 'Dribbling';

    final List<String> ageGroups = ['Little Kickers', 'Junior Kickers', 'Mighty Kickers', 'Mega Kickers'];
    final List<String> badges = ['Dribbling', 'Passing', 'Shooting', 'Control', 'Teamwork', 'General'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.edit, color: AppTheme.primaryRed),
              SizedBox(width: 8),
              Text('Edit Template'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Template Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedAgeGroup,
                  decoration: const InputDecoration(
                    labelText: 'Age Group',
                    border: OutlineInputBorder(),
                  ),
                  items: ageGroups.map((group) => DropdownMenuItem(value: group, child: Text(group))).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAgeGroup = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedBadgeFocus,
                  decoration: const InputDecoration(
                    labelText: 'Badge Focus',
                    border: OutlineInputBorder(),
                  ),
                  items: badges.map((badge) => DropdownMenuItem(value: badge, child: Text(badge))).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBadgeFocus = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a template title')),
                  );
                  return;
                }

                try {
                  await FirebaseFirestore.instance.collection('sessionTemplates').doc(templateId).update({
                    'title': titleController.text.trim(),
                    'ageGroup': selectedAgeGroup,
                    'badgeFocus': selectedBadgeFocus,
                    'updatedAt': FieldValue.serverTimestamp(),
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Template updated successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating template: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTemplate(BuildContext context, String templateId, Map<String, dynamic> templateData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Template'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${templateData['title'] ?? 'this template'}"?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. The template and all its drills will be permanently deleted.',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.collection('sessionTemplates').doc(templateId).delete();

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Template deleted successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting template: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}