import 'package:flutter/material.dart';
import '../../config/theme.dart';

class CoachResourcesView extends StatelessWidget {
  const CoachResourcesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Coach Resources"),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Resource Categories Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Resources",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                ),
                Text(
                  "Tap to access",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Resource Categories Grid
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
              children: [
                _buildResourceCard(
                  context,
                  Icons.sports_soccer,
                  "Teaching Tips",
                  "Age-appropriate techniques and methods",
                  Colors.blue,
                ),
                _buildResourceCard(
                  context,
                  Icons.group,
                  "Safety Guidelines",
                  "Best practices for child safety",
                  Colors.orange,
                ),
                _buildResourceCard(
                  context,
                  Icons.psychology,
                  "Development Guides",
                  "Age-specific skill progression",
                  Colors.green,
                ),
                _buildResourceCard(
                  context,
                  Icons.library_books,
                  "Curriculum Info",
                  "Session plans and objectives",
                  Colors.purple,
                ),
                _buildResourceCard(
                  context,
                  Icons.video_library,
                  "Training Videos",
                  "Demonstration videos",
                  Colors.red,
                ),
                _buildResourceCard(
                  context,
                  Icons.chat,
                  "Teaching Scripts",
                  "Sample phrases and cues",
                  Colors.teal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Show detailed resource information
          _showResourceDetail(context, title, description, icon, color);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResourceDetail(BuildContext context, String title, String description, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(title),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(description),
              const SizedBox(height: 16),
              if (title == "Teaching Tips") ...[
                _buildTip("Start with fun activities to engage all children"),
                _buildTip("Use clear, simple language for young children"),
                _buildTip("Encourage participation over competition"),
                _buildTip("Provide frequent positive reinforcement"),
              ] else if (title == "Safety Guidelines") ...[
                _buildTip("Always have water available"),
                _buildTip("Check equipment for damage before use"),
                _buildTip("Maintain appropriate child-to-coach ratios"),
                _buildTip("Know emergency contact information"),
              ] else if (title == "Development Guides") ...[
                _buildTip("Focus on gross motor skills for Little Kicks"),
                _buildTip("Encourage imagination for Junior Kickers"),
                _buildTip("Introduce teamwork for Mighty Kickers"),
                _buildTip("Build tactical awareness for Mega Kickers"),
              ] else if (title == "Curriculum Info") ...[
                _buildTip("Follow the structured lesson plans"),
                _buildTip("Adapt activities based on skill level"),
                _buildTip("Include warm-up and cool-down"),
                _buildTip("Integrate fun games regularly"),
              ] else if (title == "Training Videos") ...[
                _buildTip("Video demonstrations are coming soon"),
                _buildTip("Check back regularly for updates"),
              ] else if (title == "Teaching Scripts") ...[
                _buildTip("Use positive reinforcements: \"Great job!\""),
                _buildTip("Simple commands: \"Stop\", \"Look\", \"Go\""),
                _buildTip("Use animal names for movements"),
                _buildTip("Countdown for transitions: \"Ready, Set, Go\""),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 14, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(tip, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}