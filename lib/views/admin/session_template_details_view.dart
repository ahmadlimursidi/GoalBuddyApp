import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';
import '../../config/theme.dart';
import '../../models/drill_data.dart';
import '../../models/drill_animation_data.dart';
import '../../widgets/pdf_viewer_widget.dart';
import '../../widgets/drill_animation_player.dart';

class SessionTemplateDetailsView extends StatelessWidget {
  final String templateId;
  final String templateTitle;
  final String ageGroup;
  final String badgeFocus;
  final List<DrillData> drills;
  final String? pdfUrl;
  final String? pdfFileName;

  const SessionTemplateDetailsView({
    super.key,
    required this.templateId,
    required this.templateTitle,
    required this.ageGroup,
    required this.badgeFocus,
    required this.drills,
    this.pdfUrl,
    this.pdfFileName,
  });

  @override
  Widget build(BuildContext context) {
    if (drills.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Template Details"),
          backgroundColor: AppTheme.darkText,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            "No drills found in this template.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    // Calculate total duration safely
    int totalDuration = drills.fold(
      0,
      (total, drill) => total + (int.tryParse(drill.duration.toString()) ?? 0),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(templateTitle),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header with template info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryRed, Color(0xFFC41A1F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
                const Icon(Icons.library_books, size: 48, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  templateTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Age Group
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.child_care, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            ageGroup,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Badge Focus
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.emoji_events, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            badgeFocus,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sports_soccer, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${drills.length} Drills',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '$totalDuration min total',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
                // PDF viewing button
                if (pdfUrl != null && pdfUrl!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PdfViewerWidget(
                            pdfUrl: pdfUrl!,
                            fileName: pdfFileName ?? 'Session Plan',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('View Source PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryRed,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Drills list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: drills.length,
              itemBuilder: (context, index) {
                final drill = drills[index];
                return _buildDrillCard(context, drill, index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrillCard(BuildContext context, DrillData drill, int drillNumber) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          _showDrillDetailsDialog(context, drill, drillNumber);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with drill number and duration
              Row(
                children: [
                  // Drill number badge
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '$drillNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Drill title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          drill.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${drill.duration} minutes',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 16),

              // Instructions preview
              Text(
                drill.instructions,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Quick info badges
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Equipment badge
                  if (drill.equipment.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sports_soccer, size: 14, color: Colors.blue),
                          const SizedBox(width: 6),
                          Text(
                            'Equipment',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Learning Goals badge
                  if (drill.learningGoals.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.pitchGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.pitchGreen.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.emoji_events, size: 14, color: AppTheme.pitchGreen),
                          const SizedBox(width: 6),
                          Text(
                            'Learning Goals',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Progressions badge
                  if (drill.progressionEasier.isNotEmpty || drill.progressionHarder.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.purple.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.trending_up, size: 14, color: Colors.purple),
                          const SizedBox(width: 6),
                          Text(
                            'Progressions',
                            style: TextStyle(
                              color: Colors.purple[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Animation badge - AI or manual
                  if ((drill.animationJson != null && drill.animationJson!.isNotEmpty) ||
                      (drill.animationUrl != null && drill.animationUrl!.isNotEmpty))
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            drill.animationJson != null && drill.animationJson!.isNotEmpty
                                ? Icons.auto_awesome
                                : Icons.play_circle,
                            size: 14,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            drill.animationJson != null && drill.animationJson!.isNotEmpty
                                ? 'AI Animation'
                                : 'Animation',
                            style: TextStyle(
                              color: Colors.orange[700],
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
    );
  }

  void _showDrillDetailsDialog(BuildContext context, DrillData drill, int drillNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppTheme.darkText,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '$drillNumber',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              drill.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 14, color: Colors.white70),
                                const SizedBox(width: 4),
                                Text(
                                  '${drill.duration} minutes',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Animation/Visual - AI-generated or manual upload
                        if ((drill.animationJson != null && drill.animationJson!.isNotEmpty) ||
                            (drill.animationUrl != null && drill.animationUrl!.isNotEmpty)) ...[
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _buildAnimationDisplay(drill),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Instructions
                        _buildDetailSection(
                          icon: Icons.description,
                          iconColor: AppTheme.primaryRed,
                          title: 'Instructions',
                          content: drill.instructions,
                        ),

                        // Equipment
                        if (drill.equipment.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildDetailSection(
                            icon: Icons.sports_soccer,
                            iconColor: Colors.blue,
                            title: 'Equipment Needed',
                            content: drill.equipment,
                          ),
                        ],

                        // Learning Goals
                        if (drill.learningGoals.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildDetailSection(
                            icon: Icons.emoji_events,
                            iconColor: AppTheme.pitchGreen,
                            title: 'Learning Goals',
                            content: drill.learningGoals,
                          ),
                        ],

                        // Progressions
                        if (drill.progressionEasier.isNotEmpty || drill.progressionHarder.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Progressions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (drill.progressionEasier.isNotEmpty)
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.arrow_downward, color: Colors.green, size: 16),
                                            SizedBox(width: 6),
                                            Text(
                                              'Easier',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          drill.progressionEasier,
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (drill.progressionEasier.isNotEmpty && drill.progressionHarder.isNotEmpty)
                                const SizedBox(width: 12),
                              if (drill.progressionHarder.isNotEmpty)
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.arrow_upward, color: Colors.red, size: 16),
                                            SizedBox(width: 6),
                                            Text(
                                              'Harder',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          drill.progressionHarder,
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimationDisplay(DrillData drill) {
    // Priority 1: AI-generated animation (animationJson)
    if (drill.animationJson != null && drill.animationJson!.isNotEmpty) {
      try {
        final animationData = DrillAnimationData.fromJson(jsonDecode(drill.animationJson!));
        return DrillAnimationPlayer(
          animationData: animationData,
          width: double.infinity,
          height: 200,
        );
      } catch (e) {
        // If parsing fails, fall through to other options
        debugPrint('Failed to parse animation JSON: $e');
      }
    }

    // Priority 2: Manual upload (animationUrl)
    if (drill.animationUrl != null && drill.animationUrl!.isNotEmpty) {
      final animationUrl = drill.animationUrl!;

      // Check if the URL ends with .json (Lottie animation)
      if (animationUrl.toLowerCase().endsWith('.json')) {
        return Lottie.network(
          animationUrl,
          fit: BoxFit.contain,
          repeat: true,
          animate: true,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Failed to load animation', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            );
          },
        );
      }
      // If it's a video file (mp4)
      else if (animationUrl.toLowerCase().endsWith('.mp4')) {
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.video_file, size: 64, color: Colors.grey),
                SizedBox(height: 8),
                Text('Video playback coming soon', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        );
      }
      // For images (jpg, png, gif)
      else if (animationUrl.toLowerCase().endsWith('.jpg') ||
          animationUrl.toLowerCase().endsWith('.png') ||
          animationUrl.toLowerCase().endsWith('.gif')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            animationUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Failed to load image', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }
    }

    // No animation available
    return const SizedBox.shrink();
  }
}