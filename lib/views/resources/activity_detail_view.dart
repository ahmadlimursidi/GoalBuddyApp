import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';
import '../../config/theme.dart';
import '../../view_models/drill_library_view_model.dart';
import '../../widgets/pdf_viewer_widget.dart';
import '../../widgets/drill_animation_player.dart';
import '../../models/drill_animation_data.dart';

class ActivityDetailView extends StatelessWidget {
  final TemplateActivity activity;

  const ActivityDetailView({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activity Details"),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
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
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Activity Type Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconForDrillType(activity.drillType),
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Activity Title
                  Text(
                    activity.drillData.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Metadata Row
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildHeaderBadge(
                        icon: Icons.access_time,
                        label: '${activity.drillData.duration} min',
                      ),
                      _buildHeaderBadge(
                        icon: Icons.category,
                        label: activity.drillType,
                      ),
                      _buildHeaderBadge(
                        icon: Icons.child_care,
                        label: activity.ageGroup,
                      ),
                      _buildHeaderBadge(
                        icon: Icons.emoji_events,
                        label: activity.badgeFocus,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Template Source
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.library_books, size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'From: ${activity.templateTitle}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content Sections
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Debug: Log animation data received
                  Builder(builder: (context) {
                    print('🎬 [ActivityDetailView] Activity: ${activity.drillData.title}');
                    print('   - animationJson: ${activity.drillData.animationJson != null ? "${activity.drillData.animationJson!.length} chars" : "null"}');
                    print('   - animationUrl: ${activity.drillData.animationUrl}');
                    print('   - visualType: ${activity.drillData.visualType}');
                    return const SizedBox.shrink();
                  }),

                  // Animation/Visual - Check for AI-generated animation first, then manual upload
                  if (activity.drillData.animationJson != null &&
                      activity.drillData.animationJson!.isNotEmpty) ...[
                    _buildAIAnimationDisplay(activity.drillData.animationJson!),
                    const SizedBox(height: 20),
                  ] else if (activity.drillData.animationUrl != null &&
                      activity.drillData.animationUrl!.isNotEmpty) ...[
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _buildAnimationDisplay(activity.drillData.animationUrl),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Instructions Section
                  _buildDetailSection(
                    icon: Icons.description,
                    iconColor: AppTheme.primaryRed,
                    title: 'Instructions',
                    content: activity.drillData.instructions.isEmpty
                        ? 'No instructions provided'
                        : activity.drillData.instructions,
                  ),

                  // Equipment Section
                  if (activity.drillData.equipment.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildDetailSection(
                      icon: Icons.sports_soccer,
                      iconColor: Colors.blue,
                      title: 'Equipment Needed',
                      content: activity.drillData.equipment,
                    ),
                  ],

                  // Learning Goals Section
                  if (activity.drillData.learningGoals.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildDetailSection(
                      icon: Icons.emoji_events,
                      iconColor: AppTheme.pitchGreen,
                      title: 'Learning Goals',
                      content: activity.drillData.learningGoals,
                    ),
                  ],

                  // Progressions Section
                  if (activity.drillData.progressionEasier.isNotEmpty ||
                      activity.drillData.progressionHarder.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Icon(Icons.trending_up, size: 20, color: AppTheme.darkText),
                        SizedBox(width: 8),
                        Text(
                          'Progressions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (activity.drillData.progressionEasier.isNotEmpty)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
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
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    activity.drillData.progressionEasier,
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (activity.drillData.progressionEasier.isNotEmpty &&
                            activity.drillData.progressionHarder.isNotEmpty)
                          const SizedBox(width: 12),
                        if (activity.drillData.progressionHarder.isNotEmpty)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
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
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    activity.drillData.progressionHarder,
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],

                  // PDF viewing section for coaches
                  if (activity.pdfUrl != null && activity.pdfUrl!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.library_books, size: 20, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'Source Document',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.darkText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'This activity comes from: ${activity.templateTitle}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PdfViewerWidget(
                                      pdfUrl: activity.pdfUrl!,
                                      fileName: activity.pdfFileName ?? 'Session Plan',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.picture_as_pdf, size: 18),
                              label: const Text('View Original PDF'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBadge({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
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
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            content,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the AI-generated animation display using DrillAnimationPlayer
  Widget _buildAIAnimationDisplay(String animationJson) {
    try {
      final animationData = DrillAnimationData.fromJson(jsonDecode(animationJson));
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: DrillAnimationPlayer(
                animationData: animationData,
                width: double.infinity,
                height: 220,
              ),
            ),
            if (animationData.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.deepPurple, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        animationData.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    } catch (e) {
      // If parsing fails, show an error state
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'Failed to load animation',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildAnimationDisplay(String? animationUrl) {
    if (animationUrl == null || animationUrl.isEmpty) {
      return const SizedBox.shrink();
    }

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
    // For other cases
    else {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.help_outline, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('Unsupported format', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }
  }

  IconData _getIconForDrillType(String type) {
    switch (type) {
      case 'Intro / Muster':
        return Icons.waving_hand;
      case 'Warm Up':
        return Icons.directions_run;
      case 'Match / Game':
        return Icons.sports_soccer;
      case 'Technical / Skill':
        return Icons.psychology;
      default:
        return Icons.help_outline;
    }
  }
}
