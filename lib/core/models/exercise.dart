import 'dart:convert';

class Exercise {
  final String id;
  final String moduleId;
  final String type; // e.g. "multiple_choice", "matching", "drawing"
  final String question;
  final dynamic correctAnswer; // String, List, etc.
  final List<String>? options; // Opciones para ejercicios tipo quiz
  final List<dynamic>? waypoints; // Puntos de control para el Canvas

  Exercise({
    required this.id,
    required this.moduleId,
    required this.type,
    required this.question,
    required this.correctAnswer,
    this.options,
    this.waypoints,
  });

  Exercise copyWith({
    String? id,
    String? moduleId,
    String? type,
    String? question,
    dynamic correctAnswer,
    List<String>? options,
    List<dynamic>? waypoints,
  }) {
    return Exercise(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      type: type ?? this.type,
      question: question ?? this.question,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      options: options ?? this.options,
      waypoints: waypoints ?? this.waypoints,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'moduleId': moduleId,
      'type': type,
      'question': question,
      'correctAnswer': correctAnswer,
      if (options != null) 'options': options,
      if (waypoints != null) 'waypoints': waypoints,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map, String documentId) {
    // Lectura de la respuesta correcta directamente desde la raíz o fallbacks
    dynamic answerVal = map['correctAnswer'] ?? map['answer'] ?? map['data'];

    if (answerVal is String) {
      try {
        final fixedJson = answerVal.replaceAll("'", '"');
        answerVal = jsonDecode(fixedJson);
      } catch (e) {
        // Ignorar si no es JSON válido
      }
    }

    // Blindaje hiper-seguro para la lectura del array 'options' desde la raíz
    List<String>? parsedOptions;
    if (map.containsKey('options')) {
      parsedOptions = List<String>.from(map['options'] as Iterable? ?? []);
    } else if (answerVal is Map && answerVal.containsKey('options')) {
      // Fallback por si sigue metido en un mapa anidado (data)
      parsedOptions = List<String>.from(answerVal['options'] as Iterable? ?? []);
    }

    return Exercise(
      id: documentId,
      moduleId: map['moduleId'] ?? '',
      type: map['type'] ?? '',
      question: map['question'] ?? '',
      correctAnswer: answerVal,
      options: parsedOptions,
      waypoints: map['waypoints'] as List<dynamic>?,
    );
  }
}
