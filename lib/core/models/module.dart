class Module {
  final String id;
  final String title;
  final String description;
  final int orderIndex; // Para el orden visual en el mapa
  final bool isReview; // Indica si este módulo es un examen aleatorio

  Module({
    required this.id,
    required this.title,
    required this.description,
    this.orderIndex = 0,
    this.isReview = false,
  });

  Module copyWith({
    String? id,
    String? title,
    String? description,
    int? orderIndex,
    bool? isReview,
  }) {
    return Module(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      orderIndex: orderIndex ?? this.orderIndex,
      isReview: isReview ?? this.isReview,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'orderIndex': orderIndex,
      'isReview': isReview,
    };
  }

  factory Module.fromMap(Map<String, dynamic> map, String documentId) {
    return Module(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      orderIndex: map['orderIndex']?.toInt() ?? 0,
      isReview: map['isReview'] ?? false,
    );
  }
}
