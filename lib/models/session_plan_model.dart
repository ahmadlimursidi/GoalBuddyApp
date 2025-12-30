// e:\flutter\littlekickersapp\lib\models\session_plan_model.dart

class Drill {
  final String title;
  final int durationSeconds;
  final String category;
  final String instructions;
  final String iconUrl; // Using simple emojis as placeholders

  Drill({
    required this.title,
    required this.durationSeconds,
    required this.category,
    required this.instructions,
    required this.iconUrl,
  });
}

class SessionPlan {
  final List<Drill> drills;
  final int totalDuration; // in minutes

  SessionPlan({
    required this.drills,
    required this.totalDuration,
  });

  /// Generates a mock session plan for a typical Junior Kickers class.
  static SessionPlan getMockJuniorKickersPlan() {
    return SessionPlan(
      totalDuration: 45,
      drills: [
        Drill(
          title: "Traffic Lights",
          durationSeconds: 300, // 5 mins
          category: "Warm-up",
          instructions: "Run on green, slow down on yellow, stop on red. Listen for the coach's call!",
          iconUrl: "🚦",
        ),
        Drill(
          title: "Dribble & Weave",
          durationSeconds: 600, // 10 mins
          category: "Technical",
          instructions: "Dribble the ball in and out of the cones. Keep the ball close to your feet.",
          iconUrl: "⚽",
        ),
        Drill(
          title: "Penalty Shootout",
          durationSeconds: 600, // 10 mins
          category: "Game",
          instructions: "Take turns shooting at the goal. Try to score past the coach!",
          iconUrl: "🥅",
        ),
        Drill(
          title: "Cool Down",
          durationSeconds: 300, // 5 mins
          category: "Cool-down",
          instructions: "Follow the coach to stretch your legs, arms, and back.",
          iconUrl: "🧘",
        ),
      ],
    );
  }
}