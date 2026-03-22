class AuthUser {
  final String id;
  final String email;
  final String name;
  final String token;

  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
  });
}
