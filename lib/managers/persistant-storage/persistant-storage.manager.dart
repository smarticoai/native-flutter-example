import 'package:shared_preferences/shared_preferences.dart';

class PersistantStorage {
  late SharedPreferences? _instance;

  PersistantStorage() : _instance = null;

  Future<void> initInstance() async {
    if (_instance != null) {
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    _instance = prefs;
  }

  Future<void> setString(String key, String value) async {
    if (_instance == null) {
      throw Exception('Instance not initialised!');
    }

    await _instance!.setString(key, value);
  }

  String? getString(String key) {
    if (_instance == null) {
      throw Exception('Instance not initialised!');
    }

    return _instance!.getString(key);
  }

  Future<void> setInt(String key, int value) async {
    if (_instance == null) {
      throw Exception('Instance not initialised!');
    }

    await _instance!.setInt(key, value);
  }

  Future<void> setBool(String key, bool value) async {
    if (_instance == null) {
      throw Exception('Instance not initialised!');
    }

    await _instance!.setBool(key, value);
  }

  int? getInt(String key) {
    if (_instance == null) {
      throw Exception('Instance not initialised!');
    }

    return _instance!.getInt(key);
  }

  bool? getBool(String key) {
    if (_instance == null) {
      throw Exception('Instance not initialised!');
    }

    return _instance!.getBool(key);
  }
}
