class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final int userId;
  final String? username; // Del JOIN con users
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.userId,
    this.username,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: _parseDouble(json['price']),
      stock: _parseInt(json['stock']),
      userId: _parseInt(json['user_id']),
      username: json['username']?.toString(),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  // 🔧 Métodos auxiliares para conversión segura de tipos
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('⚠️ Error parsing datetime: $value');
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'user_id': userId,
      'username': username,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Para crear/actualizar producto (sin id, timestamps)
  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
    };
  }

  // Método para verificar si el usuario es propietario
  bool isOwner(int currentUserId) {
    return userId == currentUserId;
  }

  // Verificar si hay stock disponible
  bool get isInStock => stock > 0;

  // Verificar si el stock está bajo
  bool get isLowStock => stock > 0 && stock <= 5;

  // Verificar si no hay stock
  bool get isOutOfStock => stock <= 0;

  // Obtener estado del stock como string
  String get stockStatus {
    if (isOutOfStock) return 'Sin stock';
    if (isLowStock) return 'Stock bajo';
    return 'Disponible';
  }

  // Calcular valor total del inventario
  double get totalValue => price * stock;

  // Copiar con nuevos valores
  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    int? userId,
    String? username,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}