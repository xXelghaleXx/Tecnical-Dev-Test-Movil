// helpers.dart - Funciones de utilidad para la aplicación

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  // Formateo de números y moneda
  static String formatCurrency(dynamic value) {
    try {
      double amount = 0.0;
      if (value is String) {
        amount = double.tryParse(value) ?? 0.0;
      } else if (value is num) {
        amount = value.toDouble();
      }
      return NumberFormat.currency(locale: 'es_PE', symbol: 'S/').format(amount);
    } catch (e) {
      return 'S/0.00';
    }
  }

  static String formatNumber(dynamic value) {
    try {
      if (value is String) {
        return double.tryParse(value)?.toStringAsFixed(2) ?? '0.00';
      } else if (value is num) {
        return value.toStringAsFixed(2);
      }
      return '0.00';
    } catch (e) {
      return '0.00';
    }
  }

  static String formatInteger(dynamic value) {
    try {
      if (value is String) {
        return int.tryParse(value)?.toString() ?? '0';
      } else if (value is num) {
        return value.toInt().toString();
      }
      return '0';
    } catch (e) {
      return '0';
    }
  }

  // Validaciones
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    // Al menos 6 caracteres
    return password.length >= 6;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }
    if (!isValidEmail(value)) {
      return 'Ingresa un email válido';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (!isValidPassword(value)) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    if (double.tryParse(value) == null) {
      return '$fieldName debe ser un número válido';
    }
    if (double.parse(value) < 0) {
      return '$fieldName debe ser mayor a 0';
    }
    return null;
  }

  static String? validateInteger(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    if (int.tryParse(value) == null) {
      return '$fieldName debe ser un número entero válido';
    }
    if (int.parse(value) < 0) {
      return '$fieldName debe ser mayor a 0';
    }
    return null;
  }

  // Formateo de fechas
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} año${difference.inDays > 730 ? 's' : ''} atrás';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} mes${difference.inDays > 60 ? 'es' : ''} atrás';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} día${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Hace un momento';
    }
  }

  // Manejo de errores HTTP
  static String getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Solicitud incorrecta. Verifica los datos enviados.';
      case 401:
        return 'No autorizado. Inicia sesión nuevamente.';
      case 403:
        return 'Acceso prohibido. No tienes permisos para esta acción.';
      case 404:
        return 'Recurso no encontrado.';
      case 422:
        return 'Datos de entrada no válidos.';
      case 500:
        return 'Error interno del servidor. Intenta más tarde.';
      case 502:
        return 'Error de conexión con el servidor.';
      case 503:
        return 'Servicio no disponible temporalmente.';
      default:
        return 'Error inesperado. Código: $statusCode';
    }
  }

  static String getNetworkErrorMessage(Exception error) {
    if (error is SocketException) {
      return 'Sin conexión a internet. Verifica tu conexión.';
    } else if (error is FormatException) {
      return 'Error en el formato de datos recibidos.';
    } else {
      return 'Error de conexión. Intenta nuevamente.';
    }
  }

  // Utilidades de cadenas
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String removeAccents(String text) {
    const accents = 'áàäâéèëêíìïîóòöôúùüûñç';
    const withoutAccents = 'aaaaeeeeiiiioooouuuunc';
    
    String result = text.toLowerCase();
    for (int i = 0; i < accents.length; i++) {
      result = result.replaceAll(accents[i], withoutAccents[i]);
    }
    return result;
  }

  // Utilidades de UI
  static void showSnackBar(BuildContext context, String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: confirmColor != null 
                ? TextButton.styleFrom(foregroundColor: confirmColor)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static void showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // Utilidades de navegación
  static void navigateAndClearStack(BuildContext context, String routeName) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
    );
  }

  static void navigateReplacement(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.of(context).pushReplacementNamed(routeName, arguments: arguments);
  }

  static void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.of(context).pushNamed(routeName, arguments: arguments);
  }

  static void goBack(BuildContext context, {dynamic result}) {
    Navigator.of(context).pop(result);
  }

  // Utilidades de almacenamiento local
  static Map<String, dynamic> parseJsonSafely(String jsonString) {
    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  static String encodeJsonSafely(Map<String, dynamic> data) {
    try {
      return json.encode(data);
    } catch (e) {
      return '{}';
    }
  }

  // Utilidades de cálculo
  static double calculateTotal(List<dynamic> items, String priceField) {
    try {
      return items.fold(0.0, (total, item) {
        if (item is Map<String, dynamic> && item.containsKey(priceField)) {
          final price = item[priceField];
          if (price is num) {
            return total + price.toDouble();
          } else if (price is String) {
            return total + (double.tryParse(price) ?? 0.0);
          }
        }
        return total;
      });
    } catch (e) {
      return 0.0;
    }
  }

  static int calculateTotalInt(List<dynamic> items, String field) {
    try {
      return items.fold(0, (total, item) {
        if (item is Map<String, dynamic> && item.containsKey(field)) {
          final value = item[field];
          if (value is num) {
            return total + value.toInt();
          } else if (value is String) {
            return total + (int.tryParse(value) ?? 0);
          }
        }
        return total;
      });
    } catch (e) {
      return 0;
    }
  }

  // Utilidades de imagen
  static String getImageUrl(String? imagePath, {String fallback = 'assets/images/placeholder.png'}) {
    if (imagePath == null || imagePath.isEmpty) {
      return fallback;
    }
    
    // Si ya es una URL completa, devolverla tal como está
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    // Si es una ruta relativa, construir la URL completa
    // Aquí deberías usar tu URL base de la API
    const String baseUrl = 'https://tu-api.com'; // Cambiar por tu URL base
    return '$baseUrl/$imagePath';
  }

  // Utilidades de búsqueda
  static List<T> filterList<T>(
    List<T> items,
    String query,
    List<String Function(T)> searchFields,
  ) {
    if (query.isEmpty) return items;
    
    final normalizedQuery = removeAccents(query.toLowerCase());
    
    return items.where((item) {
      return searchFields.any((field) {
        final fieldValue = removeAccents(field(item).toLowerCase());
        return fieldValue.contains(normalizedQuery);
      });
    }).toList();
  }

  // Utilidades de debug
  static void debugLog(String message, {String tag = 'DEBUG'}) {
    // Solo mostrar logs en modo debug
    assert(() {
      print('[$tag] $message');
      return true;
    }());
  }

  static void debugError(String error, {String tag = 'ERROR', dynamic stackTrace}) {
    assert(() {
      print('[$tag] $error');
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
      return true;
    }());
  }
}