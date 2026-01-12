import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;
  static const String _authTokenKey = 'auth_token';

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static bool isLoggedIn() {
    if (_prefs == null) return false;
    return _prefs!.getString(_authTokenKey) != null;
  }

  static Future<bool> setAuthToken(String token) async {
    await init();
    return await _prefs!.setString(_authTokenKey, token);
  }

  static String? getAuthToken() {
    if (_prefs == null) return null;
    return _prefs!.getString(_authTokenKey);
  }

  static Future<bool> clearAuth() async {
    await init();
    return await _prefs!.remove(_authTokenKey);
  }

  static const String _selectedEntityIdKey = 'selected_entity_id';
  static const String _selectedEntityNameKey = 'selected_entity_name';

  static Future<bool> saveSelectedEntity(int id, String name) async {
    await init();
    await _prefs!.setInt(_selectedEntityIdKey, id);
    return await _prefs!.setString(_selectedEntityNameKey, name);
  }

  static Map<String, dynamic>? getSelectedEntity() {
    if (_prefs == null) return null;
    final id = _prefs!.getInt(_selectedEntityIdKey);
    final name = _prefs!.getString(_selectedEntityNameKey);
    if (id != null && name != null) {
      return {'id': id, 'name': name};
    }
    return null;
  }

  static const String _selectedActivityIdKey = 'selected_activity_id';
  static const String _selectedActivityNameKey = 'selected_activity_name';

  static Future<bool> saveSelectedActivity(int id, String name) async {
    await init();
    await _prefs!.setInt(_selectedActivityIdKey, id);
    return await _prefs!.setString(_selectedActivityNameKey, name);
  }

  static Map<String, dynamic>? getSelectedActivity() {
    if (_prefs == null) return null;
    final id = _prefs!.getInt(_selectedActivityIdKey);
    final name = _prefs!.getString(_selectedActivityNameKey);
    if (id != null && name != null) {
      return {'id': id, 'name': name};
    }
    return null;
  }
}

