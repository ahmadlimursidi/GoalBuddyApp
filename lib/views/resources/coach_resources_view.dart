import 'package:flutter/material.dart';
import '../../config/theme.dart';

class CoachResourcesView extends StatelessWidget {
  const CoachResourcesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Matches Profile background
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Styled Header (SliverAppBar)
          SliverAppBar(
            expandedHeight: 140.0,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryRed,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                "Coach Resources",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18, // Slightly larger for clarity
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryRed, Color(0xFFC41A1F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative element
                    Positioned(
                      top: -30,
                      right: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -20,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Sub-header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Library",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[800],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    child: Text(
                      "Tap to view",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Resources Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85, // Optimized for card content height
              ),
              delegate: SliverChildListDelegate([
                _buildResourceCard(
                  context,
                  Icons.sports_soccer_rounded,
                  "Teaching Tips",
                  "Age-appropriate techniques",
                  Colors.blueAccent,
                ),
                _buildResourceCard(
                  context,
                  Icons.shield_rounded, // Better safety icon
                  "Safety Guidelines",
                  "Best practices & protocols",
                  Colors.orangeAccent,
                ),
                _buildResourceCard(
                  context,
                  Icons.psychology_rounded,
                  "Development",
                  "Skill progression guides",
                  AppTheme.pitchGreen,
                ),
                _buildResourceCard(
                  context,
                  Icons.menu_book_rounded,
                  "Curriculum",
                  "Session plans & objectives",
                  Colors.purpleAccent,
                ),
                _buildResourceCard(
                  context,
                  Icons.play_circle_filled_rounded,
                  "Training Videos",
                  "Demonstration videos",
                  Colors.redAccent,
                ),
                _buildResourceCard(
                  context,
                  Icons.forum_rounded,
                  "Scripts",
                  "Phrases & cues",
                  Colors.teal,
                ),
              ]),
            ),
          ),

          // Bottom Spacing
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () =>
              _showResourceDetail(context, title, description, icon, color),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    height: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showResourceDetail(BuildContext context, String title,
      String description, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 20),
                Text(
                  "Key Points",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
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
                ] else if (title == "Development") ...[
                  _buildTip("Focus on gross motor skills for Little Kicks"),
                  _buildTip("Encourage imagination for Junior Kickers"),
                  _buildTip("Introduce teamwork for Mighty Kickers"),
                  _buildTip("Build tactical awareness for Mega Kickers"),
                ] else if (title == "Curriculum") ...[
                  _buildTip("Follow the structured lesson plans"),
                  _buildTip("Adapt activities based on skill level"),
                  _buildTip("Include warm-up and cool-down"),
                  _buildTip("Integrate fun games regularly"),
                ] else if (title == "Training Videos") ...[
                  _buildTip("Video demonstrations are coming soon"),
                  _buildTip("Check back regularly for updates"),
                ] else if (title == "Scripts") ...[
                  _buildTip("Use positive reinforcements: \"Great job!\""),
                  _buildTip("Simple commands: \"Stop\", \"Look\", \"Go\""),
                  _buildTip("Use animal names for movements"),
                  _buildTip("Countdown for transitions: \"Ready, Set, Go\""),
                ],
              ],
            ),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.grey[100],
                foregroundColor: Colors.grey[800],
              ),
              child: const Text(
                "Close",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle_rounded,
                size: 16, color: AppTheme.pitchGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}