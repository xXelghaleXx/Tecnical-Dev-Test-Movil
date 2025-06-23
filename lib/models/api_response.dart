class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success({
    required String message,
    T? data,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error({
    required String message,
    String? error,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      error: error,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null 
          ? fromJsonT(json['data']) 
          : json['data'],
      error: json['error'],
      statusCode: json['statusCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'error': error,
      'statusCode': statusCode,
    };
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, data: $data)';
  }
}

// Clase para manejar errores específicos de la API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? error;

  ApiException({
    required this.message,
    this.statusCode,
    this.error,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode)';
  }
}