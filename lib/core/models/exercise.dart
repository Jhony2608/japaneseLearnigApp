class Exercise {
  final String id;
  final String moduleId;
  final String type; // e.g. "multiple_choice", "matching", "drawing"
  final String question;
  final dynamic correctAnswer; // String, List, etc.
  final List<dynamic>? waypoints; // Puntos de control para el Canvas

  Exercise({
    required this.id,
    required this.moduleId,
    required this.type,
    required this.question,
    required this.correctAnswer,
    this.waypoints,
  });

  Exercise copyWith({
    String? id,
    String? moduleId,
    String? type,
    String? question,
    dynamic correctAnswer,
    List<dynamic>? waypoints,
  }) {
    return Exercise(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      type: type ?? this.type,
      question: question ?? this.question,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      waypoints: waypoints ?? this.waypoints,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'moduleId': moduleId,
      'type': type,
      'question': question,
      'correctAnswer': correctAnswer,
      if (waypoints != null) 'waypoints': waypoints,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map, String documentId) {
    return Exercise(
      id: documentId,
      moduleId: map['moduleId'] ?? '',
      type: map['type'] ?? '',
      question: map['question'] ?? '',
      correctAnswer: map['correctAnswer'],
      waypoints: map['waypoints'] as List<dynamic>?,
    );
  }
}
