import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.token,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id']?.toString() ?? json['user']?['id']?.toString() ?? '',
      email: json['email'] ?? json['user']?['email'] ?? '',
      name: json['name'] ?? json['user']?['name'] ?? '',
      token: json['token'] ?? json['access_token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': {'id': id, 'name': name, 'email': email},
      'token': token,
    };
  }
}
