class UserProfileModel {
  UserProfileModel({
    required this.uid,
    required this.username,
    required this.bio,
    required this.avatarUrl,
  });

  final String uid;
  final String username;
  final String bio;
  final String avatarUrl;

  factory UserProfileModel.fromMap(Map<String, dynamic> data) {
    return UserProfileModel(
      uid: (data['id'] ?? data['uid'] ?? '').toString(),
      username: (data['username'] as String? ?? '').trim(),
      bio: (data['bio'] as String? ?? '').trim(),
      avatarUrl: (data['avatar_url'] as String? ?? '').trim(),
    );
  }
}
