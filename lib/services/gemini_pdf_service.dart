import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // ⚠️ Replace with your actual key from aistudio.google.com
  static const String _apiKey = 'AIzaSyCxMNaouejURaEqASAXaJ9r_GO3t9IC1Qs';

  late final GenerativeModel _model;

  GeminiService() {
    // Using Gemini 3.0 Flash model
    _model = GenerativeModel(
      model: 'gemini-3.0-flash-preview',
      apiKey: _apiKey,
    );
  }

  Future<String?> extractLessonPlan(Uint8List pdfBytes) async {
    try {
      final prompt = TextPart(
          "Analyze this football lesson plan PDF. It contains multiple drills/activities (e.g., Warm Up, Main Game, Penalty, Match). "
          "Extract the data into a structured JSON object with a list of activities."
          "Return clean JSON ONLY (no markdown formatting). Structure:"
          "{"
          "  'title': 'String (e.g. Junior Kickers Week 5)',"
          "  'duration_minutes': int,"
          "  'badge_focus': 'String',"
          "  'age_group': 'String',"
          "  'drills': ["
          "    {"
          "      'title': 'String (e.g. Warm Up Game - Farmer Relay)',"
          "      'duration_min': int (estimate if not explicit),"
          "      'instructions': 'String',"
          "      'equipment': ['String'],"
          "      'progression_easier': 'String',"
          "      'progression_harder': 'String',"
          "      'learning_goals': ['String']"
          "    }"
          "  ]"
          "}"
      );

      final pdfData = DataPart('application/pdf', pdfBytes);
      
      final content = Content.multi([prompt, pdfData]);
      final response = await _model.generateContent([content]);

      return response.text;
    } catch (e) {
      print('❌ Gemini API Error: $e');
      return null;
    }
  }
}