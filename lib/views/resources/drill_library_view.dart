import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../view_models/drill_library_view_model.dart';
import 'activity_detail_view.dart';

class DrillLibraryView extends StatefulWidget {
  const DrillLibraryView({super.key});

  @override
  State<DrillLibraryView> createState() => _DrillLibraryViewState();
}

class _DrillLibraryViewState extends State<DrillLibraryView> {
  bool _showFilters = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load activities when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<DrillLibraryViewModel>(context, listen: false);
      viewModel.loadActivities();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Activity Library"),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          // Filter toggle button
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          // Reset filters button
          Consumer<DrillLibraryViewModel>(
            builder: (context, viewModel, child) {
              final hasActiveFilters = viewModel.selectedAgeGroup != 'All' ||
                  viewModel.selectedBadgeFocus != 'All' ||
                  viewModel.selectedDrillType != 'All' ||
                  viewModel.selectedTemplate != 'All' ||
                  viewModel.searchQuery.isNotEmpty;

              if (!hasActiveFilters) return const SizedBox.shrink();

              return IconButton(
                icon: const Icon(Icons.clear_all),
                tooltip: 'Reset Filters',
                onPressed: () {
                  _searchController.clear();
                  viewModel.resetFilters();
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<DrillLibraryViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryRed),
            );
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${viewModel.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadActivities(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => viewModel.setSearchQuery(value),
                  decoration: InputDecoration(
                    hintText: 'Search activities...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primaryRed),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              viewModel.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),

              // Filter Section
              if (_showFilters) _buildFilterSection(viewModel),

              // Results count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.white,
                child: Row(
                  children: [
                    Icon(Icons.sports_soccer, size: 18, color: AppTheme.primaryRed),
                    const SizedBox(width: 8),
                    Text(
                      '${viewModel.filteredActivities.length} Activities Found',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'From ${viewModel.allActivities.map((a) => a.templateTitle).toSet().length} Templates',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Activities List
              Expanded(
                child: viewModel.filteredActivities.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: viewModel.filteredActivities.length,
                        itemBuilder: (context, index) {
                          final activity = viewModel.filteredActivities[index];
                          return _buildActivityCard(context, activity);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(DrillLibraryViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tune, size: 20, color: AppTheme.primaryRed),
              SizedBox(width: 8),
              Text(
                'Filter Activities',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Age Group Filter
          _buildFilterRow(
            label: 'Age Group',
            icon: Icons.child_care,
            options: viewModel.ageGroups,
            selectedValue: viewModel.selectedAgeGroup,
            onChanged: (value) => viewModel.setSelectedAgeGroup(value!),
          ),
          const SizedBox(height: 12),

          // Badge Focus Filter
          _buildFilterRow(
            label: 'Badge Focus',
            icon: Icons.emoji_events,
            options: viewModel.badgeFocuses,
            selectedValue: viewModel.selectedBadgeFocus,
            onChanged: (value) => viewModel.setSelectedBadgeFocus(value!),
          ),
          const SizedBox(height: 12),

          // Drill Type Filter
          _buildFilterRow(
            label: 'Activity Type',
            icon: Icons.category,
            options: viewModel.drillTypes,
            selectedValue: viewModel.selectedDrillType,
            onChanged: (value) => viewModel.setSelectedDrillType(value!),
          ),
          const SizedBox(height: 12),

          // Template Filter
          _buildFilterRow(
            label: 'From Template',
            icon: Icons.library_books,
            options: viewModel.templateTitles,
            selectedValue: viewModel.selectedTemplate,
            onChanged: (value) => viewModel.setSelectedTemplate(value!),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow({
    required String label,
    required IconData icon,
    required List<String> options,
    required String selectedValue,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppTheme.primaryRed),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedValue,
              hint: Text(label),
              items: options.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: option == 'All' ? FontWeight.w600 : FontWeight.normal,
                      color: option == 'All' ? AppTheme.primaryRed : AppTheme.darkText,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(BuildContext context, TemplateActivity activity) {
    final drillTypeColor = _getColorForDrillType(activity.drillType);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ActivityDetailView(activity: activity),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Drill Type Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: drillTypeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconForDrillType(activity.drillType),
                        color: drillTypeColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Activity Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.drillData.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkText,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Text(
                                '${activity.drillData.duration} min',
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

                const SizedBox(height: 12),

                // Tags Row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Drill Type Badge
                    _buildBadge(
                      activity.drillType,
                      drillTypeColor,
                      Icons.category,
                    ),
                    // Age Group Badge
                    _buildBadge(
                      activity.ageGroup,
                      Colors.blue,
                      Icons.child_care,
                    ),
                    // Badge Focus
                    _buildBadge(
                      activity.badgeFocus,
                      AppTheme.pitchGreen,
                      Icons.emoji_events,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Template Source
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.library_books, size: 12, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'From: ${activity.templateTitle}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[700],
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
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
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
            child: Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            'No activities found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Color _getColorForDrillType(String type) {
    switch (type) {
      case 'Intro / Muster':
        return AppTheme.primaryRed;
      case 'Warm Up':
        return Colors.orange;
      case 'Match / Game':
        return AppTheme.pitchGreen;
      case 'Technical / Skill':
        return Colors.blue;
      default:
        return Colors.purple;
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
