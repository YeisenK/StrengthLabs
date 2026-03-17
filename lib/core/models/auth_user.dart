class AuthUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String token;

  const AuthUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.token,
  });

  String get initial => firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';
  String get fullName => '$firstName $lastName'.trim();
}
