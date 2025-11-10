class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.nombreVisible,
    this.avatarUrl,
    this.bio,
  });

  final String id;
  final String email;
  final String nombreVisible;
  final String? avatarUrl;
  final String? bio;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      nombreVisible: json['nombreVisible'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'nombreVisible': nombreVisible,
        'avatarUrl': avatarUrl,
        'bio': bio,
      };
}
