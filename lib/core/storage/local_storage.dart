import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

abstract class LocalStorage {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
}

@Injectable(as: LocalStorage)
class LocalStorageImpl implements LocalStorage {
  final SharedPreferences _prefs;
  
  static const _tokenKey = 'auth_token_key';

  LocalStorageImpl(this._prefs);

  @override
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  @override
  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  @override
  Future<void> deleteToken() async {
    await _prefs.remove(_tokenKey);
  }
}
