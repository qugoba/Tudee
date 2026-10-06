import 'package:shared_preferences/shared_preferences.dart';

/// Key-value storage (shared_preferences) used for the user's name.
class LocalStorageService {
  static const _userNameKey = 'userName';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String? getUserName() {
    final name = _prefs.getString(_userNameKey)?.trim();
    return (name == null || name.isEmpty) ? null : name;
  }

  static Future<bool> saveUserName(String name) {
    return _prefs.setString(_userNameKey, name);
  }

  static Future<bool> removeUserName() => _prefs.remove(_userNameKey);

  static String? getString(String key) => _prefs.getString(key);

  static Future<bool> remove(String key) => _prefs.remove(key);
}
