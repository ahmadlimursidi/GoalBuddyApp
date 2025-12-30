// Utility class for managing Lottie animations in the app
class AnimationManager {
  // Map of drill types to their corresponding animation files
  static const Map<String, String> drillAnimations = {
    'dribbling': 'assets/animations/dribbling.json',
    'shooting': 'assets/animations/shooting.json',
    'passing': 'assets/animations/passing.json',
    'defending': 'assets/animations/defending.json',
    'warmup': 'assets/animations/warmup.json',
    'cool_down': 'assets/animations/cool_down.json',
    'fitness': 'assets/animations/fitness.json',
  };

  // Get animation path for a specific drill type
  static String getAnimationPath(String drillType) {
    return drillAnimations[drillType.toLowerCase()] ?? 
           'assets/animations/default.json';
  }

  // Check if animation exists for a drill type
  static bool hasAnimation(String drillType) {
    return drillAnimations.containsKey(drillType.toLowerCase());
  }

  // Get all available drill types
  static List<String> getAvailableDrillTypes() {
    return drillAnimations.keys.toList();
  }
}

// Enum for different drill categories
enum DrillCategory {
  dribbling('Dribbling'),
  shooting('Shooting'),
  passing('Passing'),
  defending('Defending'),
  warmup('Warm-up'),
  coolDown('Cool Down'),
  fitness('Fitness');

  final String displayName;
  const DrillCategory(this.displayName);

  String get animationPath {
    switch (this) {
      case DrillCategory.dribbling:
        return 'assets/animations/dribbling.json';
      case DrillCategory.shooting:
        return 'assets/animations/shooting.json';
      case DrillCategory.passing:
        return 'assets/animations/passing.json';
      case DrillCategory.defending:
        return 'assets/animations/defending.json';
      case DrillCategory.warmup:
        return 'assets/animations/warmup.json';
      case DrillCategory.coolDown:
        return 'assets/animations/cool_down.json';
      case DrillCategory.fitness:
        return 'assets/animations/fitness.json';
    }
  }
}