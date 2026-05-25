class UserProfileModel {
  UserProfileModel({
    required this.uid,
    required this.username,
    required this.email,
  });

  final String uid;
  final String username;
  final String email;

  factory UserProfileModel.fromMap(Map<String, dynamic> data) {
    return UserProfileModel(
      uid: (data['id'] ?? data['uid'] ?? '').toString(),
      username: (data['username'] as String? ?? '').trim(),
      email: (data['email'] as String? ?? '').trim(),
    );
  }
}
