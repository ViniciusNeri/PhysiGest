import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:physigest/core/storage/local_storage.dart';
import 'package:physigest/features/auth/data/models/auth_user_model.dart';
import 'package:physigest/features/auth/domain/entities/auth_user.dart';

@Injectable(as: LocalStorage)
class LocalStorageImpl implements LocalStorage {
  final SharedPreferences _prefs;
  
  static const _tokenKey = 'auth_token_key';
  static const _userKey = 'cached_user';

  LocalStorageImpl(this._prefs);

 @override
Future<void> saveToken(String token) async {
  try {
    final prefs = await SharedPreferences.getInstance(); 
    await prefs.setString(_tokenKey, token);
  } catch (e) {
    print("Erro ao salvar no LocalStorage: $e");
  }
}

  @override
  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  @override
  Future<void> deleteToken() async {
    await _prefs.remove(_tokenKey);
  }

  @override
  String? getTokenSync() {
    return _prefs.getString(_tokenKey);
  }

  @override
  Future<void> saveUser(AuthUser user) async {
    final userModel = AuthUserModel(
    id: user.id,
    email: user.email,
    name: user.name,
    token: user.token,
  );
  await _prefs.setString(_userKey, jsonEncode(userModel.toJson()));
  }

  @override
  Future<AuthUser?> getUser() async {
    final json = _prefs.getString(_userKey);
    if (json == null) return null;
    return AuthUserModel.fromJson(jsonDecode(json));
  }

  @override
  Future<void> deleteUser() async {
    await _prefs.remove(_userKey);
  }

  @override
  String? getUserName() {
    final json = _prefs.getString(_userKey);
    if (json == null) return null;
    return AuthUserModel.fromJson(jsonDecode(json)).name;
  }

}