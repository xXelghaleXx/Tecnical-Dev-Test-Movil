// services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Tu IP local configurada
  static const String baseUrl = 'http://192.168.18.94:3000/api';
  
  // Método para probar múltiples URLs de conexión
  static Future<String?> findWorkingUrl() async {
    final urls = [
      'http://192.168.18.94:3000/api',
      'http://localhost:3000/api',
      'http://127.0.0.1:3000/api',
      'http://10.0.2.2:3000/api', // Para emulador Android
    ];
    
    for (String url in urls) {
      try {
        print('🔍 Probando: $url/health');
        final response = await http.get(
          Uri.parse('$url/health'),
          headers: headers,
        ).timeout(const Duration(seconds: 5));
        
        if (response.statusCode == 200) {
          print('✅ Conexión exitosa en: $url');
          return url;
        }
      } catch (e) {
        print('❌ Falló: $url - Error: $e');
        continue;
      }
    }
    return null;
  }
  
  // Método para verificar conectividad
  static Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('✅ Internet conectado');
        return true;
      }
    } catch (e) {
      print('❌ Sin internet: $e');
    }
    return false;
  }
  
  // Método de diagnóstico completo
  static Future<Map<String, dynamic>> diagnosticConnection() async {
    print('🔍 === DIAGNÓSTICO DE CONEXIÓN ===');
    
    // 1. Verificar internet
    final hasInternet = await checkInternetConnection();
    
    // 2. Buscar URL que funcione
    final workingUrl = await findWorkingUrl();
    
    // 3. Probar conexión específica
    bool canConnect = false;
    String errorMessage = '';
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      canConnect = response.statusCode == 200;
      if (!canConnect) {
        errorMessage = 'Servidor respondió con código: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = e.toString();
    }
    
    final result = {
      'hasInternet': hasInternet,
      'baseUrl': baseUrl,
      'workingUrl': workingUrl,
      'canConnect': canConnect,
      'error': errorMessage,
    };
    
    print('📊 Resultado del diagnóstico: $result');
    return result;
  }
  
  // Headers comunes
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers con token de autenticación
  static Map<String, String> headersWithAuth(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };

  // ==================== AUTH ENDPOINTS ====================
  
  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('🔐 Intentando login para: $email');
      print('📡 URL: $baseUrl/auth/login');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: headers,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      print('📡 Respuesta login: ${response.statusCode}');
      print('📄 Cuerpo: ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ Error en login: $e');
      
      // Si falla, intentar diagnóstico
      if (e.toString().contains('Failed host lookup') || 
          e.toString().contains('No address associated with hostname') ||
          e.toString().contains('Connection refused')) {
        print('🔍 Ejecutando diagnóstico automático...');
        await diagnosticConnection();
      }
      
      throw Exception('Error de conexión en login: $e');
    }
  }

  // Registro
  static Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      print('📝 Intentando registro para: $email');
      print('📡 URL: $baseUrl/auth/register');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: headers,
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      print('📡 Respuesta registro: ${response.statusCode}');
      print('📄 Cuerpo: ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ Error en registro: $e');
      
      // Diagnóstico automático en caso de fallo
      if (e.toString().contains('Failed host lookup') || 
          e.toString().contains('Connection refused')) {
        print('🔍 Ejecutando diagnóstico automático...');
        await diagnosticConnection();
      }
      
      throw Exception('Error de conexión en registro: $e');
    }
  }

  // ==================== PRODUCTS ENDPOINTS ====================
  
  // Obtener todos los productos
  static Future<List<dynamic>> getProducts([String? token]) async {
    try {
      print('📦 Obteniendo productos...');
      print('📡 URL: $baseUrl/products');
      
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: token != null ? headersWithAuth(token) : headers,
      ).timeout(const Duration(seconds: 30));

      print('📡 Respuesta productos: ${response.statusCode}');
      
      final data = _handleResponse(response);
      List<dynamic> products = data is List ? data : [];
      
      print('✅ Productos obtenidos: ${products.length}');
      return products;
    } catch (e) {
      print('❌ Error obteniendo productos: $e');
      throw Exception('Error al obtener productos: $e');
    }
  }

  // Crear producto
  static Future<Map<String, dynamic>> createProduct(Map<String, dynamic> productData, String token) async {
    try {
      print('➕ Creando producto: ${productData['name']}');
      print('📡 URL: $baseUrl/products');
      
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: headersWithAuth(token),
        body: json.encode(productData),
      ).timeout(const Duration(seconds: 30));

      print('📡 Respuesta crear producto: ${response.statusCode}');
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ Error creando producto: $e');
      throw Exception('Error al crear producto: $e');
    }
  }

  // Actualizar producto
  static Future<Map<String, dynamic>> updateProduct(int id, Map<String, dynamic> productData, String token) async {
    try {
      print('✏️ Actualizando producto ID: $id');
      print('📡 URL: $baseUrl/products/$id');
      
      final response = await http.put(
        Uri.parse('$baseUrl/products/$id'),
        headers: headersWithAuth(token),
        body: json.encode(productData),
      ).timeout(const Duration(seconds: 30));

      print('📡 Respuesta actualizar producto: ${response.statusCode}');
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ Error actualizando producto: $e');
      throw Exception('Error al actualizar producto: $e');
    }
  }

  // Eliminar producto
  static Future<bool> deleteProduct(int id, String token) async {
    try {
      print('🗑️ Eliminando producto ID: $id');
      print('📡 URL: $baseUrl/products/$id');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$id'),
        headers: headersWithAuth(token),
      ).timeout(const Duration(seconds: 30));

      print('📡 Respuesta eliminar producto: ${response.statusCode}');
      
      _handleResponse(response);
      print('✅ Producto eliminado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error eliminando producto: $e');
      throw Exception('Error al eliminar producto: $e');
    }
  }

  // ==================== HELPER METHODS ====================
  
  // Manejar respuestas HTTP
  static dynamic _handleResponse(http.Response response) {
    final body = response.body;
    print('📄 Respuesta completa del servidor:');
    print('   Status: ${response.statusCode}');
    print('   Headers: ${response.headers}');
    print('   Body: $body');
    
    // Intentar decodificar JSON
    dynamic data;
    try {
      data = json.decode(body);
    } catch (e) {
      print('❌ Error decodificando JSON: $e');
      throw Exception('Respuesta inválida del servidor: $body');
    }

    // Manejar códigos de estado
    switch (response.statusCode) {
      case 200:
      case 201:
        return data;
      case 400:
        throw Exception(data['message'] ?? 'Solicitud incorrecta');
      case 401:
        throw Exception(data['message'] ?? 'No autorizado');
      case 403:
        throw Exception(data['message'] ?? 'Acceso prohibido');
      case 404:
        throw Exception(data['message'] ?? 'Recurso no encontrado');
      case 422:
        throw Exception(data['message'] ?? 'Datos de entrada no válidos');
      case 500:
        throw Exception(data['message'] ?? 'Error interno del servidor');
      default:
        throw Exception('Error ${response.statusCode}: ${data['message'] ?? 'Error desconocido'}');
    }
  }
} 