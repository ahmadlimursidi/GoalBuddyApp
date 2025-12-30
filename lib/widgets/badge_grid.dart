import 'package:flutter/material.dart' hide Badge;
import '../models/badge_model.dart';
import '../utils/badge_data.dart';

class BadgeGrid extends StatelessWidget {
  final String ageGroup;
  final List<String> earnedBadgeIds;
  final String? currentBadgeId;

  const BadgeGrid({
    super.key,
    required this.ageGroup,
    required this.earnedBadgeIds,
    this.currentBadgeId,
  });

  @override
  Widget build(BuildContext context) {
    // Filter badges by age group (defensive: handle unexpected allBadges content)
    List<Badge> filteredBadges;
    try {
      filteredBadges = allBadges.where((badge) => badge.ageGroup == ageGroup).toList();
    } catch (e) {
      filteredBadges = <Badge>[];
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Badges',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Disable scrolling for the grid itself
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 badges per row
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1, // Square aspect ratio
            ),
            itemCount: filteredBadges.length,
            itemBuilder: (context, index) {
              final badge = filteredBadges[index];
              final isEarned = earnedBadgeIds.contains(badge.id);
              final isCurrent = currentBadgeId == badge.id;

              return BadgeItem(
                badge: badge,
                isEarned: isEarned,
                isCurrent: isCurrent,
              );
            },
          ),
        ],
      ),
    );
  }
}

class BadgeItem extends StatelessWidget {
  final Badge badge;
  final bool isEarned;
  final bool isCurrent;

  const BadgeItem({
    super.key,
    required this.badge,
    required this.isEarned,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    // Parse hex color strings robustly (accepts "#RRGGBB", "RRGGBB", or "AARRGGBB")
    Color badgeColor;
    try {
      String hex = badge.colorHex.replaceAll('#', '');
      hex = hex.replaceAll('0x', '').replaceAll('0X', '');
      if (hex.isEmpty) throw Exception('empty color');
      if (hex.length == 6) hex = 'FF$hex'; // add opaque alpha if missing
      if (hex.length != 8) throw Exception('invalid hex length');
      final intVal = int.parse(hex, radix: 16);
      badgeColor = Color(intVal);
    } catch (e) {
      // Fallback color if parsing fails
      badgeColor = Colors.orange;
    }

    final Color displayColor = isEarned ? badgeColor : Colors.grey[400]!;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? Colors.blue : Colors.transparent,
          width: isCurrent ? 3 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Badge icon
          Icon(
            getIconData(badge.iconAsset),
            size: 40,
            color: displayColor,
          ),
          const SizedBox(height: 8),
          // Badge title
          Text(
            badge.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isEarned ? Colors.black87 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          // Badge status indicator
          if (isCurrent && !isEarned)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Current',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.blue[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (isEarned)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Earned',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.green[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper function to map icon names to IconData
  IconData getIconData(String iconAsset) {
    // Map the icon names to appropriate Flutter icons
    switch (iconAsset) {
      case 'star':
        return Icons.star;
      case 'heart':
        return Icons.favorite;
      case 'foot_ball':
      case 'kicking':
        return Icons.sports_soccer;
      case 'smiley':
      case 'confidence':
        return Icons.sentiment_very_satisfied;
      case 'lightbulb':
      case 'imagination':
        return Icons.lightbulb;
      case 'jumping_person':
      case 'person':
      case 'physical_literacy':
        return Icons.directions_run;
      case 'two_figures':
      case 'team_player':
        return Icons.people;
      case 'leadership':
        return Icons.flag;
      case 'puzzle':
      case 'problem_solver':
        return Icons.extension;
      case 'match_play':
      case 'match':
        return Icons.sports;
      case 'attacking':
        return Icons.flag;
      case 'defending':
        return Icons.shield;
      case 'tactician':
        return Icons.account_balance;
      case 'captain':
        return Icons.star;
      case 'referee':
        return Icons.sports_golf;
      case 'all_rounder':
        return Icons.all_inclusive;
      default:
        // Default icon
        return Icons.help_outline;
    }
  }
}