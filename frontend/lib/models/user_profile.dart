class UserProfile {
  final String sub;
  final String username;
  final String name;
  final String email;

  const UserProfile({
    required this.sub,
    required this.username,
    required this.name,
    required this.email,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final username = json['preferred_username'] as String? ?? '';
    final name = json['name'] as String? ?? '';
    return UserProfile(
      sub: json['sub']?.toString() ?? '',
      username: username,
      name: name.isNotEmpty ? name : username,
      email: json['email'] as String? ?? '',
    );
  }
}