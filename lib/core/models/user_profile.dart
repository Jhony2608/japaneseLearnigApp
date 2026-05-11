class UserProfile {
  final String uid;
  final String email;
  final String username;
  final int totalPoints;

  UserProfile({
    required this.uid,
    required this.email,
    required this.username,
    required this.totalPoints,
  });

  UserProfile copyWith({
    String? uid,
    String? email,
    String? username,
    int? totalPoints,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'totalPoints': totalPoints,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String documentId) {
    return UserProfile(
      uid: documentId,
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      totalPoints: map['totalPoints']?.toInt() ?? 0,
    );
  }
}
