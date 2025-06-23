import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/api_response.dart';
import '../config/api_config.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Product> getUserProducts(int userId) {
    return _products.where((product) => product.userId == userId).toList();
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Cargar productos
  Future<ApiResponse<List<Product>>> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.productsUrl),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _products = data.map((json) => Product.fromJson(json)).toList();
        _isLoading = false;
        notifyListeners();
        
        return ApiResponse<List<Product>>.success(
          message: 'Productos cargados exitosamente',
          data: _products,
        );
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['message'] ?? 'Error al cargar productos';
        _isLoading = false;
        notifyListeners();
        
        return ApiResponse<List<Product>>.error(
          message: _error!,
        );
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      
      return ApiResponse<List<Product>>.error(
        message: 'Error de conexión: $e',
      );
    }
  }

  // Crear producto
  Future<ApiResponse<Product>> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.productsUrl),
        headers: ApiConfig.authHeaders(token),
        body: json.encode({
          'name': name,
          'description': description,
          'price': price,
          'stock': stock,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        final newProduct = Product.fromJson(data['product']);
        _products.insert(0, newProduct); // Agregar al inicio de la lista
        notifyListeners();
        
        return ApiResponse<Product>.success(
          message: data['message'],
          data: newProduct,
        );
      } else {
        return ApiResponse<Product>.error(
          message: data['message'] ?? 'Error al crear producto',
        );
      }
    } catch (e) {
      return ApiResponse<Product>.error(
        message: 'Error de conexión: $e',
      );
    }
  }

  // Actualizar producto
  Future<ApiResponse<Product>> updateProduct({
    required int productId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.productsUrl}/$productId'),
        headers: ApiConfig.authHeaders(token),
        body: json.encode({
          'name': name,
          'description': description,
          'price': price,
          'stock': stock,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final updatedProduct = Product.fromJson(data['product']);
        
        // Actualizar el producto en la lista
        final index = _products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          _products[index] = updatedProduct;
          notifyListeners();
        }
        
        return ApiResponse<Product>.success(
          message: data['message'],
          data: updatedProduct,
        );
      } else {
        return ApiResponse<Product>.error(
          message: data['message'] ?? 'Error al actualizar producto',
        );
      }
    } catch (e) {
      return ApiResponse<Product>.error(
        message: 'Error de conexión: $e',
      );
    }
  }

  // Eliminar producto
  Future<ApiResponse<bool>> deleteProduct(int productId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.productsUrl}/$productId'),
        headers: ApiConfig.authHeaders(token),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Remover el producto de la lista
        _products.removeWhere((product) => product.id == productId);
        notifyListeners();
        
        return ApiResponse<bool>.success(
          message: data['message'],
          data: true,
        );
      } else {
        return ApiResponse<bool>.error(
          message: data['message'] ?? 'Error al eliminar producto',
        );
      }
    } catch (e) {
      return ApiResponse<bool>.error(
        message: 'Error de conexión: $e',
      );
    }
  }

  // Obtener producto por ID
  Product? getProductById(int productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Filtrar productos por nombre
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    
    return _products.where((product) =>
      product.name.toLowerCase().contains(query.toLowerCase()) ||
      product.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Obtener estadísticas de productos del usuario
  Map<String, dynamic> getUserStats(int userId) {
    final userProducts = getUserProducts(userId);
    final totalProducts = userProducts.length;
    final totalValue = userProducts.fold<double>(
      0.0, 
      (sum, product) => sum + product.totalValue
    );
    final totalStock = userProducts.fold<int>(
      0, 
      (sum, product) => sum + product.stock
    );

    return {
      'totalProducts': totalProducts,
      'totalValue': totalValue,
      'totalStock': totalStock,
      'averagePrice': totalProducts > 0 
          ? userProducts.fold<double>(0.0, (sum, product) => sum + product.price) / totalProducts
          : 0.0,
    };
  }

  // Limpiar productos (para logout)
  void clearProducts() {
    _products.clear();
    _error = null;
    notifyListeners();
  }
}