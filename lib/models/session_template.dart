import '../models/drill_data.dart';

class SessionTemplate {
  String id;
  String title;
  String ageGroup;
  String badgeFocus;
  List<DrillData> drills;
  DateTime createdAt;
  String? createdBy;
  String? pdfUrl;        // URL to the original PDF in Firebase Storage
  String? pdfFileName;   // Original filename of the PDF

  SessionTemplate({
    required this.id,
    required this.title,
    required this.ageGroup,
    required this.badgeFocus,
    required this.drills,
    required this.createdAt,
    this.createdBy,
    this.pdfUrl,
    this.pdfFileName,
  });

  // Factory constructor to create a blank session template
  factory SessionTemplate.blank() {
    return SessionTemplate(
      id: '',
      title: '',
      ageGroup: '',
      badgeFocus: '',
      drills: [],
      createdAt: DateTime.now(),
      createdBy: null,
      pdfUrl: null,
      pdfFileName: null,
    );
  }

  // Convert from Firestore document
  factory SessionTemplate.fromFirestore(Map<String, dynamic> data, String id) {
    List<DrillData> drills = [];

    if (data['drills'] != null && data['drills'] is List) {
      for (var drill in data['drills']) {
        if (drill is Map<String, dynamic>) {
          drills.add(DrillData(
            title: drill['title']?.toString() ?? '',
            duration: drill['duration']?.toString() ?? '',
            instructions: drill['instructions']?.toString() ?? '',
            equipment: drill['equipment']?.toString() ?? '',
            progressionEasier: drill['progression_easier']?.toString() ?? '',
            progressionHarder: drill['progression_harder']?.toString() ?? '',
            learningGoals: drill['learning_goals']?.toString() ?? '',
            animationUrl: drill['animationUrl']?.toString(),
          ));
        }
      }
    }

    return SessionTemplate(
      id: id,
      title: data['title']?.toString() ?? '',
      ageGroup: data['ageGroup']?.toString() ?? '',
      badgeFocus: data['badgeFocus']?.toString() ?? '',
      drills: drills,
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy']?.toString(),
      pdfUrl: data['pdfUrl']?.toString(),
      pdfFileName: data['pdfFileName']?.toString(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'ageGroup': ageGroup,
      'badgeFocus': badgeFocus,
      'drills': drills.map((drill) {
        return {
          'title': drill.title,
          'duration': drill.duration,
          'instructions': drill.instructions,
          'equipment': drill.equipment,
          'progression_easier': drill.progressionEasier,
          'progression_harder': drill.progressionHarder,
          'learning_goals': drill.learningGoals,
          'animationUrl': drill.animationUrl,
        };
      }).toList(),
      'createdAt': createdAt,
      'createdBy': createdBy,
      'pdfUrl': pdfUrl,
      'pdfFileName': pdfFileName,
    };
  }
}