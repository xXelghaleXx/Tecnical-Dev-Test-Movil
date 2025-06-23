class ApiConfig {
  // ⚠️ IMPORTANTE: Cambia esta IP por la IP de tu computadora en la red local
  // Para encontrar tu IP:
  // Windows: ipconfig en cmd
  // Linux/Mac: ifconfig en terminal
  // Ejemplo: static const String baseUrl = 'http://192.168.1.100:3000/api';
  static const String baseUrl = 'http://192.168.1.100:3000/api';
  
  // URLs de endpoints
  static const String loginUrl = '$baseUrl/auth/login';
  static const String registerUrl = '$baseUrl/auth/register';
  static const String productsUrl = '$baseUrl/products';
  static const String healthUrl = '$baseUrl/health';
  
  // Configuración de timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  
  // Headers comunes
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
  
  // Método para verificar conectividad
  static String get testUrl => healthUrl;
}