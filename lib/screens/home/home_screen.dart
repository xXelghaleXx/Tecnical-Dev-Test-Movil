import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadInitialData() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.loadProducts();
  }

  void _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    // Mostrar diálogo de confirmación
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      productProvider.clearProducts();
      await authProvider.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  void _refreshProducts() async {
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildSearchBar(),
              _buildTabBar(),
              _buildTabBarView(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/add-product');
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }

  Widget _buildAppBar() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  authProvider.user?.username.substring(0, 1).toUpperCase() ?? 'U',
                  style: AppTextStyles.heading3.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, ${authProvider.user?.username ?? 'Usuario'}',
                      style: AppTextStyles.heading3.copyWith(color: Colors.white),
                    ),
                    Text(
                      'Gestiona tus productos',
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _refreshProducts,
                icon: const Icon(Icons.refresh, color: Colors.white),
              ),
              IconButton(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Buscar productos...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.7)),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: AppSizes.paddingM,
            ),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.white,
        labelStyle: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Todos los Productos'),
          Tab(text: 'Mis Productos'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSizes.radiusL),
            topRight: Radius.circular(AppSizes.radiusL),
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAllProductsTab(),
            _buildMyProductsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllProductsTab() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return const LoadingWidget(message: 'Cargando productos...');
        }

        if (productProvider.error != null) {
          return _buildErrorWidget(productProvider.error!);
        }

        final filteredProducts = _searchQuery.isEmpty
            ? productProvider.products
            : productProvider.searchProducts(_searchQuery);

        if (filteredProducts.isEmpty) {
          return _buildEmptyWidget(
            icon: Icons.inventory_2_outlined,
            title: _searchQuery.isEmpty ? 'No hay productos' : 'No se encontraron productos',
            subtitle: _searchQuery.isEmpty 
                ? 'Sé el primero en agregar un producto'
                : 'Intenta con otros términos de búsqueda',
          );
        }

        return _buildProductGrid(filteredProducts, false);
      },
    );
  }

  Widget _buildMyProductsTab() {
    return Consumer2<ProductProvider, AuthProvider>(
      builder: (context, productProvider, authProvider, child) {
        if (productProvider.isLoading) {
          return const LoadingWidget(message: 'Cargando tus productos...');
        }

        if (productProvider.error != null) {
          return _buildErrorWidget(productProvider.error!);
        }

        final userProducts = productProvider.getUserProducts(authProvider.user?.id ?? 0);
        final filteredProducts = _searchQuery.isEmpty
            ? userProducts
            : userProducts.where((product) =>
                product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                product.description.toLowerCase().contains(_searchQuery.toLowerCase())
              ).toList();

        if (filteredProducts.isEmpty) {
          return _buildEmptyWidget(
            icon: Icons.add_business_outlined,
            title: _searchQuery.isEmpty ? 'No tienes productos' : 'No se encontraron productos',
            subtitle: _searchQuery.isEmpty
                ? 'Agrega tu primer producto'
                : 'Intenta con otros términos de búsqueda',
            showAddButton: _searchQuery.isEmpty,
          );
        }

        return Column(
          children: [
            _buildUserStats(userProducts),
            Expanded(child: _buildProductGrid(filteredProducts, true)),
          ],
        );
      },
    );
  }

  Widget _buildUserStats(List products) {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Consumer2<ProductProvider, AuthProvider>(
        builder: (context, productProvider, authProvider, child) {
          final stats = productProvider.getUserStats(authProvider.user?.id ?? 0);
          
          return Row(
            children: [
              _buildStatItem(
                icon: Icons.inventory_2,
                label: 'Productos',
                value: stats['totalProducts'].toString(),
                color: AppColors.primary,
              ),
              _buildStatItem(
                icon: Icons.attach_money,
                label: 'Valor Total',
                value: '\$${(stats['totalValue'] ?? 0.0).toStringAsFixed(2)}',
                color: AppColors.success,
              ),
              _buildStatItem(
                icon: Icons.warehouse,
                label: 'Stock Total',
                value: stats['totalStock'].toString(),
                color: AppColors.info,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: AppSizes.iconL,
          ),
          const SizedBox(height: AppSizes.paddingXS),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List products, bool isOwner) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 2.5,
          crossAxisSpacing: AppSizes.paddingM,
          mainAxisSpacing: AppSizes.paddingM,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            isOwner: isOwner,
            onDelete: isOwner ? () => _deleteProduct(product.id) : null,
            onEdit: isOwner ? () {
              Navigator.of(context).pushNamed('/add-product', arguments: product);
            } : null,
          );
        },
      ),
    );
  }

  Widget _buildEmptyWidget({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showAddButton = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              title,
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (showAddButton) ...[
              const SizedBox(height: AppSizes.paddingL),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/add-product');
                },
                icon: const Icon(Icons.add),
                label: const Text('Agregar Producto'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              'Error',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingL),
            ElevatedButton.icon(
              onPressed: _refreshProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}