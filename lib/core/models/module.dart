class Module {
  final String id;
  final String title;
  final String description;
  final int orderIndex; // Para el orden visual en el mapa

  Module({
    required this.id,
    required this.title,
    required this.description,
    this.orderIndex = 0,
  });

  Module copyWith({
    String? id,
    String? title,
    String? description,
    int? orderIndex,
  }) {
    return Module(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'orderIndex': orderIndex,
    };
  }

  factory Module.fromMap(Map<String, dynamic> map, String documentId) {
    return Module(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      orderIndex: map['orderIndex']?.toInt() ?? 0,
    );
  }
}
