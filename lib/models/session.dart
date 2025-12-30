// e:\flutter\littlekickersapp\lib\models\session.dart
class Session {
  final String id;
  final String className;
  final String ageGroup; // e.g., "Little Kicks (1.5-2.5 yrs)"
  final DateTime startTime;
  final int durationMinutes;

  Session({
    required this.id,
    required this.className,
    required this.ageGroup,
    required this.startTime,
    required this.durationMinutes,
  });

  // Helper to check if session is theoretically over
  bool get isOvertime {
    final endTime = startTime.add(Duration(minutes: durationMinutes));
    return DateTime.now().isAfter(endTime);
  }
}
