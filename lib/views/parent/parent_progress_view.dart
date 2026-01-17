import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../view_models/student_parent_view_model.dart';
import '../../widgets/badge_grid.dart';

class ParentProgressView extends StatefulWidget {
  const ParentProgressView({super.key});

  @override
  State<ParentProgressView> createState() => _ParentProgressViewState();
}

class _ParentProgressViewState extends State<ParentProgressView> {
  List<String> _earnedBadgeIds = [];
  String? _currentBadgeId;
  String _ageGroup = 'Junior Kickers';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('DEBUG ParentProgressView: initState called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('DEBUG ParentProgressView: postFrameCallback called');
      _loadBadgeData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('DEBUG ParentProgressView: didChangeDependencies called, _isLoading = $_isLoading');
  }

  Future<void> _loadBadgeData() async {
    final viewModel = Provider.of<StudentParentViewModel>(context, listen: false);

    // Always use mock data for now
    // Get age group from viewModel or default to Junior Kickers
    String rawAgeGroup = viewModel.ageGroup ?? 'Junior Kickers';
    String ageGroup = _normalizeAgeGroup(rawAgeGroup);

    print('DEBUG ParentProgressView: rawAgeGroup = $rawAgeGroup');
    print('DEBUG ParentProgressView: normalized ageGroup = $ageGroup');

    List<String> possibleBadges = _getPossibleBadgesForAgeGroup(ageGroup);
    print('DEBUG ParentProgressView: possibleBadges count = ${possibleBadges.length}');
    print('DEBUG ParentProgressView: possibleBadges = $possibleBadges');

    List<String> mockBadges = _generateMockBadges(ageGroup, possibleBadges);
    print('DEBUG ParentProgressView: mockBadges count = ${mockBadges.length}');
    print('DEBUG ParentProgressView: mockBadges = $mockBadges');

    String? currentBadge = possibleBadges.firstWhere(
      (badge) => !mockBadges.contains(badge),
      orElse: () => '',
    );
    print('DEBUG ParentProgressView: currentBadge = $currentBadge');

    if (mounted) {
      setState(() {
        _ageGroup = ageGroup;
        _earnedBadgeIds = mockBadges;
        _currentBadgeId = currentBadge.isNotEmpty ? currentBadge : null;
        _isLoading = false;
      });
      print('DEBUG ParentProgressView: setState completed - _earnedBadgeIds = $_earnedBadgeIds');
    }
  }

  // Generate mock badges based on age group - matching student_profile_view.dart logic
  List<String> _generateMockBadges(String ageGroup, List<String> possibleBadges) {
    // Normalize the age group first
    String normalizedAgeGroup = _normalizeAgeGroup(ageGroup);

    int count;
    switch (normalizedAgeGroup) {
      case 'Mega Kickers':
        count = 6;
        break;
      case 'Mighty Kickers':
        count = 4;
        break;
      case 'Junior Kickers':
        count = 3;
        break;
      case 'Little Kicks':
      default:
        count = 2;
        break;
    }
    count = count.clamp(0, possibleBadges.length);
    return possibleBadges.take(count).toList();
  }

  // Normalize age group name to match badge_data.dart format
  String _normalizeAgeGroup(String ageGroup) {
    String normalized = ageGroup.toLowerCase().trim();

    if (normalized.contains('little') && normalized.contains('kick')) {
      return 'Little Kicks';
    } else if (normalized.contains('junior') && normalized.contains('kick')) {
      return 'Junior Kickers';
    } else if (normalized.contains('mighty') && normalized.contains('kick')) {
      return 'Mighty Kickers';
    } else if (normalized.contains('mega') && normalized.contains('kick')) {
      return 'Mega Kickers';
    }

    return ageGroup;
  }

  // Get possible badges based on age group - matching student_profile_view.dart logic
  List<String> _getPossibleBadgesForAgeGroup(String ageGroup) {
    // Normalize the age group name first
    String normalizedAgeGroup = _normalizeAgeGroup(ageGroup);

    List<String> possibleBadges = [];
    if (normalizedAgeGroup == 'Mega Kickers') {
      possibleBadges.addAll([
        'lk_attention_listening', 'lk_sharing', 'lk_kicking', 'lk_confidence',
        'jk_kicking', 'jk_imagination', 'jk_physical_literacy', 'jk_team_player',
        'mk_leadership', 'mk_physical_literacy', 'mk_all_rounder', 'mk_problem_solver', 'mk_kicking', 'mk_match_play',
        'mega_attacking', 'mega_defending', 'mega_tactician', 'mega_captain', 'mega_all_rounder', 'mega_referee'
      ]);
    } else if (normalizedAgeGroup == 'Mighty Kickers') {
      possibleBadges.addAll([
        'lk_attention_listening', 'lk_sharing', 'lk_kicking', 'lk_confidence',
        'jk_kicking', 'jk_imagination', 'jk_physical_literacy', 'jk_team_player',
        'mk_leadership', 'mk_physical_literacy', 'mk_all_rounder', 'mk_problem_solver', 'mk_kicking', 'mk_match_play'
      ]);
    } else if (normalizedAgeGroup == 'Junior Kickers') {
      possibleBadges.addAll([
        'lk_attention_listening', 'lk_sharing', 'lk_kicking', 'lk_confidence',
        'jk_kicking', 'jk_imagination', 'jk_physical_literacy', 'jk_team_player'
      ]);
    } else {
      // Little Kicks or default
      possibleBadges.addAll([
        'lk_attention_listening', 'lk_sharing', 'lk_kicking', 'lk_confidence'
      ]);
    }
    return possibleBadges;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StudentParentViewModel>(context);

    print('DEBUG ParentProgressView BUILD: _isLoading = $_isLoading');
    print('DEBUG ParentProgressView BUILD: _ageGroup = $_ageGroup');
    print('DEBUG ParentProgressView BUILD: _earnedBadgeIds = $_earnedBadgeIds');
    print('DEBUG ParentProgressView BUILD: _currentBadgeId = $_currentBadgeId');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Child Progress"),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header with gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryRed, Color(0xFFC41A1F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(viewModel.childName ?? "Child"),
                      style: const TextStyle(fontSize: 28, color: AppTheme.primaryRed, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Name
                Text(
                  viewModel.childName ?? "Child Name",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),

                // Age Group
                Text(
                  _ageGroup,
                  style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress Summary Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: _cardDecoration(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                icon: Icons.emoji_events,
                                value: _earnedBadgeIds.length.toString(),
                                label: "Badges Earned",
                                color: AppTheme.pitchGreen,
                              ),
                              Container(
                                height: 50,
                                width: 1,
                                color: Colors.grey[300],
                              ),
                              _buildStatItem(
                                icon: Icons.trending_up,
                                value: "${(_earnedBadgeIds.length / _getPossibleBadgesForAgeGroup(_ageGroup).length * 100).toStringAsFixed(0)}%",
                                label: "Progress",
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Badge Progress Section
                        _buildSectionHeader("Badge Progress", Icons.emoji_events),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: _cardDecoration(),
                          child: BadgeGrid(
                            ageGroup: _ageGroup,
                            earnedBadgeIds: _earnedBadgeIds,
                            currentBadgeId: _currentBadgeId,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Current Goal Card (if there's a current badge)
                        if (_currentBadgeId != null) ...[
                          _buildSectionHeader("Current Goal", Icons.flag),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: _cardDecoration(),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.blue, width: 2),
                                  ),
                                  child: const Icon(Icons.star_border, color: Colors.blue, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _formatBadgeName(_currentBadgeId!),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppTheme.darkText,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        "Keep attending classes to earn this badge!",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    List<String> parts = name.split(' ');
    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : "?";
  }

  String _formatBadgeName(String badgeId) {
    // Convert badge_id to readable name
    return badgeId
        .replaceAll('lk_', 'Little Kicks: ')
        .replaceAll('jk_', 'Junior Kickers: ')
        .replaceAll('mk_', 'Mighty Kickers: ')
        .replaceAll('mega_', 'Mega Kickers: ')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
        .join(' ');
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryRed),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
      ],
    );
  }
}
