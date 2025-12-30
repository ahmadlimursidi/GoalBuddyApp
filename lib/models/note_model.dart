class Note {
  final String id;
  final String text;
  final DateTime timestamp;

  Note({
    required this.id,
    required this.text,
    required this.timestamp,
  });

  // Factory constructor to create from Firestore map data
  factory Note.fromMap(Map<String, dynamic> data, String id) {
    return Note(
      id: id,
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as DateTime?) ?? DateTime.now(),
    );
  }

  // Convert to map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'timestamp': timestamp,
    };
  }
}