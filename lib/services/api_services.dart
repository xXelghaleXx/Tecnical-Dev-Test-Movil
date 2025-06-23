import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../models/product.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Cliente HTTP con configuración personalizada
  late http.Client _client;

  ApiServices() {
    _client = http.Client();
  }

  // Método para hacer peticiones GET
  Future<ApiResponse<T>> get<T>(
    String endpoint,
    String? token, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final headers = token != null 
          ? ApiConfig.authHeaders(token)
          : ApiConfig.defaultHeaders;

      final response = await _client
          .get(
            Uri.parse(endpoint),
            headers: headers,
          )
          .timeout(ApiConfig.connectTimeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse<T>.error(
        message: 'Sin conexión a internet. Verifica tu red.',
        statusCode: 0,
      );
    } on HttpException {
      return ApiResponse<T>.error(
        message: 'Error de servidor. Intenta más tarde.',
        statusCode: 500,
      );
    } catch (e) {
      return ApiResponse<T>.error(
        message: 'Error inesperado: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Método para hacer peticiones POST
  Future<ApiResponse<T>> post<T>(
    String endpoint,
    Map<String, dynamic> data,
    String? token, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final headers = token != null 
          ? ApiConfig.authHeaders(token)
          : ApiConfig.defaultHeaders;

      final response = await _client
          .post(
            Uri.parse(endpoint),
            headers: headers,
            body: json.encode(data),
          )
          .timeout(ApiConfig.connectTimeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse<T>.error(
        message: 'Sin conexión a internet. Verifica tu red.',
        statusCode: 0,
      );
    } on HttpException {
      return ApiResponse<T>.error(
        message: 'Error de servidor. Intenta más tarde.',
        statusCode: 500,
      );
    } catch (e) {
      return ApiResponse<T>.error(
        message: 'Error inesperado: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Método para hacer peticiones PUT
  Future<ApiResponse<T>> put<T>(
    String endpoint,
    Map<String, dynamic> data,
    String token, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse(endpoint),
            headers: ApiConfig.authHeaders(token),
            body: json.encode(data),
          )
          .timeout(ApiConfig.connectTimeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse<T>.error(
        message: 'Sin conexión a internet. Verifica tu red.',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse<T>.error(
        message: 'Error inesperado: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Método para hacer peticiones DELETE
  Future<ApiResponse<T>> delete<T>(
    String endpoint,
    String token, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _client
          .delete(
            Uri.parse(endpoint),
            headers: ApiConfig.authHeaders(token),
          )
          .timeout(ApiConfig.connectTimeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse<T>.error(
        message: 'Sin conexión a internet. Verifica tu red.',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse<T>.error(
        message: 'Error inesperado: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Manejar respuestas HTTP
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    final statusCode = response.statusCode;
    
    try {
      final responseData = json.decode(response.body);
      
      if (statusCode >= 200 && statusCode < 300) {
        // Respuesta exitosa
        T? data;
        if (fromJson != null && responseData['data'] != null) {
          data = fromJson(responseData['data']);
        } else if (fromJson != null && responseData is List) {
          data = fromJson(responseData);
        } else if (fromJson != null && responseData['user'] != null) {
          data = fromJson(responseData['user']);
        } else if (fromJson != null && responseData['product'] != null) {
          data = fromJson(responseData['product']);
        }

        return ApiResponse<T>.success(
          message: responseData['message'] ?? 'Operación exitosa',
          data: data,
          statusCode: statusCode,
        );
      } else {
        // Error del servidor
        return ApiResponse<T>.error(
          message: responseData['message'] ?? 'Error del servidor',
          error: responseData['error'],
          statusCode: statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<T>.error(
        message: 'Error al procesar la respuesta del servidor',
        statusCode: statusCode,
      );
    }
  }

  // Métodos específicos para autenticación
  Future<ApiResponse<User>> login(String email, String password) async {
    return await post<User>(
      ApiConfig.loginUrl,
      {'email': email, 'password': password},
      null,
      fromJson: (data) => User.fromJson(data),
    );
  }

  Future<ApiResponse<User>> register(String username, String email, String password) async {
    return await post<User>(
      ApiConfig.registerUrl,
      {'username': username, 'email': email, 'password': password},
      null,
      fromJson: (data) => User.fromJson(data),
    );
  }

  // Métodos específicos para productos
  Future<ApiResponse<List<Product>>> getProducts() async {
    final response = await get<List<Product>>(
      ApiConfig.productsUrl,
      null,
    );

    if (response.success && response.data == null) {
      // Si no hay fromJson definido, procesamos manualmente
      final rawResponse = await _client.get(Uri.parse(ApiConfig.productsUrl));
      if (rawResponse.statusCode == 200) {
        final List<dynamic> data = json.decode(rawResponse.body);
        final products = data.map((json) => Product.fromJson(json)).toList();
        return ApiResponse<List<Product>>.success(
          message: 'Productos cargados exitosamente',
          data: products,
        );
      }
    }

    return response;
  }

  Future<ApiResponse<Product>> createProduct(
    String name,
    String description,
    double price,
    int stock,
    String token,
  ) async {
    return await post<Product>(
      ApiConfig.productsUrl,
      {
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
      },
      token,
      fromJson: (data) => Product.fromJson(data),
    );
  }

  Future<ApiResponse<Product>> updateProduct(
    int productId,
    String name,
    String description,
    double price,
    int stock,
    String token,
  ) async {
    return await put<Product>(
      '${ApiConfig.productsUrl}/$productId',
      {
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
      },
      token,
      fromJson: (data) => Product.fromJson(data),
    );
  }

  Future<ApiResponse<bool>> deleteProduct(int productId, String token) async {
    final response = await delete<bool>(
      '${ApiConfig.productsUrl}/$productId',
      token,
    );

    return ApiResponse<bool>.success(
      message: response.message,
      data: true,
    );
  }

  // Verificar conectividad con el servidor
  Future<bool> checkConnectivity() async {
    try {
      final response = await _client
          .get(Uri.parse(ApiConfig.healthUrl))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Limpiar recursos
  void dispose() {
    _client.close();
  }
}