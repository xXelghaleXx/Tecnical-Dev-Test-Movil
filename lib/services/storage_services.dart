import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _serverIpKey = 'server_ip';

  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  // Inicializar SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Métodos para Token de autenticación
  Future<void> saveToken(String token) async {
    await init();
    await _prefs!.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    await init();
    return _prefs!.getString(_tokenKey);
  }

  Future<void> removeToken() async {
    await init();
    await _prefs!.remove(_tokenKey);
  }

  // Métodos para datos del usuario
  Future<void> saveUser(User user) async {
    await init();
    final userJson = json.encode(user.toJson());
    await _prefs!.setString(_userKey, userJson);
  }

  Future<User?> getUser() async {
    await init();
    final userJson = _prefs!.getString(_userKey);
    if (userJson != null) {
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    }
    return null;
  }

  Future<void> removeUser() async {
    await init();
    await _prefs!.remove(_userKey);
  }

  // Métodos para configuración del servidor
  Future<void> saveServerIp(String ip) async {
    await init();
    await _prefs!.setString(_serverIpKey, ip);
  }

  Future<String?> getServerIp() async {
    await init();
    return _prefs!.getString(_serverIpKey);
  }

  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    final user = await getUser();
    return token != null && user != null;
  }

  // Limpiar todos los datos de sesión
  Future<void> clearSession() async {
    await init();
    await _prefs!.remove(_tokenKey);
    await _prefs!.remove(_userKey);
  }

  // Limpiar todos los datos de la app
  Future<void> clearAll() async {
    await init();
    await _prefs!.clear();
  }

  // Métodos para configuraciones generales
  Future<void> setBool(String key, bool value) async {
    await init();
    await _prefs!.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    await init();
    return _prefs!.getBool(key);
  }

  Future<void> setString(String key, String value) async {
    await init();
    await _prefs!.setString(key, value);
  }

  Future<String?> getString(String key) async {
    await init();
    return _prefs!.getString(key);
  }

  Future<void> setInt(String key, int value) async {
    await init();
    await _prefs!.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    await init();
    return _prefs!.getInt(key);
  }

  Future<void> remove(String key) async {
    await init();
    await _prefs!.remove(key);
  }
}