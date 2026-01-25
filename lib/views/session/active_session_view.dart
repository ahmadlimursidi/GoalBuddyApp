import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import '../../view_models/active_session_view_model.dart';
import '../../config/theme.dart';
import '../../widgets/pdf_viewer_widget.dart';
import '../../widgets/drill_animation_player.dart';
import '../../models/drill_animation_data.dart';

class ActiveSessionView extends StatefulWidget {
  const ActiveSessionView({super.key});

  @override
  State<ActiveSessionView> createState() => _ActiveSessionViewState();
}

class _ActiveSessionViewState extends State<ActiveSessionView> {
  bool _isInit = false;
  String? _sessionId;
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _sheetController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playTimerEndSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/timer_end.mp3'));
    } catch (e) {
      debugPrint('Error playing timer end sound: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      // 1. Get Arguments passed from Dashboard
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      _sessionId = args?['sessionId'] as String?;
      debugPrint("ActiveSessionView received sessionId: '$_sessionId'");

      // 2. Load Data via ViewModel
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_sessionId != null) {
          final viewModel = Provider.of<ActiveSessionViewModel>(context, listen: false);
          viewModel.onTimerEnd = _playTimerEndSound;
          viewModel.loadSession(_sessionId!);
        }
      });

      _isInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveSessionViewModel>(
      builder: (context, viewModel, child) {
        // 1. Loading State
        if (viewModel.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFF1A1F2C), // Dark professional background
            body: Center(child: CircularProgressIndicator(color: AppTheme.pitchGreen)),
          );
        }

        // 2. Empty State (No drills found)
        if (viewModel.drills.isEmpty) {
          return Scaffold(
            backgroundColor: const Color(0xFF1A1F2C),
            appBar: AppBar(
              title: const Text("Session Error"),
              backgroundColor: Colors.transparent,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No drills found for this session.\nPlease check the session template.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        final currentDrill = viewModel.currentDrill!;

        // 3. Main Content
        return Scaffold(
          body: Stack(
            children: [
              // BACKGROUND: Dark Gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A1F2C), Color(0xFF121212)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // HEADER: Custom AppBar area
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    "LIVE SESSION",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "Drill ${viewModel.currentDrillIndex + 1}/${viewModel.drills.length}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Action Buttons - Using a more compact layout
                        // PDF Button (if available) - Now with green color and no box
                        if (viewModel.pdfUrl != null && viewModel.pdfUrl!.isNotEmpty)
                          Tooltip(
                            message: "View Session Plan PDF",
                            child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PdfViewerWidget(
                                      pdfUrl: viewModel.pdfUrl!,
                                      fileName: viewModel.pdfFileName ?? 'Session Plan',
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.picture_as_pdf,
                                color: AppTheme.pitchGreen,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints.tightFor(width: 40, height: 40),
                            ),
                          ),
                        IconButton(
                          onPressed: () {
                             Navigator.pushNamed(context, '/attendance', arguments: {
                               'sessionId': _sessionId,
                             });
                          },
                          icon: const Icon(Icons.people_alt_outlined, color: Colors.white),
                          tooltip: "Attendance",
                        ),
                        IconButton(
                          onPressed: () {
                            _showFinishSessionDialog(context, viewModel);
                          },
                          icon: const Icon(Icons.flag_outlined, color: AppTheme.pitchGreen),
                          tooltip: "Finish Session",
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // TIMER AREA: Large circular progress
              Positioned(
                top: 120, 
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background Circle
                        SizedBox(
                          width: 260,
                          height: 260,
                          child: CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 12,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        // Progress Circle
                        SizedBox(
                          width: 260,
                          height: 260,
                          child: CircularProgressIndicator(
                            value: viewModel.progress,
                            strokeWidth: 12,
                            strokeCap: StrokeCap.round,
                            // Color changes based on time remaining
                            color: viewModel.remainingSeconds < 30 ? Colors.redAccent : AppTheme.pitchGreen,
                          ),
                        ),
                        // Text Content
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              viewModel.timerText,
                              style: const TextStyle(
                                fontSize: 64, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: viewModel.isPaused 
                                    ? Colors.orange.withOpacity(0.2) 
                                    : AppTheme.pitchGreen.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                viewModel.isPaused ? "PAUSED" : "RUNNING",
                                style: TextStyle(
                                  fontSize: 12, 
                                  color: viewModel.isPaused ? Colors.orange : AppTheme.pitchGreen, 
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // DRAGGABLE SHEET: Drill Details
              DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: 0.45,
                minChildSize: 0.45,
                maxChildSize: 0.92,
                snap: true,
                builder: (context, scrollController) {
                  return GestureDetector(
                    onTap: () {
                      if (_sheetController.size < 0.6) {
                        _sheetController.animateTo(0.92, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                      } else {
                        _sheetController.animateTo(0.35, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                      }
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 20,
                            offset: Offset(0, -5),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          // Drag Handle
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(top: 12, bottom: 8),
                            child: Center(
                              child: Container(
                                width: 40,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),

                          // Scrollable Content
                          Expanded(
                            child: ListView(
                              controller: scrollController,
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 100), // Bottom padding for FAB space
                              children: [
                                // "Next Up" Indicator
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F7FA),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[200]!),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.skip_next_rounded, color: Colors.grey[600], size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text("UP NEXT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                            Text(
                                              viewModel.currentDrillIndex + 1 < viewModel.drills.length 
                                                  ? viewModel.drills[viewModel.currentDrillIndex + 1].title 
                                                  : 'Session Wrap Up',
                                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Drill Category Badge
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      currentDrill.category.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Drill Title
                                Text(
                                  currentDrill.title,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.darkText,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Tactical Board (Animation) - Only show if animation exists
                                if ((currentDrill.animationJson != null && currentDrill.animationJson!.isNotEmpty) ||
                                    (currentDrill.animationUrl != null && currentDrill.animationUrl!.isNotEmpty))
                                  Container(
                                    height: 220,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.grey[200]!),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                                      ],
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: Stack(
                                      children: [
                                        Center(child: _buildAnimationDisplay(currentDrill)),
                                        Positioned(
                                          bottom: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (currentDrill.animationJson != null && currentDrill.animationJson!.isNotEmpty)
                                                  const Icon(Icons.auto_awesome, color: Colors.amber, size: 12),
                                                if (currentDrill.animationJson != null && currentDrill.animationJson!.isNotEmpty)
                                                  const SizedBox(width: 4),
                                                const Text("TACTICAL BOARD", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                
                                const SizedBox(height: 24),

                                // Instructions Section
                                const Text(
                                  "INSTRUCTIONS",
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  currentDrill.instructions,
                                  style: const TextStyle(
                                    color: Color(0xFF4A5568),
                                    height: 1.6,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 40), // Bottom padding for safe area
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // BOTTOM CONTROLS (Floating above sheet)
              Positioned(
                bottom: 24,
                left: 16,
                right: 16,
                child: viewModel.isSessionComplete
                    ? _buildFinishButton(context, viewModel)
                    : viewModel.currentDrillIndex == viewModel.drills.length - 1
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildMediaControls(context, viewModel),
                              const SizedBox(height: 16),
                              _buildLastDrillFinishButton(context, viewModel),
                            ],
                          )
                        : _buildMediaControls(context, viewModel),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildMediaControls(BuildContext context, ActiveSessionViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2C).withOpacity(0.95), // Semi-transparent dark bg
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          IconButton(
            onPressed: viewModel.previousDrill,
            icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 32),
            tooltip: "Previous",
          ),
          
          // Play/Pause Button (Hero)
          SizedBox(
            width: 64,
            height: 64,
            child: FloatingActionButton(
              onPressed: viewModel.toggleTimer,
              backgroundColor: viewModel.isPaused ? Colors.white : AppTheme.pitchGreen,
              elevation: 0,
              shape: const CircleBorder(),
              child: Icon(
                viewModel.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                color: viewModel.isPaused ? AppTheme.darkText : Colors.white,
                size: 36,
              ),
            ),
          ),

          // Next Button
          IconButton(
            onPressed: viewModel.nextDrill,
            icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 32),
            tooltip: "Next",
          ),
        ],
      ),
    );
  }

  Widget _buildFinishButton(BuildContext context, ActiveSessionViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "🎉 Session Complete!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.darkText),
          ),
          const SizedBox(height: 8),
          const Text(
            "Great job coach! Mark this session as done.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () => _showFinishSessionDialog(context, viewModel),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.pitchGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              label: const Text("FINISH SESSION", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastDrillFinishButton(BuildContext context, ActiveSessionViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 4)),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _showFinishSessionDialog(context, viewModel),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryRed,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        icon: const Icon(Icons.flag_outlined, color: Colors.white),
        label: const Text("FINISH SESSION", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildAnimationDisplay(Drill drill) {
    debugPrint('🎬 Building animation display for drill: ${drill.title}');
    debugPrint('   - animationJson length: ${drill.animationJson?.length ?? 0}');
    debugPrint('   - animationUrl: ${drill.animationUrl ?? "null"}');

    // Priority 1: AI-generated animation (animationJson)
    if (drill.animationJson != null && drill.animationJson!.isNotEmpty) {
      debugPrint('✅ Rendering AI animation');
      try {
        final animationData = DrillAnimationData.fromJson(jsonDecode(drill.animationJson!));
        return DrillAnimationPlayer(
          animationData: animationData,
          width: double.infinity,
          height: 220,
        );
      } catch (e) {
        // If parsing fails, fall through to other options
        debugPrint('❌ Failed to parse animation JSON: $e');
      }
    }

    // Priority 2: Manual upload (animationUrl) - Lottie, video, image, GIF
    if (drill.animationUrl != null && drill.animationUrl!.isNotEmpty) {
      final url = drill.animationUrl!;

      if (url.toLowerCase().endsWith('.json')) {
        return Lottie.network(
          url,
          fit: BoxFit.contain,
          repeat: true,
          animate: true,
          errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
        );
      } else if (url.toLowerCase().endsWith('.mp4')) {
        // Placeholder for video
        return Container(
          color: Colors.grey[100],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                child: const Icon(Icons.play_circle_fill, size: 40, color: AppTheme.primaryRed),
              ),
              const SizedBox(height: 12),
              const Text("Video Playback", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
        );
      } else {
        // Image fallback (GIF, PNG, JPG)
        return Image.network(
          url,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
        );
      }
    }

    // No animation available - show grey placeholder
    debugPrint('⚪ No animation - showing placeholder');
    return Container(
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sports_soccer,
              size: 48,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "No Visual Available",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Follow instructions below",
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[50],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_rounded, size: 32, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text('Visual not available', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _showFinishSessionDialog(BuildContext context, ActiveSessionViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Finish Session?"),
          content: const Text(
            "This will mark the session as completed and log it for finance. This action cannot be undone.",
            style: TextStyle(color: Colors.grey),
          ),
          actionsPadding: const EdgeInsets.all(20),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                
                // Show loading
                if (context.mounted) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator(color: AppTheme.pitchGreen)),
                  );
                }

                bool success = await viewModel.finishSession(_sessionId!);

                if (context.mounted) {
                  Navigator.of(context).pop(); // Close loading
                  
                  if (success) {
                    Navigator.of(context).pop(); // Exit View
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Session Completed! 🏆"),
                        backgroundColor: AppTheme.pitchGreen,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to complete session."), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.pitchGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text("Finish", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}