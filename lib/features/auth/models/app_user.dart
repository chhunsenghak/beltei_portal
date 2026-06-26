enum UserRole { student, teacher, admin }

class AppUser {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? avatarUrl;
  final String? phone;

  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    this.phone,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      email: map['email'] as String? ?? '',
      fullName: map['full_name'] as String? ?? '',
      role: UserRole.values.byName(map['role'] as String? ?? 'student'),
      avatarUrl: map['avatar_url'] as String?,
      phone: map['phone'] as String?,
    );
  }
}
