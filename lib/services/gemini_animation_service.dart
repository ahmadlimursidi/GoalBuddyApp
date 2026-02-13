import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/drill_animation_data.dart';
import '../config/api_keys.dart';

class GeminiAnimationService {
  static const String _apiKey = ApiKeys.geminiApiKey;
  late final GenerativeModel _model;

  GeminiAnimationService() {
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: _apiKey,
    );
  }

  /// Generate animation data from drill instructions
  /// This is SAFE because we only parse JSON data, not execute code
  Future<DrillAnimationData?> generateAnimation({
    required String drillTitle,
    required String instructions,
    required String equipment,
    String? progressionEasier,
    String? progressionHarder,
  }) async {
    try {
      final prompt = _buildPrompt(
        drillTitle: drillTitle,
        instructions: instructions,
        equipment: equipment,
        progressionEasier: progressionEasier,
        progressionHarder: progressionHarder,
      );

      print('🤖 Sending to Gemini: Generating animation for "$drillTitle"');

      final content = Content.text(prompt);
      final response = await _model.generateContent([content]);

      if (response.text == null) {
        print('❌ Gemini returned null response');
        return null;
      }

      // Clean up the response (remove markdown code blocks if present)
      String cleanJson = response.text!
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      print('📦 Gemini response (cleaned): ${cleanJson.substring(0, cleanJson.length > 200 ? 200 : cleanJson.length)}...');

      // Parse the JSON into our safe data model
      Map<String, dynamic> jsonData = jsonDecode(cleanJson);
      DrillAnimationData animationData = DrillAnimationData.fromJson(jsonData);

      print('✅ Animation generated: ${animationData.players.length} players, ${animationData.balls.length} balls');

      return animationData;
    } catch (e) {
      print('❌ Gemini Animation Error: $e');
      return null;
    }
  }

  String _buildPrompt({
    required String drillTitle,
    required String instructions,
    required String equipment,
    String? progressionEasier,
    String? progressionHarder,
  }) {
    return '''
You are a football coaching animation expert. Analyze this drill and generate a simple top-down tactical animation.

DRILL INFORMATION:
Title: $drillTitle
Instructions: $instructions
Equipment: $equipment
${progressionEasier != null ? 'Easier Version: $progressionEasier' : ''}
${progressionHarder != null ? 'Harder Version: $progressionHarder' : ''}

TASK:
Create a JSON animation showing the drill from a top-down view. The animation should be simple, clear, and educational.

IMPORTANT RULES:
1. Use normalized coordinates (0.0 to 1.0) where:
   - x: 0.0 = left edge, 1.0 = right edge
   - y: 0.0 = top edge, 1.0 = bottom edge
   - Center of field is (0.5, 0.5)

2. Create 2-4 players maximum (keep it simple)

3. Each player should have 2-5 waypoints showing their movement path

4. Add timing to waypoints (time_ms) to create realistic movement:
   - Walking speed: ~2000ms between points
   - Running speed: ~1000ms between points
   - Sprint: ~500ms between points

5. Include equipment (cones, goals) as static markers

6. If the drill involves passing, create ball movement paths

7. Use these colors:
   - Players: "#FF0000" (red), "#0000FF" (blue), "#00FF00" (green), "#FFFF00" (yellow)
   - Coaches: "#808080" (grey)
   - Balls: "#FFFFFF" (white)
   - Cones: "#FFA500" (orange)
   - Skittles (flat cones): "#FF6B6B" (coral) - render as smaller circles
   - Hoops: "#9B59B6" (purple) - render as rings/circles
   - Goals: "#FFD700" (gold)

RETURN ONLY THIS JSON STRUCTURE (no extra text):
{
  "description": "Brief description of what the animation shows",
  "duration_ms": 5000,
  "players": [
    {
      "id": "player1",
      "label": "P1",
      "color": "#FF0000",
      "path": [
        {"x": 0.2, "y": 0.5, "time_ms": 0},
        {"x": 0.5, "y": 0.3, "time_ms": 1000},
        {"x": 0.8, "y": 0.5, "time_ms": 2000}
      ]
    }
  ],
  "balls": [
    {
      "id": "ball1",
      "is_dribbled": false,
      "path": [
        {"x": 0.2, "y": 0.5, "time_ms": 0},
        {"x": 0.8, "y": 0.5, "time_ms": 1500}
      ]
    }
  ],
  "equipment": [
    {
      "type": "cone",
      "color": "#FFA500",
      "position": {"x": 0.5, "y": 0.5}
    },
    {
      "type": "skittle",
      "color": "#FF6B6B",
      "position": {"x": 0.3, "y": 0.5}
    },
    {
      "type": "hoop",
      "color": "#9B59B6",
      "position": {"x": 0.7, "y": 0.5}
    },
    {
      "type": "coach",
      "color": "#808080",
      "position": {"x": 0.1, "y": 0.5}
    }
  ]
}

Now generate the animation JSON for the drill described above.
''';
  }
}
