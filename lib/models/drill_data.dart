class DrillData {
  String title;
  String duration;
  String instructions;
  String equipment;
  String progressionEasier;
  String progressionHarder;
  String learningGoals;
  String? animationUrl; // Optional animation URL

  DrillData({
    required this.title,
    required this.duration,
    required this.instructions,
    required this.equipment,
    required this.progressionEasier,
    required this.progressionHarder,
    required this.learningGoals,
    this.animationUrl,
  });

  // Factory constructor to create a blank drill
  factory DrillData.blank() {
    return DrillData(
      title: '',
      duration: '',
      instructions: '',
      equipment: '',
      progressionEasier: '',
      progressionHarder: '',
      learningGoals: '',
      animationUrl: null,
    );
  }
}