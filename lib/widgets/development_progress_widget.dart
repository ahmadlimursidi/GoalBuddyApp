import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../config/theme.dart';

class DevelopmentProgressWidget extends StatelessWidget {
  final String studentName;
  final String ageGroup;
  final Map<String, double> skillsProgress; // Skill name to progress percentage
  final List<String> milestones; // Completed milestones
  final List<String> achievements; // Achievements earned

  const DevelopmentProgressWidget({
    super.key,
    required this.studentName,
    required this.ageGroup,
    this.skillsProgress = const {},
    this.milestones = const [],
    this.achievements = const [],
  });

  @override
  Widget build(BuildContext context) {
    // Calculate overall development score based on skills
    double overallScore = skillsProgress.isNotEmpty
        ? skillsProgress.values.reduce((a, b) => a + b) / skillsProgress.length
        : 0.0;

    List<String> ageGroupSkills = _getAgeGroupSkills(ageGroup);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.school,
                  color: AppTheme.primaryRed,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Development Progress",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Overall progress indicator
            if (overallScore > 0)
              Row(
                children: [
                  CircularPercentIndicator(
                    radius: 60.0,
                    lineWidth: 8.0,
                    animation: true,
                    percent: overallScore / 100,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${overallScore.toStringAsFixed(0)}%",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          "Score",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: overallScore >= 80 
                        ? Colors.green 
                        : overallScore >= 60 
                            ? Colors.orange 
                            : Colors.red,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "For $ageGroup",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryRed,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$studentName's development",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            
            if (overallScore > 0) const SizedBox(height: 16),
            
            // Skills progress section
            if (skillsProgress.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Skills Development",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...ageGroupSkills.map((skill) {
                    double progress = skillsProgress[skill] ?? 0.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              skill,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: LinearPercentIndicator(
                              lineHeight: 8.0,
                              percent: progress / 100,
                              backgroundColor: Colors.grey[300],
                              progressColor: progress >= 80 
                                  ? Colors.green 
                                  : progress >= 60 
                                      ? Colors.orange 
                                      : Colors.red,
                              center: Text(
                                "${progress.toStringAsFixed(0)}%",
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            
            // Milestones and achievements
            if (milestones.isNotEmpty || achievements.isNotEmpty)
              const SizedBox(height: 16),
            
            if (milestones.isNotEmpty) ...[
              const Text(
                "Milestones",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: milestones.map((milestone) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 12, color: AppTheme.primaryRed),
                        const SizedBox(width: 4),
                        Text(
                          milestone,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryRed,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            
            if (achievements.isNotEmpty) ...[
              const Text(
                "Achievements",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: achievements.map((achievement) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 12, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          achievement,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
            
            // Empty state if no data
            if (overallScore == 0 && milestones.isEmpty && achievements.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.psychology_outlined,
                      size: 50,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Development Tracking",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Coaches will track your child's progress",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<String> _getAgeGroupSkills(String ageGroup) {
    switch (ageGroup) {
      case 'Little Kicks':
        return [
          'Basic Movement',
          'Ball Control',
          'Following Instructions',
          'Social Interaction',
        ];
      case 'Junior Kickers':
        return [
          'Dribbling',
          'Passing',
          'Shooting',
          'Team Work',
        ];
      case 'Mighty Kickers':
        return [
          'Advanced Dribbling',
          'Controlled Passing',
          'Accurate Shooting',
          'Game Understanding',
        ];
      case 'Mega Kickers':
        return [
          'Strategic Play',
          'Advanced Techniques',
          'Leadership',
          'Sportsmanship',
        ];
      default:
        return [
          'Movement',
          'Ball Skills',
          'Social Skills',
        ];
    }
  }
}