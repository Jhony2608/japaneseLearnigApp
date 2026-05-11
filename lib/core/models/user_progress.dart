class UserProgress {
  final String id;
  final String userId;
  final String moduleId;
  final bool isCompleted;
  final int score;

  UserProgress({
    required this.id,
    required this.userId,
    required this.moduleId,
    required this.isCompleted,
    required this.score,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'moduleId': moduleId,
      'isCompleted': isCompleted,
      'score': score,
    };
  }

  factory UserProgress.fromMap(Map<String, dynamic> map, String documentId) {
    return UserProgress(
      id: documentId,
      userId: map['userId'] ?? '',
      moduleId: map['moduleId'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      score: map['score']?.toInt() ?? 0,
    );
  }
}
