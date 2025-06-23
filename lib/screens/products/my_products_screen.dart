import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.loadProducts();
  }

  void _deleteProduct(int productId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: const Text('¿Estás seguro de que quieres eliminar este producto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && authProvider.token != null) {
      final response = await productProvider.deleteProduct(
        productId,
        authProvider.token!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: response.success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Productos'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadProducts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer2<ProductProvider, AuthProvider>(
        builder: (context, productProvider, authProvider, child) {
          if (productProvider.isLoading) {
            return const LoadingWidget(message: 'Cargando tus productos...');
          }

          final userProducts = productProvider.getUserProducts(authProvider.user?.id ?? 0);

          if (userProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_business_outlined,
                    size: 80,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  Text(
                    'No tienes productos',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingS),
                  Text(
                    'Agrega tu primer producto',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingL),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/add-product');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Producto'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            itemCount: userProducts.length,
            itemBuilder: (context, index) {
              final product = userProducts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
                child: ProductCard(
                  product: product,
                  isOwner: true,
                  onDelete: () => _deleteProduct(product.id),
                  onEdit: () {
                    Navigator.of(context).pushNamed('/add-product', arguments: product);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/add-product');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}