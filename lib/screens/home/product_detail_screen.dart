import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_button.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

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
              _buildAppBar(context),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppSizes.radiusL),
                      topRight: Radius.circular(AppSizes.radiusL),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSizes.paddingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: AppSizes.paddingL),
                        _buildDescription(),
                        const SizedBox(height: AppSizes.paddingL),
                        _buildPriceAndStock(),
                        const SizedBox(height: AppSizes.paddingL),
                        _buildMetadata(),
                        const SizedBox(height: AppSizes.paddingL),
                        _buildActions(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: AppSizes.paddingS),
          Expanded(
            child: Text(
              'Detalle del Producto',
              style: AppTextStyles.heading2.copyWith(color: Colors.white),
            ),
          ),
          Consumer2<AuthProvider, ProductProvider>(
            builder: (context, authProvider, productProvider, child) {
              final userId = authProvider.user?.id ?? 0;
              final isOwner = product.userId == userId;
              
              if (!isOwner) return const SizedBox.shrink();

              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.of(context).pushNamed('/add-product', arguments: product);
                  } else if (value == 'delete') {
                    _showDeleteDialog(context, productProvider, authProvider);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: AppColors.primary),
                        SizedBox(width: AppSizes.paddingS),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: AppColors.error),
                        SizedBox(width: AppSizes.paddingS),
                        Text('Eliminar'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Icon(
                  Icons.inventory_2,
                  color: AppColors.primary,
                  size: AppSizes.iconL,
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTextStyles.heading2,
                    ),
                    const SizedBox(height: AppSizes.paddingXS),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingS,
                        vertical: AppSizes.paddingXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      ),
                      child: Text(
                        Helpers.formatCurrency(product.price),
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingL),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description,
                color: AppColors.info,
                size: AppSizes.iconM,
              ),
              const SizedBox(width: AppSizes.paddingS),
              Text(
                'Descripción',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          Text(
            product.description,
            style: AppTextStyles.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAndStock() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.attach_money,
            title: 'Precio',
            value: Helpers.formatCurrency(product.price),
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSizes.paddingM),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.warehouse,
            title: 'Stock',
            value: '${product.stock} unidades',
            color: _getStockColor(product.stock),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
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
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: AppSizes.iconL,
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.paddingXS),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata() {
    final createdDate = product.createdAt ?? DateTime.now();
    final updatedDate = product.updatedAt ?? DateTime.now();
    final totalValue = product.price * product.stock;
    
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información adicional',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSizes.paddingM),
          _buildMetadataRow(
            icon: Icons.person,
            label: 'Creado por',
            value: 'Usuario',
          ),
          _buildMetadataRow(
            icon: Icons.calendar_today,
            label: 'Fecha de creación',
            value: Helpers.formatDate(createdDate),
          ),
          _buildMetadataRow(
            icon: Icons.update,
            label: 'Última actualización',
            value: Helpers.formatDate(updatedDate),
          ),
          _buildMetadataRow(
            icon: Icons.calculate,
            label: 'Valor total',
            value: Helpers.formatCurrency(totalValue),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppSizes.iconS,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: AppSizes.paddingS),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Consumer2<AuthProvider, ProductProvider>(
      builder: (context, authProvider, productProvider, child) {
        final userId = authProvider.user?.id ?? 0;
        final isOwner = product.userId == userId;

        if (!isOwner) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            CustomButton(
              text: 'Editar Producto',
              onPressed: () {
                Navigator.of(context).pushNamed('/add-product', arguments: product);
              },
              icon: Icons.edit,
            ),
            const SizedBox(height: AppSizes.paddingM),
            CustomButton(
              text: 'Eliminar Producto',
              onPressed: () {
                _showDeleteDialog(context, productProvider, authProvider);
              },
              backgroundColor: AppColors.error,
              icon: Icons.delete,
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ProductProvider productProvider,
    AuthProvider authProvider,
  ) async {
    final shouldDelete = await Helpers.showConfirmDialog(
      context,
      title: 'Eliminar Producto',
      content: '¿Estás seguro de que quieres eliminar "${product.name}"? Esta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      confirmColor: AppColors.error,
    );

    if (shouldDelete && authProvider.token != null) {
      try {
        final success = await productProvider.deleteProduct(
          product.id,
          authProvider.token!,
        );

        if (context.mounted) {
          if (success == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Producto eliminado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al eliminar el producto'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar el producto'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Método para obtener color del stock
  Color _getStockColor(int stock) {
    if (stock <= 0) {
      return Colors.red;
    } else if (stock <= 5) {
      return Colors.orange;
    } else if (stock <= 10) {
      return Colors.yellow.shade700;
    } else {
      return Colors.green;
    }
  }
}