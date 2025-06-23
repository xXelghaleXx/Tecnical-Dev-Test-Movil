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
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
      userId: json['user_id'] as int,
      username: json['username'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
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