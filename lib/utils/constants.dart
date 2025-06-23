import 'package:flutter/material.dart';

class AppColors {
  // Colores rojos principales
  static const Color primary = Color(0xFFdc2626);
  static const Color primaryDark = Color(0xFF991b1b);
  static const Color primaryLight = Color(0xFFfca5a5);
  
  // Colores de estado
  static const Color success = Color(0xFF10b981);
  static const Color warning = Color(0xFFf59e0b);
  static const Color error = Color(0xFFef4444);
  static const Color info = Color(0xFF3b82f6);
  
  // Colores neutrales
  static const Color background = Color(0xFFf8fafc);
  static const Color surface = Colors.white;
  static const Color onSurface = Color(0xFF1f2937);
  static const Color onSurfaceVariant = Color(0xFF6b7280);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
}

class AppSizes {
  // Padding y márgenes
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  
  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  
  // Tamaños de iconos
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
}

class AppStrings {
  // App
  static const String appName = 'Productos App';
  static const String appDescription = 'Gestiona tus productos fácilmente';
  
  // Auth
  static const String login = 'Iniciar Sesión';
  static const String register = 'Crear Cuenta';
  static const String logout = 'Cerrar Sesión';
  static const String email = 'Correo Electrónico';
  static const String password = 'Contraseña';
  static const String username = 'Nombre de Usuario';
  static const String confirmPassword = 'Confirmar Contraseña';
  
  // Products
  static const String products = 'Productos';
  static const String myProducts = 'Mis Productos';
  static const String addProduct = 'Agregar Producto';
  static const String productName = 'Nombre del Producto';
  static const String description = 'Descripción';
  static const String price = 'Precio';
  static const String stock = 'Stock';
  static const String totalValue = 'Valor Total';
  
  // Actions
  static const String save = 'Guardar';
  static const String cancel = 'Cancelar';
  static const String delete = 'Eliminar';
  static const String edit = 'Editar';
  static const String refresh = 'Actualizar';
  
  // Messages
  static const String loading = 'Cargando...';
  static const String noData = 'No hay datos disponibles';
  static const String error = 'Error';
  static const String success = 'Éxito';
  static const String tryAgain = 'Intentar de nuevo';
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.onSurface,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.onSurface,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.onSurfaceVariant,
  );
  
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}