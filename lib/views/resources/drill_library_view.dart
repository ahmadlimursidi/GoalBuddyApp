import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../view_models/drill_library_view_model.dart';
import '../../models/drill_model.dart';
import 'drill_detail_view.dart';

class DrillLibraryView extends StatefulWidget {
  const DrillLibraryView({super.key});

  @override
  State<DrillLibraryView> createState() => _DrillLibraryViewState();
}

class _DrillLibraryViewState extends State<DrillLibraryView> {
  @override
  void initState() {
    super.initState();
    // Load drills when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<DrillLibraryViewModel>(context, listen: false);
      viewModel.loadDrills();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Drill Library"),
        centerTitle: false,
      ),
      body: Consumer<DrillLibraryViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
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
                    onPressed: () => viewModel.loadDrills(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filter Tabs (Horizontal scrollable pills)
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: viewModel.ageGroups.map((ageGroup) {
                    bool isSelected = viewModel.selectedAgeGroup == ageGroup;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () => viewModel.setSelectedAgeGroup(ageGroup),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryRed : Colors.white,
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryRed : Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                          child: Text(
                            ageGroup,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade700,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Display count of drills found
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Consumer<DrillLibraryViewModel>(
                      builder: (context, vm, child) {
                        return Text(
                          "${vm.filteredDrills.length} Drills for ${vm.selectedAgeGroup}",
                          style: const TextStyle(color: Colors.grey),
                        );
                      },
                    ),
                    Text(
                      "Tap to view details",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Drill Grid
              Expanded(
                child: viewModel.filteredDrills.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.library_books_outlined, size: 60, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              "No drills found",
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            Text(
                              "Try selecting a different age group",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1, // Single column as requested
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 3.0, // Wider rectangle for single column
                        ),
                        itemCount: viewModel.filteredDrills.length,
                        itemBuilder: (context, index) {
                          final drill = viewModel.filteredDrills[index];
                          return _buildDrillCard(context, drill);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrillCard(BuildContext context, Drill drill) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTheme.primaryRed.withOpacity(0.1),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to drill detail view
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DrillDetailView(drill: drill),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon/Thumbnail
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getColorForCategory(drill.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getColorForCategory(drill.category),
                  ),
                ),
                child: Icon(
                  _getIconForCategory(drill.category),
                  color: _getColorForCategory(drill.category),
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      drill.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Category tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getColorForCategory(drill.category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getColorForCategory(drill.category).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        drill.category,
                        style: TextStyle(
                          color: _getColorForCategory(drill.category),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Duration
                    Text(
                      "${drill.durationSeconds ~/ 60} min",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow indicator
              Icon(
                Icons.chevron_right,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'warm up':
        return Colors.orange;
      case 'technical':
      case 'skill':
      case 'ball mastery':
      case 'technical / skill':
        return Colors.blue;
      case 'match':
      case 'game':
      case 'fun game':
      case 'match / game':
        return AppTheme.pitchGreen;
      case 'intro':
      case 'muster':
      case 'intro / muster':
      default:
        return AppTheme.primaryRed;
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'warm up':
        return Icons.directions_run;
      case 'technical':
      case 'skill':
      case 'ball mastery':
      case 'technical / skill':
        return Icons.psychology;
      case 'match':
      case 'game':
      case 'fun game':
      case 'match / game':
        return Icons.sports_soccer;
      case 'intro':
      case 'muster':
      case 'intro / muster':
      default:
        return Icons.waving_hand;
    }
  }
}