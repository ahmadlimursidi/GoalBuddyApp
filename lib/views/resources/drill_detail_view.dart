import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/drill_model.dart';

class DrillDetailView extends StatefulWidget {
  final Drill drill;

  const DrillDetailView({super.key, required this.drill});

  @override
  State<DrillDetailView> createState() => _DrillDetailViewState();
}

class _DrillDetailViewState extends State<DrillDetailView> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.drill.title),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drill Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _getColorForCategory(widget.drill.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getColorForCategory(widget.drill.category).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getColorForCategory(widget.drill.category),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIconForCategory(widget.drill.category),
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
                                widget.drill.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.drill.category,
                                style: TextStyle(
                                  color: _getColorForCategory(widget.drill.category),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.access_time,
                          "${widget.drill.durationSeconds ~/ 60} min",
                          AppTheme.primaryRed,
                        ),
                        const SizedBox(width: 12),
                        _buildInfoChip(
                          Icons.group,
                          widget.drill.ageGroup,
                          AppTheme.pitchGreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),

              // Animation Section (Step-by-step or single animation)
              if (widget.drill.animationSteps != null && widget.drill.animationSteps!.isNotEmpty) ...[
                const Text(
                  "Animation Steps",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // PageView for animation steps instead of CarouselSlider
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    itemCount: widget.drill.animationSteps?.length ?? 0,
                    onPageChanged: (index) {
                      setState(() {
                        _currentStep = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      String stepImage = widget.drill.animationSteps![index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[200],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: stepImage.startsWith('assets/') || stepImage.startsWith('http')
                              ? Image.network(
                                  stepImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.image_not_supported,
                                      size: 80,
                                      color: Colors.grey,
                                    );
                                  },
                                )
                              : Icon(
                                  _getIconForCategory(widget.drill.category),
                                  size: 80,
                                  color: _getColorForCategory(widget.drill.category),
                                ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // Step indicators (dots)
                if ((widget.drill.animationSteps?.length ?? 0) > 1)
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.drill.animationSteps?.length ?? 0,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == _currentStep
                                ? _getColorForCategory(widget.drill.category)
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
              ] else if (widget.drill.animationSource != null) ...[
                // Single animation if available
                const Text(
                  "Animation Preview",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: widget.drill.animationSource!.startsWith('assets/') || 
                            widget.drill.animationSource!.startsWith('http')
                        ? Image.network(
                            widget.drill.animationSource!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image_not_supported,
                                size: 80,
                                color: Colors.grey,
                              );
                            },
                          )
                        : Icon(
                            _getIconForCategory(widget.drill.category),
                            size: 80,
                            color: _getColorForCategory(widget.drill.category),
                          ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],

              // Instructions Section
              const Text(
                "Instructions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  widget.drill.instructions,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      
      // Floating Action Button to "Use in Session"
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryRed,
        onPressed: () {
          // In a real app, this could add the drill to the current active session
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Added '${widget.drill.title}' to session"),
            ),
          );
        },
        label: const Text("Use in Session"),
        icon: const Icon(Icons.add_task),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
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