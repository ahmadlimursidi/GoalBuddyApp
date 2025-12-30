import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../view_models/student_parent_view_model.dart';

class ParentProgressView extends StatelessWidget {
  const ParentProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StudentParentViewModel>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Child Progress"),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Child Info Header
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryRed,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.child_care,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            viewModel.childName ?? "Child Name",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            viewModel.childAgeGroup ?? "Age Group",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Progress Summary
            const Text(
              "Badge Progress",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Badges Grid
            Expanded(
              child: Consumer<StudentParentViewModel>(
                builder: (context, viewModel, child) {
                  final badges = viewModel.childBadges;
                  
                  if (badges.isEmpty) {
                    return const Center(
                      child: Text(
                        "No badges earned yet.\nKeep attending classes!",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }
                  
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: badges.length,
                    itemBuilder: (context, index) {
                      final badge = badges[index];
                      return _buildBadgeCard(badge);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBadgeCard(Map<String, dynamic> badge) {
    String badgeName = badge['name'] ?? 'Badge';
    String badgeType = badge['type'] ?? 'Unknown'; // Could be 'Red', 'Yellow', 'Green', 'Purple'
    
    Color badgeColor = _getBadgeColor(badgeType);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: badgeColor,
                  width: 2,
                ),
              ),
              child: Icon(
                _getBadgeIcon(badgeType),
                color: badgeColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badgeName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              badgeType,
              style: TextStyle(
                color: badgeColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getBadgeColor(String badgeType) {
    switch (badgeType.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'yellow':
        return Colors.yellow[700]!;
      case 'green':
        return AppTheme.pitchGreen;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getBadgeIcon(String badgeType) {
    switch (badgeType.toLowerCase()) {
      case 'red':
        return Icons.star_border;
      case 'yellow':
        return Icons.star_half;
      case 'green':
        return Icons.star;
      case 'purple':
        return Icons.star_purple500_sharp;
      default:
        return Icons.help_outline;
    }
  }
}