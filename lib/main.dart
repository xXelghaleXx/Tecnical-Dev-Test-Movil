import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/product_detail_screen.dart';
import 'screens/products/add_product_screen.dart';
import 'screens/products/my_products_screen.dart';
import 'utils/constants.dart';
import 'models/product.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/my-products': (context) => const MyProductsScreen(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/add-product':
              final product = settings.arguments as Product?;
              return MaterialPageRoute(
                builder: (_) => const AddProductScreen(),
                settings: RouteSettings(arguments: product),
              );
            case '/product-detail':
              final product = settings.arguments as Product;
              return MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: product),
              );
            default:
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(
                    child: Text('Página no encontrada'),
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}