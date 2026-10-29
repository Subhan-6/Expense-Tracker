import 'package:shared_preferences/shared_preferences.dart';

/// Small key-value settings (currently only the user's own API key).
class SettingsRepository {
  static const String _apiKey = 'anthropic_api_key';

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKey);
  }

  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKey, key);
  }

  Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKey);
  }
}
