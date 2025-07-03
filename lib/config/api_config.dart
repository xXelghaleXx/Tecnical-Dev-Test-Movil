class ApiConfig {
  static const String baseUrl = 'http://10.200.172.168/api';
  
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