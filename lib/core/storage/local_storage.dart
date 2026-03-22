import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'dart:convert';
import 'package:physigest/features/auth/domain/entities/auth_user.dart';


abstract class LocalStorage {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
  String? getTokenSync();
  Future<void> saveUser(AuthUser user);
  Future<AuthUser?> getUser();
  Future<void> deleteUser();
  String? getUserName();
}