import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../view_models/active_session_view_model.dart';
import '../../config/theme.dart';

class ActiveSessionView extends StatefulWidget {
  const ActiveSessionView({super.key});

  @override
  State<ActiveSessionView> createState() => _ActiveSessionViewState();
}

class _ActiveSessionViewState extends State<ActiveSessionView> {
  bool _isInit = false;
  String? _sessionId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      // 1. Get Arguments passed from Dashboard
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      _sessionId = args?['sessionId'] as String?;
      debugPrint("ActiveSessionView received sessionId: '$_sessionId'"); // <-- DEBUG PRINT

      // 2. Load Data via ViewModel
      // FIX: Wrap this in addPostFrameCallback to avoid "setState during build" error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_sessionId != null) {
          Provider.of<ActiveSessionViewModel>(context, listen: false).loadSession(_sessionId!);
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
            backgroundColor: AppTheme.darkText,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        // 2. Empty State (No drills found)
        if (viewModel.drills.isEmpty) {
          return Scaffold(
            backgroundColor: AppTheme.darkText,
            appBar: AppBar(
              title: const Text("Session Error"),
              backgroundColor: Colors.transparent,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: const Center(
              child: Text(
                "No drills found for this session.\nTry seeding the database again.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final currentDrill = viewModel.currentDrill!;

        // 3. Main Content
        return Scaffold(
          backgroundColor: AppTheme.darkText,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              "Drill ${viewModel.currentDrillIndex + 1} of ${viewModel.drills.length}",
              style: const TextStyle(color: Colors.white, fontSize: 16)
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                   Navigator.pushNamed(context, '/attendance', arguments: {
                     'sessionId': _sessionId,
                   });
                },
                icon: const Icon(Icons.list_alt, color: Colors.white),
                label: const Text("Attendance", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
          body: Stack(
            children: [
              // Timer positioned at the top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.only(top: 24, bottom: 12),
                  // Give a fixed height so the sheet can overlay it
                  height: 360,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 250,
                          height: 250,
                          child: CircularProgressIndicator(
                            value: viewModel.progress,
                            strokeWidth: 15,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            color: viewModel.remainingSeconds < 30 ? Colors.red : AppTheme.pitchGreen,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              viewModel.timerText,
                              style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              viewModel.isPaused ? "PAUSED" : "RUNNING",
                              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6), letterSpacing: 2),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Draggable sheet overlays the timer and can expand nearly full-screen
              DraggableScrollableSheet(
                // Ensure min <= initial <= max to satisfy assertion
                minChildSize: 0.6,
                initialChildSize: 0.6,
                maxChildSize: 0.98,
                builder: (context, scrollController) {
                  return Container(
                    margin: const EdgeInsets.only(top: 120), // start below the appbar area
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Grab handle
                          Center(
                            child: Container(
                              width: 48,
                              height: 6,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
                            ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Show what is coming next
                              Expanded(
                                child: Text(
                                  "NEXT: ${viewModel.currentDrillIndex + 1 < viewModel.drills.length ? viewModel.drills[viewModel.currentDrillIndex + 1].title : 'Finish'}",
                                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                child: Text(
                                  currentDrill.category,
                                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10),
                                ),
                              )
                            ],
                          ),

                          const SizedBox(height: 12),
                          Text(currentDrill.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),

                          // Tactical Board - Animation (fixed height for predictable scrolling)
                          Container(
                            height: 260,
                            width: double.infinity,
                            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                            child: _buildAnimationDisplay(currentDrill.animationUrl),
                          ),

                          const SizedBox(height: 16),

                          // Traditional drill instructions display
                          Text(currentDrill.instructions, style: TextStyle(color: Colors.grey[600], height: 1.5, fontSize: 16)),

                          const SizedBox(height: 16),

                          // Controls
                          Row(
                            children: [
                              // Play/Pause Button
                              FloatingActionButton(
                                onPressed: viewModel.toggleTimer,
                                backgroundColor: viewModel.isPaused ? AppTheme.pitchGreen : Colors.orange,
                                child: Icon(viewModel.isPaused ? Icons.play_arrow : Icons.pause),
                              ),
                              const SizedBox(width: 24),

                              // Navigation Buttons
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: viewModel.previousDrill,
                                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
                                  child: const Text("Prev"),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: viewModel.nextDrill,
                                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed, padding: const EdgeInsets.all(16)),
                                  child: const Text("Next Drill"),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget to display the animation based on file type
  Widget _buildAnimationDisplay(String? animationUrl) {
    if (animationUrl == null || animationUrl.isEmpty) {
      // Return a default placeholder if no animation is provided
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.sports_soccer,
            size: 80,
            color: Colors.grey,
          ),
        ),
      );
    }

    // Check if the URL ends with .json (Lottie animation)
    if (animationUrl.toLowerCase().endsWith('.json')) {
      return Lottie.network(
        animationUrl,
        fit: BoxFit.contain,
        repeat: true,
        animate: true,
      );
    }
    // If it's a video file (mp4)
    else if (animationUrl.toLowerCase().endsWith('.mp4')) {
      // For now, we'll return a placeholder since we don't have VideoPlayerWidget
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.video_file,
            size: 80,
            color: Colors.grey,
          ),
        ),
      );
    }
    // For other cases or if it's an image
    else {
      // For now, return a placeholder
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 80,
            color: Colors.grey,
          ),
        ),
      );
    }
  }
}