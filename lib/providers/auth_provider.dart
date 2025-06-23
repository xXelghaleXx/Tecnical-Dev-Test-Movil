import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/api_response.dart';
import '../services/storage_services.dart';
import '../config/api_config.dart';

class AuthProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _user != null;

  AuthProvider() {
    _loadUserData();
  }

  // Cargar datos del usuario desde almacenamiento local
  Future<void> _loadUserData() async {
    try {
      _token = await _storageService.getToken();
      _user = await _storageService.getUser();
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar datos del usuario';
      notifyListeners();
    }
  }

  // Guardar datos del usuario en almacenamiento local
  Future<void> _saveUserData() async {
    if (_token != null && _user != null) {
      await _storageService.saveToken(_token!);
      await _storageService.saveUser(_user!);
    }
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Iniciar sesión
  Future<ApiResponse<User>> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: ApiConfig.defaultHeaders,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        _token = data['token'];
        _user = User.fromJson(data['user']);
        await _saveUserData();
        _isLoading = false;
        notifyListeners();
        
        return ApiResponse<User>.success(
          message: data['message'],
          data: _user,
        );
      } else {
        _error = data['message'] ?? 'Error en el login';
        _isLoading = false;
        notifyListeners();
        
        return ApiResponse<User>.error(
          message: data['message'] ?? 'Error en el login',
        );
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      
      return ApiResponse<User>.error(
        message: 'Error de conexión: $e',
      );
    }
  }

  // Registrar usuario
  Future<ApiResponse<User>> register(
    String username,
    String email,
    String password,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.registerUrl),
        headers: ApiConfig.defaultHeaders,
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        _token = data['token'];
        _user = User.fromJson(data['user']);
        await _saveUserData();
        _isLoading = false;
        notifyListeners();
        
        return ApiResponse<User>.success(
          message: data['message'],
          data: _user,
        );
      } else {
        _error = data['message'] ?? 'Error en el registro';
        _isLoading = false;
        notifyListeners();
        
        return ApiResponse<User>.error(
          message: data['message'] ?? 'Error en el registro',
        );
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      
      return ApiResponse<User>.error(
        message: 'Error de conexión: $e',
      );
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    _user = null;
    _token = null;
    _error = null;
    
    await _storageService.clearSession();
    notifyListeners();
  }

  // Actualizar información del usuario
  void updateUser(User user) {
    _user = user;
    _saveUserData();
    notifyListeners();
  }

  // Verificar conectividad
  Future<bool> checkConnectivity() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.healthUrl),
        headers: ApiConfig.defaultHeaders,
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}