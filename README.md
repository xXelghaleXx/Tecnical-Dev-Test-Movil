# 📱 Productos App - Flutter

Una aplicación móvil moderna para gestionar productos, conectada a un backend Node.js con PostgreSQL.

## 🚀 Características

- **Autenticación completa**: Login y registro con JWT
- **Gestión de productos**: Crear, leer, actualizar y eliminar productos
- **Interfaz moderna**: Diseño Material Design 3 con tema rojo
- **Búsqueda en tiempo real**: Filtrar productos por nombre o descripción
- **Estadísticas**: Ver resumen de tus productos y valor total
- **Responsive**: Adaptado para diferentes tamaños de pantalla
- **Validaciones**: Validaciones robustas en formularios
- **Manejo de errores**: Mensajes claros y manejo de conectividad

## 🛠️ Tecnologías

- **Flutter 3.0+**
- **Provider** (State Management)
- **HTTP** (API calls)
- **SharedPreferences** (Local Storage)
- **Material Design 3**

## 📦 Instalación

1. **Clonar el repositorio**
   ```bash
   git clone <tu-repositorio>
   cd products_app
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Configurar la IP del servidor**
   - Abre `lib/config/api_config.dart`
   - Cambia `192.168.1.100` por la IP de tu computadora:
   ```bash
   # Windows
   ipconfig
   
   # Linux/Mac
   ifconfig
   ```

4. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

## 🏗️ Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada
├── config/
│   └── api_config.dart       # Configuración de la API
├── models/
│   ├── user.dart            # Modelo de usuario
│   ├── product.dart         # Modelo de producto
│   └── api_response.dart    # Modelo de respuesta API
├── providers/
│   ├── auth_provider.dart   # Provider de autenticación
│   └── product_provider.dart # Provider de productos
├── services/
│   ├── api_service.dart     # Servicio API
│   └── storage_service.dart # Servicio de almacenamiento
├── screens/
│   ├── splash_screen.dart   # Pantalla de inicio
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   └── products/
│       ├── add_product_screen.dart
│       └── my_products_screen.dart
├── widgets/
│   ├── custom_button.dart   # Botón personalizado
│   ├── custom_text_field.dart # Campo de texto personalizado
│   ├── product_card.dart    # Tarjeta de producto
│   └── loading_widget.dart  # Widget de carga
└── utils/
    ├── constants.dart       # Constantes y colores
    └── helpers.dart         # Funciones helper
```

## 🎨 Tema y Colores

La aplicación usa un esquema de colores rojos:

- **Primario**: `#dc2626` (Rojo brillante)
- **Secundario**: `#991b1b` (Rojo oscuro)
- **Éxito**: `#10b981` (Verde)
- **Advertencia**: `#f59e0b` (Naranja)
- **Error**: `#ef4444` (Rojo error)

## 📱 Funcionalidades

### Autenticación
- **Registro**: Crear cuenta con username, email y password
- **Login**: Iniciar sesión con email y password
- **Logout**: Cerrar sesión con confirmación
- **Persistencia**: Mantener sesión iniciada

### Productos
- **Ver todos**: Lista de productos de todos los usuarios
- **Mis productos**: Lista de productos propios con estadísticas
- **Crear**: Agregar nuevo producto con validaciones
- **Editar**: Modificar productos existentes
- **Eliminar**: Borrar productos con confirmación
- **Búsqueda**: Filtrar productos en tiempo real

### Interfaz
- **Navegación**: Tabs para "Todos" y "Mis productos"
- **Búsqueda**: Barra de búsqueda integrada
- **FAB**: Botón flotante para agregar productos
- **Estadísticas**: Resumen visual de productos y valores
- **Validaciones**: Feedback visual en formularios

## ⚙️ Configuración

### Variables de entorno
Configura la IP de tu servidor en `lib/config/api_config.dart`:

```dart
static const String baseUrl = 'http://TU_IP_LOCAL:3000/api';
```

### Permisos
Asegúrate de que el archivo `android/app/src/main/AndroidManifest.xml` tenga los permisos de internet.

## 🔧 Desarrollo

### Comandos útiles

```bash
# Ejecutar en modo debug
flutter run

# Ejecutar en dispositivo específico
flutter run -d <device_id>

# Ver dispositivos disponibles
flutter devices

# Compilar para release
flutter build apk

# Análisis de código
flutter analyze

# Ejecutar tests
flutter test
```

### Debugging

1. **Error de conexión**: Verifica que tu backend esté corriendo y la IP sea correcta
2. **Error de CORS**: Asegúrate de que el backend permita conexiones desde tu IP
3. **Error de certificados**: Usa HTTP (no HTTPS) para desarrollo local

## 📋 Requisitos

- **Flutter**: 3.0.0 o superior
- **Dart**: 3.0.0 o superior
- **Android**: API 21+ (Android 5.0)
- **iOS**: iOS 11.0+

## 🤝 Contribuir

1. Fork el proyecto
2. Crear rama para feature (`git checkout -b feature/AmazingFeature`)
3. Commit los cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 🆘 Solución de Problemas

### Error: "SocketException: Failed host lookup"
- Verifica que tu dispositivo esté en la misma red WiFi
- Confirma que la IP en `api_config.dart` sea correcta
- Asegúrate de que el backend esté ejecutándose

### Error: "FormatException: Unexpected character"
- Verifica que el backend esté devolviendo JSON válido
- Revisa los headers de las respuestas de la API

### Error: "RenderFlex overflowed"
- Este error de UI se soluciona usando `Expanded` o `Flexible` widgets
- Ya está manejado en la aplicación

## 📞 Contacto

Si tienes problemas o sugerencias, crea un issue en el repositorio.