class Drill {
  final String title;
  final String category; // e.g., Warm Up, Technical
  final String instructions;
  final int durationSeconds;
  final String icon; // Icon name as string
  final String? animationSource; // Path to Rive file or GIF asset (deprecated - use animationUrl)
  final List<String>? animationSteps; // List of animation step image paths for step-by-step guide
  final List<String>? stepInstructions; // List of text instructions for each animation step
  final String ageGroup; // Age group for the drill (e.g., Little Kicks, Junior Kickers)
  final String? animationUrl; // URL to uploaded animation file (Lottie, video, image, GIF)
  final String? animationJson; // JSON string of AI-generated DrillAnimationData
  final String? visualType; // "animation", "video", "image", "gif", or null

  Drill({
    required this.title,
    required this.category,
    required this.instructions,
    required this.durationSeconds,
    required this.icon,
    this.animationSource,
    this.animationSteps,
    this.stepInstructions,
    required this.ageGroup,
    this.animationUrl,
    this.animationJson,
    this.visualType,
  });

  factory Drill.fromMap(dynamic data) {
    // Handle null data gracefully
    if (data == null || data is! Map<String, dynamic>) {
      return Drill(
        title: 'Unknown Drill',
        category: 'General',
        instructions: '',
        durationSeconds: 300,
        icon: 'sports_soccer',
        animationSource: null,
        animationSteps: null,
        stepInstructions: null,
        ageGroup: 'General',
        animationUrl: null,
        animationJson: null,
        visualType: null,
      );
    }

    // Safe type casting and null checking for each field
    Map<String, dynamic> mapData = data;

    return Drill(
      title: mapData['title'] as String? ?? 'Unknown Drill',
      category: mapData['category'] as String? ?? 'General',
      instructions: mapData['instructions'] as String? ?? '',
      durationSeconds: mapData['durationSeconds'] as int? ?? 300,
      icon: mapData['icon'] as String? ?? 'sports_soccer',
      animationSource: mapData['animationSource'] as String?,
      animationSteps: (mapData['animationSteps'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      stepInstructions: (mapData['stepInstructions'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      ageGroup: mapData['ageGroup'] as String? ?? 'General',
      animationUrl: mapData['animationUrl'] as String?,
      animationJson: mapData['animationJson'] as String?,
      visualType: mapData['visualType'] as String?,
    );
  }

  /// Getter that returns the sort order based on Little Kickers SOP
  int get sortOrder {
    switch (category.toLowerCase()) {
      case 'intro':
      case 'muster':
      case 'intro / muster':
        return 0; // First: Intro / Muster
      case 'warm up':
        return 1; // Second: Warm Up
      case 'technical':
      case 'skill':
      case 'ball mastery':
      case 'technical / skill':
        return 2; // Third: Technical / Skill / Ball Mastery
      case 'match':
      case 'game':
      case 'fun game':
      case 'match / game':
        return 3; // Fourth: Match / Game
      default:
        return 999; // Any other categories go to the end
    }
  }
}